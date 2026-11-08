#!/usr/bin/env bash
set -euo pipefail
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE="${1:-}"
if [[ -z "$WORKSPACE" ]]; then
  echo "usage: $0 <workspace-containing-XiangShan-and-NEMU>" >&2
  exit 2
fi
WORKSPACE="$(cd "$WORKSPACE" && pwd)"
for required in \
  "$WORKSPACE/flash.ld" \
  "$WORKSPACE/XiangShan/build_exact/emu" \
  "$WORKSPACE/NEMU/Makefile"; do
  if [[ ! -e "$required" ]]; then
    echo "required build input not found: $required" >&2
    exit 2
  fi
done

PREFIX="${RISCV_PREFIX:-riscv64-linux-gnu-}"
CC="${PREFIX}gcc"
OBJCOPY="${PREFIX}objcopy"
command -v "$CC" >/dev/null 2>&1 || { echo "$CC not found" >&2; exit 2; }
command -v "$OBJCOPY" >/dev/null 2>&1 || { echo "$OBJCOPY not found" >&2; exit 2; }
OUT_DIR="$WORKSPACE/vdot_e8_run"
mkdir -p "$OUT_DIR"
export NEMU_HOME="$WORKSPACE/NEMU"
make -B -j8 -C "$WORKSPACE/NEMU"

build_test() {
  local name="$1"
  "$CC" -march=rv64gcv -mabi=lp64d -fno-pic -mcmodel=medany \
    -nostdlib -nostartfiles -T "$WORKSPACE/flash.ld" \
    "$PKG_DIR/tests/system/$name.S" -o "$OUT_DIR/$name.elf"
  "$OBJCOPY" -O binary "$OUT_DIR/$name.elf" "$OUT_DIR/$name.bin"
}
build_test vdot_exact_test
build_test vdot_baseline_supported

EMU="$WORKSPACE/XiangShan/build_exact/emu"
NEMU_SO="$WORKSPACE/NEMU/build/riscv64-nemu-interpreter-so"
command -v timeout >/dev/null 2>&1 || { echo "GNU timeout not found" >&2; exit 2; }
[[ -f "$NEMU_SO" ]] || { echo "NEMU reference not found: $NEMU_SO" >&2; exit 2; }

# The bare-metal tests end in a self-loop. A timeout after the expected UART
# marker is a bounded observation, not a normal simulator exit.
run_test() {
  local name="$1" expected="$2" rc
  set +e
  (cd "$WORKSPACE/XiangShan" && \
    timeout "${VDOT_TIMEOUT_SECONDS:-300}s" "$EMU" -F "$OUT_DIR/$name.bin" \
      --diff="$NEMU_SO" -I 200000) > "$OUT_DIR/$name.log" 2>&1
  rc=$?
  set -e
  cat "$OUT_DIR/$name.log"
  if [[ "$rc" != 0 && "$rc" != 124 ]]; then
    echo "$name: emu failed with status $rc" >&2; return 1
  fi
  if ! grep -Fq "$expected" "$OUT_DIR/$name.log" || \
     grep -Eiq 'different at pc|difftest mismatch|ABORT|HIT BAD TRAP' "$OUT_DIR/$name.log"; then
    echo "$name: expected marker absent or mismatch reported" >&2; return 1
  fi
  echo "$name: marker observed; emulator exit status $rc"
}
run_test vdot_exact_test S00000000
run_test vdot_baseline_supported S0
echo "Markers observed; inspect logs and exit status: $OUT_DIR"
