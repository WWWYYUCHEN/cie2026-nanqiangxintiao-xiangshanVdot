# coding 统一源码环境

本目录是三个阶段共用的完整源码交付区，包含：

- XiangShan 的完整改动文件：rocket-chip 指令编码、Parameters.scala、FuType.scala、FuConfig.scala、VecDecoder.scala、VDotU.scala，以及生成的 VDotU.sv。
- NEMU 的完整改动文件：isa-all-instr.h、RVV decode.h、RVV vcompute.h。
- 独立 Verilog：vdot_exact_unit.v、完整 RTL testbench、波形 testbench。
- 测试软件和汇编：vdot_exact_test.S、baseline、性能夹具和空循环夹具。
- 编译/覆盖/运行脚本：apply_overlay.sh、run_rtl_tests.sh、run_system_tests.sh、flash.ld。

这里的文件都是完整文件，不是单个代码片段。`overlay/` 按原始 XiangShan/NEMU 仓库路径保存；`rtl/`、`tests/` 和 `scripts/` 是独立回归与复现入口。

`VM完整工程源码_含生成RTL.tar.gz` 才是从 VM 打包的完整源工程和整套生成 RTL；它保留 Linux 符号链接，必须在 Linux 下解压。它不包含系统工具链、Git 历史或预编译 emu，完整说明见上一级的 `提交目录与完整工程说明.txt`。`overlay/` 仅包含完整改动文件的副本。

历史 SEW=32 版本没有放入当前活动代码目录，避免和当前 SEW=8 语义混用。


20261108 e8 修订
第一阶段已改用 SEW=8、LMUL=1、vl=8 的 vadd.vv 作为主案例，八个元素全部自检通过并正常 HIT GOOD TRAP。核级波形的前端握手为 4338，执行输入/输出为 4422/4423，提交为 4428。源码、ELF/BIN、原始 VCD、CSV、别名映射和查看脚本位于 coding/phase1_vadd_e8；阶段1/png 中为新的 e8 截图，旧 e64 截图与波形保存在 e64_history 子目录。三份报告均按比赛成果陈述重构，每份目录仅列五个一级章节。第一阶段原 hello 视频已经收录，e8 部分按最新指导补录；新拍视频随后分别合入各阶段 video 目录。
