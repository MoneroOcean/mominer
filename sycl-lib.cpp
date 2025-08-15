// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

#include "sycl-lib-internal.h"
#include <list>

static std::map<std::string, sycl::device> str2dev;

static void update_str2dev(const bool verbose = false) {
  unsigned cpu_num = 0, gpu_num = 0;
  for (auto platform : sycl::platform::get_platforms()) {
    const std::string& platform_name = platform.get_info<sycl::info::platform::name>();
    for (auto device : platform.get_devices()) {
      if (device.is_cpu()) {
        str2dev[std::string("cpu") + std::to_string(++cpu_num)] = device;
      } else if (device.is_gpu()) {
        // OpenCL GPU platforms will be available but not used by default if something else is present
	const std::string gpuN = std::string("gpu") + std::to_string(++gpu_num);
	if (platform_name.find("OpenCL") != std::string::npos) {
	  str2dev[gpuN + "o"] = device;
	  if (!str2dev.contains(gpuN)) str2dev[gpuN] = device;
        } else if (platform_name.find("Level-Zero") != std::string::npos) {
          str2dev[gpuN + "z"] = device;
	  str2dev[gpuN] = device;
	} else if (verbose) std::cout << "Found unsupported " << platform_name << " GPU platform device" << std::endl;
      }
    }
    gpu_num = 0; // reset gpu counter for every platform
  }
  if (verbose) for (const auto& pair : str2dev) {
    std::cout << pair.first << ": " << pair.second.get_platform().get_info<sycl::info::platform::name>() << std::endl;
  }
}

sycl::device get_dev(const std::string& dev_str) {
  if (str2dev.empty()) update_str2dev();
  if (!str2dev.contains(dev_str)) throw std::string("Unknown compute platform " + dev_str);
  return str2dev.at(dev_str);
}

// return list of supported algos with the best device config
std::map<std::string, std::string> algo_params(
  const unsigned max_cpu_batch,
  const unsigned cpu_sockets, const unsigned cpu_threads, const unsigned cpu_l3cache,
  const std::map<std::string, unsigned>& algo2mem,
  const std::set<std::string>& cpu_algos,
  const std::set<std::string>& gpu_algos
) {
  if (str2dev.empty()) update_str2dev(true);
  std::map<std::string, std::string> result;
  std::set<std::string> algos = cpu_algos;
  algos.insert(gpu_algos.begin(), gpu_algos.end());
  for (const auto& algo : algos) {
    std::string result_dev;
    auto add_result_dev = [&](const std::string& add_str) {
      if (!result_dev.empty()) result_dev += ",";
      result_dev += add_str;
    };
    if (cpu_algos.contains(algo)) {
      if (algo2mem.contains(algo)) {
        const unsigned batch_mem = algo2mem.at(algo);
        unsigned used_l3cache = 0;
        unsigned used_threads = 0;
        std::list<unsigned> threads; // process batch numbers
        if (algo.starts_with("rx/")) {
          // for rx algos we emulate parallelism via inprocess batch threads
          // for each CPU socket we start separate process (named "threads" here)
          // normally we only want one separate process per socket
          // to reduce memory usage per process (2GB) and amount of huge pages too
          for (unsigned i = 0; i != cpu_sockets; ++i) {
            threads.push_back(std::min(cpu_threads, cpu_l3cache / batch_mem) / cpu_sockets);
          }
        } else {
          // fill threads list with single batch
          while (++used_threads <= cpu_threads && (used_l3cache += batch_mem) <= cpu_l3cache)
            threads.push_back(algo == "ghostrider" ? 8 : 1);
          if (!algo.starts_with("argon2/")) {
            // increase batch size until we hit L3 cache limit
            while (used_l3cache < cpu_l3cache) {
              bool updated = false;
              for (auto& i : threads) {
                if (i < max_cpu_batch && (used_l3cache += batch_mem) <= cpu_l3cache) {
                  ++ i;
                  updated = true;
                }
              }
              if (!updated) break; // in case we hit all max_cpu_batch and not L3 cache
            }
          }
        }
        // convert threads list into dev string
        unsigned prev_batch = 0;
        unsigned same_batch_threads = 0;
        auto add_last_dev = [&]() {
          add_result_dev("cpu" + (prev_batch != 1 ? "*" + std::to_string(prev_batch) : ""));
          if (same_batch_threads != 1) result_dev += "^" + std::to_string(same_batch_threads);
          same_batch_threads = 0;
        };
        for (auto& i : threads) {
          if (same_batch_threads && prev_batch != i) add_last_dev();
          prev_batch = i;
          ++ same_batch_threads;
        }
        add_last_dev();
      } else add_result_dev("cpu^" + std::to_string(cpu_threads)); // default fallback
    }
    if (gpu_algos.contains(algo)) {
      for (const auto& dev_pair : str2dev) {
        const std::string dev_str = dev_pair.first;
        // CPU and explicit GPU platforms are not used by default
        if (dev_str.starts_with("cpu") || dev_str.ends_with("o") || dev_str.ends_with("z"))
          continue;
	if (algo == "c29s") {
	  add_result_dev(dev_str + "*1"); // batch is not really used by this algo
	} else {
          const sycl::device& dev = dev_pair.second;
          const unsigned max_compute_units = dev.get_info<sycl::info::device::max_compute_units>();
          if (algo2mem.contains(algo)) {
            const unsigned batch_mem        = algo2mem.at(algo),
                           max_alloc_batch  = (dev.get_info<sycl::info::device::max_mem_alloc_size>()
                                              / batch_mem) & 0xFFFFFFF8,
                           max_batch        = dev.get_info<sycl::info::device::global_mem_size>()
                                              / batch_mem,
                           max_thread_batch = std::min(max_alloc_batch, max_batch),
                           best_batch       = std::min(max_compute_units * 6, max_batch);
            unsigned used_batch = 0;
            while (used_batch < best_batch) {
              const unsigned current_batch = std::min(best_batch - used_batch, max_thread_batch);
              add_result_dev(dev_str + "*" + std::to_string(current_batch));
              used_batch += current_batch;
            }
          } else add_result_dev(dev_str + "*" + std::to_string(max_compute_units));
	}
      }
    }
    result[algo] = result_dev;
  }
  return result;
}
