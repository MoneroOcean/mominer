## Moner

# About

Moner is open-source cryptocurrency miner that is built upon high performance xmrig CPU miner
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
* GPU: cn/gpu

Miner supports algo switching if you connect it to algo switching pool like
gulf.moneroocean.stream that auto switches to the most profitable algo.

# Donation

By default, miner donates 1% of hashrate (can be disabled in config).

# Distribution

Miner moner.node dynamic library can be compiled and run from sources using ./r.sh script that
will build docker container with SYCL compiler:

```
git clone https://github.com/MoneroOcean/moner.git
cd moner
./r.sh
```

There is also x86-64 Linux .tgz archive distribution with precompiled moner.node and SYCL
libraries where you can use docker-moner.sh script to run miner inside docker container with
Intel Level-Zero/OpenCL runtimes or you can use moner.sh script to run miner if you have
these runtimes already installed on your system.

# Usage example

On Linux system with docker installed if you run miner like that for the first time it will
benchmarks all supported algos and will start mining (this is perf numbers for Intel i7-11700K CPU
and Intel Arc A770 GPU):

```
$ ./docker-moner.sh mine gulf.moneroocean.stream:20064tls 89TxfrUmqJJcb1V124WsUzA78Xa3UYHt7Bg8RGMhXVeZYPN8cE5CZEk58Y1m23ZMLHN7wYeJ9da5n5MXharEjrm41hSnWHL --save_config config.json
sha256:d59ea9964e92182e5751a19e296b05209f6545ead6b1a010174f0dbf6fb7f761
2023-02-24 05:10:23 Doing algo benchmarks...
2023-02-24 05:11:23 Algo argon2/chukwa (cpu^16) hashrate: 47547.74 H/s (2978.07, 2973.45, 2966.28, 2960.35, 2974.64, 2949.52, 2963.02, 2979.47, 2983.90, 2974.18, 2971.12, 2970.57, 2967.12, 2976.52, 2983.23, 2976.30)
2023-02-24 05:12:23 Algo argon2/chukwav2 (cpu^16) hashrate: 16398.76 H/s (1029.88, 1022.91, 1027.40, 1026.18, 1025.70, 1018.13, 1032.65, 1027.20, 1020.20, 1023.55, 1018.82, 1025.95, 1024.90, 1027.41, 1028.33, 1019.56)
2023-02-24 05:13:23 Algo argon2/wrkz (cpu^16) hashrate: 73588.92 H/s (4614.68, 4594.59, 4610.01, 4618.42, 4590.68, 4577.92, 4571.18, 4595.44, 4594.09, 4605.35, 4605.85, 4611.92, 4609.09, 4583.76, 4612.01, 4593.92)
2023-02-24 05:14:24 Algo cn-heavy/0 (cpu^4) hashrate: 348.43 H/s (87.95, 87.49, 85.93, 87.06)
2023-02-24 05:15:24 Algo cn-heavy/tube (cpu^4) hashrate: 287.52 H/s (71.71, 70.67, 72.11, 73.03)
2023-02-24 05:16:25 Algo cn-heavy/xhv (cpu^4) hashrate: 340.06 H/s (86.22, 82.16, 88.09, 83.59)
2023-02-24 05:17:25 Algo cn-lite/0 (cpu^16) hashrate: 2371.58 H/s (144.45, 146.74, 150.86, 151.38, 149.04, 145.43, 145.37, 147.02, 143.22, 151.62, 146.88, 150.69, 147.09, 149.25, 151.76, 150.77)
2023-02-24 05:18:26 Algo cn-lite/1 (cpu^16) hashrate: 2349.03 H/s (151.38, 149.19, 150.14, 141.60, 146.30, 149.55, 149.63, 148.82, 146.12, 141.66, 146.08, 150.07, 144.88, 142.62, 147.27, 143.72)
2023-02-24 05:19:26 Algo cn-pico/0 (cpu*4^16) hashrate: 14722.00 H/s (921.69, 928.70, 921.74, 914.92, 911.47, 919.75, 922.10, 931.22, 916.84, 922.61, 924.79, 913.44, 912.16, 914.13, 927.92, 918.50)
2023-02-24 05:20:26 Algo cn-pico/tlo (cpu*4^16) hashrate: 13247.17 H/s (828.88, 830.93, 833.13, 838.43, 822.76, 822.63, 835.46, 824.36, 829.10, 831.29, 824.58, 828.20, 825.28, 829.21, 820.98, 821.97)
2023-02-24 05:21:27 Algo cn/0 (cpu^8) hashrate: 630.51 H/s (77.99, 79.76, 81.24, 76.08, 79.51, 75.32, 80.68, 79.94)
2023-02-24 05:22:27 Algo cn/1 (cpu^8) hashrate: 625.30 H/s (79.89, 75.59, 75.54, 79.71, 79.58, 77.27, 79.24, 78.49)
2023-02-24 05:23:28 Algo cn/2 (cpu^8) hashrate: 632.27 H/s (77.01, 79.94, 78.29, 80.42, 76.10, 80.64, 79.40, 80.47)
2023-02-24 05:24:28 Algo cn/ccx (cpu^8) hashrate: 1216.24 H/s (153.67, 156.26, 154.33, 146.85, 154.91, 154.85, 148.62, 146.75)
2023-02-24 05:25:29 Algo cn/double (cpu^8) hashrate: 319.38 H/s (40.85, 40.64, 39.21, 40.28, 38.68, 38.71, 40.36, 40.65)
2023-02-24 05:26:29 Algo cn/fast (cpu^8) hashrate: 1216.46 H/s (156.91, 146.30, 154.47, 150.36, 147.66, 154.31, 155.14, 151.30)
2023-02-24 05:28:00 Algo cn/gpu (gpu1*2040,gpu1*1032) hashrate: 1721.57 H/s (1143.19, 578.38)
2023-02-24 05:29:01 Algo cn/half (cpu^8) hashrate: 1245.13 H/s (156.87, 153.15, 159.34, 159.05, 150.68, 157.73, 156.65, 151.67)
2023-02-24 05:30:01 Algo cn/r (cpu^8) hashrate: 597.21 H/s (75.62, 72.94, 75.59, 75.89, 75.25, 73.68, 75.50, 72.74)
2023-02-24 05:31:02 Algo cn/rto (cpu^8) hashrate: 623.34 H/s (79.12, 79.61, 74.47, 80.40, 80.06, 78.92, 74.10, 76.65)
2023-02-24 05:32:02 Algo cn/rwz (cpu^8) hashrate: 832.28 H/s (105.74, 101.06, 104.25, 101.33, 106.16, 102.88, 104.73, 106.12)
2023-02-24 05:33:02 Algo cn/upx2 (cpu*5^16) hashrate: 54416.16 H/s (3394.00, 3380.38, 3416.82, 3394.32, 3405.38, 3389.44, 3418.43, 3394.11, 3393.88, 3425.03, 3383.83, 3405.38, 3402.65, 3426.87, 3377.83, 3407.82)
2023-02-24 05:34:03 Algo cn/xao (cpu^8) hashrate: 319.69 H/s (39.94, 41.14, 38.55, 40.70, 40.45, 40.98, 38.56, 39.36)
2023-02-24 05:35:04 Algo cn/zls (cpu^8) hashrate: 833.24 H/s (103.42, 105.21, 103.41, 105.23, 105.27, 102.95, 106.46, 101.29)
2023-02-24 05:36:05 Algo ghostrider (cpu*8^8) hashrate: 1604.28 H/s (194.08, 197.63, 203.14, 203.83, 201.26, 204.53, 194.39, 205.42)
2023-02-24 05:37:08 Algo rx/0 (cpu*8) hashrate: 5900.70 H/s (5900.70)
2023-02-24 05:38:11 Algo rx/arq (cpu*16) hashrate: 38233.45 H/s (38233.45)
2023-02-24 05:39:14 Algo rx/graft (cpu*8) hashrate: 5696.92 H/s (5696.92)
2023-02-24 05:40:17 Algo rx/keva (cpu*16) hashrate: 8216.35 H/s (8216.35)
2023-02-24 05:41:21 Algo rx/sfx (cpu*8) hashrate: 5895.44 H/s (5895.44)
2023-02-24 05:42:24 Algo rx/wow (cpu*16) hashrate: 7928.37 H/s (7928.37)
2023-02-24 05:42:24 Saving config file to config.json
2023-02-24 05:42:24 Connecting to primary gulf.moneroocean.stream:20064tls pool
2023-02-24 05:42:24 Got new cn/gpu algo job with 11545 diff
2023-02-24 05:42:28 Share accepted by the pool (1/0)
...
```

Next time you can reuse saved config.json file to avoid running benchmarks again before mining:

```
$ ./docker-moner.sh mine ./config.json
sha256:d59ea9964e92182e5751a19e296b05209f6545ead6b1a010174f0dbf6fb7f761
2023-02-24 05:55:59 Loading config file ./config.json
2023-02-24 05:55:59 Connecting to primary gulf.moneroocean.stream:20064tls pool
2023-02-24 05:55:59 Got new cn/gpu algo job with 12004 diff
2023-02-24 05:56:24 Share accepted by the pool (1/0)
...
```

Without parameters miner will show help:

```
$ ./docker-moner.sh
sha256:d59ea9964e92182e5751a19e296b05209f6545ead6b1a010174f0dbf6fb7f761

# Node.js/SYCL based CPU/GPU miner v0.1
$ node moner.js <directive> <parameter>+ [<option>+]

Directives:
  mine  (<pool_address:port[tls]> <login> [<pass>]|<config.json>)
  test  <algo> <result_hash_hex_str>
  bench <algo>

Options:
--job '{...}':                      JSON string of the default job params (mostly used in test/bench mode)
  --job.dev:                        device config line "[<dev>[*B][^P],]+", dev = {cpu, gpu<N>, cpu<N>}, N = device number, B = hash batch size, P = number of parallel processes ("cpu" by default)
  --job.blob_hex:                   hexadecimal string of input blob ("0305A0DBD6BF05CF16E503F3A66F78007CBF34144332ECBFC22ED95C8700383B309ACE1923A0964B00000008BA939A62724C0D7581FCE5761E9D8A0E6A1C3F924FDD8493D1115649C05EB601" by default)
  --job.seed_hex:                   hexadecimal string of seed hash blob (used for rx algos) ("3132333435363738393031323334353637383930313233343536373839303132" by default)
  --job.height:                     Block height used by somo algos (0 by default)

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
./r.sh node moner.js test cn/gpu e55cb23e51649a59b127b96b515f2bf7bfea199741a0216cf838ded06eff82df --job '{"algo":"cn/gpu","dev":"gpu1*8"}'
./r.sh node moner.js bench cn/gpu --job '{"algo":"cn/gpu","dev":"gpu1z*960"}'
```
