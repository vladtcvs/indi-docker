#!/bin/sh

docker run --privileged --rm -p 8624:8624 -p 7624:7624 --name indi indi:2.1.0 
