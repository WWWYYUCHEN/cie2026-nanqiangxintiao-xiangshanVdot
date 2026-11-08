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
  "$WORKSPACE/XiangShan/src/main/scala/xiangshan" \
  "$WORKSPACE/XiangShan/rocket-chip/src/main/scala/rocket" \
  "$WORKSPACE/NEMU/src/isa/riscv64/instr/rvv"; do
  if [[ ! -d "$required" ]]; then
    echo "required source directory not found: $required" >&2
    exit 2
  fi
done

files=(
  "XiangShan/rocket-chip/src/main/scala/rocket/Instructions.scala"
  "XiangShan/src/main/scala/xiangshan/Parameters.scala"
  "XiangShan/src/main/scala/xiangshan/backend/fu/FuType.scala"
  "XiangShan/src/main/scala/xiangshan/backend/fu/FuConfig.scala"
  "XiangShan/src/main/scala/xiangshan/backend/decode/VecDecoder.scala"
  "XiangShan/src/main/scala/xiangshan/backend/fu/wrapper/VDotU.scala"
  "XiangShan/build_exact/rtl/VDotU.sv"
  "NEMU/src/isa/riscv64/include/isa-all-instr.h"
  "NEMU/src/isa/riscv64/instr/rvv/decode.h"
  "NEMU/src/isa/riscv64/instr/rvv/vcompute.h"
)
for rel in "${files[@]}"; do
  source="$PKG_DIR/overlay/$rel"
  target="$WORKSPACE/$rel"
  if [[ ! -f "$source" ]]; then
    echo "overlay file missing: $source" >&2
    exit 2
  fi
  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
  printf 'installed %s\n' "$rel"
done
