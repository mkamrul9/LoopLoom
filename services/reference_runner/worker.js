// Trusted protocol wrapper. Docker, not JavaScript evaluation, is the boundary.
const fs = require('node:fs');
const request = JSON.parse(fs.readFileSync(0, 'utf8'));
// Keep ordinary debug logs out of the result protocol; stderr stays bounded.
global.console = new (require('node:console').Console)({stdout:process.stderr, stderr:process.stderr});
let solve;
try {
  // Language comes from our fixed launch arguments, never learner-controlled JSON.
  const source = process.argv[1] === 'typescript'
    ? require('node:module').stripTypeScriptTypes(request.source, {mode:'strip'})
    : request.source;
  solve = new Function(source + '\n; return solve;')();
} catch (error) {
  const status = error.code === 'ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX' ? 'unsupported_syntax'
    : error instanceof SyntaxError || error.code === 'ERR_INVALID_TYPESCRIPT_SYNTAX' ? 'syntax_error' : 'runtime_error';
  process.stdout.write(JSON.stringify({status}));
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
