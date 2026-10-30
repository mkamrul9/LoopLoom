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
