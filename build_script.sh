#!/bin/bash -xv
#
#Purpose: build images consists nginx 

docker build -t 'local/nginx:local' --no-cache --force-rm .
#docker tag local/nginx:local docker-repo.pitchbook.com/riznykyurii-nginx:$(date +%Y%m%d)
#docker push docker-repo.pitchbook.com/riznykyurii-nginx:$(date +%Y%m%d)
