#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t mominer-deploy - <$SCRIPT_DIR/deploy.dockerfile &&\
docker build -q -t mominer-build --pull=false - <$SCRIPT_DIR/build.dockerfile &&\
if [ $# -ne 0 ]; then
  docker run --privileged --rm --name mominer --hostname mominer --device=/dev/dri\
             --mount type=bind,source=$SCRIPT_DIR,target=/root/mominer\
             -it mominer-build "$@"
else
  docker run --privileged --rm --name mominer --hostname mominer --device=/dev/dri\
             --mount type=bind,source=$SCRIPT_DIR,target=/root/mominer\
             -it mominer-build
fi
