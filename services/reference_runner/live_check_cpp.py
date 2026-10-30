"""Live C++17 container checks from authored fixtures, never learner drafts."""
import json
from pathlib import Path
from runner import CASES, docker, preflight, review, run_cpp_suite

SOLUTIONS = {
    'supply-pair-v1': 'vector<int> solve(const vector<int>& a,int t){for(int i=0;i<(int)a.size();++i)for(int j=i+1;j<(int)a.size();++j)if(a[i]+a[j]==t)return {j,i};return {};}',
    'sorted-crates-v1': 'vector<int> solve(const vector<int>& a,int t){for(int i=0;i<(int)a.size();++i)for(int j=i+1;j<(int)a.size();++j)if(a[i]+a[j]==t)return {i,j};return {};}',
    'focus-block-v1': 'int solve(const vector<int>& a,int k){int best=INT_MIN;for(int i=0;i+k<=(int)a.size();++i){int s=0;for(int j=i;j<i+k;++j)s+=a[j];best=max(best,s);}return best;}',
    'signal-ranges-v1': 'int solve(const vector<int>& a,int t){int count=0;for(int i=0;i<(int)a.size();++i){int s=0;for(int j=i;j<(int)a.size();++j){s+=a[j];if(s==t)++count;}}return count;}',
    'warmer-readings-v1': 'vector<int> solve(const vector<int>& a){vector<int> out(a.size());for(int i=0;i<(int)a.size();++i)for(int j=i+1;j<(int)a.size();++j)if(a[j]>a[i]){out[i]=j-i;break;}return out;}',
    'busy-periods-v1': 'vector<vector<int>> solve(const vector<vector<int>>& a){auto b=a;sort(b.begin(),b.end());vector<vector<int>> out;for(auto x:b){if(out.empty()||x[0]>=out.back()[1])out.push_back(x);else out.back()[1]=max(out.back()[1],x[1]);}return out;}',
    'rotated-index-v1': 'int solve(const vector<int>& a,int t){int l=0,r=(int)a.size()-1;while(l<=r){int m=l+(r-l)/2;if(a[m]==t)return m;if(a[l]<=a[m]){if(a[l]<=t&&t<a[m])r=m-1;else l=m+1;}else{if(a[m]<t&&t<=a[r])l=m+1;else r=m-1;}}return -1;}',
    'products-except-self-v1': 'vector<int> solve(const vector<int>& a){vector<int> out(a.size(),1);int p=1;for(int i=0;i<(int)a.size();++i){out[i]=p;p*=a[i];}p=1;for(int i=(int)a.size()-1;i>=0;--i){out[i]*=p;p*=a[i];}return out;}',
    'longest-run-v1': 'int solve(const vector<int>& a){unordered_set<int> s(a.begin(),a.end());int best=0;for(int x:s){if(!s.count(x-1)){int n=1;while(s.count(x+n))++n;best=max(best,n);}}return best;}',
    'budget-window-v1': 'int solve(const vector<int>& a,int k){int left=0,sum=0,best=0;for(int right=0;right<(int)a.size();++right){sum+=a[right];while(sum>k)sum-=a[left++];best=max(best,right-left+1);}return best;}',
    'lower-bound-v1': 'int solve(const vector<int>& a,int t){int left=0,right=a.size();while(left<right){int mid=left+(right-left)/2;if(a[mid]<t)left=mid+1;else right=mid;}return left;}',
    'island-count-v1': 'int solve(const vector<vector<int>>& g){int rows=g.size(),cols=rows?g[0].size():0,count=0;vector<vector<char>> seen(rows,vector<char>(cols));int d[4][2]={{1,0},{-1,0},{0,1},{0,-1}};for(int r=0;r<rows;++r)for(int c=0;c<cols;++c){if(!g[r][c]||seen[r][c])continue;++count;queue<pair<int,int>> q;q.push({r,c});seen[r][c]=1;while(!q.empty()){auto [y,x]=q.front();q.pop();for(auto& step:d){int ny=y+step[0],nx=x+step[1];if(ny>=0&&ny<rows&&nx>=0&&nx<cols&&g[ny][nx]&&!seen[ny][nx]){seen[ny][nx]=1;q.push({ny,nx});}}}}return count;}',
    'max-subarray-v1': 'int solve(const vector<int>& a){int ending=a[0],best=a[0];for(int i=1;i<(int)a.size();++i){ending=max(a[i],ending+a[i]);best=max(best,ending);}return best;}',
    'single-trade-v1': 'int solve(const vector<int>& a){int low=INT_MAX,best=0;for(int p:a){if(low!=INT_MAX)best=max(best,p-low);low=min(low,p);}return best;}',
    'graph-components-v1': 'int solve(const vector<vector<int>>& g){vector<char> seen(g.size());int count=0;for(int start=0;start<(int)g.size();++start){if(seen[start])continue;++count;seen[start]=1;queue<int> q;q.push(start);while(!q.empty()){int node=q.front();q.pop();for(int v:g[node])if(!seen[v]){seen[v]=1;q.push(v);}}}return count;}',
    'first-signal-v1': 'int solve(const string& s){int counts[26]={};for(char c:s)++counts[c-\'a\'];for(int i=0;i<(int)s.size();++i)if(counts[s[i]-\'a\']==1)return i;return -1;}',
    'anagram-pair-v1': 'bool solve(const string& a,const string& b){if(a.size()!=b.size())return false;int counts[26]={};for(char c:a)++counts[c-\'a\'];for(char c:b)--counts[c-\'a\'];for(int n:counts)if(n)return false;return true;}',
    'distinct-letter-window-v1': 'int solve(const string& s){vector<int> last(26,-1);int left=0,best=0;for(int i=0;i<(int)s.size();++i){int c=s[i]-\'a\';left=max(left,last[c]+1);last[c]=i;best=max(best,i-left+1);}return best;}',
    'kth-score-v1': 'int solve(const vector<int>& a,int k){auto copy=a;sort(copy.rbegin(),copy.rend());return copy[k-1];}',
    'top-frequency-v1': 'vector<int> solve(const vector<int>& a,int k){unordered_map<int,int> count;for(int x:a)++count[x];vector<pair<int,int>> ranked;for(auto [x,n]:count)ranked.push_back({x,n});sort(ranked.begin(),ranked.end(),[](auto x,auto y){return x.second!=y.second?x.second>y.second:x.first<y.first;});vector<int> out;for(int i=0;i<k;++i)out.push_back(ranked[i].first);sort(out.begin(),out.end());return out;}',
    'merge-streams-v1': 'vector<int> solve(const vector<vector<int>>& a){using Item=tuple<int,int,int>;priority_queue<Item,vector<Item>,greater<Item>> q;for(int r=0;r<(int)a.size();++r)if(!a[r].empty())q.push({a[r][0],r,0});vector<int> out;while(!q.empty()){auto [x,r,i]=q.top();q.pop();out.push_back(x);if(++i<(int)a[r].size())q.push({a[r][i],r,i});}return out;}',
    'tree-depth-v1': 'int solve(const vector<vector<int>>& t){if(t.empty())return 0;queue<pair<int,int>> q;q.push({0,1});int best=0;while(!q.empty()){auto [i,d]=q.front();q.pop();best=max(best,d);if(t[i][1]!=-1)q.push({t[i][1],d+1});if(t[i][2]!=-1)q.push({t[i][2],d+1});}return best;}',
    'tree-width-v1': 'int solve(const vector<vector<int>>& t){if(t.empty())return 0;queue<int> q;q.push(0);int best=0;while(!q.empty()){int n=q.size();best=max(best,n);while(n--){int i=q.front();q.pop();if(t[i][1]!=-1)q.push(t[i][1]);if(t[i][2]!=-1)q.push(t[i][2]);}}return best;}',
    'tree-path-sum-v1': 'bool solve(const vector<vector<int>>& t,int target){if(t.empty())return false;stack<pair<int,int>> q;q.push({0,t[0][0]});while(!q.empty()){auto [i,sum]=q.top();q.pop();int l=t[i][1],r=t[i][2];if(l==-1&&r==-1&&sum==target)return true;if(l!=-1)q.push({l,sum+t[l][0]});if(r!=-1)q.push({r,sum+t[r][0]});}return false;}',
    'list-middle-v1': 'int solve(const vector<vector<int>>& n){if(n.empty())return -1;int slow=0,fast=0;while(fast!=-1&&n[fast][1]!=-1){slow=n[slow][1];fast=n[n[fast][1]][1];}return slow;}',
    'list-cycle-v1': 'bool solve(const vector<vector<int>>& n){if(n.empty())return false;int slow=0,fast=0;while(fast!=-1&&n[fast][1]!=-1){slow=n[slow][1];fast=n[n[fast][1]][1];if(slow==fast)return true;}return false;}',
    'list-nth-from-end-v1': 'int solve(const vector<vector<int>>& n,int k){int fast=0,slow=0;for(int i=0;i<k;++i)fast=n[fast][1];while(fast!=-1){fast=n[fast][1];slow=n[slow][1];}return slow;}',
    'subset-sum-v1': 'bool solve(const vector<int>& a,int target){function<bool(int,int)> search=[&](int i,int r){if(r==0)return true;if(i==(int)a.size())return false;return search(i+1,r)||search(i+1,r-a[i]);};return search(0,target);}',
    'combination-count-v1': 'int solve(const vector<int>& a,int target){function<int(int,int)> search=[&](int i,int r){if(r==0)return 1;if(r<0||i==(int)a.size())return 0;return search(i,r-a[i])+search(i+1,r);};return search(0,target);}',
    'target-sum-ways-v1': 'int solve(const vector<int>& a,int target){function<int(int,int)> search=[&](int i,int r){if(i==(int)a.size())return r==0?1:0;return search(i+1,r-a[i])+search(i+1,r+a[i]);};return search(0,target);}',
}


def main():
    preflight('cpp')
    rows=[]
    for lesson,source in SOLUTIONS.items():
        result=review({'lesson_id':lesson,'language':'cpp','source':source})
        rows.append({'check':lesson,'passed':result['language']=='cpp' and result['passed']==3 and not result['verified_solve'],'result':result})
        print(lesson,rows[-1]['passed'],flush=True)

    probes=[
        ('compile_error','int solve(vector<int> a,int t){return ;}', 'compile_error'),
        ('runtime_error','int solve(vector<int> a,int t){throw runtime_error("fixture");}', 'runtime_error'),
        ('time_limit','int solve(vector<int> a,int t){while(true){}}', 'time_limit'),
        ('output_limit','int solve(vector<int> a,int t){cout<<string(100000,\'x\');return 0;}', 'output_limit'),
        ('memory_limit','int solve(vector<int> a,int t){vector<char> huge(600*1024*1024,1);return huge[0];}', 'memory_limit'),
    ]
    for label,source,expected in probes:
        result=review({'lesson_id':'signal-ranges-v1','language':'cpp','source':source})
        rows.append({'check':label,'passed':all(case['status']==expected for case in result['cases']),'result':result})
        print(label,rows[-1]['passed'],flush=True)

    probe='#include <unistd.h>\n#include <fcntl.h>\n#include <sys/socket.h>\n#include <arpa/inet.h>\nint solve(vector<int> a,int t){const int uid=geteuid();bool writable=false;int fd=open("/solveit-forbidden",O_WRONLY|O_CREAT,0600);if(fd>=0){writable=true;close(fd);}int s=socket(AF_INET,SOCK_STREAM,0);sockaddr_in addr{};addr.sin_family=AF_INET;addr.sin_port=htons(9);inet_pton(AF_INET,"1.1.1.1",&addr.sin_addr);bool connected=s>=0&&connect(s,(sockaddr*)&addr,sizeof(addr))==0;if(s>=0)close(s);return uid==65534&&!writable&&!connected?42:0;}'
    result=run_cpp_suite(probe,CASES['signal-ranges-v1'],'signal-ranges-v1')
    rows.append({'check':'uid_root_filesystem_and_network','passed':all(item.get('result')==42 for item in result),'result':result})

    debug_source=SOLUTIONS['signal-ranges-v1'].replace('{','{cout<<"debug output\\n";',1)
    debug=review({'lesson_id':'signal-ranges-v1','language':'cpp','source':debug_source})
    rows.append({'check':'debug_output_keeps_result_protocol','passed':debug['passed']==3,'result':debug})
    boolean=review({'lesson_id':'signal-ranges-v1','language':'cpp','source':'bool solve(vector<int> a,int t){return true;}'})
    rows.append({'check':'boolean_is_not_an_integer_answer','passed':boolean['passed']==0,'result':boolean})
    mutated=review({'lesson_id':'busy-periods-v1','language':'cpp','source':'vector<vector<int>> solve(vector<vector<int>>& a){a.push_back({99,100});return {};}'})
    rows.append({'check':'mutating_input_is_reported','passed':all(c['status']=='input_modified' for c in mutated['cases']),'result':mutated})
    remaining=docker('ps','-a','--filter','label=dev.solveit.reference=true','--format','{{.Names}}')
    rows.append({'check':'container_cleanup','passed':not remaining})

    report={'kind':'local_development_authored_cpp_fixtures_not_security_certification','compiler':'GNU C++17','passed':sum(r['passed'] for r in rows),'total':len(rows),'checks':rows}
    Path('docs/CPP_RUNNER_VALIDATION.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({'passed':report['passed'],'total':report['total']}))
    return 0 if all(r['passed'] for r in rows) else 1


if __name__=='__main__':
    raise SystemExit(main())
