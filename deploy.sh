#!/usr/bin/env bash

tag=$1

./r.sh node test.js &&\
(test -d deploy && rm -rf deploy || true) &&\
mkdir deploy &&\
docker create --name mominer mominer-build &&\
FILE=$(docker export mominer | tar -t | grep 'opt/intel/oneapi/.*/lib/libumf.so.0' | head -n1) &&\
docker cp -L mominer:$FILE deploy &&\
docker rm -f mominer &&\
cp mominer.js pool.js opts.js helper.js deploy &&\
cp -r node_modules deploy &&\
cp build/Release/mominer.node deploy &&\
cp deploy.dockerfile deploy &&\
cp README.md deploy &&\
cat <<'EOF' >deploy/docker-mominer.sh &&\
#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t mominer-deploy -f $SCRIPT_DIR/deploy.dockerfile $SCRIPT_DIR &&\
docker run --privileged --rm --name mominer-deploy --hostname mominer-deploy\
           --mount type=bind,source=$SCRIPT_DIR,target=/root/mominer --workdir /root/mominer\
           -it mominer-deploy node mominer.js "$@"
EOF
chmod +x deploy/docker-mominer.sh &&\
rm -rf *.tgz; (cd deploy; tar -cf - * | gzip -9 > ../mominer-$tag.tgz) &&\
echo OK
