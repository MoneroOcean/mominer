// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

#pragma once

#include <map>
#include <set>

std::map<std::string, std::string> algo_params(
  unsigned max_cpu_batch, unsigned cpu_sockets, unsigned cpu_threads, unsigned cpu_l3cache,
  const std::map<std::string, unsigned>& algo2mem,
  const std::set<std::string>& cpu_algos,
  const std::set<std::string>& gpu_cn_algos,
  const std::set<std::string>& gpu_c29_algos
);

void cn_gpu(
  const uint8_t* inputs, unsigned input_size, uint8_t* output,
  void* Spads, unsigned batch, const std::string& dev_str
);

int c29(
  unsigned job_id, unsigned c29_proof_size,
  const uint8_t* inputs, unsigned input_size, uint8_t* output,
  uint32_t* output_edges, uint64_t* pnonce, const std::string& dev_str
);
