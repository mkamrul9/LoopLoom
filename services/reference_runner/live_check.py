"""Explicit live checks using authored fixtures only. Requires local Docker."""
import json
from pathlib import Path
from runner import docker, preflight, review, run_case

SOLUTIONS = {
    'supply-pair-v1':'function solve(a,t){for(let i=0;i<a.length;i++)for(let j=i+1;j<a.length;j++)if(a[i]+a[j]===t)return [j,i];return [];}',
    'sorted-crates-v1':'function solve(a,t){for(let i=0;i<a.length;i++)for(let j=i+1;j<a.length;j++)if(a[i]+a[j]===t)return [i,j];return [];}',
    'focus-block-v1':'function solve(a,k){let best=-Infinity;for(let i=0;i+k<=a.length;i++){let s=0;for(let j=i;j<i+k;j++)s+=a[j];best=Math.max(best,s);}return best;}',
    'signal-ranges-v1':'function solve(a,t){let count=0;for(let i=0;i<a.length;i++){let s=0;for(let j=i;j<a.length;j++){s+=a[j];if(s===t)count++;}}return count;}',
    'warmer-readings-v1':'function solve(a){return a.map((x,i)=>{for(let j=i+1;j<a.length;j++)if(a[j]>x)return j-i;return 0;});}',
    'busy-periods-v1':'function solve(a){const b=a.map(x=>[...x]).sort((x,y)=>x[0]-y[0]),r=[];for(const x of b){if(!r.length||x[0]>=r[r.length-1][1])r.push(x);else r[r.length-1][1]=Math.max(r[r.length-1][1],x[1]);}return r;}',
}

def main():
    preflight()
    rows=[]
    for lesson,source in SOLUTIONS.items():
        result=review({'lesson_id':lesson,'language':'javascript','source':source})
        rows.append({'check':lesson,'passed':result['passed']==3 and not result['verified_solve'],'result':result})
        print(lesson, rows[-1]['passed'], flush=True)
    probes=[
        ('syntax_error','function solve( {','syntax_error'),
        ('runtime_error','function solve(){throw new Error("fixture");}','runtime_error'),
        ('time_limit','function solve(){while(true){}}','time_limit'),
        ('output_limit','function solve(){console.log("x".repeat(100000));return 0;}','output_limit'),
        ('memory_limit','function solve(){const a=[];while(true)a.push(Buffer.alloc(1024*1024,1));}','memory_limit'),
    ]
    for label,source,expected in probes:
        result=run_case(source,[])
        rows.append({'check':label,'passed':result['status']==expected,'result':result})
        print(label, rows[-1]['passed'], flush=True)
    probe=run_case('function solve(){let writable=true;try{require("fs").writeFileSync("/forbidden","x");}catch(e){writable=false;}return {uid:process.getuid(),writable,interfaces:Object.keys(require("os").networkInterfaces())};}',[])
    value=probe.get('result',{})
    rows.append({'check':'uid_root_filesystem_and_network','passed':value.get('uid')==65534 and value.get('writable') is False and value.get('interfaces')==['lo'],'result':probe})
    remaining=docker('ps','-a','--filter','label=dev.solveit.reference=true','--format','{{.Names}}')
    rows.append({'check':'container_cleanup','passed':not remaining})
    report={'kind':'local_development_authored_fixtures_not_security_certification','passed':sum(r['passed'] for r in rows),'total':len(rows),'checks':rows}
    Path('docs/REFERENCE_RUNNER_VALIDATION.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({'passed':report['passed'],'total':report['total']}))
    return 0 if all(r['passed'] for r in rows) else 1

if __name__ == '__main__': raise SystemExit(main())
