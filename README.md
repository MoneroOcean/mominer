## MoMiner

# About

MoMiner is open-source cryptocurrency miner that is built upon high performance xmrig CPU miner
sources with front-end and network backend rewritten in Node.js to significantly simplify its code.
GPU mining sources are also simplified and rewritten in SYCL from OpenCL/CUDA.
The main goal of this project is to make simple, easy to extend open-source miner with native
miner performance.

# Limitations

The only platform tested at this moment is Linux with one socket x86-64 CPU and Intel Arc GPU
(my current development system). 2+ socket CPU, Windows, ARM CPU, nVidia/AMD GPU support
is possible and WIP.

# Supported algos

* CPU: All xmrig miner CPU supported algos with similar performance
* GPU: cn/gpu, c29

Miner supports algo switching if you connect it to algo switching pool like
gulf.moneroocean.stream that auto switches to the most profitable algo.

# Donation

By default, miner donates 1% of hashrate (can be disabled in config).

# Distribution

Miner mominer.node dynamic library can be compiled and run from sources using ./r.sh script that
will build docker container with SYCL compiler:

```
git clone https://github.com/MoneroOcean/mominer.git
cd mominer
./r.sh
```

There is also x86-64 Linux .tgz archive distribution with precompiled mominer.node and SYCL
libraries where you can use docker-mominer.sh script to run miner inside docker container with
Intel Level-Zero/OpenCL runtimes or you can use mominer.sh script to run miner if you have
these runtimes already installed on your system.

# Usage example

On Linux system with docker installed if you run miner like that for the first time it will
benchmarks all supported algos and will start mining (this is perf numbers for Intel i7-11700K CPU
and Intel Arc B580 GPU):

```
$ ./docker-mominer.sh mine gulf.moneroocean.stream:20001tls 89TxfrUmqJJcb1V124WsUzA78Xa3UYHt7Bg8RGMhXVeZYPN8cE5CZEk58Y1m23ZMLHN7wYeJ9da5n5MXharEjrm41hSnWHL --save_config config.json
...
cpu1: Intel(R) OpenCL
gpu1: Intel(R) oneAPI Unified Runtime over Level-Zero
gpu1o: Intel(R) OpenCL Graphics
gpu1z: Intel(R) oneAPI Unified Runtime over Level-Zero
2025-09-15 01:35:55 Doing algo benchmarks...
2025-09-15 01:36:55 Algo argon2/chukwa (cpu^16) hashrate: 47513.80 H/s (2984.62, 2944.52, 2972.28, 2956.90, 2977.68, 2986.23, 2971.90, 2966.90, 2970.45, 2966.12, 2977.23, 2966.95, 2974.12, 2953.90, 2979.02, 2964.97)
2025-09-15 01:37:55 Algo argon2/chukwav2 (cpu^16) hashrate: 15967.23 H/s (999.98, 990.77, 998.45, 1003.10, 1001.63, 1002.35, 1002.95, 999.90, 999.42, 996.63, 1000.07, 998.45, 990.43, 986.65, 994.72, 1001.73)
2025-09-15 01:38:56 Algo argon2/wrkz (cpu^16) hashrate: 72486.84 H/s (4536.26, 4475.52, 4542.09, 4541.02, 4556.68, 4550.35, 4534.92, 4539.27, 4528.26, 4532.26, 4519.59, 4533.76, 4527.92, 4541.76, 4542.42, 4484.76)
2025-09-15 01:40:13 Algo c29 (gpu1*1) hashrate: 0.79 H/s (0.79)
2025-09-15 01:41:14 Algo cn-heavy/0 (cpu^4) hashrate: 342.83 H/s (85.88, 83.51, 86.28, 87.16)
2025-09-15 01:42:14 Algo cn-heavy/tube (cpu^4) hashrate: 304.03 H/s (74.47, 76.85, 77.59, 75.12)
2025-09-15 01:43:15 Algo cn-heavy/xhv (cpu^4) hashrate: 341.90 H/s (86.54, 87.25, 82.98, 85.13)
2025-09-15 01:44:15 Algo cn-lite/0 (cpu^16) hashrate: 2351.22 H/s (149.76, 141.54, 151.29, 141.95, 145.17, 145.09, 150.65, 149.99, 149.69, 142.25, 145.23, 150.77, 145.19, 141.57, 151.29, 149.80)
2025-09-15 01:45:16 Algo cn-lite/1 (cpu^16) hashrate: 2302.39 H/s (139.09, 142.41, 146.57, 146.37, 148.35, 138.94, 147.64, 142.10, 147.38, 142.36, 142.07, 146.58, 146.54, 139.00, 148.33, 138.65)
2025-09-15 01:46:16 Algo cn-pico/0 (cpu*4^16) hashrate: 14661.97 H/s (917.74, 922.24, 907.09, 923.10, 922.36, 911.59, 923.77, 913.04, 906.26, 914.10, 925.94, 923.71, 905.83, 907.11, 912.76, 925.34)
2025-09-15 01:47:17 Algo cn-pico/tlo (cpu*4^16) hashrate: 13090.18 H/s (815.24, 816.79, 825.35, 825.38, 826.25, 810.19, 807.76, 823.06, 808.55, 823.55, 814.29, 809.16, 815.31, 822.78, 823.78, 822.74)
2025-09-15 01:48:17 Algo cn/0 (cpu^8) hashrate: 623.08 H/s (79.61, 80.16, 76.87, 74.92, 80.25, 76.82, 79.58, 74.85)
2025-09-15 01:49:18 Algo cn/1 (cpu^8) hashrate: 616.83 H/s (76.08, 74.09, 79.41, 74.20, 79.09, 76.07, 78.78, 79.11)
2025-09-15 01:50:18 Algo cn/2 (cpu^8) hashrate: 621.27 H/s (79.15, 79.35, 79.16, 79.32, 76.81, 75.38, 75.32, 76.78)
2025-09-15 01:51:18 Algo cn/ccx (cpu^8) hashrate: 1194.36 H/s (147.30, 152.49, 143.78, 143.70, 153.68, 152.52, 153.63, 147.27)
2025-09-15 01:52:19 Algo cn/double (cpu^8) hashrate: 314.76 H/s (38.92, 40.11, 38.19, 40.11, 38.87, 40.21, 40.22, 38.12)
2025-09-15 01:53:20 Algo cn/fast (cpu^8) hashrate: 1197.40 H/s (154.03, 152.89, 147.73, 154.05, 153.07, 147.69, 144.04, 143.91)
2025-09-15 01:54:30 Algo cn/gpu (gpu1*960) hashrate: 1946.35 H/s (1946.35)
2025-09-15 01:55:30 Algo cn/half (cpu^8) hashrate: 1236.35 H/s (157.66, 158.03, 149.68, 149.70, 157.55, 153.16, 157.76, 152.81)
2025-09-15 01:56:31 Algo cn/r (cpu^8) hashrate: 590.60 H/s (71.98, 75.20, 75.04, 75.33, 73.15, 72.87, 71.67, 75.36)
2025-09-15 01:57:31 Algo cn/rto (cpu^8) hashrate: 615.67 H/s (75.91, 79.24, 78.63, 79.23, 75.96, 73.98, 78.66, 74.08)
2025-09-15 01:58:32 Algo cn/rwz (cpu^8) hashrate: 819.92 H/s (104.43, 104.68, 101.40, 104.70, 101.40, 99.28, 104.48, 99.55)
2025-09-15 01:59:32 Algo cn/upx2 (cpu*5^16) hashrate: 54442.91 H/s (3419.54, 3427.59, 3393.60, 3393.05, 3378.11, 3377.94, 3427.76, 3426.81, 3393.22, 3412.27, 3416.32, 3409.72, 3376.10, 3375.88, 3422.39, 3392.60)
2025-09-15 02:00:33 Algo cn/xao (cpu^8) hashrate: 316.19 H/s (40.73, 40.38, 38.97, 37.97, 38.02, 38.99, 40.73, 40.40)
2025-09-15 02:01:33 Algo cn/zls (cpu^8) hashrate: 812.81 H/s (103.68, 104.26, 104.01, 98.97, 98.01, 100.88, 104.23, 98.77)
2025-09-15 02:02:34 Algo ghostrider (cpu*8^8) hashrate: 1602.74 H/s (204.24, 198.80, 203.49, 193.88, 193.86, 205.20, 205.29, 197.98)
2025-09-15 02:03:37 Algo rx/0 (cpu*8) hashrate: 5939.81 H/s (5939.81)
2025-09-15 02:04:40 Algo rx/arq (cpu*16) hashrate: 39197.87 H/s (39197.87)
2025-09-15 02:05:44 Algo rx/graft (cpu*8) hashrate: 5742.19 H/s (5742.19)
2025-09-15 02:06:47 Algo rx/sfx (cpu*8) hashrate: 5935.91 H/s (5935.91)
2025-09-15 02:07:50 Algo rx/wow (cpu*16) hashrate: 7835.79 H/s (7835.79)
2025-09-15 02:08:53 Algo rx/yada (cpu*8) hashrate: 5908.27 H/s (5908.27)
2025-09-15 02:08:53 Saving config file to config4.json
2025-09-15 02:08:53 Connecting to primary gulf.moneroocean.stream:20001tls pool
2025-09-15 02:08:54 Got new rx/0 algo job with 10000 diff and 3500250 height
2025-09-15 02:08:56 Share accepted by the pool (1/0)
...
```

Next time you can reuse saved config.json file to avoid running benchmarks again before mining:

```
$ ./docker-mominer.sh mine ./config.json
sha256:d59ea9964e92182e5751a19e296b05209f6545ead6b1a010174f0dbf6fb7f761
2023-02-24 05:55:59 Loading config file ./config.json
2023-02-24 05:55:59 Connecting to primary gulf.moneroocean.stream:20064tls pool
2023-02-24 05:55:59 Got new cn/gpu algo job with 12004 diff
2023-02-24 05:56:24 Share accepted by the pool (1/0)
...
```

Without parameters miner will show help:

```
$ ./docker-mominer.sh
sha256:d59ea9964e92182e5751a19e296b05209f6545ead6b1a010174f0dbf6fb7f761

# Node.js/SYCL based CPU/GPU miner v0.1
$ node mominer.js <directive> <parameter>+ [<option>+]

Directives:
  mine  (<pool_address:port[tls]> <login> [<pass>]|<config.json>)
  test  <algo> <result_hash_hex_str>
  bench <algo>

Options:
--job '{...}':                      JSON string of the default job params (mostly used in test/bench mode)
  --job.dev:                        device config line "[<dev>[*B][^P],]+", dev = {cpu, gpu<N>, cpu<N>}, N = device number, B = hash batch size, P = number of parallel processes ("cpu" by default)
  --job.blob_hex:                   hexadecimal string of input blob ("0305A0DBD6BF05CF16E503F3A66F78007CBF34144332ECBFC22ED95C8700383B309ACE1923A0964B00000008BA939A62724C0D7581FCE5761E9D8A0E6A1C3F924FDD8493D1115649C05EB601" by default)
  --job.seed_hex:                   hexadecimal string of seed hash blob (used for rx algos) ("3132333435363738393031323334353637383930313233343536373839303132" by default)
  --job.height:                     Block height used by some algos (0 by default)

--pool_time '{...}':                JSON string of pool related timings (in seconds)
  --pool_time.stats:                time to show pool mining stats (600 by default)
  --pool_time.connect_throttle:     time between pool connection attempts (60 by default)
  --pool_time.primary_reconnect:    time to try to use primary pool if currently on backup pool (90 by default)
  --pool_time.first_job_wait:       consider pool bad if no first job after connection (15 by default)
  --pool_time.close_wait:           keep pool socket to submit delayed jobs (10 by default)
  --pool_time.donate_interval:      time before donation pool is activated (6000 by default)
  --pool_time.donate_length:        donation pool work time (60 by default)
  --pool_time.keepalive:            interval to send keepalive messages (300 by default)

--add.pool '{["<key>": <value>,]+}': add backup pool, defined by the following keys:
  url:                              pool DNS or IP address
  port:                             pool port
  is_tls:                           is pool port is encrypted using TLS/SSL (false by default)
  is_nicehash:                      nicehash nonce mining mode support (false by default)
  is_keepalive:                     sends keepalive messages to the pool to avoid disconnect (true by default)
  login:                            pool login data
  pass:                             pool password ("" by default)

--new.default_msr.<name> '{["<key>": <value>,]+}': stores default MSR register values to restore them without reboot, keys should be hex strings with 0x prefix
  value:                            MSR register value in hex string with 0x prefix format
  mask:                             MSR register mask in hex string with 0x prefix format ("0xFFFFFFFFFFFFFFFF" by default)

--new.algo_param.<name> '{["<key>": <value>,]+}': new algo params, defined by the following keys:
  dev:                              device config line "[<dev>[*B][^T],]+", dev = {cpu, gpu<N>, cpu<N>}, N = device number, B = hash batch size, T = number of parallel threads ("cpu" by default)

--log_level:                        log level: 0=minimal, 1=verbose, 2=network debug, 3=compute core debug (0 by default)
--save_config:                      file name to save config in JSON format (only for mine directive) ("" by default)
2023-02-24 05:58:24 ERROR: No directive specified
```

You can run test and benchmark separately for algo you need like this:

```
./r.sh node mominer.js test cn/gpu e55cb23e51649a59b127b96b515f2bf7bfea199741a0216cf838ded06eff82df --job '{"algo":"cn/gpu","dev":"gpu1*8"}'
./r.sh node mominer.js bench cn/gpu --job '{"algo":"cn/gpu","dev":"gpu1z*960"}'
```

Enable huge pages for better performance (check [Huge Pages](https://xmrig.com/docs/miner/hugepages)):

```
sudo sysctl -w vm.nr_hugepages=1280
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"
```
