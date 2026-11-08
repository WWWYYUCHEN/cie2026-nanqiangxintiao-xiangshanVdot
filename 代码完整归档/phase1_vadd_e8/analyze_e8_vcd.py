from pathlib import Path
import re,gzip,json,csv,collections

ROOT=Path(__file__).resolve().parent
source=ROOT/'vadd_e8_3500_5000.vcd.gz'
paths={}; widths={}; stack=[]; hist=collections.defaultdict(list); now=0
def keep(path):
    if path in ('TOP.clock','TOP.reset'): return True
    if '.backend.' not in path: return False
    patterns=[
      r'\.io_frontend_cfVec_\d+_(ready|valid|bits_pc|bits_instr)$',
      r'\.inner_ctrlBlock\.(decode|rename)\.io_out_\d+_(ready|valid|bits_pc|bits_instr|bits_pdest|bits_robIdx_value|bits_fuType)$',
      r'\.inner_ctrlBlock\.io_toIssueBlock_vfUops_\d+_(valid|bits_pc|bits_robIdx_value)$',
      r'\.inner_ctrlBlock\.rob\.io_enq_req_\d+_(valid|bits_pc|bits_robIdx_value)$',
      r'\.inner_ctrlBlock\.rob\.io_commits_(commitValid_\d+|info_\d+_debug_(pc|instr))$',
      r'\.inner_ctrlBlock\.rob\.io_commits_(isCommit|isWalk|isCommit_0)$',
      r'\.inner_vfExuBlock\.exus_\d+\.VialuFix\.io_(in|out)_',
      r'\.inner_vfExuBlock\.exus_\d+\.VialuFix\.mgu\.io_',
      r'\.inner_bypassNetwork\.io_toExus_vf_\d+_0_(valid|bits_fuOpType|bits_robIdx_value|bits_pc)$',
      r'\.inner_vfWriteBackDelayed_\d+_(vecWen_REG|addr_r|valid_r|data_r)$',
    ]
    return any(re.search(p,path) for p in patterns)

with gzip.open(source,'rt',encoding='ascii',errors='replace') as f:
    for ln in f:
        p=ln.split()
        if not p: continue
        if p[0]=='$scope': stack.append(p[2])
        elif p[0]=='$upscope': stack.pop()
        elif p[0]=='$var':
            path='.'.join(stack+[p[4]])
            if keep(path): paths[path]=p[3]; widths[p[3]]=int(p[2]); hist[p[3]]=[]
        elif p[0]=='$enddefinitions': break
    for ln in f:
        s=ln.strip()
        if not s: continue
        if s[0]=='#':now=int(s[1:]);continue
        if s[0] in '01xzXZ':vid=s[1:];v=s[0]
        elif s[0] in 'bB':
            pp=s[1:].split()
            if len(pp)!=2:continue
            v,vid=pp
        else:continue
        if vid in hist:hist[vid].append((now,v))

def val(path,t):
    if path not in paths:return None
    v=None
    for tt,vv in hist[paths[path]]:
        if tt>t:break
        v=vv
    try:return int(v,2) if v is not None else None
    except ValueError:return v

prefix='TOP.SimTop.l_soc.core_with_l2.core.backend.'
target=0x80000166; rows=[]
for path in paths:
    if not path.endswith(('_bits_pc','_debug_pc')): continue
    if '.io_frontend_cfVec_' in path:valid=path.replace('_bits_pc','_valid');label='fetch'
    elif '.decode.' in path:valid=path.replace('_bits_pc','_valid');label='decode'
    elif '.rename.' in path:valid=path.replace('_bits_pc','_valid');label='rename'
    elif '.io_toIssueBlock_vfUops_' in path:valid=path.replace('_bits_pc','_valid');label='dispatch'
    elif '.rob.io_enq_req_' in path:valid=path.replace('_bits_pc','_valid');label='rob_enq'
    elif '.rob.io_commits_info_' in path:
        slot=re.search(r'info_(\d+)',path).group(1)
        valid=prefix+'inner_ctrlBlock.rob.io_commits_commitValid_'+slot;label='commit'
    else:continue
    for t in range(3500,5001):
        if val(path,t)==target and val(valid,t)==1:
            if path.endswith('_bits_pc') and (path.replace('_bits_pc','_ready') in paths) and val(path.replace('_bits_pc','_ready'),t)!=1:continue
            if label=='commit' and val(prefix+'inner_ctrlBlock.rob.io_commits_isCommit',t)!=1:continue
            rows.append({'stage':label,'time_ps':t,'pc':hex(target),'path':path,'valid_path':valid})

exe=[]
for path in paths:
    if not path.endswith('.io_in_valid') or '.VialuFix.' not in path:continue
    b=path[:-len('io_in_valid')]
    for t in range(3500,5001):
        if val(path,t)==1:
            exe.append({'time_ps':t,'path':path,'op':val(b+'io_in_bits_ctrl_fuOpType',t),
                        'output_rob_at_next_sample':val(b+'io_out_bits_ctrl_robIdx_value',t+1),
                        'src0':val(b+'io_in_bits_data_src_0',t),'src1':val(b+'io_in_bits_data_src_1',t)})
summary={'source':source.name,'target_pc':hex(target),'events':rows,'execute_candidates':exe,'paths':paths,'widths':widths}
(ROOT/'vcd_analysis.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
(ROOT/'vcd_histories.json').write_text(json.dumps(hist),encoding='utf-8')
with (ROOT/'stage_events.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.DictWriter(f,fieldnames=['stage','time_ps','pc','path','valid_path']);w.writeheader();w.writerows(rows)
print('selected',len(paths),'events',len(rows))
for r in rows:print(r['stage'],r['time_ps'],r['path'].split('.backend.')[-1])
for r in exe:print('EXEC',r)
