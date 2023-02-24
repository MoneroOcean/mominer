// Copyright GNU GPLv3 (c) 2023-2023 MoneroOcean <support@moneroocean.stream>

#pragma once

#include <sycl.hpp>
#include "sycl-lib.h"

sycl::device get_dev(const std::string& dev_str);
