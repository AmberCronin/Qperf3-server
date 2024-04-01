#!/bin/bash

sh unconfigure.sh

# uncomment/modify to copy qperf in from somewhere else
# this is then recopied into the server docker image, so it being here is mainly a utility for client scripts
# sudo cp -r -u ../qperf .
[ ! -d build-qperf ] && mkdir -p build-qperf
cd build-qperf; cmake ../qperf/ ; make ; cd ..

# per-connection secrets output here for decrypting pcaps
[ ! -d secrets ] && mkdir -p secrets

cd router
sh build.sh
sh run.sh

cd ..
cd server
sh build.sh
sh run.sh

cd ..
sh postconfigsetup.sh
