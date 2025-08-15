#!/usr/bin/env bash

tag=$1

./r.sh node test.js &&\
docker create --name mominer mominer-build &&\
(test -d deploy && rm -rf deploy || true) &&\
mkdir deploy &&\
docker cp -L mominer:/usr/local/lib/libsycl.so.8 deploy &&\
docker cp -L mominer:/usr/local/lib/libumf.so.0 deploy &&\
docker cp -L mominer:/usr/local/lib/libur_loader.so.0 deploy &&\
docker cp -L mominer:/usr/local/lib/libur_adapter_opencl.so.0 deploy &&\
docker cp -L mominer:/usr/local/lib/libur_adapter_level_zero.so.0 deploy &&\
docker rm -f mominer &&\
cp mominer.js pool.js opts.js helper.js deploy &&\
cp -r node_modules deploy &&\
cp build/Release/mominer.node deploy &&\
cp deploy.dockerfile deploy &&\
cp README.md deploy &&\
echo OK
cat <<'EOF' >deploy/mominer.sh
#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LD_LIBRARY_PATH=$SCRIPT_DIR:$LD_LIBRARY_PATH node mominer.js "$@"
EOF
cat <<'EOF' >deploy/docker-mominer.sh
#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t mominer-deploy - <$SCRIPT_DIR/deploy.dockerfile &&\
docker run --privileged --rm --name mominer-deploy --hostname mominer-deploy --device=/dev/dri\
           --mount type=bind,source=$SCRIPT_DIR,target=/root/mominer --workdir /root/mominer\
           -it mominer-deploy ./mominer.sh "$@"
EOF
chmod +x deploy/mominer.sh deploy/docker-mominer.sh
rm -rf *.tgz; (cd deploy; tar -cf - * | gzip -9 > ../mominer-$tag.tgz)
