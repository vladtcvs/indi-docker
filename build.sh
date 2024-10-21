#!/bin/sh

docker build  -t indi:2.1.0 .
docker container create --name indi indi:2.1.0
docker container cp indi:/opt/indi/rules.tar rules.tar
docker container rm indi
docker save indi:2.1.0 -o indi-2.1.0.tar
bzip2 -f indi-2.1.0.tar
bzip2 -f rules.tar

