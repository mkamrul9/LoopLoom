"""Live Python container checks using authored fixtures only, not learner drafts."""
import json
from pathlib import Path
from runner import docker, preflight, review, run_case

SOLUTIONS = {
    'supply-pair-v1': 'def solve(a,t):\n for i in range(len(a)):\n  for j in range(i+1,len(a)):\n   if a[i]+a[j]==t:return [j,i]\n return []',
    'sorted-crates-v1': 'def solve(a,t):\n for i in range(len(a)):\n  for j in range(i+1,len(a)):\n   if a[i]+a[j]==t:return [i,j]\n return []',
    'focus-block-v1': 'def solve(a,k):\n return max(sum(a[i:i+k]) for i in range(len(a)-k+1))',
    'signal-ranges-v1': 'def solve(a,t):\n count=0\n for i in range(len(a)):\n  s=0\n  for j in range(i,len(a)):\n   s+=a[j]\n   if s==t:count+=1\n return count',
    'warmer-readings-v1': 'def solve(a):\n out=[0]*len(a)\n for i in range(len(a)):\n  for j in range(i+1,len(a)):\n   if a[j]>a[i]:\n    out[i]=j-i\n    break\n return out',
    'busy-periods-v1': 'def solve(a):\n out=[]\n for start,end in sorted(a):\n  if not out or start>=out[-1][1]:out.append([start,end])\n  else:out[-1][1]=max(out[-1][1],end)\n return out',
}

def main():
    preflight('python')
    rows=[]
    for lesson,source in SOLUTIONS.items():
        result=review({'lesson_id':lesson,'language':'python','source':source})
        rows.append({'check':lesson,'passed':result['language']=='python' and result['passed']==3 and not result['verified_solve'],'result':result})
        print(lesson,rows[-1]['passed'],flush=True)
    probes=[
        ('syntax_error','def solve(:','syntax_error'),
        ('runtime_error','def solve():\n return 1/0','runtime_error'),
        ('time_limit','def solve():\n while True:pass','time_limit'),
        ('output_limit','def solve():\n print("x"*100000)\n return 0','output_limit'),
        ('memory_limit','def solve():\n a=[]\n while True:a.append(bytearray(1024*1024))','memory_limit'),
    ]
    for label,source,expected in probes:
        result=run_case(source,[],'python')
        rows.append({'check':label,'passed':result['status']==expected,'result':result})
        print(label,rows[-1]['passed'],flush=True)
    probe=run_case('def solve():\n import os\n writable=True\n try:open("/forbidden","w").write("x")\n except OSError:writable=False\n return {"uid":os.getuid(),"writable":writable,"interfaces":os.listdir("/sys/class/net")} ',[],'python')
    value=probe.get('result',{})
    rows.append({'check':'uid_root_filesystem_and_network','passed':value.get('uid')==65534 and value.get('writable') is False and value.get('interfaces')==['lo'],'result':probe})
    debug=run_case('def solve():\n print("debug log")\n return 42',[],'python')
    rows.append({'check':'debug_print_keeps_result_protocol','passed':debug.get('result')==42,'result':debug})
    boolean=review({'lesson_id':'signal-ranges-v1','language':'python','source':'def solve(*args):return True'})
    rows.append({'check':'boolean_is_not_an_integer_answer','passed':boolean['passed']==0,'result':boolean})
    mutated=review({'lesson_id':'busy-periods-v1','language':'python','source':'def solve(a):\n a.append([99,100])\n return []'})
    rows.append({'check':'mutating_input_is_reported','passed':all(c['status']=='input_modified' for c in mutated['cases']),'result':mutated})
    remaining=docker('ps','-a','--filter','label=dev.solveit.reference=true','--format','{{.Names}}')
    rows.append({'check':'container_cleanup','passed':not remaining})
    report={'kind':'local_development_authored_python_fixtures_not_security_certification','passed':sum(r['passed'] for r in rows),'total':len(rows),'checks':rows}
    Path('docs/PYTHON_RUNNER_VALIDATION.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({'passed':report['passed'],'total':report['total']}))
    return 0 if all(r['passed'] for r in rows) else 1

if __name__=='__main__':raise SystemExit(main())
