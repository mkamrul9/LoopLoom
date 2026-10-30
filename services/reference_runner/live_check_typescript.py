"""Live erasable-TypeScript checks using authored fixtures, never learner drafts."""
import json
from pathlib import Path
from runner import docker, preflight, review, run_case

SOLUTIONS = {
    'supply-pair-v1': 'function solve(a: readonly number[],t: number): number[]{for(let i=0;i<a.length;i++)for(let j=i+1;j<a.length;j++)if(a[i]+a[j]===t)return [j,i];return [];}',
    'sorted-crates-v1': 'function solve(a: readonly number[],t: number): number[]{for(let i=0;i<a.length;i++)for(let j=i+1;j<a.length;j++)if(a[i]+a[j]===t)return [i,j];return [];}',
    'focus-block-v1': 'function solve(a: readonly number[],k: number): number{let best=-Infinity;for(let i=0;i+k<=a.length;i++){let s=0;for(let j=i;j<i+k;j++)s+=a[j];best=Math.max(best,s);}return best;}',
    'signal-ranges-v1': 'function solve(a: readonly number[],t: number): number{let count=0;for(let i=0;i<a.length;i++){let s=0;for(let j=i;j<a.length;j++){s+=a[j];if(s===t)count++;}}return count;}',
    'warmer-readings-v1': 'function solve(a: readonly number[]): number[]{return a.map((x,i)=>{for(let j=i+1;j<a.length;j++)if(a[j]>x)return j-i;return 0;});}',
    'busy-periods-v1': 'function solve(a: ReadonlyArray<readonly [number,number]>): Array<[number,number]>{const b=a.map(x=>[...x] as [number,number]).sort((x,y)=>x[0]-y[0]),r: Array<[number,number]>=[];for(const x of b){if(!r.length||x[0]>=r[r.length-1][1])r.push(x);else r[r.length-1][1]=Math.max(r[r.length-1][1],x[1]);}return r;}',
}


def main():
    preflight('typescript')
    rows=[]
    for lesson,source in SOLUTIONS.items():
        result=review({'lesson_id':lesson,'language':'typescript','source':source})
        rows.append({'check':lesson,'passed':result['language']=='typescript' and result['passed']==3 and not result['verified_solve'],'result':result})
        print(lesson,rows[-1]['passed'],flush=True)
    probes=[
        ('syntax_error','function solve(a: ): number { return 0; }','syntax_error'),
        ('unsupported_enum','enum X { A }; function solve(): number {return X.A;}','unsupported_syntax'),
        ('unsupported_parameter_property','class X {constructor(public a: number){}}; function solve(){return 0;}','unsupported_syntax'),
        ('runtime_error','function solve(): number {throw new Error("fixture");}','runtime_error'),
        ('time_limit','function solve(): number {while(true){}}','time_limit'),
        ('output_limit','function solve(): number {console.log("x".repeat(100000));return 0;}','output_limit'),
        ('memory_limit','function solve(): number {const a: Buffer[]=[];while(true)a.push(Buffer.alloc(1024*1024,1));}','memory_limit'),
    ]
    for label,source,expected in probes:
        result=run_case(source,[],'typescript')
        rows.append({'check':label,'passed':result['status']==expected,'result':result})
        print(label,rows[-1]['passed'],flush=True)
    probe=run_case('function solve(){let writable=true;try{require("fs").writeFileSync("/forbidden","x");}catch(e){writable=false;}return {uid:process.getuid(),writable,interfaces:Object.keys(require("os").networkInterfaces())};}',[],'typescript')
    value=probe.get('result',{})
    rows.append({'check':'uid_root_filesystem_and_network','passed':value.get('uid')==65534 and value.get('writable') is False and value.get('interfaces')==['lo'],'result':probe})
    debug=run_case('type Count=number; function solve(): Count {console.log("debug");return 42;}',[],'typescript')
    rows.append({'check':'type_alias_and_debug_output','passed':debug.get('result')==42,'result':debug})
    no_typecheck=run_case('function solve(): number {const deliberatelyWrong: number="fixture";return 42;}',[],'typescript')
    rows.append({'check':'explicitly_no_semantic_type_checking','passed':no_typecheck.get('result')==42,'result':no_typecheck})
    boolean=review({'lesson_id':'signal-ranges-v1','language':'typescript','source':'function solve(): boolean {return true;}'})
    rows.append({'check':'boolean_is_not_an_integer_answer','passed':boolean['passed']==0,'result':boolean})
    mutated=review({'lesson_id':'busy-periods-v1','language':'typescript','source':'function solve(a: number[][]): number[][] {a.push([99,100]);return [];}'})
    rows.append({'check':'mutating_input_is_reported','passed':all(c['status']=='input_modified' for c in mutated['cases']),'result':mutated})
    remaining=docker('ps','-a','--filter','label=dev.solveit.reference=true','--format','{{.Names}}')
    rows.append({'check':'container_cleanup','passed':not remaining})
    report={'kind':'local_development_authored_typescript_fixtures_not_security_certification','type_checking':False,'passed':sum(r['passed'] for r in rows),'total':len(rows),'checks':rows}
    Path('docs/TYPESCRIPT_RUNNER_VALIDATION.json').write_text(json.dumps(report,indent=2))
    print(json.dumps({'passed':report['passed'],'total':report['total']}))
    return 0 if all(r['passed'] for r in rows) else 1


if __name__=='__main__':raise SystemExit(main())
