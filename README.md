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
sha256:b8ac981ff2b434ed865803c4fdb94b21412e0cc6b28fbe53f4a675972b544e46
gpu1: Intel(R) oneAPI Unified Runtime over Level-Zero
gpu1o: Intel(R) OpenCL Graphics
gpu1z: Intel(R) oneAPI Unified Runtime over Level-Zero
2025-07-11 20:05:01 Doing algo benchmarks...
2025-07-11 20:06:02 Algo argon2/chukwa (cpu^16) hashrate: 48180.51 H/s (3014.02, 3014.57, 3019.40, 3005.85, 3024.02, 3012.45, 3008.18, 3007.95, 3002.12, 3009.57, 3003.85, 3012.78, 3009.47, 3006.28, 3013.23, 3016.78)
2025-07-11 20:07:02 Algo argon2/chukwav2 (cpu^16) hashrate: 16246.31 H/s (1012.66, 1012.00, 1010.58, 1015.85, 1020.10, 1017.45, 1017.15, 1016.70, 1012.07, 1012.62, 1018.18, 1014.82, 1015.86, 1018.63, 1018.21, 1013.43)
2025-07-11 20:08:02 Algo argon2/wrkz (cpu^16) hashrate: 74287.22 H/s (4639.26, 4654.59, 4635.51, 4638.09, 4641.27, 4653.01, 4645.34, 4640.42, 4644.26, 4637.92, 4649.18, 4625.92, 4660.26, 4643.09, 4639.59, 4639.51)
2025-07-11 20:09:03 Algo cn-heavy/0 (cpu^4) hashrate: 343.57 H/s (86.97, 86.31, 86.96, 83.33)
2025-07-11 20:10:03 Algo cn-heavy/tube (cpu^4) hashrate: 302.73 H/s (76.84, 73.61, 74.13, 78.15)
2025-07-11 20:11:04 Algo cn-heavy/xhv (cpu^4) hashrate: 345.60 H/s (84.60, 86.23, 87.10, 87.67)
2025-07-11 20:12:04 Algo cn-lite/0 (cpu^16) hashrate: 2334.52 H/s (148.84, 143.99, 143.92, 141.07, 149.94, 148.93, 149.25, 140.86, 150.04, 148.94, 149.64, 144.04, 140.94, 144.19, 148.89, 141.04)
2025-07-11 20:13:05 Algo cn-lite/1 (cpu^16) hashrate: 2292.67 H/s (147.39, 141.17, 138.55, 146.22, 146.88, 146.27, 138.19, 141.74, 141.49, 146.11, 147.55, 141.36, 146.91, 138.65, 146.02, 138.18)
2025-07-11 20:14:05 Algo cn-pico/0 (cpu*4^16) hashrate: 14640.01 H/s (905.02, 925.06, 923.32, 912.29, 902.37, 902.97, 924.24, 911.79, 912.15, 922.30, 922.28, 902.85, 921.99, 911.82, 921.30, 918.28)
2025-07-11 20:15:05 Algo cn-pico/tlo (cpu*4^16) hashrate: 12989.29 H/s (817.90, 821.81, 817.86, 808.69, 804.34, 813.40, 805.91, 807.39, 803.05, 815.36, 807.72, 810.25, 815.03, 820.96, 816.75, 802.85)
2025-07-11 20:16:06 Algo cn/0 (cpu^8) hashrate: 617.94 H/s (79.65, 78.85, 74.16, 74.28, 79.44, 76.33, 79.06, 76.17)
2025-07-11 20:17:06 Algo cn/1 (cpu^8) hashrate: 615.30 H/s (73.96, 79.19, 75.97, 78.62, 79.28, 75.80, 73.82, 78.66)
2025-07-11 20:18:07 Algo cn/2 (cpu^8) hashrate: 620.71 H/s (79.12, 76.77, 79.19, 76.72, 79.31, 75.22, 79.03, 75.35)
2025-07-11 20:19:07 Algo cn/ccx (cpu^8) hashrate: 1186.97 H/s (152.67, 146.56, 152.57, 151.65, 146.56, 142.90, 151.31, 142.75)
2025-07-11 20:20:08 Algo cn/double (cpu^8) hashrate: 313.52 H/s (38.51, 40.02, 40.02, 40.07, 40.03, 38.80, 38.01, 38.07)
2025-07-11 20:21:08 Algo cn/fast (cpu^8) hashrate: 1197.43 H/s (154.11, 147.73, 143.91, 147.84, 152.85, 152.96, 154.00, 144.03)
2025-07-11 20:22:19 Algo cn/gpu (gpu1z*960) hashrate: 1550.99 H/s (1550.99)
2025-07-11 20:23:19 Algo cn/half (cpu^8) hashrate: 1239.72 H/s (157.74, 153.53, 150.55, 150.41, 158.33, 157.84, 158.09, 153.23)
2025-07-11 20:24:19 Algo cn/r (cpu^8) hashrate: 590.93 H/s (71.82, 75.23, 73.11, 73.10, 75.39, 75.17, 75.36, 71.75)
2025-07-11 20:25:20 Algo cn/rto (cpu^8) hashrate: 614.26 H/s (75.83, 78.40, 79.06, 79.08, 73.78, 75.69, 78.51, 73.90)
2025-07-11 20:26:20 Algo cn/rwz (cpu^8) hashrate: 819.11 H/s (104.41, 101.13, 99.50, 99.39, 104.65, 104.50, 101.36, 104.15)
2025-07-11 20:27:21 Algo cn/upx2 (cpu*5^16) hashrate: 54205.49 H/s (3397.05, 3370.66, 3377.60, 3377.44, 3418.37, 3396.88, 3385.61, 3394.32, 3384.77, 3411.82, 3366.88, 3391.99, 3405.21, 3367.11, 3374.05, 3385.72)
2025-07-11 20:28:21 Algo cn/xao (cpu^8) hashrate: 314.15 H/s (40.44, 38.76, 37.73, 40.12, 40.45, 38.75, 40.16, 37.75)
2025-07-11 20:29:22 Algo cn/zls (cpu^8) hashrate: 818.64 H/s (104.24, 99.36, 101.22, 101.22, 104.27, 99.24, 104.57, 104.53)
2025-07-11 20:30:23 Algo ghostrider (cpu*8^8) hashrate: 1601.99 H/s (197.87, 204.16, 205.16, 205.14, 197.94, 193.81, 204.16, 193.75)
2025-07-11 20:31:26 Algo rx/0 (cpu*8) hashrate: 5918.59 H/s (5918.59)
2025-07-11 20:32:29 Algo rx/arq (cpu*16) hashrate: 39219.83 H/s (39219.83)
2025-07-11 20:33:32 Algo rx/graft (cpu*8) hashrate: 5721.90 H/s (5721.90)
2025-07-11 20:34:35 Algo rx/sfx (cpu*8) hashrate: 5926.25 H/s (5926.25)
2025-07-11 20:35:39 Algo rx/wow (cpu*16) hashrate: 7916.50 H/s (7916.50)
2025-07-11 20:36:42 Algo rx/yada (cpu*8) hashrate: 5928.08 H/s (5928.08)
2025-07-11 20:36:42 Saving config file to config.json
2025-07-11 20:43:41 Connecting to primary gulf.moneroocean.stream:20001tls pool
2025-07-11 20:43:41 Got new rx/0 algo job with 10000 diff
2025-07-11 20:43:45 Share accepted by the pool (1/0)
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
