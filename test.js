// Copyright GNU GPLv3 (c) 2023-2023 MoneroOcean <support@moneroocean.stream>

"use strict";

const child_process = require("child_process");

function test(job, result, cb) {
  if (!("dev" in job)) job.dev = "cpu";
  const cmd = "node moner.js test " + job.algo + " " + result + " --job '" +
              JSON.stringify(job) + "'";

  let output = "";
  const fail = function(message) {
    console.log("FAILED: " + job.dev + " " + job.algo + ": ");
    console.log("$ " + cmd);
    console.log(message);
    console.log(output);
    return cb(false);
  };

  let test_process = null;
  let timeout = setTimeout(function() {
    if (!test_process) return; // already failed or passed before
    test_process.kill();
    test_process = null;
    return fail("Timeouted");
  }, 5*60*1000);

  test_process = child_process.exec(cmd);
  test_process.stdout.on('data', function(data) { output += data; });
  test_process.stderr.on('data', function(data) { output += data; });
  test_process.on('exit', function(code) {
    if (!test_process) return; // already failed or passed before
    clearTimeout(timeout);
    test_process = null;
    if (code) {
      return fail("Non zero exit code: " + code);
    } else if (!output.includes("PASSED") || output.includes("FAIL")) {
      return fail("No PASSED in the test output:");
    } else {
      console.log("PASSED: " + job.dev + " " + job.algo);
      return cb(true);
    }
  });
  test_process.on('error', function(err) {
    if (!test_process) return; // already failed or passed before
    clearTimeout(timeout);
    test_process = null;
    return fail("Error: " + err);
  });
}

function test_gpu(job, result, cb) {
  job.dev = "gpu1*8";
  test(job, result, cb);
}

let tests = [
  [ test, { algo: "rx/0", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "38f638606c730dd6f271d037556b83988c71acc6980e22e25271b22389ecfce6"
  ], [ test, { algo: "rx/wow", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "15c9bd99b3180ab256e89beecaf7b693abb7cdb0d1dfe30020c72f0c70b904ce"
  ], [ test, { algo: "rx/arq", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "8b9937420651309742f833333371a8ab4d04e5f06d4b3d0a2dbec1b381e9a0e5"
  ], [ test, { algo: "rx/graft", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "08135aaeb098d86f269d0a037aba423093e4c48e9e31f16c13d2ed3dc4489ba7"
  ], [ test, { algo: "rx/sfx", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "19e786570a6d959f023cb77b0be5bede76cc4a5c61c090b3d24c5ebd2c9ecb27"
  ], [ test, { algo: "rx/keva", dev: "cpu*2", blob_hex: "5468697320697320612074657374" },
    "745ac75a1d5d044ebd5cbc97269c1f75b1bfeb6ce2df4ed700be898356a879df"
  ], [ test, { algo: "ghostrider", dev: "cpu*8",
            blob_hex: "000000208c246d0b90c3b389c4086e8b672ee040" +
                      "d64db5b9648527133e217fbfa48da64c0f3c0a0b" +
                      "0e8350800568b40fbb323ac3ccdf2965de51b9aa" +
                      "eb939b4f11ff81c49b74a16156ff251c00000000" },
    "84402e62b6bedafcd65f6ba13b59ff19ad7f273900c59fa49bfbb5f67e10030f"
  ], [ test, { algo: "argon2/chukwa" },
    "c158a105ae75c7561cfd029083a47a87653d51f914128e21c1971d8b10c49034"
  ], [ test, { algo: "argon2/chukwav2" },
    "77cf6958b3536e1f9f0d1ea165f22811ca7bc487ea9f52030b5050c17fcdd8f5"
  ], [ test, { algo: "argon2/wrkz" },
    "35e083d4b9c64c2a68820a431f61311998a8cd1864dba4077e25b7f121d54bd1"
  ], [ test, { algo: "cn/0" },
    "1a3ffbee909b420d91f7be6e5fb56db71b3110d886011e877ee5786afd080100"
  ], [ test, { algo: "cn/1" },
    "f22d3d6203d2a08b41d9027278d8bcc983acada9b68e52e3c689692a50e921d9"
  ], [ test, { algo: "cn/2" },
    "97378282cf10e7ad033f7b8074c40e14d06e7f609dddda787680b58c05f43d21"
  ], [ test, { algo: "cn/r", height: 1806260,
               blob_hex: "54686973206973206120746573742054686973206973" +
                         "20612074657374205468697320697320612074657374" },
    "f759588ad57e758467295443a9bd71490abff8e9dad1b95b6bf2f5d0d78387bc"
  ], [ test, { algo: "cn/fast" },
    "3c7a61084c5eb865b498ab2f5a1ac52c49c177c2d0133442d65ed514335c82c5"
  ], [ test, { algo: "cn/half" },
    "5d4fbc356097ea6440b0888edeb635ddc84a0e397c868456895c3f29be7312a7"
  ], [ test, { algo: "cn/xao" },
    "9a29d0c4afdc639b6553b1c83735114c5d77162142975cb850c0a51f6407bd33"
  ], [ test, { algo: "cn/rto" },
    "82661e1c6e6436668406327a9bb11319a5561615dfec1c9ee3884a6c1ceb76a5"
  ], [ test, { algo: "cn/rwz" },
    "5f56c6b0996ba23e0bba0729c99074855a10e3087fdbfe947533547376f075b8"
  ], [ test, { algo: "cn/zls" },
    "516e33c6e446abbccdad18c04cd9a25e64102853b20a42dfdeaa8b599ecf40e2"
  ], [ test, { algo: "cn/double" },
    "aefbb3f0cc88046d119f6c54b96d90c9e884ea3b5983a60d50a42d7d3ebe4821"
  ], [ test, { algo: "cn/ccx" },
    "b3a16786d2c985ecadc45f910527c7a196f0e1e97c8709381d7d419335f81672"
  ], [ test, { algo: "cn/upx2" },
    "aabbb8ed14a835fa22cfb1b5dea872b0a1d6cbd846f4391c0f01f3875e3a3761"
  ], [ test, { algo: "cn-pico/0" },
    "08f421d7833117300eda66e98f4a2569093df300500173944efc401e9a4a17af"
  ], [ test, { algo: "cn-pico/tlo" },
    "9975f2c1b3b45434a49386213097f31bb4b9a6586a7e81f4429f6d5f65c38d1a"
  ], [ test, { algo: "cn-lite/0" },
    "3695b4b53bb00358b0ad38dc160feb9e004eece09b83a72ef6ba9864d3510c88"
  ], [ test, { algo: "cn-lite/1" },
    "6d8cdc444e9bbbfd68fc43fcd4855b228c8a1bd91d9d00285bec02b7ca2d6741"
  ], [ test, { algo: "cn-heavy/0" },
    "9983f21bdf2010a8d707bb2f14d78664bbe1187f55014b39e5f3d69328e48fc2"
  ], [ test, { algo: "cn-heavy/xhv" },
    "5ac3f785c490c58550ec95d2726563577e7c1c212d0cde591273201e44fdd5b6"
  ], [ test, { algo: "cn-heavy/tube" },
    "fe53352076eae689fa3b4fda614634cfc312ee0c387df2b8b74da2a159741235"
  ], [ test_gpu, { algo: "cn/gpu" },
    "e55cb23e51649a59b127b96b515f2bf7bfea199741a0216cf838ded06eff82df"
  ],
];

// repeat while cb_next is called returns true result with ms delay
function repeat(cb_next, delay) {
  cb_next(function() {
    if (delay) setTimeout(repeat, delay, cb_next, delay);
    else return repeat(cb_next, delay);
  });
};

let test_count = 0;
let fail_count = 0;

// do opt.algo_params benchmarks if perf === null
repeat(function(cb_next) {
  let test = tests.shift();
  if (test) {
    ++ test_count;
    test[0](test[1], test[2], function(result) {
      if (!result) ++ fail_count;
      return cb_next();
    });
  } else {
    console.log(fail_count ? "FAILED (" + fail_count + " of " + test_count + " tests)" :
                             "PASSED (" + test_count + " tests)");
    process.exit(fail_count ? 1 : 0);
  }
});

