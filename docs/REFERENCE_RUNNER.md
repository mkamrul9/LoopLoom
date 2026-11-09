# Local reference runner

The runner executes three visible reference cases per supported lesson in C++, JavaScript, Python or TypeScript. All 25 problems in the one-week track and all 7 in its last-day subset now have suites. It is an opt-in private development service, **not a public arbitrary-code service or a verified-solve judge**. Reference matches never approve a checkpoint, complete reflection, or mark a problem solved.

## Run locally

Use Docker Desktop's Linux engine and the pinned Docker Official images:

- JavaScript and TypeScript: `node@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c` (Node 24.22.2).
- Python: `python@sha256:516b51cb9db2ef061e465c803e50f64361b82cefd91e525b889b967b83e83527`, downloaded from `python:3.14-slim-bookworm`. [Image packaging source](https://github.com/docker-library/python).
- C++17: `gcc@sha256:20eec427045c47d0aad1bd28c81d435916c327cd992240aa78350f755d04d04a`, the Docker Official `gcc:13.5.0-bookworm` image. [Image packaging source](https://github.com/docker-library/gcc). The downloaded image occupies about 2 GB on disk.

The runner selects the local `desktop-linux` context and refuses a non-local context endpoint, Windows containers, missing seccomp support, or a missing selected image. Health lists only installed, usable runtimes. A missing image affects only its language; no language falls back to another runtime or the host. Requests never pull images; obtain the desired pinned image explicitly when setting up another machine:

```powershell
docker --context desktop-linux pull gcc@sha256:20eec427045c47d0aad1bd28c81d435916c327cd992240aa78350f755d04d04a
```

From the repository root:

```powershell
./scripts/start-reference-runner.ps1 -Development
python -m unittest discover -s services/reference_runner -p 'test_*.py' -v
python services/reference_runner/live_check.py
python services/reference_runner/live_check_python.py
python services/reference_runner/live_check_typescript.py
python services/reference_runner/live_check_cpp.py
```

From `apps/solveit`, enable the client in a development build:

```powershell
flutter run -d chrome --web-port 8123 --dart-define=SOLVEIT_RUNNER_URL=http://127.0.0.1:8766
```

Android emulator builds use `http://10.0.2.2:8766`. The Android app also accepts a private LAN IPv4 runner address in **Profile & settings → Run your draft**. It connects only after you configure it. The PC or server must stay awake with Docker running; no compiler or model is bundled into the phone.

### Physical phone on trusted Wi-Fi

1. Connect phone and PC to the same trusted private network. Find the PC's Wi-Fi IPv4 address with `ipconfig`; it must be in `10.*`, `172.16–31.*`, or `192.168.*`.
2. On the PC, generate a random access token and start the runner bound to that exact address:

```powershell
$env:LOOPLOOM_RUNNER_TOKEN = python -c "import secrets; print(secrets.token_urlsafe(32))"
./scripts/start-reference-runner.ps1 -Development -ListenAddress 192.168.1.20
```

Replace `192.168.1.20` with the PC's address. Keep the token private. If Windows Firewall blocks the connection, allow inbound TCP 8766 on the **Private** network for this PC; do not open or forward the port to the internet.

3. On the phone, enter `http://PC-IP:8766` and the same token in **Profile & settings → Run your draft**. Save, open a one-week problem, advance to **Code**, write `solve`, and tap **Run reference cases**.

The token is stored in this device's local app preferences. LAN HTTP is unencrypted, so use this only on a trusted local network; do not place private code or credentials in submissions. Browser builds served over HTTPS cannot call a plain HTTP LAN runner because of browser mixed-content rules. For web use, configure a private HTTPS reverse proxy and a dedicated origin policy in a future runner deployment.

The one-week tree runner cases use heap-indexed level-order integer arrays with `-1` denoting an absent node. The linked-list cases use value arrays, except the existing cycle exercise, which uses indexed node/next rows. First Bad Version supplies `firstBad` as a second argument in place of the official API. These signatures are workbook adapters; adapt code to the official platform signature when submitting there.

In Settings, enter the private runner address and token, then choose **Test connection**. The app calls the authenticated `/health` endpoint without sending learner code and reports the languages ready on that PC. Save the connection after a successful check. The hosted HTTPS PWA cannot call this HTTP LAN service; use the Android app or the local web preview. A reachable service with no ready languages needs Docker and the pinned runtime images started on the runner PC.

At the Code checkpoint select C++, JavaScript, Python or TypeScript, implement synchronous `solve`, and choose **Run reference cases**. The response lists matches or wrong answers, compile/syntax/runtime errors, unsupported syntax, time/memory/output limits, or input modification for the interval task. An unavailable engine or failed container launch returns an infrastructure failure rather than a learner-code verdict. No source is executed on the host as fallback.

C++ uses GNU C++17. The compiler runs once, followed by all three visible cases in a fresh container. It supplies input through the lesson's `solve` signature and returns JSON values for the host checker. Compile errors are reported separately. The compiler requires a 64 MB executable `/tmp` for its output, 512 MB memory, one CPU, 64 processes and a 12 second total compile-and-run limit. Its root filesystem remains read-only, `/tmp` is private to the disposable container, and no host path is mounted. These limits are higher than the interpreter-only containers to allow compilation. For problems whose contract preserves input, mutation is reported separately.

TypeScript uses `node:module.stripTypeScriptTypes` in strip mode inside the container. It supports annotations, interfaces, aliases, generics and readonly tuple signatures that can be erased. **Types are not checked**; a type-invalid program can still run and match examples. Enums, parameter properties and runtime namespaces report `unsupported syntax`. Use one synchronous `solve` function without imports or exports; there is no multi-file project, tsconfig, JSX or external dependency installation. [Node 24 TypeScript documentation](https://nodejs.org/docs/latest-v24.x/api/typescript.html).

The parser needs WebAssembly, so TypeScript uses Node's normal execution mode with a 64 MB old-space heap limit; JavaScript retains `--jitless`. Docker's non-root, network, filesystem, capability and resource controls are identical. This mode is not a substitute for a full compiler/type-checking pipeline.

Python runs with `-I -B -u`: isolated interpreter configuration, no bytecode cache writes, and unbuffered output. These interpreter flags are not a security sandbox; Docker supplies the development boundary. Standard-library imports are available; external packages are not installed. [Python command-line documentation](https://docs.python.org/3.14/using/cmdline.html). Normal Python `print` and JavaScript console logs go to bounded stderr, keeping the result JSON separate. Logs are discarded rather than displayed or stored. Direct low-level stdout writes can invalidate the result protocol. Python booleans are not accepted as integer answers; unserializable or nonfinite outputs become runtime errors.

Results are transient and tied to the current lesson, language, and exact source. Editing clears them; replies arriving for a changed draft are discarded. Cursor movement preserves results. Reloading clears results. The existing saved draft, self-review, and assistance state remain independent.

Stop only the helper-owned idle service:

```powershell
./scripts/stop-reference-runner.ps1
```

The helper refuses to stop while a labeled runner container is active. Abruptly killing the host process or Docker can interrupt cleanup. Inspect only this project's containers with `docker --context desktop-linux ps -a --filter label=dev.solveit.reference=true`; never use a global prune to clean up the pilot.

## Execution boundary and limits

Each case starts a fresh disposable container. Source and arguments arrive on stdin; no host directory or Docker socket is mounted. The image is read-only, runs as UID/GID 65534, drops all capabilities, disallows privilege escalation, and uses Docker's default seccomp policy. Network access is disabled. A 16 MB noexec/nosuid temporary filesystem is available. Limits: 128 MB memory with no additional swap, half a CPU, 32 processes, 64 file descriptors, no core dumps, four seconds wall time including launch, and 32 KB captured output per stream. Docker logging is disabled. The server serializes requests and removes each uniquely named container after normal completion, timeout, or output-limit termination. [Docker run documentation](https://docs.docker.com/engine/containers/run/).

Docker containers share their engine's kernel and are not a sufficient production boundary for hostile public submissions. This developer service binds to loopback by default and can bind to one private LAN IPv4 address only with an explicit 32-character token. It permits only the two local preview origins, validates Host/JSON/body size, and has no paid/cloud or host-execution fallback. It does not log learner source. Production requires independently reviewed hardened isolation on separate infrastructure, authentication, quotas, monitoring, language harnesses, hidden tests, and authoritative result provenance.

The public reference cases can be hardcoded or their in-container harness spoofed by a submission. They establish only observed example behavior, never general correctness or tamper-resistant input-mutation evidence. Checks remain outside the container for returned values; pair tasks accept any valid distinct pair in either index order. No hidden test or trusted progress privilege is placed in the container.

## Verification

The [JavaScript report](REFERENCE_RUNNER_VALIDATION.json), [Python report](PYTHON_RUNNER_VALIDATION.json), [TypeScript report](TYPESCRIPT_RUNNER_VALIDATION.json) and [C++ report](CPP_RUNNER_VALIDATION.json) record prior trusted reference implementations, compile/syntax/runtime/timeout/output/memory fixtures, actual UID/root-filesystem/network probes, debug-output separation, and cleanup. Those reports predate the twenty-four lessons added after the original six-problem catalog; rerun the updated scripts before relying on runner results for the new examples. Python, TypeScript and C++ additionally check boolean rejection and mutation reporting. TypeScript probes also document unsupported syntax and the deliberate absence of semantic type checks. These authored probes are regression checks, not a sandbox security certification. Unit/HTTP tests cover validation, pair checking, fake-verification rejection, per-runtime readiness, infrastructure failures, required launch controls, host/origin restrictions, and request limits. Flutter tests cover language-aware bounded reply parsing, visible/server case consistency, stale replies, and edit/cursor invalidation.
