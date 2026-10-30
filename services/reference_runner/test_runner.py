import json
import unittest
from runner import CASES, RunnerUnavailable, command, matches, review, validate


class RunnerTests(unittest.TestCase):
    def test_validation_rejects_unknown_fields_and_unsupported_language_before_execution(self):
        valid = {'lesson_id':'signal-ranges-v1','language':'javascript','source':'function solve(){return 0;}'}
        for changed in ({'language':'python'},{'lesson_id':[]},{'source':'x'*32001},{'image':'remote:latest'}):
            with self.assertRaises(ValueError):
                review({**valid,**changed}, execute=lambda *_: self.fail('executed invalid input'), check=lambda:None)

    def test_pair_checker_accepts_order_and_rejects_values_reuse_boolean(self):
        case = CASES['supply-pair-v1'][0]
        self.assertTrue(matches('supply-pair-v1',case,[3,2]))
        for result in ([6,2],[2,2],[True,3],[-1,2]):
            self.assertFalse(matches('supply-pair-v1',case,result))

    def test_non_pair_results_require_exact_types_and_order(self):
        self.assertFalse(matches('signal-ranges-v1',{'expected':1},True))
        self.assertFalse(matches('signal-ranges-v1',{'expected':1},1.0))
        self.assertFalse(matches('warmer-readings-v1',{'expected':[1,0]},[0,1]))

    def test_all_matches_never_grant_verified_solve(self):
        index = iter(CASES['signal-ranges-v1'])
        result = review({'lesson_id':'signal-ranges-v1','language':'javascript','source':'placeholder'},
                        execute=lambda *_:{'status':'returned','result':next(index)['expected']}, check=lambda:None)
        self.assertEqual(result['passed'],3)
        self.assertIs(result['verified_solve'],False)

    def test_container_failure_is_not_a_wrong_answer(self):
        def offline(): raise RunnerUnavailable('offline')
        with self.assertRaises(RunnerUnavailable):
            review({'lesson_id':'signal-ranges-v1','language':'javascript','source':'placeholder'},check=offline)

    def test_launch_has_no_mounts_no_privileged_access_and_no_implicit_pull(self):
        args=command('solveit-reference-test')
        for flag in ('--network=none','--read-only','--user=65534:65534','--cap-drop=ALL','--security-opt=no-new-privileges',
                     '--memory=128m','--memory-swap=128m','--pids-limit=32','--pull=never'):
            self.assertIn(flag,args)
        for flag in ('--privileged','--volume','-v','--mount'):
            self.assertNotIn(flag,args)

if __name__ == '__main__': unittest.main()
