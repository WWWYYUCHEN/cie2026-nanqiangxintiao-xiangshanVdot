set sigs {
vadd_e8.execute_in_valid
vadd_e8.execute_in_ready
vadd_e8.execute_op
vadd_e8.execute_vsew
vadd_e8.execute_src0
vadd_e8.execute_src1
vadd_e8.execute_out_valid
vadd_e8.execute_out_ready
vadd_e8.execute_result
vadd_e8.execute_out_rob
vadd_e8.execute_out_pdest
vadd_e8.mgu_vl
vadd_e8.mgu_vstart
vadd_e8.mgu_ta
vadd_e8.commit_isCommit
vadd_e8.commit_valid
vadd_e8.commit_pc
vadd_e8.commit_instr
}
gtkwave::addSignalsFromList $sigs
gtkwave::setZoomRangeTimes 4418 4450
gtkwave::/View/Scale_To_Time_Dimension/ps
gtkwave::nop
