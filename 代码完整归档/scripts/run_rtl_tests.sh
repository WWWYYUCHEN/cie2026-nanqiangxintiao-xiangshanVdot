#!/usr/bin/env bash
set -euo pipefail
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${TMPDIR:-/tmp}/vdot_e8_rtl_$$"
mkdir -p "$OUT_DIR"

command -v iverilog >/dev/null 2>&1 || { echo "iverilog not found" >&2; exit 2; }
command -v vvp >/dev/null 2>&1 || { echo "vvp not found" >&2; exit 2; }
iverilog -g2012 -o "$OUT_DIR/tb_vdot_exact.vvp" \
  "$PKG_DIR/rtl/standalone/vdot_exact_unit.v" \
  "$PKG_DIR/tests/rtl/tb_vdot_exact.v"
vvp "$OUT_DIR/tb_vdot_exact.vvp" | tee "$OUT_DIR/tb_vdot_exact.log"
grep -q 'checks=5 errors=0' "$OUT_DIR/tb_vdot_exact.log"
iverilog -g2012 -o "$OUT_DIR/tb_vdot_exact_wave.vvp" \
  "$PKG_DIR/rtl/standalone/vdot_exact_unit.v" \
  "$PKG_DIR/tests/rtl/tb_vdot_exact_wave.v"
(cd "$OUT_DIR" && vvp ./tb_vdot_exact_wave.vvp | tee ./tb_vdot_exact_wave.log)
test -s "$OUT_DIR/vdot_exact_wave.vcd"
echo "RTL tests passed; VCD: $OUT_DIR/vdot_exact_wave.vcd"
