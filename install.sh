#!/usr/bin/env bash
set -euo pipefail

# Install the Intel GPU compute runtime used by mominer's bundled SYCL runtime.
# This intentionally does not add an apt repository. It installs a pinned,
# coherent Intel compute-runtime package set from upstream release artifacts.

runtime_version="26.18.38308.1"
igc_version="2.34.4"
igc_build="21428"
level_zero_version="1.28.2"
gmmlib_version="22.10.0"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -n env \
    MOMINER_INTEL_RUNTIME_FORCE="${MOMINER_INTEL_RUNTIME_FORCE:-}" \
    MOMINER_INTEL_RUNTIME_KEEP_DOWNLOADS="${MOMINER_INTEL_RUNTIME_KEEP_DOWNLOADS:-}" \
    "$0" "$@"
fi

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Intel GPU runtime installer supports x86_64 Linux only." >&2
  exit 1
fi

if [ ! -r /etc/os-release ]; then
  echo "/etc/os-release is missing; unable to detect Linux distribution." >&2
  exit 1
fi

. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  echo "This installer supports Ubuntu 24.04 and 26.04 only; detected ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

case "${VERSION_ID:-}" in
  24.*|26.*) ;;
  *)
    echo "This installer supports Ubuntu 24.04 and 26.04 only; detected ${PRETTY_NAME:-unknown}." >&2
    exit 1
    ;;
esac

pkg_version() {
  dpkg-query -W -f='${Version}' "$1" 2>/dev/null || true
}

pkg_at_least() {
  local package="$1"
  local version="$2"
  local installed
  installed="$(pkg_version "$package")"
  [ -n "$installed" ] && dpkg --compare-versions "$installed" ge "$version"
}

if [ "${MOMINER_INTEL_RUNTIME_FORCE:-}" != "1" ] &&
   pkg_at_least level-zero "$level_zero_version" &&
   pkg_at_least libze-intel-gpu1 "${runtime_version}-0" &&
   pkg_at_least intel-opencl-icd "${runtime_version}-0" &&
   pkg_at_least intel-igc-core-2 "$igc_version" &&
   pkg_at_least intel-igc-opencl-2 "$igc_version" &&
   pkg_at_least libigdgmm12 "$gmmlib_version" &&
   pkg_at_least intel-ocloc "${runtime_version}-0"; then
  echo "Intel GPU compute runtime is already installed at the requested versions or newer."
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl ocl-icd-libopencl1

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/mominer-intel-runtime.XXXXXX")"
if [ "${MOMINER_INTEL_RUNTIME_KEEP_DOWNLOADS:-}" = "1" ]; then
  echo "Keeping downloads in $work_dir"
else
  trap 'rm -rf "$work_dir"' EXIT
fi

cd "$work_dir"

cat >packages.txt <<EOF
df339abcc8872b3d30887b8845c62a9768db943debcdd96a900b573a02a12cae  level-zero_${level_zero_version}+u24.04_amd64.deb  https://github.com/oneapi-src/level-zero/releases/download/v${level_zero_version}/level-zero_${level_zero_version}%2Bu24.04_amd64.deb
0ce1e715ec5bf30b1304b42acfbda34cc514a0f616dd48c6a31973c4075d8d09  intel-igc-core-2_${igc_version}+${igc_build}_amd64.deb  https://github.com/intel/intel-graphics-compiler/releases/download/v${igc_version}/intel-igc-core-2_${igc_version}+${igc_build}_amd64.deb
09a71e8b6ad432ed0511b09fa4f580c1b44534a60ccb0545212507bf67dc0d1b  intel-igc-opencl-2_${igc_version}+${igc_build}_amd64.deb  https://github.com/intel/intel-graphics-compiler/releases/download/v${igc_version}/intel-igc-opencl-2_${igc_version}+${igc_build}_amd64.deb
f36cb8a6899353c61cc7261b650f287f4a652acadaad859103bdfc51f93b6e8a  intel-ocloc_${runtime_version}-0_amd64.deb  https://github.com/intel/compute-runtime/releases/download/${runtime_version}/intel-ocloc_${runtime_version}-0_amd64.deb
b2d0c924e56b3f9e5837774d68b0c67461b8633035d93ca18b1a8e3e5ead15fa  intel-opencl-icd_${runtime_version}-0_amd64.deb  https://github.com/intel/compute-runtime/releases/download/${runtime_version}/intel-opencl-icd_${runtime_version}-0_amd64.deb
6031a63d6e8a12ce61c14efc15f2c8e727061286e3820b8594e6d00615e04d54  libigdgmm12_${gmmlib_version}_amd64.deb  https://github.com/intel/compute-runtime/releases/download/${runtime_version}/libigdgmm12_${gmmlib_version}_amd64.deb
12b8254e6d3415c32cee9cd13943030b991d91212445c79fe1cc27176a72eca4  libze-intel-gpu1_${runtime_version}-0_amd64.deb  https://github.com/intel/compute-runtime/releases/download/${runtime_version}/libze-intel-gpu1_${runtime_version}-0_amd64.deb
EOF

while read -r sha file url; do
  [ -n "$sha" ] || continue
  curl -fL --retry 3 --retry-delay 2 -o "$file" "$url"
  printf '%s  %s\n' "$sha" "$file" | sha256sum -c -
done <packages.txt

apt-get install -y --no-install-recommends \
  "./level-zero_${level_zero_version}+u24.04_amd64.deb" \
  "./libigdgmm12_${gmmlib_version}_amd64.deb" \
  "./intel-igc-core-2_${igc_version}+${igc_build}_amd64.deb" \
  "./intel-igc-opencl-2_${igc_version}+${igc_build}_amd64.deb" \
  "./intel-ocloc_${runtime_version}-0_amd64.deb" \
  "./intel-opencl-icd_${runtime_version}-0_amd64.deb" \
  "./libze-intel-gpu1_${runtime_version}-0_amd64.deb"

ldconfig

echo "Installed Intel GPU compute runtime:"
dpkg-query -W -f='${Package}\t${Version}\n' \
  level-zero libze-intel-gpu1 intel-opencl-icd intel-igc-core-2 intel-igc-opencl-2 libigdgmm12 intel-ocloc |
  sort
