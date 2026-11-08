#!/usr/bin/env bash
set -euo pipefail
mode="${1:-function}"
run_dir="${2:-$HOME/vdot_e8_reproduce}"
project_dir="${XS_PROJECT_ROOT:-$HOME/Desktop/xs-env}"
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "$mode" in function|wave) ;; *) echo 'usage: bash run_vadd_e8.sh [function|wave] [run_dir]' >&2; exit 2;; esac
source "$project_dir/env.sh"
mkdir -p "$run_dir"
cp "$source_dir/vadd_e8.c" "$source_dir/Makefile" "$run_dir/"
cd "$run_dir"
make ARCH=riscv64-xs CROSS_COMPILE=riscv64-unknown-linux-gnu- MARCH=rv64gcv > build.log 2>&1
riscv64-unknown-linux-gnu-objdump -d build/vadd_e8-riscv64-xs.elf > vadd_e8.dis
image_path="$run_dir/build/vadd_e8-riscv64-xs.bin"
if [ "$mode" = function ]; then
  cd "$NOOP_HOME"
  timeout 180 stdbuf -o0 ./build/emu -i "$image_path" --no-diff --ram-size 256MB -C 50000 > "$run_dir/function.log" 2>&1
  grep -F 'SEW=e8 vl=8' "$run_dir/function.log"
  grep -F 'vadd result: 0 0 0 8 -128 127 127 -50' "$run_dir/function.log"
  grep -F 'VADD E8 PASS' "$run_dir/function.log"
  grep -F 'HIT GOOD TRAP' "$run_dir/function.log"
else
  cd "$NOOP_HOME"
  timeout 180 stdbuf -o0 ./build/emu -i "$image_path" --no-diff --ram-size 256MB --dump-wave -b 3500 -e 5000 -C 5010 --wave-path "$run_dir/vadd_e8_3500_5000.vcd" > "$run_dir/wave.log" 2>&1
  test -s "$run_dir/vadd_e8_3500_5000.vcd"
  gzip -c "$run_dir/vadd_e8_3500_5000.vcd" > "$run_dir/vadd_e8_3500_5000.vcd.gz"
  echo "Waveform saved at $run_dir/vadd_e8_3500_5000.vcd.gz"
fi
