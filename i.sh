#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t mominer-build --pull=false - <$SCRIPT_DIR/build.dockerfile &&\
docker run --privileged --rm --name mominer --hostname mominer\
           --mount type=bind,source=$SCRIPT_DIR,target=/root/mominer\
           -it --entrypoint "" mominer-build bash
