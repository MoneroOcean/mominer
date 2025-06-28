#!/usr/bin/env bash
./r.sh node test.js &&\
docker create --name moner moner-build &&\
(test -d deploy && rm -rf deploy || true) &&\
mkdir deploy &&\
docker cp -L moner:/usr/local/lib/libsycl.so.8 deploy &&\
docker cp -L moner:/usr/local/lib/libumf.so.0 deploy &&\
docker cp -L moner:/usr/local/lib/libur_loader.so.0 deploy &&\
docker cp -L moner:/usr/local/lib/libur_adapter_opencl.so.0 deploy &&\
docker cp -L moner:/usr/local/lib/libur_adapter_level_zero.so.0 deploy &&\
docker rm -f moner &&\
cp moner.js pool.js opts.js helper.js deploy &&\
cp -r node_modules deploy &&\
cp build/Release/moner.node deploy &&\
cp deploy.dockerfile deploy &&\
cp README.md deploy &&\
echo OK
cat <<'EOF' >deploy/moner.sh
#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LD_LIBRARY_PATH=$SCRIPT_DIR:$LD_LIBRARY_PATH node moner.js "$@"
EOF
cat <<'EOF' >deploy/docker-moner.sh
#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker build -q -t moner-deploy - <$SCRIPT_DIR/deploy.dockerfile &&\
docker run --privileged --rm --name moner-deploy --hostname moner-deploy --device=/dev/dri\
           --mount type=bind,source=$SCRIPT_DIR,target=/root/moner --workdir /root/moner\
           -it moner-deploy ./moner.sh "$@"
EOF
chmod +x deploy/moner.sh deploy/docker-moner.sh
