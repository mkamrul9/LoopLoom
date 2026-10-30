# Local reference runner

The runner executes the three visible reference cases for each of the six lessons in JavaScript or Python. It is an opt-in local development experiment, **not a public arbitrary-code service or a verified-solve judge**. C++ and TypeScript remain drafting-only. Reference matches never approve a checkpoint, complete reflection, or mark a problem solved.

## Run locally

Use Docker Desktop's Linux engine and the pinned Docker Official images:

- JavaScript: `node@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c`.
- Python: `python@sha256:516b51cb9db2ef061e465c803e50f64361b82cefd91e525b889b967b83e83527`, downloaded from `python:3.14-slim-bookworm`. [Image packaging source](https://github.com/docker-library/python).

The runner selects the local `desktop-linux` context and refuses a non-local context endpoint, Windows containers, missing seccomp support, or a missing selected image. Health lists only installed, usable runtimes. A missing Python image does not disable JavaScript, and neither language falls back to another runtime or the host. Requests never pull images; obtain the desired pinned image explicitly when setting up another machine.

From the repository root:

```powershell
./scripts/start-reference-runner.ps1 -Development
python -m unittest discover -s services/reference_runner -p 'test_*.py' -v
python services/reference_runner/live_check.py
python services/reference_runner/live_check_python.py
```

From `apps/solveit`, enable the client in a development build:

```powershell
flutter run -d chrome --web-port 8123 --dart-define=SOLVEIT_RUNNER_URL=http://127.0.0.1:8766
```

Android emulator builds use `http://10.0.2.2:8766`. Physical-phone LAN access is not configured. The normal APK has no runner URL and makes no execution requests. The current web preview explicitly enables the local development runner.

At the Code checkpoint select JavaScript or Python, implement synchronous `solve`, and choose **Run reference cases**. The response lists matches or wrong answers, syntax/runtime errors, time/memory/output limits, or input modification for the interval task. An unavailable engine or failed container launch returns an infrastructure failure rather than a learner-code verdict. No source is executed on the host as fallback.

Python runs with `-I -B -u`: isolated interpreter configuration, no bytecode cache writes, and unbuffered output. These interpreter flags are not a security sandbox; Docker supplies the development boundary. Standard-library imports are available; external packages are not installed. [Python command-line documentation](https://docs.python.org/3.14/using/cmdline.html). Normal Python `print` and JavaScript console logs go to bounded stderr, keeping the result JSON separate. Logs are discarded rather than displayed or stored. Direct low-level stdout writes can invalidate the result protocol. Python booleans are not accepted as integer answers; unserializable or nonfinite outputs become runtime errors.

Results are transient and tied to the current lesson, language, and exact source. Editing clears them; replies arriving for a changed draft are discarded. Cursor movement preserves results. Reloading clears results. The existing saved draft, self-review, and assistance state remain independent.

Stop only the helper-owned idle service:

```powershell
./scripts/stop-reference-runner.ps1
```

The helper refuses to stop while a labeled runner container is active. Abruptly killing the host process or Docker can interrupt cleanup. Inspect only this project's containers with `docker --context desktop-linux ps -a --filter label=dev.solveit.reference=true`; never use a global prune to clean up the pilot.

## Execution boundary and limits

Each case starts a fresh disposable container. Source and arguments arrive on stdin; no host directory or Docker socket is mounted. The image is read-only, runs as UID/GID 65534, drops all capabilities, disallows privilege escalation, and uses Docker's default seccomp policy. Network access is disabled. A 16 MB noexec/nosuid temporary filesystem is available. Limits: 128 MB memory with no additional swap, half a CPU, 32 processes, 64 file descriptors, no core dumps, four seconds wall time including launch, and 32 KB captured output per stream. Docker logging is disabled. The server serializes requests and removes each uniquely named container after normal completion, timeout, or output-limit termination. [Docker run documentation](https://docs.docker.com/engine/containers/run/).

Docker containers share their engine's kernel and are not a sufficient production boundary for hostile public submissions. This developer service is bound to loopback, has an explicit development startup flag, permits only the two local preview origins, validates Host/JSON/body size, and has no paid/cloud or host-execution fallback. It does not log learner source. Production requires independently reviewed hardened isolation on separate infrastructure, authentication, quotas, monitoring, language harnesses, hidden tests, and authoritative result provenance.

The public reference cases can be hardcoded or their in-container harness spoofed by a submission. They establish only observed example behavior, never general correctness or tamper-resistant input-mutation evidence. Checks remain outside the container for returned values; pair tasks accept any valid distinct pair in either index order. No hidden test or trusted progress privilege is placed in the container.

## Verification

The [JavaScript report](REFERENCE_RUNNER_VALIDATION.json) and [Python report](PYTHON_RUNNER_VALIDATION.json) record trusted reference implementations, syntax/runtime/timeout/output/memory fixtures, actual UID/root-filesystem/network probes, debug-output separation, and cleanup. Python additionally checks boolean rejection and mutation reporting. These authored probes are regression checks, not a sandbox security certification. Unit/HTTP tests cover validation, pair checking, fake-verification rejection, per-runtime readiness, infrastructure failures, required launch controls, host/origin restrictions, and request limits. Flutter tests cover language-aware bounded reply parsing, visible/server case consistency, stale replies, and edit/cursor invalidation.
