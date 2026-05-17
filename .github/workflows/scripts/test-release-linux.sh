#!/usr/bin/env bash
set -euo pipefail

archive="${1:?Usage: .github/workflows/scripts/test-release-linux.sh <archive> [suite]}"
suite="${2:-all}"
node_bin="${NODE_BIN:-$(command -v node)}"
work_dir="${MOMINER_RELEASE_TEST_DIR:-release-test}"

rm -rf "$work_dir"
mkdir -p "$work_dir"

archive_list="$(mktemp)"
trap 'rm -f "$archive_list"' EXIT
tar -tzf "$archive" >"$archive_list"

root="$(sed -n '1p' "$archive_list" | cut -d/ -f1)"
if [ -z "$root" ]; then
  echo "Unable to determine archive root for $archive." >&2
  exit 1
fi
if grep -Eq '(^|/)tests(/|$)' "$archive_list"; then
  echo "Release archive must not contain tests/." >&2
  exit 1
fi

tar -C "$work_dir" -xzf "$archive"
package_dir="$work_dir/$root"
if [ -d "$package_dir/tests" ]; then
  echo "Extracted release package unexpectedly contains tests/." >&2
  exit 1
fi

check_ldd() {
  local file output failed=0
  while IFS= read -r -d "" file; do
    output="$(LD_LIBRARY_PATH="$PWD/$package_dir" ldd "$file" 2>&1 || true)"
    if grep -q "not found" <<<"$output"; then
      echo "$output" >&2
      failed=1
    fi
  done < <(
    find "$package_dir" -maxdepth 1 -type f \
      \( -name "mominer-bin" -o -name "mominer.node" -o -name "*.so" -o -name "*.so.*" \) \
      -print0
  )
  return "$failed"
}

check_ldd

cp -r tests "$package_dir/"

system_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH="$PWD/$package_dir:$system_path"
if [ -f "$package_dir/libintelocl.so" ]; then
  export OCL_ICD_FILENAMES="$PWD/$package_dir/libintelocl.so"
fi

smoke_output="$(cd "$package_dir" && env -u LD_LIBRARY_PATH ./mominer algo_params)"
if ! grep -q '^MOMINER_ALGO_PARAMS ' <<<"$smoke_output"; then
  echo "Direct executable smoke test did not print algo params marker." >&2
  echo "$smoke_output" >&2
  exit 1
fi
printf '%s\n' "$smoke_output" | "$node_bin" -e '
const fs = require("node:fs");
const marker = fs.readFileSync(0, "utf8").split(/\r?\n/).find((line) => line.startsWith("MOMINER_ALGO_PARAMS "));
const params = JSON.parse(marker.slice("MOMINER_ALGO_PARAMS ".length));
for (const [algo, dev] of Object.entries(params)) {
  if (typeof dev !== "string" || !dev || /(?:^|,)[^,]*(?:\*0|\^0)(?:,|$)/.test(dev)) {
    console.error(`Invalid algo params for ${algo}: ${dev}`);
    process.exit(1);
  }
}
'

run_suite() {
  local name="$1"
  (cd "$package_dir" && "$node_bin" tests/run_hash.js "$name")
}

case "$suite" in
  all)
    (cd "$package_dir" && "$node_bin" tests/run_hash.js)
    ;;
  cpu|gpu|sycl-cpu)
    run_suite "$suite"
    ;;
  *)
    echo "Unknown release test suite: $suite" >&2
    exit 1
    ;;
esac
