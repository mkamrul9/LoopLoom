part of 'engineering_course.dart';

const backendLessons = <EngineeringLesson>[
  EngineeringLesson(
    id: 'backend-request',
    unit: 'Request foundations',
    title: 'Follow a request',
    summary: 'Trace browser → server → response.',
    concept:
        'A backend receives a request, chooses a handler, reads trusted server state, and returns a response. The network boundary is where client input becomes untrusted input.',
    why:
        'Tracing the full path helps locate failures: a missing route, rejected input, database error, or incorrect response.',
    when:
        'Start here whenever a feature depends on data or actions outside the browser.',
    how:
        'Read the method and URL, route to a handler, perform the operation, then return a status, headers, and body.',
    codeLabel: 'TYPESCRIPT · WEB REQUEST API',
    code: '''function handle(request: Request): Response {
  const path = new URL(request.url).pathname;
  if (request.method === 'GET' && path === '/health') {
    return Response.json({ status: 'ok' });
  }
  return Response.json({ error: 'Not found' }, { status: 404 });
}''',
    result:
        'GET /health returns 200 and a small JSON body; an unknown path returns 404.',
    application:
        'The shop app asks the API for products. The API routes the request, reads products, and sends JSON for the catalog screen.',
    appCode: '''const response = await fetch('/api/products');
if (!response.ok) throw new Error('Catalog unavailable');
const products = await response.json();''',
    alternative:
        'A server-rendered page can send HTML instead of JSON. The same request and response boundary still applies.',
    pitfall:
        'A successful TCP connection does not mean the application returned a successful HTTP response.',
    traceInput: ['GET /api/products', 'route: products', 'data: two products'],
    trace: [
      EngineeringTraceStep(
        'Receive',
        'The server reads the method and URL.',
        [0],
        ['request received'],
      ),
      EngineeringTraceStep(
        'Handle',
        'The products route reads catalog data.',
        [1, 2],
        ['two rows loaded'],
      ),
      EngineeringTraceStep(
        'Respond',
        'The handler sends JSON and a success status.',
        [0, 1, 2],
        ['200 · product array'],
      ),
    ],
    check:
        'Where should a product read failure be diagnosed: before routing, in the handler, or in rendering?',
    answer:
        'Trace each boundary. If the route matched and the data read failed, diagnose the handler/data layer; rendering is downstream.',
  ),
  EngineeringLesson(
    id: 'backend-http',
    unit: 'Request foundations',
    title: 'Methods and status codes',
    summary: 'Make an API contract predictable.',
    concept:
        'HTTP methods express the intended operation; status codes describe the outcome. A client should not have to infer success from the shape of a text message.',
    why:
        'Clear method and status choices let browser, mobile, tests, caches, and monitoring agree on what happened.',
    when:
        'Design a new endpoint or review an endpoint that handles both success and failure.',
    how:
        'Use GET to read, POST to create or trigger, PATCH to change part of a resource, and DELETE to remove. Return an appropriate 2xx, 4xx, or 5xx outcome.',
    codeLabel: 'TYPESCRIPT · WEB RESPONSE API',
    code: '''function created(order: { id: number }): Response {
  return Response.json(order, {
    status: 201,
    headers: { Location: '/api/orders/' + order.id },
  });
}''',
    result:
        'A created order returns 201 and a Location header pointing to its resource.',
    application:
        'Checkout creates an order. The client can navigate to its detail URL after the API returns 201.',
    appCode: '''const response = await fetch('/api/orders', {
  method: 'POST', body: JSON.stringify(cart),
  headers: { 'Content-Type': 'application/json' },
});
if (response.status === 201) openOrder(await response.json());''',
    alternative:
        'A command endpoint can use POST even if it does not create a conventional resource; document its response carefully.',
    pitfall:
        'Do not return 200 for every outcome and hide validation or authorization failures inside the JSON body.',
    traceInput: ['POST /api/orders', 'valid cart', 'new order #41'],
    trace: [
      EngineeringTraceStep(
        'Intent',
        'POST signals creation or processing.',
        [0],
        ['create requested'],
      ),
      EngineeringTraceStep(
        'Process',
        'The server validates and stores the order.',
        [1, 2],
        ['order #41 stored'],
      ),
      EngineeringTraceStep(
        'Result',
        '201 and Location describe the created resource.',
        [0, 2],
        ['201 · /api/orders/41'],
      ),
    ],
    check: 'Should a malformed cart return 201, 400, or 500?',
    answer:
        'Use a 4xx client error such as 400 for malformed input. 201 means creation succeeded; 500 is for an unexpected server failure.',
  ),
  EngineeringLesson(
    id: 'backend-routes',
    unit: 'Request foundations',
    title: 'Routes and resource IDs',
    summary: 'Turn URLs into deliberate handlers.',
    concept:
        'A route maps a method and path to one handler. Path parameters identify resources; query parameters usually adjust a read, such as filtering or pagination.',
    why:
        'A stable URL contract lets multiple clients use the same service without sharing implementation details.',
    when: 'Expose product details, orders, profiles, or filtered lists.',
    how:
        'Parse the URL, validate the path ID, check access, and return one consistent response shape.',
    codeLabel: 'TYPESCRIPT · WEB REQUEST API',
    code: '''function productId(request: Request): number | null {
  const match = new URL(request.url).pathname.match(new RegExp('^/api/products/([0-9]+)\$'));
  if (!match) return null;
  const id = Number(match[1]);
  return Number.isSafeInteger(id) && id > 0 ? id : null;
}''',
    result:
        '/api/products/12 yields 12; a nonnumeric or unsafe ID is rejected.',
    application:
        'A product detail page loads one product by URL ID while the catalog uses /api/products with optional query filters.',
    appCode: '''const id = productId(request);
if (id === null) return Response.json(
  { error: 'Invalid product ID' }, { status: 400 });
const product = await products.findById(id);''',
    alternative:
        'A router library handles matching and parameter extraction; validation and authorization still belong to your application.',
    pitfall:
        'A well-formed ID is not proof that the requested resource exists or belongs to the caller.',
    traceInput: ['/api/products/12', 'path ID: 12', 'product row: 12'],
    trace: [
      EngineeringTraceStep(
        'Match',
        'The path matches the product-detail route.',
        [0],
        ['route selected'],
      ),
      EngineeringTraceStep(
        'Parse',
        'The ID becomes a safe positive integer.',
        [1],
        ['id = 12'],
      ),
      EngineeringTraceStep(
        'Load',
        'The repository reads product 12.',
        [2],
        ['product detail'],
      ),
    ],
    check:
        'What is the difference between a route parameter and an ownership check?',
    answer:
        'The route parameter identifies a candidate resource. An ownership check decides whether this caller may access it.',
  ),
  EngineeringLesson(
    id: 'backend-validation',
    unit: 'Request foundations',
    title: 'Validate at the boundary',
    summary: 'Reject bad shapes and bad values.',
    concept:
        'Validation checks both syntax and meaning. A JSON object can parse correctly and still contain an impossible quantity, unknown field, or invalid workflow state.',
    why:
        'The server must protect its rules even when a client is buggy, old, or deliberately modified.',
    when:
        'Before storing, charging, sending, or acting on any client-supplied data.',
    how:
        'Limit request size, parse safely, check types and allowed fields, then validate business rules. Return a useful 4xx response.',
    codeLabel: 'TYPESCRIPT · VALIDATION FUNCTION',
    code: '''function parseQuantity(value: unknown): number | null {
  if (typeof value !== 'number') return null;
  if (!Number.isSafeInteger(value) || value < 1 || value > 99) return null;
  return value;
}''',
    result: '2 is accepted; 0, 2.5, and the string "2" are rejected.',
    application:
        'A cart API checks quantity on the server before reserving stock. The form can also validate for fast feedback, but it cannot replace the server check.',
    appCode: '''const body: unknown = await request.json();
if (!body || typeof body !== 'object' || !('quantity' in body)) {
  return Response.json({ error: 'Quantity required' }, { status: 400 });
}
const quantity = parseQuantity(body.quantity);''',
    alternative:
        'A schema-validation library can express the same contract declaratively and generate reusable error details.',
    pitfall:
        'Rejecting apostrophes is not SQL injection protection; parameterize queries separately.',
    traceInput: ['quantity: 2', 'quantity: 0', 'quantity: "2"'],
    trace: [
      EngineeringTraceStep(
        'Check type',
        'Only numeric values pass the type gate.',
        [0, 1],
        ['string rejected'],
      ),
      EngineeringTraceStep(
        'Check range',
        'Quantity zero is outside 1–99.',
        [1],
        ['zero rejected'],
      ),
      EngineeringTraceStep(
        'Accept',
        'Only the safe integer 2 remains.',
        [0],
        ['quantity = 2'],
      ),
    ],
    check: 'Why validate a cart quantity on both the browser and the server?',
    answer:
        'The browser gives immediate feedback. The server enforces the rule because clients can be changed or bypassed.',
  ),
  EngineeringLesson(
    id: 'backend-repository',
    unit: 'Data and identity',
    title: 'Keep data access behind a boundary',
    summary: 'Separate rules from queries.',
    concept:
        'A repository or data-access function owns how records are read and written. A handler coordinates the request; domain code decides the business rule.',
    why:
        'A small boundary makes storage changes and tests easier without duplicating queries across routes.',
    when: 'Several handlers need the same product, order, or user data.',
    how:
        'Give the data layer focused methods, return typed values, and keep authorization and workflow rules explicit.',
    codeLabel: 'TYPESCRIPT · DATA ADAPTER',
    code: '''type Product = { id: number; name: string; stock: number };
interface ProductStore {
  findById(id: number): Promise<Product | null>;
  decrementStock(id: number, amount: number): Promise<boolean>;
}''',
    result:
        'Handlers depend on ProductStore rather than writing raw SQL everywhere.',
    application:
        'The shop product page and checkout both use the same product store, but checkout still owns its stock rule.',
    appCode: '''async function showProduct(store: ProductStore, id: number) {
  const product = await store.findById(id);
  return product
    ? Response.json(product)
    : Response.json({ error: 'Not found' }, { status: 404 });
}''',
    alternative:
        'For a tiny app, a few well-named query functions can be enough; avoid layers with no distinct responsibility.',
    pitfall:
        'Do not hide every business decision inside a generic save() method.',
    traceInput: [
      'GET product 12',
      'ProductStore.findById(12)',
      'database row 12',
    ],
    trace: [
      EngineeringTraceStep(
        'Handler',
        'The handler asks for product 12.',
        [0],
        ['request intent'],
      ),
      EngineeringTraceStep(
        'Boundary',
        'The store owns the lookup details.',
        [1],
        ['typed product or null'],
      ),
      EngineeringTraceStep(
        'Response',
        'The handler chooses 200 or 404.',
        [2],
        ['200 · product'],
      ),
    ],
    check: 'Should a repository decide which HTTP status to return?',
    answer:
        'Usually no. The repository returns data or a domain result; the HTTP handler maps that result to a response.',
  ),
  EngineeringLesson(
    id: 'backend-transaction',
    unit: 'Data and identity',
    title: 'Make multi-step changes atomic',
    summary: 'Commit together or roll back.',
    concept:
        'A transaction groups related database changes. If any required step fails, the group rolls back so partial business state is not stored.',
    why:
        'Checkout should not create an order while leaving stock unchanged, or reduce stock without creating an order.',
    when: 'A business operation writes multiple rows that must agree.',
    how:
        'Begin the transaction, perform guarded writes, check their results, and commit only after every rule succeeds.',
    codeLabel: 'TYPESCRIPT · DRIVER-NEUTRAL SKETCH',
    code: '''await db.transaction(async (tx) => {
  const changed = await tx.run(
    'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
    [quantity, productId, quantity]);
  if (changed.rowsAffected !== 1) throw new Error('Out of stock');
  await tx.run('INSERT INTO orders(user_id) VALUES (?)', [userId]);
});''',
    result: 'Both stock and order changes commit, or neither does.',
    application:
        'The shop checkout service makes stock reservation and order creation one database operation.',
    appCode: '''const result = await createOrder(db, userId, productId, quantity);
if (result.kind === 'out_of_stock') {
  return Response.json({ error: 'Out of stock' }, { status: 409 });
}
return Response.json(result.order, { status: 201 });''',
    alternative:
        'Across independent services, a single database transaction is unavailable; use a workflow with compensating actions and explicit failure handling.',
    pitfall:
        'A transaction does not by itself make an external payment call reversible.',
    traceInput: ['stock: 3', 'buy: 2', 'order insert'],
    trace: [
      EngineeringTraceStep(
        'Begin',
        'The operation starts with stock 3.',
        [0],
        ['transaction open'],
      ),
      EngineeringTraceStep(
        'Guard',
        'The stock update checks that 3 is at least 2.',
        [0, 1],
        ['stock becomes 1'],
      ),
      EngineeringTraceStep(
        'Commit',
        'The order insert succeeds, so both writes commit.',
        [2],
        ['stock 1 · order created'],
      ),
    ],
    check:
        'What should happen if the order insert fails after stock is reduced?',
    answer: 'The transaction should roll back the stock update as well.',
  ),
  EngineeringLesson(
    id: 'backend-authentication',
    unit: 'Data and identity',
    title: 'Identify the caller',
    summary: 'Authentication establishes identity.',
    concept:
        'Authentication proves which principal is making a request. A session is checked on the server and linked to a user identity; it is not a client-supplied user ID.',
    why:
        'Without a trusted identity, private orders and profile actions cannot be tied to the right account.',
    when:
        'Before serving account-specific data or accepting account-specific actions.',
    how:
        'Verify a session or token, handle expiry, then use the verified identity for the request.',
    codeLabel: 'TYPESCRIPT · SESSION BOUNDARY',
    code:
        '''async function currentUser(request: Request, sessions: SessionStore) {
  const cookie = request.headers.get('Cookie') ?? '';
  const sessionId = readSessionCookie(cookie);
  if (!sessionId) return null;
  return sessions.userFor(sessionId);
}''',
    result:
        'A valid session yields a user; a missing or expired session yields null.',
    application:
        'The order-history API reads the user from a verified session and never trusts a user_id from the browser.',
    appCode: '''const user = await currentUser(request, sessions);
if (!user) return Response.json(
  { error: 'Sign in required' }, { status: 401 });
const orders = await orderStore.forUser(user.id);''',
    alternative:
        'A verified bearer token can carry identity instead of a cookie session, but token validation and lifecycle still matter.',
    pitfall: 'Authentication alone does not authorize access to every order.',
    traceInput: ['session cookie', 'session store', 'user 7'],
    trace: [
      EngineeringTraceStep(
        'Read',
        'The server reads a session credential.',
        [0],
        ['credential present'],
      ),
      EngineeringTraceStep(
        'Verify',
        'The session store checks it and expiry.',
        [1],
        ['valid session'],
      ),
      EngineeringTraceStep(
        'Identify',
        'The trusted identity is user 7.',
        [2],
        ['current user: 7'],
      ),
    ],
    check:
        'Why should an order API not accept user_id in the request body as identity?',
    answer:
        'The caller can alter the body. The API must derive identity from a verified session or token.',
  ),
  EngineeringLesson(
    id: 'backend-authorization',
    unit: 'Data and identity',
    title: 'Check access to every resource',
    summary: 'Identity is not permission.',
    concept:
        'Authorization checks whether the authenticated caller may perform an action on a specific resource. Ownership must be enforced on every relevant request.',
    why:
        'A valid login must not let one shopper read another shopper’s order by changing the URL ID.',
    when: 'Whenever a route reads or changes private or privileged data.',
    how:
        'Load with the caller ID in the query or verify ownership before returning or changing the resource.',
    codeLabel: 'TYPESCRIPT · DRIVER-NEUTRAL SKETCH',
    code: '''const order = await db.get(
  'SELECT id, status FROM orders WHERE id = ? AND user_id = ?',
  [orderId, currentUser.id]);
if (!order) return Response.json(
  { error: 'Not found' }, { status: 404 });''',
    result: 'Order 41 is returned only if it belongs to the signed-in user.',
    application:
        'The shop order-detail page may display an order URL, but the API still checks ownership before returning it.',
    appCode: '''async function getMyOrder(id: number, userId: number) {
  return orderStore.findForUser(id, userId);
}''',
    alternative:
        'A policy layer can centralize complex roles and permissions, while resource-specific rules remain testable.',
    pitfall: 'Hiding a button in the frontend is not authorization.',
    traceInput: ['user 7', 'order 41 · owner 7', 'order 42 · owner 8'],
    trace: [
      EngineeringTraceStep(
        'Identify',
        'The session resolves to user 7.',
        [0],
        ['caller = 7'],
      ),
      EngineeringTraceStep(
        'Filter',
        'Order 41 matches the caller; order 42 does not.',
        [1, 2],
        ['41 allowed · 42 excluded'],
      ),
      EngineeringTraceStep(
        'Return',
        'Only the allowed order is returned.',
        [0, 1],
        ['200 · order 41'],
      ),
    ],
    check:
        'If a user guesses a real order ID, is authentication enough to return it?',
    answer:
        'No. The server must also check that the user may access that specific order.',
  ),
  EngineeringLesson(
    id: 'backend-errors',
    unit: 'Reliable services',
    title: 'Design useful errors',
    summary: 'Give clients a safe, stable failure shape.',
    concept:
        'A handler translates expected domain failures into a consistent HTTP status and response. Unexpected failures are logged with context but not exposed as internal details.',
    why:
        'The frontend needs to know whether to retry, ask for a correction, sign in, or show a general failure.',
    when: 'Every endpoint needs both a success contract and an error contract.',
    how:
        'Define a small error code vocabulary, map known failures, and use one safe fallback for unexpected exceptions.',
    codeLabel: 'TYPESCRIPT · WEB RESPONSE API',
    code: '''function errorResponse(code: string, status: number): Response {
  return Response.json({ error: { code } }, { status });
}
// 400 INVALID_QUANTITY, 401 SIGN_IN_REQUIRED,
// 409 OUT_OF_STOCK, 500 INTERNAL_ERROR''',
    result:
        'A client can branch on status and stable code without parsing English text.',
    application:
        'Checkout tells the customer when stock changed, while logging an unexpected database outage for operators.',
    appCode: '''if (result.kind === 'out_of_stock') {
  return errorResponse('OUT_OF_STOCK', 409);
}
if (result.kind === 'created') {
  return Response.json(result.order, { status: 201 });
}''',
    alternative:
        'Problem Details for HTTP APIs is a standard structured error format when interoperable clients need richer details.',
    pitfall:
        'Do not include stack traces, SQL text, or secrets in a public error body.',
    traceInput: ['invalid quantity', 'out of stock', 'unexpected DB fault'],
    trace: [
      EngineeringTraceStep(
        'Classify',
        'The handler distinguishes known from unexpected failures.',
        [0, 1, 2],
        ['three failure kinds'],
      ),
      EngineeringTraceStep(
        'Map',
        'Known client/business failures get stable codes.',
        [0, 1],
        ['400 · 409'],
      ),
      EngineeringTraceStep(
        'Protect',
        'The unexpected failure gets a generic public response.',
        [2],
        ['500 · INTERNAL_ERROR'],
      ),
    ],
    check:
        'Should a database stack trace be returned to a shopper after checkout fails?',
    answer:
        'No. Log it privately with a request identifier and return a safe, stable error response.',
  ),
  EngineeringLesson(
    id: 'backend-idempotency',
    unit: 'Reliable services',
    title: 'Handle retries without duplicates',
    summary: 'A repeated request should not repeat a purchase.',
    concept:
        'Networks fail after a server commits but before the client sees the response. An idempotency key lets the server recognize a retry of the same action.',
    why: 'A checkout retry must not produce a second order or second charge.',
    when: 'A write can be retried after timeout or intermittent connectivity.',
    how:
        'Scope a client-generated key to a user and operation, store the result atomically, and replay the same result for the same request.',
    codeLabel: 'TYPESCRIPT · SERVICE SKETCH',
    code: '''const key = request.headers.get('Idempotency-Key');
if (!key) return errorResponse('KEY_REQUIRED', 400);
const prior = await attempts.find(user.id, key);
if (prior) return Response.json(prior.body, { status: prior.status });
const result = await createOrderOnce(user.id, key, cart);''',
    result: 'The same user/key pair gets the original order result on retry.',
    application:
        'The shop checkout button can retry after a timeout without creating two orders.',
    appCode: '''const key = crypto.randomUUID();
await fetch('/api/orders', {
  method: 'POST',
  headers: { 'Idempotency-Key': key, 'Content-Type': 'application/json' },
  body: JSON.stringify(cart),
});''',
    alternative:
        'A naturally idempotent PUT to a client-chosen resource URL can avoid a separate key for some operations.',
    pitfall:
        'Checking then inserting without a unique constraint or atomic transaction can still race.',
    traceInput: [
      'key abc · first request',
      'order #41 committed',
      'key abc · retry',
    ],
    trace: [
      EngineeringTraceStep(
        'First request',
        'No stored result exists yet.',
        [0],
        ['process checkout'],
      ),
      EngineeringTraceStep(
        'Commit',
        'Store order and idempotency result together.',
        [1],
        ['order #41'],
      ),
      EngineeringTraceStep(
        'Retry',
        'The same key returns the stored result.',
        [2],
        ['order #41 again; no new order'],
      ),
    ],
    check:
        'Why is a unique idempotency key helpful even when the button is disabled after one tap?',
    answer:
        'The client may never receive the first response and retry later. UI state cannot guarantee the server did not commit.',
  ),
  EngineeringLesson(
    id: 'backend-jobs',
    unit: 'Reliable services',
    title: 'Move slow work to jobs',
    summary: 'Respond quickly; process reliably.',
    concept:
        'A background job handles work that need not finish before the request returns. The API records an intent, a worker processes it, and status can be checked later.',
    why:
        'Email and report generation can be slow or fail independently of a successful order write.',
    when:
        'An operation takes longer than the user should wait or needs retry after transient failure.',
    how:
        'Store the job durably, return the created order with receipt pending, process with retries, and make the worker safe to repeat.',
    codeLabel: 'TYPESCRIPT · QUEUE ADAPTER SKETCH',
    code: '''await jobs.enqueue('send-receipt', { orderId: order.id });
return Response.json(
  { orderId: order.id, receipt: 'pending' },
  { status: 201 });''',
    result: 'Checkout returns while a worker sends the receipt later.',
    application:
        'The shop saves an order first, then a receipt worker sends email without making checkout wait for an email provider.',
    appCode: '''async function sendReceipt(job: { orderId: number }) {
  const order = await orders.findById(job.orderId);
  if (!order || order.receiptSentAt) return;
  await mail.sendReceipt(order);
  await orders.markReceiptSent(order.id);
}''',
    alternative:
        'For short, essential work, keep it in the request. If the order and job must be atomic, save an outbox record in the same database transaction and publish it later.',
    pitfall:
        'A queue can deliver more than once, and enqueue can fail after the order is saved. Handle both duplicate delivery and a missing job.',
    traceInput: ['order saved', 'receipt job queued', 'worker sends email'],
    trace: [
      EngineeringTraceStep(
        'Commit order',
        'The durable business state is saved first.',
        [0],
        ['order #41'],
      ),
      EngineeringTraceStep(
        'Queue',
        'A receipt job is recorded for later work.',
        [1],
        ['201 · receipt pending'],
      ),
      EngineeringTraceStep(
        'Process',
        'The worker sends and marks the receipt.',
        [2],
        ['receipt sent'],
      ),
    ],
    check:
        'Can a background worker assume it will receive each job exactly once?',
    answer:
        'No. Design the handler so duplicate delivery does not repeat an unsafe side effect.',
  ),
  EngineeringLesson(
    id: 'backend-cache',
    unit: 'Reliable services',
    title: 'Cache the right data',
    summary: 'Speed reads without serving stale private data.',
    concept:
        'A cache stores a reusable result closer to a consumer. Its key, lifetime, invalidation rule, and privacy scope are part of correctness.',
    why:
        'A product catalog is read often and changes less often than it is viewed.',
    when:
        'Measurement shows repeated reads are expensive and bounded staleness is acceptable.',
    how:
        'Cache by all inputs that affect the result, choose a TTL, and invalidate or refresh after writes.',
    codeLabel: 'TYPESCRIPT · CACHE ADAPTER SKETCH',
    code: '''const key = 'catalog:' + categoryId;
const cached = await cache.get(key);
if (cached) return cached;
const products = await productStore.byCategory(categoryId);
await cache.set(key, products, { ttlSeconds: 60 });
return products;''',
    result:
        'Repeated catalog reads within the TTL reuse the cached product list.',
    application:
        'The shop can cache public product listings while keeping user-specific order history out of a shared public cache.',
    appCode: '''await productStore.updatePrice(productId, newPrice);
await cache.delete('catalog:' + categoryId);''',
    alternative:
        'HTTP cache headers or a CDN may be enough for public read-only resources, without an application cache.',
    pitfall:
        'A cache key that omits user identity can leak private results between users.',
    traceInput: ['catalog request A', 'cache entry · 60s', 'catalog request B'],
    trace: [
      EngineeringTraceStep(
        'Miss',
        'The first read has no entry.',
        [0],
        ['read database'],
      ),
      EngineeringTraceStep(
        'Store',
        'The result is cached briefly.',
        [1],
        ['catalog cached'],
      ),
      EngineeringTraceStep(
        'Hit',
        'The next matching read reuses the entry.',
        [2],
        ['serve cached catalog'],
      ),
    ],
    check: 'What must a cache key include for a user-specific order list?',
    answer:
        'At least the verified user identity and every filter or page parameter that changes the result; shared caching may be inappropriate.',
  ),
  EngineeringLesson(
    id: 'backend-pagination',
    unit: 'Ship and operate',
    title: 'Page large result sets',
    summary: 'Bound each response.',
    concept:
        'Pagination returns a manageable slice and a way to request the next slice. Stable ordering prevents records from moving unpredictably between pages.',
    why:
        'Returning every order or product can consume too much memory, bandwidth, and screen space.',
    when: 'A list can grow beyond a small, predictable size.',
    how:
        'Limit the page size, order by a stable key, and return a cursor from the last item.',
    codeLabel: 'TYPESCRIPT · DRIVER-NEUTRAL SKETCH',
    code:
        '''const limit = Math.min(Math.max(Number(url.searchParams.get('limit')) || 20, 1), 50);
const after = Number(url.searchParams.get('after')) || 0;
const rows = await db.all(
  'SELECT id, name FROM products WHERE id > ? ORDER BY id LIMIT ?',
  [after, limit + 1]);''',
    result:
        'At most 50 products are returned, with an extra row used to detect more pages.',
    application:
        'The shop catalog loads the next set of products when the customer reaches the end of the list.',
    appCode: '''const hasMore = rows.length > limit;
const items = rows.slice(0, limit);
return Response.json({
  items,
  nextCursor: hasMore ? items.at(-1)?.id : null,
});''',
    alternative:
        'Offset pagination is simple for small stable data sets; cursor pagination behaves better under frequent inserts and deep scrolling.',
    pitfall: 'Without a deterministic ORDER BY, page boundaries are unstable.',
    traceInput: ['IDs 1–20', 'IDs 21–40', 'ID 41 extra'],
    trace: [
      EngineeringTraceStep(
        'Read',
        'Ask for one more than the page size.',
        [0, 1, 2],
        ['21 rows read'],
      ),
      EngineeringTraceStep(
        'Trim',
        'Return only the requested page.',
        [0, 1],
        ['20 items'],
      ),
      EngineeringTraceStep(
        'Cursor',
        'The extra row proves another page exists.',
        [2],
        ['nextCursor = 20'],
      ),
    ],
    check: 'Why read limit + 1 rows?',
    answer:
        'The extra row reveals whether another page exists without returning it in the current page.',
  ),
  EngineeringLesson(
    id: 'backend-tests',
    unit: 'Ship and operate',
    title: 'Test contracts and failure paths',
    summary: 'Verify behavior at useful boundaries.',
    concept:
        'A backend test checks outputs and side effects for a known input. Unit tests exercise pure rules; integration tests exercise the route and real data adapter together.',
    why:
        'A happy-path checkout test alone misses invalid input, missing authorization, and stock races.',
    when: 'Before shipping or changing a public API contract or business rule.',
    how:
        'Write cases for success, invalid input, access denied, missing data, and a failure during multi-step work.',
    codeLabel: 'TYPESCRIPT · NODE TEST RUNNER',
    code: '''import { test } from 'node:test';
import assert from 'node:assert/strict';

test('quantity rejects zero', () => {
  assert.equal(parseQuantity(0), null);
  assert.equal(parseQuantity(2), 2);
});''',
    result:
        'The validation rule is checked with an accepted and rejected value.',
    application:
        'The shop adds an API integration test that user 7 cannot read user 8’s order, plus a checkout rollback test.',
    appCode: '''test('other user cannot read order', async () => {
  const response = await app.handle(requestAs(7, '/api/orders/42'));
  assert.equal(response.status, 404);
});''',
    alternative:
        'Contract tests between separately deployed clients and services can catch incompatible changes that unit tests miss.',
    pitfall:
        'Mocks that return exactly what the handler expects can hide broken SQL, serialization, or transaction behavior.',
    traceInput: ['valid quantity', 'zero quantity', 'foreign order'],
    trace: [
      EngineeringTraceStep(
        'Arrange',
        'Prepare controlled inputs and state.',
        [0, 1, 2],
        ['fixtures ready'],
      ),
      EngineeringTraceStep(
        'Act',
        'Call the rule or API.',
        [0, 1, 2],
        ['responses captured'],
      ),
      EngineeringTraceStep(
        'Assert',
        'Check status, body, and side effects.',
        [0, 1, 2],
        ['success · 400 · 404'],
      ),
    ],
    check: 'Which test best detects a missing ownership check?',
    answer:
        'An API test using a signed-in user who requests a different user’s real order.',
  ),
  EngineeringLesson(
    id: 'backend-observability',
    unit: 'Ship and operate',
    title: 'Observe production behavior',
    summary: 'Use logs, metrics, and request IDs.',
    concept:
        'Observability connects a failing user request to service behavior. Structured logs explain one event, metrics show trends, and traces follow work across components.',
    why:
        'A generic 500 response is safe for users but operators still need enough context to fix the cause.',
    when:
        'Before running an API for real users, especially around checkout and authentication.',
    how:
        'Attach a request ID, record outcome and duration, avoid sensitive fields, and alert on meaningful failure rates.',
    codeLabel: 'TYPESCRIPT · STRUCTURED LOG',
    code: '''const started = performance.now();
const requestId = crypto.randomUUID();
try {
  return await handleCheckout(request);
} finally {
  console.info(JSON.stringify({
    event: 'checkout_request', requestId,
    durationMs: Math.round(performance.now() - started),
  }));
}''',
    result: 'Each checkout request has a correlation ID and measured duration.',
    application:
        'Support can locate a failed checkout using a request ID without asking for passwords or full payment details.',
    appCode:
        '''return Response.json({ error: { code: 'INTERNAL_ERROR', requestId } },
  { status: 500, headers: { 'X-Request-ID': requestId } });''',
    alternative:
        'A managed telemetry SDK can collect traces and metrics, but you still choose useful events and data boundaries.',
    pitfall:
        'Do not log session cookies, raw tokens, card data, or whole request bodies by default.',
    traceInput: ['request id r1', 'database timeout', '500 response'],
    trace: [
      EngineeringTraceStep(
        'Correlate',
        'Assign a request ID at entry.',
        [0],
        ['r1'],
      ),
      EngineeringTraceStep(
        'Record',
        'Log the failure and safe context privately.',
        [1],
        ['timeout · r1'],
      ),
      EngineeringTraceStep(
        'Respond',
        'Return a safe error with the same ID.',
        [2],
        ['500 · r1'],
      ),
    ],
    check:
        'What is safer to put in a public error: a stack trace or a request ID?',
    answer:
        'A request ID. Operators can use it to find private logs without exposing internals to the caller.',
  ),
  EngineeringLesson(
    id: 'backend-deploy',
    unit: 'Ship and operate',
    title: 'Deploy a service safely',
    summary: 'Config, health, migration, rollback.',
    concept:
        'Deployment is a controlled change to running software. Code, configuration, database schema, and observability must agree across versions.',
    why:
        'A working local API can fail in production because of missing secrets, incompatible schema, or an unhealthy process.',
    when:
        'Before a service is exposed to real users or a new version replaces an old one.',
    how:
        'Validate config at startup, run compatible migrations, expose health/readiness, deploy gradually, and retain a rollback path.',
    codeLabel: 'TYPESCRIPT · STARTUP CHECK',
    code: '''const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error('DATABASE_URL is required');
const port = Number(process.env.PORT ?? 8080);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error('Invalid PORT');
}''',
    result:
        'A bad deployment fails immediately instead of serving broken checkout requests.',
    application:
        'The shop API checks its database connection and schema before receiving traffic, then watches checkout error rate after release.',
    appCode: '''async function readiness(): Promise<Response> {
  const ready = await db.ping();
  return Response.json({ ready }, { status: ready ? 200 : 503 });
}''',
    alternative:
        'A managed platform may perform rollout and health checks for you, but application readiness and schema compatibility still need design.',
    pitfall:
        'Never commit production secrets into source control or assume one successful health request proves every feature works.',
    traceInput: ['new build', 'schema + config check', 'traffic switch'],
    trace: [
      EngineeringTraceStep(
        'Prepare',
        'Build and validate required configuration.',
        [0],
        ['artifact ready'],
      ),
      EngineeringTraceStep(
        'Ready',
        'Check database and compatible schema.',
        [1],
        ['ready = true'],
      ),
      EngineeringTraceStep(
        'Release',
        'Send traffic and observe errors.',
        [2],
        ['service live'],
      ),
    ],
    check:
        'Why should a service check its configuration before accepting requests?',
    answer:
        'Missing or invalid configuration should fail startup clearly, before users hit broken endpoints.',
  ),
];
