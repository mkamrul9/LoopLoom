"""Small reproducible development smoke set, not a held-out quality benchmark."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import statistics
import time
from server import INFERENCE_OPTIONS, PROMPT_VERSION, ollama_request, review


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--cases', type=Path, default=Path(__file__).with_name('evaluation_cases.json'))
    args = parser.parse_args()
    case_bytes = args.cases.read_bytes()
    cases = json.loads(case_bytes.decode('utf-8'))
    started_at = datetime.now(timezone.utc).isoformat()
    tags = ollama_request('/api/tags')['models']
    selected = next(item for item in tags if item['name'] == args.model)
    results = []
    for case in cases:
        payload = {key: case[key] for key in ('lesson_id', 'stage', 'language', 'answer')}
        payload['previous_answers'] = []
        started = time.monotonic()
        try:
            result = review(payload, args.model)
            text = (result['feedback'] + ' ' + result['next_question']).lower()
            matches = result['outcome'] in case['expected']
            forbidden = [phrase for phrase in case['forbidden'] if phrase in text]
            item = {'id': case['id'], 'expected': case['expected'], 'response': result,
                    'contract_ok': True, 'expected_outcome_match': matches,
                    'forbidden_phrase_matches': forbidden, 'passed': matches and not forbidden}
        except Exception as error:
            item = {'id': case['id'], 'expected': case['expected'], 'contract_ok': False,
                    'passed': False, 'error_type': type(error).__name__, 'error': str(error)}
        item['seconds'] = round(time.monotonic() - started, 3)
        results.append(item)
        print(f"{case['id']}: {'PASS' if item['passed'] else 'FAIL'} ({item['seconds']} s)", flush=True)
        # Save each completed case so interrupted evaluations remain inspectable.
        report = {'kind': 'development_smoke_set_not_held_out', 'model': args.model,
                  'model_digest': selected['digest'], 'runtime': ollama_request('/api/version'),
                  'prompt_version': PROMPT_VERSION, 'inference_options': INFERENCE_OPTIONS,
                  'thinking': False, 'cases_sha256': hashlib.sha256(case_bytes).hexdigest(),
                  'started_at_utc': started_at, 'cases_completed': len(results),
                  'cases_total': len(cases), 'passed': sum(row['passed'] for row in results),
                  'median_seconds': round(statistics.median(row['seconds'] for row in results), 3),
                  'release_approved': False,
                  'results': results}
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2), encoding='utf-8')
    # Even a clean smoke set still requires independent held-out and human review.
    return 0 if results and all(row['passed'] for row in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
