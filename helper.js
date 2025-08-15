// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

"use strict";

const path    = require("path");
const events  = require("events");
const cluster = require("cluster");
const fs      = require('fs');

const thread_id = cluster.isMaster ? "master" : parseInt(process.env["thread_id"]);
let worker_ids = []; // active worker ids (cluster.workers can contain not yet closed workers)

function log_str(str) {
  return (new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')) + " " + str;
}

module.exports.log = function(str) {
  console.log(log_str(global.opt.log_level >= 1 ? "[0] " + str : str));
};

module.exports.log1 = function(str) {
  if (global.opt.log_level >= 1) console.log(log_str("[1] " + str));
};

module.exports.log2 = function(str) {
  if (global.opt.log_level >= 2) console.log(log_str("[2] " + str));
};

module.exports.log3 = function(str) {
  if (global.opt.log_level >= 3) console.log(log_str("[3] " + str));
};

module.exports.log_err = function(str) {
  console.error(log_str("ERROR: " + str));
};

module.exports.create_core = function() {
  this.log3("Starting compute core in " + thread_id + " thread");
  const deploy_path = path.join(__dirname, "./moner.node");
  const core_path   = fs.existsSync(deploy_path) ? deploy_path :
                      path.join(__dirname, "/build/Release/moner.node");
  const core_module = require(core_path);
  let emitter = new events();
  let worker = new core_module.AsyncWorker(
    function(name, value) {
      module.exports.log3("Getting from compute core " + thread_id + " " + name + " message: " +
                          JSON.stringify(value));
      emitter.emit(name, value);
    },
    function ()     { emitter.emit("close"); },
    function(error) { emitter.emit("error", error); },
    {} // no extra options
  );
  return {
    from:    emitter,
    emit_to: function(name, data) {
      module.exports.log3("Sending to compute core " + thread_id + " " + name + " message: " +
                          JSON.stringify(data));
      worker.sendToCpp(name, data ? data : {});
    }
  };
};

module.exports.cluster_process = function() {
  if (cluster.isMaster) return false;

  // process worker thread env vars
  global.opt = { log_level: parseInt(process.env["log_level"]) };

  let compute_core = this.create_core();

  // send message from worker thread to master thread
  function send_msg(type, value) {
    return process.send({type: type, value: value, thread_id: thread_id});
  }
  compute_core.from.on("test",        function(v) { send_msg("test", v); });
  compute_core.from.on("last_nonce",  function(v) { send_msg("last_nonce", v); });
  compute_core.from.on("result",      function(v) { send_msg("result", v); });
  compute_core.from.on("hashrate",    function(v) { send_msg("hashrate", v); });
  compute_core.from.on("algo_params", function(v) { send_msg("algo_params", v); });
  compute_core.from.on("error",       function(v) { send_msg("error", v); });
  compute_core.from.on("close",       function()  { process.exit(0); });

  // process messages from the master thread
  process.on("message", function(msg) {
    switch (msg.type) {
      case "job": case "bench": case "test":
        // find dev for this specific thread from msg.job.dev list
        msg.job.dev = module.exports.get_thread_dev(thread_id, msg.job.dev);
        msg.job.thread_id = thread_id;
        compute_core.emit_to(msg.type, msg.job);
        break;
      case "pause": case "close":
        compute_core.emit_to(msg.type);
        break;
      default: this.log_err("Unknown thread message");
    }
  });

  return true;
};


// get thread dev stripping ^thread specification from it
module.exports.get_thread_dev = function(thread_id, devs) {
  const dev_parts = devs.split(",");
  let thread_count = 0;
  for (const dev_part of dev_parts) {
    const m = dev_part.match(/^([^\^]+)\^(\d+)$/);
    thread_count += m ? parseInt(m[2]) : 1;
    if (thread_id < thread_count) return m ? m[1] : dev_part;
  }
  this.log_err("Can't find " + thread_id + " thread device in " + devs + " specification");
  return null;
};

// return number of ^threads in dev specification
module.exports.get_dev_threads = function(dev) {
  const dev_parts = dev.split(",");
  let thread_count = 0;
  for (const dev_part of dev_parts) {
    const m = dev_part.match(/\^(\d+)$/);
    thread_count += m ? parseInt(m[1]) : 1;
  }
  return thread_count;
};

// return dev *batch value
module.exports.get_dev_batch = function(dev) {
  const m = dev.match(/\*(\d+)$/);
  return m ? parseInt(m[1]) : 1;
};

module.exports.messageWorkers = function(msg) {
  for (const worker_id of worker_ids) if (cluster.workers[worker_id]) cluster.workers[worker_id].send(msg);
};

// map 0..N-1 thread IDs into worker.id (that might be not sequential)
// need to recreate threads from 0 for every algo change since huge memory reallocations
// can have issues
module.exports.recreate_threads = function(dev, messageHandler) {
  module.exports.messageWorkers({type: "close"});
  //for (const thread of Object.values(thread_id_map)) cluster.workers[thread].kill();
  worker_ids = [];
  const curr_thread_count = this.get_dev_threads(dev);
  for (let i = 0; i < curr_thread_count; ++ i) {
    let thread = cluster.fork({thread_id: i, log_level: global.opt.log_level});
    thread.on("message", messageHandler);
    worker_ids.push(thread.id);
  }
};

// repeat while cb_next is called returns true result with ms delay
module.exports.repeat = function(cb_next, delay) {
  cb_next(function() {
    if (delay) setTimeout(repeat, delay, cb_next, delay);
    else return module.exports.repeat(cb_next, delay);
  });
};

// pack opt.default_msrs to it can be more easily passed into compute core
module.exports.pack_msr = function(default_msr) {
  let packed = {};
  for (const [key, val] of Object.entries(default_msr)) {
    packed["msr:" + key] = val.value + "," + val.mask;
  }
  return packed;
};

module.exports.unpack_msr = function(default_msr) {
  let unpacked = {};
  for (const [key, val] of Object.entries(default_msr)) {
    if (!key.startsWith("msr:0x")) continue;
    const parts = val.split(",");
    if (parts.length !== 2) continue;
    unpacked[key.substring(4)] = { value: parts[0], mask: parts[1] };
  }
  return unpacked;
};

module.exports.target2diff = function(target) {
  if (target.length === 8) target = "00000000" + target;
  // need BE -> LE conversion here
  const div = BigInt("0x" + target.match(/.{2}/g).reverse().join(""));
  if (div === BigInt(0)) return 0;
  return BigInt("0xFFFFFFFFFFFFFFFF") / div;
};

module.exports.diff2target = function(diff) {
  if (diff === 0n) return "0000000000000000";
  // Reverse of: div = BigInt(0xFFFFFFFFFFFFFFFF) / diff
  let div = BigInt("0xFFFFFFFFFFFFFFFF") / BigInt(diff);
  // Convert to hex without `0x`
  let hexLE = div.toString(16).padStart(16, "0");
  // Reverse LE -> BE
  let hexBE = hexLE.match(/.{2}/g).reverse().join("");
  // If 8-byte (16 hex chars), remove leading zeros to match original style
  if (hexBE.startsWith("00000000")) {
    hexBE = hexBE.slice(8);
  }
  return hexBE;
};

module.exports.edge_hex2arr = function(hex) {
  const pow = [];
  const size = 8; // 8 hex chars per uint32_t
  for (let i = 0; i < hex.length; i += size) {
    const hex1 = hex.slice(i, i + size);
    pow.push(parseInt(hex1, 16)); // to decimal integer
  }
  return pow;
}
