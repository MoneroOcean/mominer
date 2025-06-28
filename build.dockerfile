FROM moner-deploy

# install tools to build SYCL compiler and run our nodejs miner
RUN apt-get update && apt-get install -y --no-install-recommends\
    sudo git cmake build-essential npm binutils-dev

# build SYCL compiler with LTO support
RUN export DPCPP_HOME=/tmp/sycl-compiler &&\
    mkdir -p $DPCPP_HOME/build &&\
    cd $DPCPP_HOME &&\
    git clone https://github.com/intel/llvm -b nightly-2025-06-28 --depth 1 &&\
    cd $DPCPP_HOME/build &&\
    cmake $DPCPP_HOME/llvm/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=X86\
          -DLLVM_EXTERNAL_PROJECTS="sycl;llvm-spirv;opencl;sycl-jit;libdevice;xpti;xptifw"\
          -DLLVM_ENABLE_PROJECTS="clang;sycl;llvm-spirv;opencl;sycl-jit;libdevice;xpti;xptifw"\
          -DSYCL_ENABLE_PLUGINS="opencl;level_zero"\
          -DLLVM_EXTERNAL_SYCL_SOURCE_DIR=$DPCPP_HOME/llvm/sycl\
          -DLLVM_EXTERNAL_LLVM_SPIRV_SOURCE_DIR=$DPCPP_HOME/llvm/llvm-spirv\
          -DLLVM_EXTERNAL_SYCL_JIT_SOURCE_DIR=$DPCPP_HOME/llvm/sycl-jit\
          -DLLVM_EXTERNAL_LIBDEVICE_SOURCE_DIR=$DPCPP_HOME/llvm/libdevice\
          -DLLVM_EXTERNAL_XPTI_SOURCE_DIR=$DPCPP_HOME/llvm/xpti\
          -DXPTI_SOURCE_DIR=$DPCPP_HOME/llvm/xpti\
          -DLLVM_EXTERNAL_XPTIFW_SOURCE_DIR=$DPCPP_HOME/llvm/xptifw\
          -DLLVM_BINUTILS_INCDIR=/usr/include\
          -DLLVM_BUILD_TOOLS=ON -DSYCL_ENABLE_EXTENSION_JIT=ON\
          -DSYCL_ENABLE_XPTI_TRACING=ON -DSYCL_INCLUDE_TESTS=OFF\
          -DCMAKE_INSTALL_PREFIX=/usr/local &&\
    make LLVMgold deploy-sycl-toolchain -j$(nproc) &&\
    cp $DPCPP_HOME/build/lib/LLVMgold.so /usr/local/lib &&\
    rm -rf /tmp/*

# allow root group access to /root
RUN chmod g=u /root
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
# replace dash by bash as default /bin/sh shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# setup env for docker user commands
RUN echo $'#!/usr/bin/env bash\n\
    useradd user -u $(stat -c "%g" /root/moner) -G root,video -m -s /bin/bash\n\
    echo "user ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/user-user\n\
    echo "#!/usr/bin/env bash" >/root/cmd.sh\n\
    echo "npm update &&" >>/root/cmd.sh\n\
    echo "( test -s ./build/Release/moner.node ||"\
         "CC=clang CXX=clang++ node-gyp configure ) &&" >>/root/cmd.sh\n\
    echo "JOBS=$(nproc) CC=clang CXX=clang++ node-gyp build &&" >>/root/cmd.sh\n\
    echo "if [ $# -eq 1 ]; then" >>/root/cmd.sh\n\
    echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -- /bin/bash -c ${*@Q}; else" >>/root/cmd.sh\n\
    echo "sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH -- ${*@Q}; fi" >>/root/cmd.sh\n\
    chmod +x /root/cmd.sh\n\
    exec su user /root/cmd.sh' >/root/entrypoint.sh &&\
    chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

# sync user with host, build and run application
WORKDIR /root/moner
CMD node test.js
