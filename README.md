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
and Intel Arc B580 GPU):

```
$ ./docker-moner.sh mine gulf.moneroocean.stream:20001tls 89TxfrUmqJJcb1V124WsUzA78Xa3UYHt7Bg8RGMhXVeZYPN8cE5CZEk58Y1m23ZMLHN7wYeJ9da5n5MXharEjrm41hSnWHL --save_config config.json
...
gpu1: Intel(R) oneAPI Unified Runtime over Level-Zero
gpu1o: Intel(R) OpenCL Graphics
gpu1z: Intel(R) oneAPI Unified Runtime over Level-Zero
2025-08-15 03:40:29 Doing algo benchmarks...
2025-08-15 03:41:29 Algo argon2/chukwa (cpu^16) hashrate: 47176.18 H/s (2924.74, 2944.24, 2957.45, 2959.64, 2926.74, 2957.95, 2920.69, 2968.90, 2973.97, 2926.45, 2939.24, 2945.95, 2964.64, 2971.97, 2941.95, 2951.69)
2025-08-15 03:42:30 Algo argon2/chukwav2 (cpu^16) hashrate: 15572.80 H/s (987.34, 983.45, 974.40, 957.80, 968.28, 954.15, 984.42, 957.55, 972.34, 991.15, 966.51, 983.82, 975.24, 960.05, 985.85, 970.44)
2025-08-15 03:43:30 Algo argon2/wrkz (cpu^16) hashrate: 72262.68 H/s (4534.94, 4551.35, 4510.76, 4517.18, 4532.76, 4540.76, 4472.43, 4521.40, 4510.61, 4545.59, 4503.59, 4537.11, 4491.26, 4470.26, 4533.68, 4489.02)
2025-08-15 03:44:46 Algo c29s (gpu1*1) hashrate: 0.79 H/s (0.79)
2025-08-15 03:45:47 Algo cn-heavy/0 (cpu^4) hashrate: 287.71 H/s (71.52, 72.19, 71.48, 72.53)
2025-08-15 03:46:47 Algo cn-heavy/tube (cpu^4) hashrate: 256.11 H/s (64.33, 63.91, 63.93, 63.93)
2025-08-15 03:47:48 Algo cn-heavy/xhv (cpu^4) hashrate: 279.11 H/s (70.64, 69.47, 69.64, 69.37)
2025-08-15 03:48:48 Algo cn-lite/0 (cpu^16) hashrate: 2141.21 H/s (132.58, 136.24, 134.70, 133.74, 130.40, 138.89, 132.92, 134.73, 138.24, 130.07, 135.09, 131.27, 134.01, 138.32, 129.90, 130.10)
2025-08-15 03:49:49 Algo cn-lite/1 (cpu^16) hashrate: 2064.11 H/s (130.45, 127.15, 131.24, 130.14, 135.69, 124.70, 126.29, 129.13, 129.28, 130.72, 131.78, 127.02, 132.99, 125.61, 125.95, 126.00)
2025-08-15 03:50:49 Algo cn-pico/0 (cpu*4^16) hashrate: 14113.40 H/s (880.46, 903.32, 890.64, 899.24, 894.92, 880.61, 872.25, 888.56, 859.97, 886.06, 872.27, 878.29, 872.17, 885.96, 881.40, 867.29)
2025-08-15 03:51:49 Algo cn-pico/tlo (cpu*4^16) hashrate: 12237.83 H/s (773.17, 769.78, 759.94, 749.92, 768.14, 761.09, 758.57, 762.25, 770.28, 764.55, 752.19, 779.36, 756.87, 760.51, 766.42, 784.78)
2025-08-15 03:52:50 Algo cn/0 (cpu^8) hashrate: 552.70 H/s (65.95, 71.43, 66.16, 71.61, 70.90, 68.07, 67.75, 70.83)
2025-08-15 03:53:50 Algo cn/1 (cpu^8) hashrate: 547.37 H/s (70.19, 65.30, 70.80, 67.18, 69.32, 68.25, 65.49, 70.83)
2025-08-15 03:54:51 Algo cn/2 (cpu^8) hashrate: 562.88 H/s (72.04, 72.24, 67.82, 71.80, 69.69, 69.27, 67.98, 72.06)
2025-08-15 03:55:51 Algo cn/ccx (cpu^8) hashrate: 1057.28 H/s (135.47, 129.78, 126.85, 130.49, 136.61, 135.97, 135.51, 126.61)
2025-08-15 03:56:52 Algo cn/double (cpu^8) hashrate: 286.13 H/s (34.59, 34.58, 36.49, 36.58, 36.69, 36.56, 35.40, 35.23)
2025-08-15 03:57:52 Algo cn/fast (cpu^8) hashrate: 1060.85 H/s (137.29, 136.88, 135.61, 130.92, 135.83, 127.20, 130.08, 127.05)
2025-08-15 03:59:02 Algo cn/gpu (gpu1*960) hashrate: 1534.72 H/s (1534.72)
2025-08-15 04:00:03 Algo cn/half (cpu^8) hashrate: 1135.69 H/s (144.96, 145.51, 137.17, 137.28, 140.94, 145.08, 140.29, 144.46)
2025-08-15 04:01:03 Algo cn/r (cpu^8) hashrate: 536.36 H/s (68.62, 64.94, 64.92, 68.66, 66.35, 68.37, 66.14, 68.36)
2025-08-15 04:02:04 Algo cn/rto (cpu^8) hashrate: 544.27 H/s (67.14, 69.54, 66.77, 70.39, 65.40, 64.95, 69.71, 70.37)
2025-08-15 04:03:04 Algo cn/rwz (cpu^8) hashrate: 742.84 H/s (95.29, 92.03, 91.31, 95.39, 89.89, 89.44, 94.66, 94.83)
2025-08-15 04:04:05 Algo cn/upx2 (cpu*5^16) hashrate: 52512.82 H/s (3241.56, 3279.40, 3295.67, 3267.39, 3304.94, 3272.01, 3290.18, 3288.78, 3265.41, 3306.45, 3336.22, 3263.84, 3284.29, 3254.89, 3265.62, 3296.17)
2025-08-15 04:05:05 Algo cn/xao (cpu^8) hashrate: 280.80 H/s (34.37, 36.08, 34.49, 33.53, 36.35, 36.39, 33.62, 35.98)
2025-08-15 04:06:06 Algo cn/zls (cpu^8) hashrate: 743.14 H/s (95.13, 94.86, 89.86, 95.31, 91.27, 89.70, 95.10, 91.92)
2025-08-15 04:07:07 Algo ghostrider (cpu*8^8) hashrate: 1464.00 H/s (176.21, 180.31, 180.88, 188.35, 186.62, 176.59, 188.18, 186.85)
2025-08-15 04:08:10 Algo rx/0 (cpu*8) hashrate: 5428.60 H/s (5428.60)
2025-08-15 04:09:14 Algo rx/arq (cpu*16) hashrate: 37529.00 H/s (37529.00)
2025-08-15 04:10:17 Algo rx/graft (cpu*8) hashrate: 5246.12 H/s (5246.12)
2025-08-15 04:11:20 Algo rx/sfx (cpu*8) hashrate: 5405.56 H/s (5405.56)
2025-08-15 04:12:24 Algo rx/wow (cpu*16) hashrate: 7391.83 H/s (7391.83)
2025-08-15 04:13:27 Algo rx/yada (cpu*8) hashrate: 5408.39 H/s (5408.39)
2025-08-15 04:13:27 Saving config file to config.json
2025-08-15 04:13:27 Connecting to primary gulf.moneroocean.stream:20001tls pool
2025-08-15 04:13:27 Got new rx/0 algo job with 10000 diff and 3478192 height
2025-08-15 04:13:35 Share accepted by the pool (1/0)
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
./r.sh node moner.js test cn/gpu e55cb23e51649a59b127b96b515f2bf7bfea199741a0216cf838ded06eff82df --job '{"algo":"cn/gpu","dev":"gpu1*8"}'
./r.sh node moner.js bench cn/gpu --job '{"algo":"cn/gpu","dev":"gpu1z*960"}'
```

Enable huge pages for better performance (check [Huge Pages](https://xmrig.com/docs/miner/hugepages)):

```
sudo sysctl -w vm.nr_hugepages=1280
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"
```
