FROM ubuntu:25.04

# install minimal number of packages needed
RUN (id -u ubuntu &>/dev/null && userdel -r ubuntu || exit 0) && apt-get update && apt-get install -y --no-install-recommends wget ca-certificates nodejs

# download and install graphics compiler and runtime
RUN cd /tmp &&\
    CR=https://github.com/intel/compute-runtime/releases/download\
    LZ=https://github.com/oneapi-src/level-zero/releases/download\
    IGC=https://github.com/intel/intel-graphics-compiler/releases/download bash -c '\
    wget -q $CR/25.22.33944.8/libze-intel-gpu1_25.22.33944.8-0_amd64.deb\
            $CR/25.22.33944.8/intel-opencl-icd_25.22.33944.8-0_amd64.deb\
            $CR/25.22.33944.8/libigdgmm12_22.7.0_amd64.deb\
            $LZ/v1.22.4/level-zero_1.22.4+u24.04_amd64.deb\
            $IGC/v2.12.5/intel-igc-core-2_2.12.5+19302_amd64.deb\
            $IGC/v2.12.5/intel-igc-opencl-2_2.12.5+19302_amd64.deb' &&\
    apt-get install -y /tmp/*.deb &&\
    rm -rf /tmp/*

