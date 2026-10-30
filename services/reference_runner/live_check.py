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
    'rotated-index-v1':'function solve(a,t){let l=0,r=a.length-1;while(l<=r){const m=(l+r)>>1;if(a[m]===t)return m;if(a[l]<=a[m]){if(a[l]<=t&&t<a[m])r=m-1;else l=m+1;}else{if(a[m]<t&&t<=a[r])l=m+1;else r=m-1;}}return -1;}',
    'products-except-self-v1':'function solve(a){const out=Array(a.length).fill(1);let p=1;for(let i=0;i<a.length;i++){out[i]=p;p*=a[i];}p=1;for(let i=a.length-1;i>=0;i--){out[i]*=p;p*=a[i];}return out;}',
    'longest-run-v1':'function solve(a){const s=new Set(a);let best=0;for(const x of s){if(!s.has(x-1)){let n=1;while(s.has(x+n))n++;best=Math.max(best,n);}}return best;}',
    'budget-window-v1':'function solve(a,k){let left=0,sum=0,best=0;for(let right=0;right<a.length;right++){sum+=a[right];while(sum>k){sum-=a[left++];}best=Math.max(best,right-left+1);}return best;}',
    'lower-bound-v1':'function solve(a,t){let left=0,right=a.length;while(left<right){const mid=left+Math.floor((right-left)/2);if(a[mid]<t)left=mid+1;else right=mid;}return left;}',
    'island-count-v1':'function solve(g){const rows=g.length,cols=rows?g[0].length:0,seen=Array.from({length:rows},()=>Array(cols).fill(false));let count=0;for(let r=0;r<rows;r++)for(let c=0;c<cols;c++){if(!g[r][c]||seen[r][c])continue;count++;const q=[[r,c]];seen[r][c]=true;for(let i=0;i<q.length;i++){const [y,x]=q[i];for(const [dy,dx] of [[1,0],[-1,0],[0,1],[0,-1]]){const ny=y+dy,nx=x+dx;if(ny>=0&&ny<rows&&nx>=0&&nx<cols&&g[ny][nx]&&!seen[ny][nx]){seen[ny][nx]=true;q.push([ny,nx]);}}}}return count;}',
    'max-subarray-v1':'function solve(a){let ending=a[0],best=a[0];for(let i=1;i<a.length;i++){ending=Math.max(a[i],ending+a[i]);best=Math.max(best,ending);}return best;}',
    'single-trade-v1':'function solve(a){let min=Infinity,best=0;for(const p of a){if(min!==Infinity)best=Math.max(best,p-min);min=Math.min(min,p);}return best;}',
    'graph-components-v1':'function solve(g){const seen=Array(g.length).fill(false);let count=0;for(let start=0;start<g.length;start++){if(seen[start])continue;count++;seen[start]=true;const q=[start];for(let i=0;i<q.length;i++)for(const v of g[q[i]])if(!seen[v]){seen[v]=true;q.push(v);}}return count;}',
    'first-signal-v1':'function solve(s){const counts=Array(26).fill(0);for(const c of s)counts[c.charCodeAt(0)-97]++;for(let i=0;i<s.length;i++)if(counts[s.charCodeAt(i)-97]===1)return i;return -1;}',
    'anagram-pair-v1':'function solve(a,b){if(a.length!==b.length)return false;const counts=Array(26).fill(0);for(const c of a)counts[c.charCodeAt(0)-97]++;for(const c of b)counts[c.charCodeAt(0)-97]--;return counts.every(x=>x===0);}',
    'distinct-letter-window-v1':'function solve(s){const last=Array(26).fill(-1);let left=0,best=0;for(let right=0;right<s.length;right++){const c=s.charCodeAt(right)-97;left=Math.max(left,last[c]+1);last[c]=right;best=Math.max(best,right-left+1);}return best;}',
    'kth-score-v1':'function solve(a,k){return a.slice().sort((x,y)=>y-x)[k-1];}',
    'top-frequency-v1':'function solve(a,k){const count=new Map();for(const x of a)count.set(x,(count.get(x)||0)+1);return [...count].sort((x,y)=>y[1]-x[1]||x[0]-y[0]).slice(0,k).map(x=>x[0]).sort((x,y)=>x-y);}',
    'merge-streams-v1':'function solve(a){return a.flat().sort((x,y)=>x-y);}',
    'tree-depth-v1':'function solve(t){if(!t.length)return 0;const q=[[0,1]];let best=0;for(let h=0;h<q.length;h++){const [i,d]=q[h];best=Math.max(best,d);if(t[i][1]!==-1)q.push([t[i][1],d+1]);if(t[i][2]!==-1)q.push([t[i][2],d+1]);}return best;}',
    'tree-width-v1':'function solve(t){if(!t.length)return 0;const q=[0];let head=0,best=0;while(head<q.length){const end=q.length;best=Math.max(best,end-head);while(head<end){const i=q[head++];if(t[i][1]!==-1)q.push(t[i][1]);if(t[i][2]!==-1)q.push(t[i][2]);}}return best;}',
    'tree-path-sum-v1':'function solve(t,target){if(!t.length)return false;const s=[[0,t[0][0]]];while(s.length){const [i,total]=s.pop(),l=t[i][1],r=t[i][2];if(l===-1&&r===-1&&total===target)return true;if(l!==-1)s.push([l,total+t[l][0]]);if(r!==-1)s.push([r,total+t[r][0]]);}return false;}',
    'list-middle-v1':'function solve(n){if(!n.length)return -1;let slow=0,fast=0;while(fast!==-1&&n[fast][1]!==-1){slow=n[slow][1];fast=n[n[fast][1]][1];}return slow;}',
    'list-cycle-v1':'function solve(n){if(!n.length)return false;let slow=0,fast=0;while(fast!==-1&&n[fast][1]!==-1){slow=n[slow][1];fast=n[n[fast][1]][1];if(slow===fast)return true;}return false;}',
    'list-nth-from-end-v1':'function solve(n,k){let fast=0,slow=0;for(let i=0;i<k;i++)fast=n[fast][1];while(fast!==-1){fast=n[fast][1];slow=n[slow][1];}return slow;}',
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
    debug=run_case('function solve(){console.log("debug");return 42;}',[])
    rows.append({'check':'debug_print_keeps_result_protocol','passed':debug.get('result')==42,'result':debug})
    remaining=docker('ps','-a','--filter','label=dev.solveit.reference=true','--format','{{.Names}}')
    rows.append({'check':'container_cleanup','passed':not remaining})
    report={'kind':'local_development_authored_fixtures_not_security_certification','passed':sum(r['passed'] for r in rows),'total':len(rows),'checks':rows}
    Path('docs/REFERENCE_RUNNER_VALIDATION.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({'passed':report['passed'],'total':report['total']}))
    return 0 if all(r['passed'] for r in rows) else 1

if __name__ == '__main__': raise SystemExit(main())
