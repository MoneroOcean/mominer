#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t moner-deploy - <$SCRIPT_DIR/deploy.dockerfile &&\
docker build -q -t moner-build --pull=false - <$SCRIPT_DIR/build.dockerfile &&\
docker run --privileged --rm --name moner --hostname moner --device=/dev/dri\
           --mount type=bind,source=$SCRIPT_DIR,target=/root/moner\
           -it moner-build /bin/bash
