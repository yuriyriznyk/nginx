#!/bin/bash -xv
#
#Purpose: build images consists nginx-lua

docker build -t 'local/nginx:local' --no-cache --force-rm .
docker tag local/nginx:local yuriiriznyk/nginx:latest
docker push yuriiriznyk/nginx:latest
