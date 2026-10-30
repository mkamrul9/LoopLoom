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
    'rotated-index-v1': 'def solve(a,t):\n l,r=0,len(a)-1\n while l<=r:\n  m=(l+r)//2\n  if a[m]==t:return m\n  if a[l]<=a[m]:\n   if a[l]<=t<a[m]:r=m-1\n   else:l=m+1\n  elif a[m]<t<=a[r]:l=m+1\n  else:r=m-1\n return -1',
    'products-except-self-v1': 'def solve(a):\n out=[1]*len(a)\n p=1\n for i,x in enumerate(a):out[i]=p;p*=x\n p=1\n for i in range(len(a)-1,-1,-1):out[i]*=p;p*=a[i]\n return out',
    'longest-run-v1': 'def solve(a):\n s=set(a);best=0\n for x in s:\n  if x-1 not in s:\n   n=1\n   while x+n in s:n+=1\n   best=max(best,n)\n return best',
    'budget-window-v1': 'def solve(a,k):\n left=total=best=0\n for right,x in enumerate(a):\n  total+=x\n  while total>k:total-=a[left];left+=1\n  best=max(best,right-left+1)\n return best',
    'lower-bound-v1': 'def solve(a,t):\n left,right=0,len(a)\n while left<right:\n  mid=left+(right-left)//2\n  if a[mid]<t:left=mid+1\n  else:right=mid\n return left',
    'island-count-v1': 'def solve(g):\n rows=len(g);cols=len(g[0]) if rows else 0;seen=set();count=0\n for r in range(rows):\n  for c in range(cols):\n   if not g[r][c] or (r,c) in seen:continue\n   count+=1;seen.add((r,c));q=[(r,c)];head=0\n   while head<len(q):\n    y,x=q[head];head+=1\n    for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):\n     ny,nx=y+dy,x+dx\n     if 0<=ny<rows and 0<=nx<cols and g[ny][nx] and (ny,nx) not in seen:seen.add((ny,nx));q.append((ny,nx))\n return count',
    'max-subarray-v1': 'def solve(a):\n ending=best=a[0]\n for x in a[1:]:ending=max(x,ending+x);best=max(best,ending)\n return best',
    'single-trade-v1': 'def solve(a):\n low=float("inf");best=0\n for p in a:\n  if low!=float("inf"):best=max(best,p-low)\n  low=min(low,p)\n return best',
    'graph-components-v1': 'def solve(g):\n seen=set();count=0\n for start in range(len(g)):\n  if start in seen:continue\n  count+=1;seen.add(start);q=[start];head=0\n  while head<len(q):\n   node=q[head];head+=1\n   for v in g[node]:\n    if v not in seen:seen.add(v);q.append(v)\n return count',
    'first-signal-v1': 'def solve(s):\n counts=[0]*26\n for c in s:counts[ord(c)-97]+=1\n for i,c in enumerate(s):\n  if counts[ord(c)-97]==1:return i\n return -1',
    'anagram-pair-v1': 'def solve(a,b):\n if len(a)!=len(b):return False\n counts=[0]*26\n for c in a:counts[ord(c)-97]+=1\n for c in b:counts[ord(c)-97]-=1\n return all(x==0 for x in counts)',
    'distinct-letter-window-v1': 'def solve(s):\n last=[-1]*26;left=best=0\n for right,c in enumerate(s):\n  x=ord(c)-97;left=max(left,last[x]+1);last[x]=right;best=max(best,right-left+1)\n return best',
    'kth-score-v1': 'def solve(a,k):\n return sorted(a,reverse=True)[k-1]',
    'top-frequency-v1': 'def solve(a,k):\n from collections import Counter\n return sorted(x for x,n in sorted(Counter(a).items(),key=lambda p:(-p[1],p[0]))[:k])',
    'merge-streams-v1': 'def solve(a):\n import heapq\n return list(heapq.merge(*a))',
    'tree-depth-v1': 'def solve(t):\n if not t:return 0\n q=[(0,1)];head=0;best=0\n while head<len(q):\n  i,d=q[head];head+=1;best=max(best,d)\n  for child in t[i][1:]:\n   if child!=-1:q.append((child,d+1))\n return best',
    'tree-width-v1': 'def solve(t):\n if not t:return 0\n q=[0];head=0;best=0\n while head<len(q):\n  end=len(q);best=max(best,end-head)\n  while head<end:\n   i=q[head];head+=1\n   for child in t[i][1:]:\n    if child!=-1:q.append(child)\n return best',
    'tree-path-sum-v1': 'def solve(t,target):\n if not t:return False\n stack=[(0,t[0][0])]\n while stack:\n  i,total=stack.pop();left,right=t[i][1:]\n  if left==-1 and right==-1 and total==target:return True\n  if left!=-1:stack.append((left,total+t[left][0]))\n  if right!=-1:stack.append((right,total+t[right][0]))\n return False',
    'list-middle-v1': 'def solve(n):\n if not n:return -1\n slow=fast=0\n while fast!=-1 and n[fast][1]!=-1:\n  slow=n[slow][1];fast=n[n[fast][1]][1]\n return slow',
    'list-cycle-v1': 'def solve(n):\n if not n:return False\n slow=fast=0\n while fast!=-1 and n[fast][1]!=-1:\n  slow=n[slow][1];fast=n[n[fast][1]][1]\n  if slow==fast:return True\n return False',
    'list-nth-from-end-v1': 'def solve(n,k):\n fast=slow=0\n for _ in range(k):fast=n[fast][1]\n while fast!=-1:\n  fast=n[fast][1];slow=n[slow][1]\n return slow',
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
