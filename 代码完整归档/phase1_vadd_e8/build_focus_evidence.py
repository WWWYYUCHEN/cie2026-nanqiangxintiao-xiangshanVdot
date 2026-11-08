from pathlib import Path
import json,csv
R=Path(__file__).resolve().parent
d=json.loads((R/'vcd_analysis.json').read_text());h=json.loads((R/'vcd_histories.json').read_text())
P='TOP.SimTop.l_soc.core_with_l2.core.backend.'
E=P+'inner_vfExuBlock.exus_2.VialuFix.'
aliases={
 'fetch_valid':P+'io_frontend_cfVec_1_valid',
 'fetch_ready':P+'io_frontend_cfVec_1_ready',
 'fetch_pc':P+'io_frontend_cfVec_1_bits_pc',
 'fetch_instr':P+'io_frontend_cfVec_1_bits_instr',
 'decode_valid':P+'inner_ctrlBlock.decode.io_out_0_valid',
 'decode_ready':P+'inner_ctrlBlock.decode.io_out_0_ready',
 'decode_pc':P+'inner_ctrlBlock.decode.io_out_0_bits_pc',
 'rename_valid':P+'inner_ctrlBlock.rename.io_out_0_valid',
 'rename_ready':P+'inner_ctrlBlock.rename.io_out_0_ready',
 'rename_pc':P+'inner_ctrlBlock.rename.io_out_0_bits_pc',
 'rename_rob':P+'inner_ctrlBlock.rename.io_out_0_bits_robIdx_value',
 'rename_pdest':P+'inner_ctrlBlock.rename.io_out_0_bits_pdest',
 'dispatch_valid':P+'inner_ctrlBlock.io_toIssueBlock_vfUops_2_valid',
 'dispatch_pc':P+'inner_ctrlBlock.io_toIssueBlock_vfUops_2_bits_pc',
 'alloc_valid':P+'inner_ctrlBlock.rob.io_enq_req_0_valid',
 'alloc_pc':P+'inner_ctrlBlock.rob.io_enq_req_0_bits_pc',
 'execute_in_valid':E+'io_in_valid',
 'execute_in_ready':E+'io_in_ready',
 'execute_op':E+'io_in_bits_ctrl_fuOpType',
 'execute_vsew':E+'io_in_bits_ctrl_vpu_vsew',
 'execute_src0':E+'io_in_bits_data_src_0',
 'execute_src1':E+'io_in_bits_data_src_1',
 'execute_out_valid':E+'io_out_valid',
 'execute_out_ready':E+'io_out_ready',
 'execute_result':E+'io_out_bits_res_data',
 'execute_out_rob':E+'io_out_bits_ctrl_robIdx_value',
 'execute_out_pdest':E+'io_out_bits_ctrl_pdest',
 'mgu_vl':E+'mgu.io_in_info_vl',
 'mgu_vstart':E+'mgu.io_in_info_vstart',
 'mgu_ta':E+'mgu.io_in_info_ta',
 'commit_isCommit':P+'inner_ctrlBlock.rob.io_commits_isCommit',
 'commit_valid':P+'inner_ctrlBlock.rob.io_commits_commitValid_0',
 'commit_pc':P+'inner_ctrlBlock.rob.io_commits_info_0_debug_pc',
 'commit_instr':P+'inner_ctrlBlock.rob.io_commits_info_0_debug_instr',
}
for a,p in aliases.items():assert p in d['paths'],(a,p)
def val(alias,t):
 v=None
 for tt,vv in h[d['paths'][aliases[alias]]]:
  if tt>t:break
  v=vv
 return v or 'x'
def hx(alias,t):
 v=val(alias,t)
 try:return hex(int(v,2))
 except:return v
with (R/'vadd_e8_focus.vcd').open('w',encoding='ascii') as f:
 f.write('$comment Lossless signal selection from vadd_e8_3500_5000.vcd.gz; names mapped by signal_aliases.json; timestamps preserved; no synthetic clock. $end\n$timescale 1ps $end\n$scope module vadd_e8 $end\n')
 for i,(a,p) in enumerate(aliases.items()):f.write(f'$var wire {d["widths"][d["paths"][p]]} s{i} {a} $end\n')
 f.write('$upscope $end\n$enddefinitions $end\n')
 for t in range(4328,4437):
  f.write(f'#{t}\n')
  for i,a in enumerate(aliases):
   v=val(a,t)
   if t==4328 or v!=val(a,t-1):f.write(f'b{v} s{i}\n')
(R/'signal_aliases.json').write_text(json.dumps(aliases,indent=2),encoding='utf-8')
with (R/'vadd_e8_stage_samples.csv').open('w',newline='',encoding='utf-8') as f:
 w=csv.writer(f);w.writerow(['sample_time_ps']+list(aliases))
 for t in range(4328,4437):w.writerow([t]+[hx(a,t) for a in aliases])
front=list(aliases)[:16]
back=list(aliases)[16:]
for name,sigs,lo,hi in [('frontend',front,4332,4364),('backend',back,4418,4450),('pipeline',front+['execute_in_valid','execute_out_valid','execute_result','commit_isCommit','commit_valid','commit_pc'],4330,4520)]:
 text='set sigs {\n'+'\n'.join('vadd_e8.'+s for s in sigs)+'\n}\n'
 text+='gtkwave::addSignalsFromList $sigs\n'+f'gtkwave::setZoomRangeTimes {lo} {hi}\n'
 text+='gtkwave::/View/Scale_To_Time_Dimension/ps\ngtkwave::nop\n'
 (R/f'{name}.tcl').write_text(text,encoding='ascii')
print('focus VCD bytes',(R/'vadd_e8_focus.vcd').stat().st_size)
for t in [4338,4340,4341,4342,4343,4422,4423,4427,4428]:
 print(t,{a:hx(a,t) for a in ['rename_rob','execute_in_valid','execute_out_valid','execute_result','execute_out_rob','mgu_vl','commit_isCommit','commit_valid','commit_pc']})
