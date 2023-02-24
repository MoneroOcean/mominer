// Copyright GNU GPLv3 (c) 2023-2023 MoneroOcean <support@moneroocean.stream>

#include "moner-core.h"

#include "3rdparty/fmt/core.h"
#include "backend/cpu/Cpu.h"
#include "crypto/cn/CnCtx.h" 
#include "crypto/randomx/blake2/blake2.h"
#include "crypto/randomx/blake2/avx2/blake2b.h"
#include "crypto/rx/RxFix.h"
#include "hw/msr/Msr.h"
#include "3rdparty/argon2.h"

#include <chrono>

static const xmrig::ICpuInfo& ci = *xmrig::Cpu::info();
void (*rx_blake2b_compress)(blake2b_state* S, const uint8_t * block) = rx_blake2b_compress_integer;
int (*rx_blake2b)(void* out, size_t outlen, const void* in, size_t inlen) = rx_blake2b_default;

struct MsrValue {
  uint64_t value, mask;
  MsrValue() {};
  MsrValue(const uint64_t value, const uint64_t mask = ~0) : value(value), mask(mask) {}
};
typedef std::map<uint32_t, MsrValue> MsrItems;
static const std::map<xmrig::ICpuInfo::MsrMod, MsrItems> msr_mods = {
  { xmrig::ICpuInfo::MSR_MOD_RYZEN_17H, MsrItems {
    { 0xC0011020, MsrValue(0ULL) },
    { 0xC0011021, MsrValue(0x40ULL, ~0x20ULL) },
    { 0xC0011022, MsrValue(0x1510000ULL) },
    { 0xC001102b, MsrValue(0x2000cc16ULL) }
  }}, { xmrig::ICpuInfo::MSR_MOD_RYZEN_19H, MsrItems {
    { 0xC0011020, MsrValue(0x0004480000000000ULL) },
    { 0xC0011021, MsrValue(0x001c000200000040ULL, ~0x20ULL) },
    { 0xC0011022, MsrValue(0xc000000401570000ULL) },
    { 0xC001102b, MsrValue(0x2000cc10ULL) }
  }}, { xmrig::ICpuInfo::MSR_MOD_RYZEN_19H_ZEN4, MsrItems {
    { 0xC0011020, MsrValue(0x0004400000000000ULL) },
    { 0xC0011021, MsrValue(0x0004000000000040ULL, ~0x20ULL) },
    { 0xC0011022, MsrValue(0x8680000401570000ULL) },
    { 0xC001102b, MsrValue(0x2040cc10ULL) }
  }}, { xmrig::ICpuInfo::MSR_MOD_INTEL, MsrItems {
    { 0x1a4, MsrValue(0xf) }
  }}
};

static inline unsigned char hf_hex2bin(const char c, bool& err) {
  if (c >= '0' && c <= '9')      return c - '0';
  else if (c >= 'a' && c <= 'f') return c - 'a' + 0xA;
  else if (c >= 'A' && c <= 'F') return c - 'A' + 0xA;
  err = true;
  return 0;
}

bool Core::hex2bin(const char* in, unsigned int len, unsigned char* out) {
  bool error = false;
  for (unsigned int i = 0; i < len; ++i, ++out, in += 2) {
    *out = (hf_hex2bin(*in, error) << 4) | hf_hex2bin(*(in + 1), error);
    if (error) return false;
  }
  return true;
}

std::vector<std::string> Core::tokenize(const std::string& str, const char delim) {
  std::vector<std::string> out;
  size_t start;
  size_t end = 0;
  while ((start = str.find_first_not_of(delim, end)) != std::string::npos) {
    end = str.find(delim, start);
    out.push_back(str.substr(start, end - start));
  }
  return out;
}

static inline char hf_bin2hex(const unsigned n) {
  if (n < 10) return '0' + n;
  return 'a' + (n - 10);
}

char* Core::hash_bin2hex(const uint8_t* const output, char* hash, const unsigned batch) const {
  char* hash0 = hash;
  for (unsigned i = 0, offset = batch * HASH_LEN; i != HASH_LEN; ++ i, ++ offset) {
    *hash++ = hf_bin2hex(output[offset] >> 4);
    *hash++ = hf_bin2hex(output[offset] & 0xF);
  }
  *hash = 0;
  return hash0;
}

char* Core::hash_bin2hex(char* const hash, const unsigned batch) const {
  return hash_bin2hex(m_output, hash, batch);
}

void Core::send_msg(const std::string key, const MessageValues& values) {
  static std::mutex mutex_message;
  mutex_message.lock();
  sendToNode(*m_progress, Message(key, values));
  mutex_message.unlock();
}

void Core::send_msg(const std::string& topic, const std::string& key, const std::string& value) {
  MessageValues values;
  if (!key.empty()) values[key] = value;
  send_msg(topic, values);
}

void Core::send_error(const std::string& str) {
  send_msg("error", "message", str);
}

void Core::send_result(const uint32_t nonce, const uint8_t* const output) {
  MessageValues values;
  char nonce_hex[sizeof(uint32_t)*2+1], hash_hex[HASH_LEN*2+1];
  snprintf(nonce_hex, sizeof(uint32_t)*2+1, "%08x", __builtin_bswap32(nonce));
  values["nonce"]     = nonce_hex;
  values["hash"]      = hash_bin2hex(output, hash_hex);
  values["pool_id"]   = m_pool_id;
  values["worker_id"] = m_worker_id;
  values["job_id"]    = m_job_id;
  send_msg("result", values);
}

void Core::send_last_nonce(const uint32_t nonce, const std::string& pool_id) {
  MessageValues result;
  result["nonce"]   = std::to_string(nonce);
  result["pool_id"] = pool_id;
  send_msg("last_nonce", result);
}

static void free_mem(void* const mem) { _mm_free(mem); }

void Core::free_memory(
  const bool is_batch_changed,
  const bool is_mem_size_changed,
  const bool is_free_cn,
  const bool is_free_rx
) {
  // m_thread_pool need to be deleted first if anything rx related is deleted
  if (is_batch_changed || is_free_rx) {
    // ++ m_job_ref is to stop rx threads if any
    if (m_thread_pool) { ++ m_job_ref; delete m_thread_pool; m_thread_pool = nullptr; }
  }
  if (is_batch_changed || is_mem_size_changed) {
    if (m_lpads) { delete m_lpads; m_lpads = nullptr; }
  }
  if (is_batch_changed) {
    if (m_input)  { free_mem(m_input);  m_input  = nullptr; }
    if (m_output) { free_mem(m_output); m_output = nullptr; }
  }
  if (is_batch_changed || is_mem_size_changed || is_free_cn) {
    if (m_ctx) { xmrig::CnCtx::release(m_ctx, m_batch); delete [] m_ctx; m_ctx = nullptr; }
  }
  if (is_batch_changed || is_free_cn) {
    if (m_spads) { free_mem(m_spads); m_spads = nullptr; }
  }
  if (is_free_rx) {
    if (m_rx_dataset)     { randomx_release_dataset(m_rx_dataset); m_rx_dataset = nullptr; }
    if (m_rx_cache)       { randomx_release_cache(m_rx_cache); m_rx_cache = nullptr; }
    if (m_rx_dataset_mem) { delete m_rx_dataset_mem; m_rx_dataset_mem = nullptr; }
    if (m_rx_cache_mem)   { delete m_rx_cache_mem; m_rx_cache_mem = nullptr; }
  }
}

void Core::set_fn(cn_any_hash_fun fn) {
  m_fn.any     = fn;
  m_timestamp  = 0;
  m_hash_count = 0;
}

bool Core::process_message(const std::string& type, const MessageValues& v) {
  if (type == "job") {
    if (!v.contains("target"))    throw std::string("Missing target job key");
    if (!v.contains("pool_id"))   throw std::string("Missing pool_id job key");
    if (!v.contains("worker_id")) throw std::string("Missing worker_id job key");
    if (!v.contains("job_id"))    throw std::string("Missing job_id job key");
    const std::string new_target_str = v.at("target");

    uint64_t new_target;
    if (new_target_str.size() <= sizeof(uint32_t)*2) {
      uint32_t tmp = 0;
      char str[sizeof(uint32_t)*2 + 1] = "00000000";
      memcpy(str, new_target_str.c_str(), new_target_str.size());
      if ( !hex2bin(str, sizeof(uint32_t), reinterpret_cast<unsigned char*>(&tmp)) ||
           tmp == 0 ) throw std::string("Bad target hex");
      new_target = 0xFFFFFFFFFFFFFFFFULL / (0xFFFFFFFFULL / static_cast<uint64_t>(tmp));

    } else if (new_target_str.size() <= sizeof(uint64_t)*2) {
       uint64_t tmp = 0;
       char str[sizeof(uint64_t)*2 + 1] = "0000000000000000";
       memcpy(str, new_target_str.c_str(), new_target_str.size());
       if ( !hex2bin(str, sizeof(uint64_t), reinterpret_cast<unsigned char*>(&tmp)) ||
            tmp == 0 ) throw std::string("Bad target hex");
       new_target = tmp;

    } else throw std::string("Bad target hex");

    const uint32_t last_nonce = m_nonce;
    const std::string prev_pool_id = m_pool_id;
    set_job(true, true, v, [&]() {
      m_target    = new_target;
      m_pool_id   = v.at("pool_id");
      m_worker_id = v.at("worker_id");
      m_job_id    = v.at("job_id");
    });
    if (last_nonce) send_last_nonce(last_nonce, prev_pool_id);

  } else if (type == "bench") {
    set_job(true, false, v);
    m_target = 0;

  } else if (type == "test") {
    set_job(false, false, v);
    m_nonce  = 0;
    m_target = 0;

  } else if (type == "pause") {
    ++ m_job_ref; // to stop rx threads if any
    set_fn(nullptr);

  } else if (type == "read_msr" || type == "write_msr") {
     // in case of unknown MSR mod support stop here
     const auto pi = msr_mods.find(ci.msrMod());
     if (pi == msr_mods.end()) throw std::string("Unsupported CPU");

     // build default_msr_items from input message params
     const MsrItems& msr_items = pi->second;
     MsrItems default_msr_items;
     for (const auto& vi : v) {
       const std::string& key = vi.first;
       if (key.starts_with("msr:0x")) {
         const std::string& value = vi.second;
         const uint32_t reg = strtoul(key.substr(6).c_str(), NULL, 16);
         auto parts = tokenize(value, ',');
         if (parts.size() != 2 || !parts[0].starts_with("0x") || !parts[1].starts_with("0x"))
           throw std::string("Wrong value,mask MSR value: " + value);
         default_msr_items[reg] = MsrValue(
           strtoul(parts[0].substr(2).c_str(), NULL, 16),
           strtoul(parts[1].substr(2).c_str(), NULL, 16)
         );
       }
     }

     auto msr = xmrig::Msr::get();

     if (type == "read_msr") { // read missing default_msr_items and return them all as result
       MessageValues result;
       for (const auto& i : msr_items) {
         const uint32_t reg = i.first;
         MsrValue value;
         const auto pi = default_msr_items.find(reg);
         if (pi == default_msr_items.end()) {
           const auto msr_item = msr->read(reg);
           if (!msr_item.isValid()) throw fmt::format("Can't read MSR register {:#x}", reg);
           value = MsrValue(msr_item.value(), msr_item.mask());
         } else value = pi->second;
         result[fmt::format("msr:{:#x}", reg)] =
           fmt::format("{:#x},{:#x}", value.value, value.mask);
       }
       send_msg("read_msr", result);

     } else { // write msr
       // if algo is set and needs MSR mod then set it
       // otherwise reset MSR to default values
       bool is_set_msr = false;
       { const auto pi = v.find("algo");
         if (pi != v.end()) {
           const auto& algo = pi->second;
           is_set_msr = algo.starts_with("rx/") || algo == "ghostrider" || algo == "cn-hexy/xhv";
         }
       }

       for (const auto& i : msr_items) {
         const uint32_t reg = i.first;
         xmrig::MsrItem msr_item;
         if (!is_set_msr) {
           const auto pi = default_msr_items.find(reg);
           if (pi == default_msr_items.end()) continue; // this item was not recorded before
           msr_item = xmrig::MsrItem(reg, pi->second.value, pi->second.mask);
         } else msr_item = xmrig::MsrItem(reg, i.second.value, i.second.mask);
         msr->write([&msr, msr_item, reg](const int32_t cpu) {
           if (!msr->write(msr_item, cpu))
             throw fmt::format("Can't write MSR register {:#x}", reg);
           return true;
         });
       }
     }

     return true;

  } else if (type == "close") {
    if (m_nonce) send_last_nonce(m_nonce, m_pool_id);
    free_memory();
    return false; // stop processing messages

  } else if (type == "algo_params") {
    get_algo_params(v);
  }

  return true; // continue processing messages
}

void Core::Execute(const AsyncProgressQueueWorker<char>::ExecutionProgress& progress) {
  { // select best argon2 implementation
    const char* hint = nullptr;
#if defined(HAVE_SSSE2)
    if (ci.has(xmrig::ICpuInfo::FLAG_SSE2))    hint = "SSE2";
#endif
#if defined(HAVE_SSSE3)
    if (ci.has(xmrig::ICpuInfo::FLAG_SSSE3))   hint = "SSSE3";
#endif
#if defined(HAVE_XOP)
    if (ci.has(xmrig::ICpuInfo::FLAG_XOP))     hint = "XOP";
#endif
#if defined(HAVE_AVX2)
    if (ci.has(xmrig::ICpuInfo::FLAG_AVX2))    hint = "AVX2";
#endif
#if defined(HAVE_AVX512F)
    if      (ci.has(xmrig::ICpuInfo::FLAG_AVX512F)) hint = "AVX-512F";
#endif
    if (hint) argon2_select_impl_by_name(hint);
  }

  if (ci.arch() == xmrig::ICpuInfo::ARCH_ZEN)
    xmrig::RxFix::setupMainLoopExceptionFrame();

  if (ci.has(xmrig::ICpuInfo::FLAG_SSE41)) rx_blake2b_compress = rx_blake2b_compress_sse41;
  if (ci.hasAVX2())                        rx_blake2b          = blake2b_avx2;

  randomx_set_scratchpad_prefetch_mode(0);
  randomx_set_huge_pages_jit(true);
  randomx_set_optimized_dataset_init(1);
   m_progress = &progress;

  while (true) {
    std::deque<Message> messages;
    fromNode.readAll(messages);
    for (const auto& message : messages) {
      try {
        if (!process_message(message.name, message.values)) return;
      } catch(const std::string& err) {
        send_error(std::string("Message processing exception: ") + err);
      }
    }

    // we skip first hash function run using m_hash_count check to exclude GPU compile time
    // that effectively skips it in test mode too
    static unsigned hashrate_check_counter = HASHRATE_COUNTER_INTERVAL;
    if (m_dev == DEV::RX_CPU) m_mutex_hashrate.lock();
    const unsigned hash_count = m_hash_count;
    if (m_dev == DEV::RX_CPU) m_mutex_hashrate.unlock();
    if (hash_count && --hashrate_check_counter == 0) {
      hashrate_check_counter = HASHRATE_COUNTER_INTERVAL;
      const uint64_t new_timestamp = std::chrono::time_point_cast<std::chrono::milliseconds>(
        std::chrono::high_resolution_clock::now()
      ).time_since_epoch().count();
      if (!m_timestamp || new_timestamp - m_timestamp > 60*1000) {
        if (m_timestamp) send_msg("hashrate", "hashrate", std::to_string(
          static_cast<float>(hash_count) / (new_timestamp - m_timestamp) * 1000.0f
        ));
        m_timestamp = new_timestamp;
        if (m_dev == DEV::RX_CPU) m_mutex_hashrate.lock();
        m_hash_count = 0;
        if (m_dev == DEV::RX_CPU) m_mutex_hashrate.unlock();
      }
    }

    if (m_fn.any) {
      try {
        switch (m_dev) {
          case DEV::CPU:
            m_fn.cpu(m_input, m_input_len, m_output, m_ctx, m_height);
            break;

          case DEV::GPU:
            m_fn.gpu(m_input, m_input_len, m_output, m_lpads->scratchpad(), m_spads,
                     m_batch, m_dev_str);
            break;

          case DEV::RX_CPU: throw "Internal error: Unreachable code executed";
        }
      } catch(const std::string& err) {
        send_error(std::string("Compute function exception: ") + err);
        set_fn(nullptr);
        continue;
      } catch(...) {
        send_error("Compute function exception");
        set_fn(nullptr);
        continue;
      }

      if (!m_nonce) { // test job
        std::string result_hash_str;
        for (unsigned i = 0; i != m_batch; ++ i) {
          if (i) result_hash_str += " ";
          char hash[HASH_LEN*2+1];
          result_hash_str += hash_bin2hex(hash, i);
        }
        send_msg("test", "result", result_hash_str);
        set_fn(nullptr);
        continue;
      }

      m_hash_count += m_batch; // here we do not need mutex since there are no threads

      const uint32_t prev_nonce = m_nonce;
      for (unsigned i = 0; i != m_batch; ++i) {
        uint32_t* const pnonce = get_nonce(i);
        if (m_target && *get_result(i) < m_target) send_result(*pnonce, m_output + HASH_LEN * i);
        *pnonce = m_nonce;
        m_nonce += m_nonce_step;
      }

      if (m_target && ( m_is_nicehash ? (prev_nonce & 0xFF000000) != (m_nonce & 0xFF000000) :
                        prev_nonce > m_nonce )
      ) {
        send_error("Nonce overflow");
        set_fn(nullptr);
        continue;
      }

    } else {
      std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
  }
}

AsyncWorker* create_worker(
  Nan::Callback* const data, Nan::Callback* const complete, Nan::Callback* const error_callback,
  v8::Local<v8::Object>& options
) {
  return new Core(data, complete, error_callback, options);
}

NODE_MODULE(moner_core, AsyncWorkerWrapper::Init)
