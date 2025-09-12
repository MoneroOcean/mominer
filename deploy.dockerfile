# https://hub.docker.com/r/intel/oneapi-basekit/tags
FROM intel/oneapi-runtime:2025.2.2-0-devel-ubuntu24.04

# install minimal number of packages needed
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs

COPY libumf.so.0 /opt/intel/oneapi/redist/lib
