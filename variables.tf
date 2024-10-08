variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "AWS_REGION" {
  type      = string
  sensitive = true
}

variable "world_name" {
  type      = string
  sensitive = true
}

variable "prefix" {
  type = string
}

variable "log_file_path" {
  type      = string
}