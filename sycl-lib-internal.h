// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

#pragma once

#include <sycl/sycl.hpp>
#include "sycl-lib.h"

sycl::device get_dev(const std::string& dev_str);
