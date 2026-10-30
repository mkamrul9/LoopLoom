// Trusted protocol wrapper. Docker, not JavaScript evaluation, is the boundary.
const fs = require('node:fs');
const request = JSON.parse(fs.readFileSync(0, 'utf8'));
let solve;
try {
  solve = new Function(request.source + '\n; return solve;')();
} catch (error) {
  process.stdout.write(JSON.stringify({status: error instanceof SyntaxError ? 'syntax_error' : 'runtime_error'}));
  process.exit(0);
}
try {
  if (typeof solve !== 'function') throw new Error('Missing solve');
  const before = JSON.stringify(request.args);
  const result = solve(...request.args);
  process.stdout.write(JSON.stringify({status:'returned', result, mutated: JSON.stringify(request.args) !== before}));
} catch (_) {
  process.stdout.write(JSON.stringify({status:'runtime_error'}));
}
