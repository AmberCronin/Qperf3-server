#!/bin/bash

if [ ! -f server.key ] || [ ! -f server.crt ]; then
	openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt -sha256 -days 365 -nodes -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"
fi

sudo cp -r -u ../qperf .
sudo docker build -t qperf-server .