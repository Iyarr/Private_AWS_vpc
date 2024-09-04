#!/bin/bash

yum install -y unzip amazon-cloudwatch-agent
script /var/log/test.log
cd /opt/aws/amazon-cloudwatch-agent
echo "$agent_json" > ./etc/amazon-cloudwatch-agent.json
./bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:./etc/amazon-cloudwatch-agent.json -s
su - ec2-user
cd ~
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.20.03.zip -o server.zip
unzip server.zip
rm server.zip
sed -i "/server-name=*/s/.*/server-name=$world_name/" server.properties
sed -i '/difficulty=*/s/.*/difficulty=hard/' server.properties
LD_LIBRARY_PATH=. ./bedrock_server &