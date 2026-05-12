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

Miner mominer.node dynamic library can be compiled and run from sources using `./r.sh` script that
will build Docker container with SYCL compiler. Docker buildx is required so builds use BuildKit
instead of Docker's deprecated legacy builder:

```
git clone https://github.com/MoneroOcean/mominer.git
cd mominer
./r.sh
```

Install buildx from Docker packages when available:

```
sudo apt-get update
sudo apt-get install docker-buildx-plugin
docker buildx version
```

If your distribution does not package it, install the Docker CLI plugin manually from the
[Docker buildx releases](https://github.com/docker/buildx/releases):

```
mkdir -p ~/.docker/cli-plugins
curl -fsSL https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
docker buildx version
```

Tagged GitHub releases build an x86-64 Linux `.tgz` archive with precompiled `mominer.node` and SYCL
libraries. Use the archive `docker-mominer.sh` script to run miner inside docker container with
Intel Level-Zero/OpenCL runtimes. The release archive runner can use buildx when it is installed,
but still falls back to plain `docker build` for systems without buildx.

# Usage example

On Linux system with docker installed if you run miner like that for the first time it will
benchmarks all supported algos and will start mining (this is perf numbers for Intel i7-11700K CPU
and Intel Arc B580 GPU):

```
$ ./docker-mominer.sh mine gulf.moneroocean.stream:20001tls 89TxfrUmqJJcb1V124WsUzA78Xa3UYHt7Bg8RGMhXVeZYPN8cE5CZEk58Y1m23ZMLHN7wYeJ9da5n5MXharEjrm41hSnWHL --save_config config.json
cpu1: Intel(R) OpenCL
gpu1: Intel(R) oneAPI Unified Runtime over Level-Zero
gpu1o: Intel(R) OpenCL Graphics
gpu1z: Intel(R) oneAPI Unified Runtime over Level-Zero
2026-05-12 01:51:55 Doing algo benchmarks...
2026-05-12 01:52:55 Algo argon2/chukwa (cpu^16) hashrate: 48873.55 H/s (3038.78, 3050.13, 3062.85, 3063.01, 3056.12, 3054.40, 3061.78, 3066.45, 3054.90, 3034.18, 3056.45, 3053.28, 3055.12, 3063.13, 3051.35, 3051.63)
2026-05-12 01:53:55 Algo argon2/chukwav2 (cpu^16) hashrate: 16244.29 H/s (1012.50, 1018.73, 1017.05, 1015.63, 1017.08, 1015.82, 1016.51, 1017.83, 1017.83, 1013.73, 1017.32, 1012.18, 1006.78, 1012.86, 1019.27, 1013.16)
2026-05-12 01:54:56 Algo argon2/wrkz (cpu^16) hashrate: 73383.85 H/s (4592.18, 4591.51, 4581.42, 4595.35, 4581.18, 4541.18, 4594.68, 4603.59, 4545.68, 4594.01, 4597.09, 4590.26, 4598.68, 4585.51, 4593.42, 4598.09)
2026-05-12 01:56:13 Algo c29 (gpu1*1) hashrate: 0.79 H/s (0.79)
2026-05-12 01:57:14 Algo cn-heavy/0 (cpu^4) hashrate: 344.47 H/s (84.17, 88.49, 82.65, 89.17)
2026-05-12 01:58:14 Algo cn-heavy/tube (cpu^4) hashrate: 300.05 H/s (72.38, 76.19, 76.92, 74.56)
2026-05-12 01:59:15 Algo cn-heavy/xhv (cpu^4) hashrate: 341.59 H/s (84.15, 87.28, 87.61, 82.56)
2026-05-12 02:00:15 Algo cn-lite/0 (cpu^16) hashrate: 2341.45 H/s (150.00, 144.79, 149.81, 150.85, 148.32, 140.75, 141.62, 144.62, 141.76, 149.90, 150.69, 149.67, 140.58, 144.66, 144.77, 148.66)
2026-05-12 02:01:15 Algo cn-lite/1 (cpu^16) hashrate: 2300.16 H/s (147.33, 146.74, 147.65, 147.66, 141.92, 138.58, 138.61, 147.15, 142.07, 141.94, 141.97, 146.92, 138.71, 147.68, 138.58, 146.65)
2026-05-12 02:02:16 Algo cn-pico/0 (cpu*4^16) hashrate: 14740.56 H/s (929.26, 931.70, 927.80, 916.06, 909.88, 916.86, 910.27, 929.72, 910.53, 910.09, 916.61, 915.89, 928.50, 929.58, 927.24, 930.57)
2026-05-12 02:03:16 Algo cn-pico/tlo (cpu*4^16) hashrate: 13129.50 H/s (818.56, 828.84, 815.35, 828.20, 828.60, 809.06, 825.21, 816.49, 809.51, 825.28, 825.33, 819.16, 819.78, 827.72, 819.40, 813.02)
2026-05-12 02:04:17 Algo cn/0 (cpu^8) hashrate: 621.99 H/s (76.68, 79.47, 76.18, 80.13, 74.74, 75.26, 79.46, 80.08)
2026-05-12 02:05:17 Algo cn/1 (cpu^8) hashrate: 615.26 H/s (73.96, 78.56, 75.85, 78.61, 79.24, 73.93, 75.92, 79.20)
2026-05-12 02:06:18 Algo cn/2 (cpu^8) hashrate: 624.52 H/s (79.58, 77.19, 79.78, 79.78, 75.68, 75.73, 79.58, 77.20)
2026-05-12 02:07:18 Algo cn/ccx (cpu^8) hashrate: 1196.26 H/s (153.93, 147.60, 147.64, 143.66, 153.82, 152.80, 152.83, 143.98)
2026-05-12 02:08:19 Algo cn/double (cpu^8) hashrate: 315.33 H/s (38.99, 38.26, 40.26, 40.17, 38.21, 39.00, 40.18, 40.27)
2026-05-12 02:09:19 Algo cn/fast (cpu^8) hashrate: 1181.92 H/s (150.40, 146.11, 146.15, 142.33, 150.30, 152.37, 142.49, 151.77)
2026-05-12 02:10:27 Algo cn/gpu (gpu1*960) hashrate: 2166.17 H/s (2166.17)
2026-05-12 02:11:28 Algo cn/half (cpu^8) hashrate: 1239.18 H/s (157.76, 153.31, 150.39, 153.19, 150.16, 157.82, 158.21, 158.33)
2026-05-12 02:12:28 Algo cn/r (cpu^8) hashrate: 590.76 H/s (75.32, 73.10, 73.13, 75.18, 75.37, 71.70, 75.20, 71.76)
2026-05-12 02:13:29 Algo cn/rto (cpu^8) hashrate: 614.79 H/s (79.05, 75.84, 78.51, 73.96, 75.80, 79.12, 78.61, 73.90)
2026-05-12 02:14:29 Algo cn/rwz (cpu^8) hashrate: 819.80 H/s (101.38, 104.42, 104.64, 99.44, 104.45, 101.42, 104.69, 99.37)
2026-05-12 02:15:29 Algo cn/upx2 (cpu*5^16) hashrate: 54452.50 H/s (3431.32, 3402.33, 3438.88, 3419.15, 3417.54, 3393.71, 3395.15, 3421.99, 3418.31, 3379.49, 3429.60, 3379.38, 3390.55, 3396.33, 3362.00, 3376.77)
2026-05-12 02:16:30 Algo cn/xao (cpu^8) hashrate: 312.39 H/s (37.44, 37.44, 40.17, 39.97, 39.96, 38.51, 40.36, 38.55)
2026-05-12 02:17:31 Algo cn/zls (cpu^8) hashrate: 815.56 H/s (104.22, 98.62, 98.67, 104.08, 103.95, 104.13, 100.97, 100.91)
2026-05-12 02:18:32 Algo ghostrider (cpu*8^8) hashrate: 1598.76 H/s (193.40, 203.73, 204.88, 204.71, 203.74, 197.47, 197.43, 193.40)
2026-05-12 02:19:35 Algo rx/0 (cpu*8) hashrate: 5932.17 H/s (5932.17)
2026-05-12 02:20:38 Algo rx/2 (cpu*8) hashrate: 5044.80 H/s (5044.80)
2026-05-12 02:21:41 Algo rx/arq (cpu*16) hashrate: 39165.02 H/s (39165.02)
2026-05-12 02:22:44 Algo rx/graft (cpu*8) hashrate: 5739.84 H/s (5739.84)
2026-05-12 02:23:48 Algo rx/sfx (cpu*8) hashrate: 5885.49 H/s (5885.49)
2026-05-12 02:24:51 Algo rx/wow (cpu*16) hashrate: 7855.22 H/s (7855.22)
2026-05-12 02:25:54 Algo rx/yada (cpu*8) hashrate: 5894.25 H/s (5894.25)
2026-05-12 02:25:54 Saving config file to config.json
2026-05-12 02:25:54 Connecting to primary gulf.moneroocean.stream:20001tls pool
2026-05-12 02:25:55 Got new c29 algo job with 1 diff and 262361 height
2026-05-12 02:26:44 Got new c29 algo job with 1 diff and 262362 height
2026-05-12 02:27:12 Algo c29 (gpu1*1) hashrate: 0.78 H/s (0.78)
2026-05-12 02:27:18 Share accepted by the pool (1/0)
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

Project test suites are npm entry points:

```
npm test
npm run test:perf
npm run test:perf:ghostrider
```

`npm test` runs the hash-vector suite under Docker and skips GPU cases when no GPU device is
available. `npm run test:perf` benchmarks every supported algo with mominer's detected mining
device config and prints each hashrate in the same test reporter output. Individual benchmark entry points are available as
`npm run test:perf:<algo>`, for example `npm run test:perf:rx/0`,
`npm run test:perf:cn-heavy/tube`, or `npm run test:perf:c29`.

Enable huge pages for better performance (check [Huge Pages](https://xmrig.com/docs/miner/hugepages)):

```
sudo sysctl -w vm.nr_hugepages=1280
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"
```

For repeatable RandomX performance tests, make sure other services are not consuming huge pages or
CPU. A local `monerod` can reserve hugetlb pages and lower `rx/0` hashrate; stop it before perf
tests, or increase `vm.nr_hugepages` enough for both processes. On systems that run it as
`xmr.service`:

```
sudo systemctl stop xmr.service
npm run test:perf:rx/0
sudo systemctl start xmr.service
```

# License

MoMiner is licensed under [GPL-3.0-or-later](LICENSE).
