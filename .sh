#!/bin/bash

dnf install -y unzip amazon-cloudwatch-agent
script $log_file_path
cd /opt/aws/amazon-cloudwatch-agent
cat <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "$log_file_path",
            "log_group_name": "$log_group_name",
            "log_stream_name": "$log_stream_name"
          }
        ]
      }
    }
  }
}
EOF > ./etc/amazon-cloudwatch-agent.json
./bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:./etc/amazon-cloudwatch-agent.json -s
su - ec2-user
cd ~
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.20.03.zip -o server.zip
unzip server.zip
rm server.zip
sed -i "/server-name=*/s/.*/server-name=$world_name/" server.properties
sed -i '/difficulty=*/s/.*/difficulty=hard/' server.properties
LD_LIBRARY_PATH=. ./bedrock_server &