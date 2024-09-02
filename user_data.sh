#!/bin/bash

yum install -y unzip
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.20.03.zip -o server.zip
unzip server.zip  -d /home/
rm server.zip
sed -i '/difficulty=*/s/.*/difficulty=hard/' /home/server.properties
cd /home
LD_LIBRARY_PATH=. ./bedrock_server