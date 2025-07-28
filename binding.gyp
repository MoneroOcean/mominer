{ "targets": [
  { "target_name": "moner",
    "sources": [
      "moner-core.cpp",
      "moner-job.cpp",

      "xmrig/crypto/common/VirtualMemory.cpp",
      "xmrig/crypto/common/VirtualMemory_unix.cpp",
      "xmrig/base/crypto/keccak.cpp",
      "xmrig/backend/cpu/Cpu.cpp",

      "xmrig/crypto/cn/CnCtx.cpp",
      "xmrig/crypto/cn/CnHash.cpp",
      "xmrig/crypto/cn/c_blake256.c",
      "xmrig/crypto/cn/c_groestl.c",
      "xmrig/crypto/cn/c_jh.c",
      "xmrig/crypto/cn/c_skein.c",
      "xmrig/crypto/cn/r/CryptonightR_gen.cpp",

      "xmrig/crypto/randomx/aes_hash.cpp",
      "xmrig/crypto/randomx/bytecode_machine.cpp",
      "xmrig/crypto/randomx/dataset.cpp",
      "xmrig/crypto/randomx/soft_aes.cpp",
      "xmrig/crypto/randomx/virtual_memory.cpp",
      "xmrig/crypto/randomx/vm_interpreted.cpp",
      "xmrig/crypto/randomx/allocator.cpp",
      "xmrig/crypto/randomx/randomx.cpp",
      "xmrig/crypto/randomx/superscalar.cpp",
      "xmrig/crypto/randomx/vm_compiled.cpp",
      "xmrig/crypto/randomx/vm_interpreted_light.cpp",
      "xmrig/crypto/randomx/blake2_generator.cpp",
      "xmrig/crypto/randomx/instructions_portable.cpp",
      "xmrig/crypto/randomx/reciprocal.c",
      "xmrig/crypto/randomx/virtual_machine.cpp",
      "xmrig/crypto/randomx/vm_compiled_light.cpp",
      "xmrig/crypto/randomx/blake2/blake2b.c",

      "xmrig/crypto/ghostrider/sph_blake.c",
      "xmrig/crypto/ghostrider/sph_bmw.c",
      "xmrig/crypto/ghostrider/sph_cubehash.c",
      "xmrig/crypto/ghostrider/sph_echo.c",
      "xmrig/crypto/ghostrider/sph_fugue.c",
      "xmrig/crypto/ghostrider/sph_groestl.c",
      "xmrig/crypto/ghostrider/sph_hamsi.c",
      "xmrig/crypto/ghostrider/sph_hamsi_helper.c",
      "xmrig/crypto/ghostrider/sph_jh.c",
      "xmrig/crypto/ghostrider/sph_keccak.c",
      "xmrig/crypto/ghostrider/sph_luffa.c",
      "xmrig/crypto/ghostrider/sph_sha2.c",
      "xmrig/crypto/ghostrider/sph_shabal.c",
      "xmrig/crypto/ghostrider/sph_shavite.c",
      "xmrig/crypto/ghostrider/sph_simd.c",
      "xmrig/crypto/ghostrider/sph_skein.c",
      "xmrig/crypto/ghostrider/sph_whirlpool.c",
      "xmrig/crypto/ghostrider/ghostrider.cpp",

      "xmrig/3rdparty/argon2/lib/argon2.c",
      "xmrig/3rdparty/argon2/lib/core.c",
      "xmrig/3rdparty/argon2/lib/encoding.c",
      "xmrig/3rdparty/argon2/lib/genkat.c",
      "xmrig/3rdparty/argon2/lib/impl-select.c",
      "xmrig/3rdparty/argon2/lib/blake2/blake2.c",

      "xmrig/3rdparty/fmt/format.cc",

      '<!@(./test-cpu.sh x86_64 && ('
      '     echo "xmrig/backend/cpu/platform/BasicCpuInfo.cpp"'
      '     echo "xmrig/hw/msr/Msr.cpp"'
      '     echo "xmrig/hw/msr/Msr_linux.cpp"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-arch.c"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-avx512f.c"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-avx2.c"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-xop.c"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-ssse3.c"'
      '     echo "xmrig/3rdparty/argon2/arch/x86_64/lib/argon2-sse2.c"'
      '     echo "xmrig/crypto/randomx/blake2/blake2b_sse41.c"'
      '     echo "xmrig/crypto/randomx/blake2/avx2/blake2b_avx2.c"'
      '     echo "xmrig/crypto/rx/RxFix_linux.c"'
      '     echo "xmrig/crypto/cn/asm/cn_main_loop.S"'
      '     echo "xmrig/crypto/cn/asm/CryptonightR_template.S"'
      '     echo "xmrig/crypto/randomx/jit_compiler_x86_static.S"'
      '     echo "xmrig/crypto/randomx/jit_compiler_x86.cpp"'
      '   ) || ('
      '     echo "xmrig/backend/cpu/platform/BasicCpuInfo_arm.cpp"'
      '     echo "xmrig/3rdparty/argon2/arch/generic/lib/argon2-arch.c"'
      '     echo "xmrig/crypto/randomx/jit_compiler_a64_static.S"'
      '     echo "xmrig/crypto/randomx/jit_compiler_a64.cpp"'
      '   ))',
    ],
    "include_dirs": [
      "xmrig",
      "xmrig/3rdparty/argon2/include",
      "xmrig/3rdparty/argon2/lib",
      "<!(node -e \"require('nan')\")"
    ],
    "cflags!": [ "-O3" ],
    "cflags_cc!": [ "-std=gnu++1y", "-std=gnu++17", "-fno-exceptions" ],
    "cflags+": [
      '<!@(./test-cpu.sh arm64 &&'
      '     echo "-march=armv8-a+crypto -flax-vector-conversions" || ('
      '       ./test-cpu.sh arm &&'
      '       echo "-mfpu=neon -flax-vector-conversions" ||'
      '       echo "-march=native"'
      '     )'
      '   )',
      '<!@(./test-cpu.sh avx512f && echo "-DHAVE_AVX512F" || echo)',
      '<!@(./test-cpu.sh avx2    && echo "-DHAVE_AVX2 -DXMRIG_FEATURE_AVX2" || echo)',
      '<!@(./test-cpu.sh xop     && echo "-DHAVE_XOP" || echo)',
      '<!@(./test-cpu.sh sse4_1  && echo "-DXMRIG_FEATURE_SSE4_1" || echo)',
      '<!@(./test-cpu.sh ssse3   && echo "-DHAVE_SSSE3" || echo)',
      '<!@(./test-cpu.sh sse2    && echo "-DHAVE_SSE2" || echo)',
      '<!@(./test-cpu.sh msr     && echo "-DXMRIG_FEATURE_MSR" || echo)',
      '<!@(./test-cpu.sh vaes    && echo "-DHAVE_VAES" || echo)',
      "-DNDEBUG -DHAVE_ROTR -DXMRIG_FEATURE_ASM "
      "-DXMRIG_ALGO_CN_LITE -DXMRIG_ALGO_CN_HEAVY -DXMRIG_ALGO_CN_PICO -DXMRIG_ALGO_CN_FEMTO "
      "-DXMRIG_ALGO_ARGON2 -DXMRIG_ALGO_GHOSTRIDER "
      "-O3 -ffast-math -flto=thin -funroll-loops -fmerge-all-constants"
    ],
    "cflags_cc+": [
      "-std=c++20"
    ],
    "libraries": [
      "-fsycl -flto=thin /usr/local/lib/libsycl.so"
    ],
    "dependencies": [ "sycl" ]
  },
  { "target_name": "sycl",
    "type": "static_library",
    "sources": [
      "sycl-lib.cpp",
      "c29s.cpp",
      "cn-gpu.cpp",
    ],
    "cflags!": [ "-O3" ],
    "cflags_cc!": [ "-fno-rtti", "-fno-exceptions", "-std=gnu++1y", "-std=gnu++17" ],
    "cflags+": [
      '<!@(./test-cpu.sh arm64 &&'
      '     echo "-march=armv8-a+crypto -flax-vector-conversions" || ('
      '       ./test-cpu.sh arm &&'
      '       echo "-mfpu=neon -flax-vector-conversions" ||'
      '       echo "-march=native"'
      '     )'
      '   )',
      "-std=c++20 -fsycl -DNDEBUG"
    ]
  },
]}
