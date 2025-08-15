// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

#pragma once

#include <map>
#include <set>

std::map<std::string, std::string> algo_params(
  unsigned max_cpu_batch, unsigned cpu_sockets, unsigned cpu_threads, unsigned cpu_l3cache,
  const std::map<std::string, unsigned>& algo2mem,
  const std::set<std::string>& cpu_algos,
  const std::set<std::string>& gpu_algos
);

void cn_gpu(
  uint32_t job_id, uint32_t nonce_offset,
  const uint8_t* inputs, unsigned input_size, uint8_t* output,
  void* Spads, uint32_t* pbatch, const std::string& dev_str
);

void c29s(
  uint32_t job_id, uint32_t nonce_offset,
  const uint8_t* inputs, uint32_t input_size, uint8_t* output,
  void* output_nonces, uint32_t* pbatch, const std::string& dev_str
);
