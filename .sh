#!/bin/bash

yum install -y unzip amazon-cloudwatch-agent
su - ec2-user
cd ~
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.20.03.zip -o server.zip
unzip server.zip
rm server.zip
sed -i "/server-name=*/s/.*/server-name=${world_name}/" server.properties
sed -i '/difficulty=*/s/.*/difficulty=hard/' server.properties
LD_LIBRARY_PATH=. ./bedrock_server &