provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.AWS_REGION
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.igw_route_table.id
}

resource "aws_security_group" "default" {
  name   = "MinecraftServer_SG"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 19132
    to_port     = 19132
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "init" {
  template = "${file(".sh")}"
  vars = {
    world_name = var.world_name
    agent_json = jsonencode({
      logs = {
        logs_collected = {
          files = {
            collect_list = [
              {
                file_path       = "${var.log_file_path}",
                log_group_name  = "${aws_cloudwatch_log_group.minecraft.name}",
                log_stream_name = "${aws_cloudwatch_log_stream.default.name}",
              }
            ]
          }
        }
      }
    })
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.default.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.default.id]

  iam_instance_profile = aws_iam_instance_profile.default.name

  user_data                   = data.template_file.init.rendered
  user_data_replace_on_change = true
}

resource "aws_iam_instance_profile" "default" {
  name = "${var.prefix}_profile"
  role = aws_iam_role.default.name
}

data "aws_iam_policy_document" "assumerole_ec2" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  name               = "ec2_instance_role"
  path               = "/${var.prefix}/"
  assume_role_policy = data.aws_iam_policy_document.assumerole_ec2.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_cloudwatch_log_group" "minecraft" {
  name = "/${var.prefix}/minecraft"

  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "default" {
  name           = var.world_name
  log_group_name = aws_cloudwatch_log_group.minecraft.name
}