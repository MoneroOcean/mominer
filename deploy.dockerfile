FROM ubuntu:22.04

# install minimal number of packages needed
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates nodejs

# download and install graphics compiler and runtime
RUN cd /tmp &&\
    CR=https://github.com/intel/compute-runtime/releases/download\
    IGC=https://github.com/intel/intel-graphics-compiler/releases/download bash -c '\
    wget -q $CR/22.49.25018.24/intel-level-zero-gpu_1.3.25018.24_amd64.deb\
            $CR/22.49.25018.24/intel-opencl-icd_22.49.25018.24_amd64.deb\
            $CR/22.49.25018.24/libigdgmm12_22.3.0_amd64.deb\
            $IGC/igc-1.0.12812.24/intel-igc-core_1.0.12812.24_amd64.deb\
            $IGC/igc-1.0.12812.24/intel-igc-opencl_1.0.12812.24_amd64.deb' &&\
    apt-get install -y /tmp/*.deb &&\
    rm -rf /tmp/*

