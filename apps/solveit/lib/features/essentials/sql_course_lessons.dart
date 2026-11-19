part of 'sql_course.dart';

const sqlLessons = <SqlLesson>[
  SqlLesson(
    id: 'relational-model',
    unit: 'Foundations',
    title: 'Tables, rows, and relationships',
    summary: 'Model one real thing per table.',
    concept:
        'A relational database stores rows in named tables. Each column has a meaning; a key identifies a row; a foreign key connects rows without copying an entire object.',
    why:
        'Separate tables let an application update a customer or product once while many orders still refer to it.',
    when:
        'Use a relational model when entities have stable identities, relationships, and rules that must hold across updates.',
    operation:
        'Identify entities, choose primary keys, then represent one-to-many links with a foreign key on the many side.',
    sql: '''CREATE TABLE users (
  id INTEGER PRIMARY KEY, email TEXT NOT NULL UNIQUE
);
CREATE TABLE orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'draft',
  total_cents INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  shipped_at TEXT
);''',
    result: 'One user can own many orders; each order points to one user.',
    application:
        'An order history screen fetches orders by the signed-in user ID instead of copying the email into every order.',
    appCode: '''const orders = await db.all(
  'SELECT id FROM orders WHERE user_id = ?', [userId]
); // Driver adapter with parameter binding''',
    alternative:
        'Embedding orders inside one document can simplify a bounded single-user aggregate, but cross-user reporting and integrity need different tradeoffs.',
    pitfall: 'Do not use a mutable email address as the relationship key.',
    traceInput: [
      'user 7 · ada@example.com',
      'order 41 · user_id 7',
      'order 42 · user_id 7',
    ],
    trace: [
      SqlTraceStep(
        'Create the user',
        'The user row receives stable key 7.',
        [0],
        ['users: 7'],
      ),
      SqlTraceStep(
        'Link orders',
        'Both orders store 7 in user_id.',
        [1, 2],
        ['orders: 41 → 7', '42 → 7'],
      ),
      SqlTraceStep(
        'Read history',
        'Looking up user 7 returns both orders.',
        [0, 1, 2],
        ['41', '42'],
      ),
    ],
    check:
        'Which table should hold user_id in a one-user-to-many-orders design?',
    answer:
        'orders holds user_id, because each order belongs to one user and many order rows can reference the same user.',
  ),
  SqlLesson(
    id: 'create-table',
    unit: 'Foundations',
    title: 'Create tables and constraints',
    summary: 'Make invalid data harder to store.',
    concept:
        'CREATE TABLE declares columns and constraints. PRIMARY KEY identifies rows; NOT NULL, UNIQUE, CHECK, and REFERENCES express rules near the data.',
    why:
        'Database constraints protect data even when multiple app screens or services write to the same tables.',
    when:
        'Define these rules before building forms or APIs that write the data.',
    operation:
        'Choose a key, data types, required fields, uniqueness, valid ranges, and relationships.',
    sql: '''PRAGMA foreign_keys = ON;
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  sku TEXT NOT NULL UNIQUE
);''',
    result: 'A negative price, missing name, or duplicate SKU is rejected.',
    application:
        'A product administration API validates inputs and lets the database enforce the same invariants.',
    appCode: '''await db.exec(schemaSql); // Run through a versioned migration
// Catch constraint errors and show a clear form message.''',
    alternative:
        'App validation gives faster feedback; database constraints are the final shared guard. Use both.',
    pitfall:
        'SQLite foreign-key enforcement must be enabled on connections that rely on it.',
    traceInput: [
      'id 1 · Notebook · 999 cents',
      'id 2 · Pen · -50 cents',
      'id 3 · duplicate SKU',
    ],
    trace: [
      SqlTraceStep(
        'Check required fields',
        'The first row has all required values.',
        [0],
        ['Notebook accepted'],
      ),
      SqlTraceStep(
        'Check price',
        'The CHECK constraint rejects -50.',
        [1],
        ['Notebook accepted', 'Pen rejected'],
      ),
      SqlTraceStep(
        'Check uniqueness',
        'A duplicate SKU cannot enter the table.',
        [2],
        ['1 valid product'],
      ),
    ],
    check:
        'Why keep a price CHECK constraint if the UI already validates price?',
    answer:
        'Other writers and future code paths can bypass the UI; the database rule protects the shared data.',
  ),
  SqlLesson(
    id: 'insert-rows',
    unit: 'Foundations',
    title: 'Insert rows safely',
    summary: 'Write values with bound parameters.',
    concept:
        'INSERT adds a row. The database assigns an INTEGER PRIMARY KEY when omitted in SQLite. Bind user values as parameters instead of building SQL strings.',
    why:
        'Parameters separate data from SQL syntax and protect an application from SQL injection.',
    when:
        'Use INSERT for new accounts, products, events, or any persisted object.',
    operation:
        'Name target columns, provide one bound value per placeholder, then check the write result.',
    sql: '''INSERT INTO products (name, price_cents, sku)
VALUES (?, ?, ?);''',
    result: 'One new product row is stored when its constraints pass.',
    application:
        'A catalog form saves a product without embedding the submitted name directly in the query text.',
    appCode: '''await db.run(
  'INSERT INTO products (name, price_cents, sku) VALUES (?, ?, ?)',
  [name, priceCents, sku]
);''',
    alternative:
        'For repeated imports, batch parameterized inserts inside a transaction rather than issuing unrelated writes one by one.',
    pitfall:
        'Never concatenate user text into SQL, even if it came from an internal admin form.',
    traceInput: [
      'SQL shape: VALUES (?, ?, ?)',
      'name: Notebook',
      'price: 999 · sku: NB-1',
    ],
    trace: [
      SqlTraceStep(
        'Prepare',
        'The SQL shape is fixed before any values arrive.',
        [0],
        ['prepared statement'],
      ),
      SqlTraceStep(
        'Bind',
        'Values fill placeholders as data, not syntax.',
        [1, 2],
        ['Notebook', '999', 'NB-1'],
      ),
      SqlTraceStep(
        'Validate and save',
        'Constraints pass and one row is inserted.',
        [0, 1, 2],
        ['product row saved'],
      ),
    ],
    check:
        'What is wrong with INSERT text built using a customer-provided product name?',
    answer:
        'The value could become SQL syntax. Use a placeholder and bind the name as a separate parameter.',
  ),
  SqlLesson(
    id: 'select-columns',
    unit: 'Reading data',
    title: 'SELECT only what you need',
    summary: 'Project useful columns into a result.',
    concept:
        'SELECT chooses columns from rows. A result is a new table-like set; reading does not change the stored rows.',
    why:
        'Explicit columns make APIs stable and avoid transferring large or sensitive fields that a screen does not need.',
    when: 'Read a list, detail view, lookup, or report from persisted data.',
    operation:
        'Write SELECT columns FROM table; use aliases for computed or renamed outputs.',
    sql: '''SELECT id, name, price_cents
FROM products;''',
    result: 'Each product contributes id, name, and price_cents only.',
    application:
        'A product list can render name and price without fetching an internal supplier note.',
    appCode: '''const products = await db.all(
  'SELECT id, name, price_cents FROM products'
);''',
    alternative:
        'SELECT * is convenient while exploring a table, but explicit columns are better for an application contract.',
    pitfall: 'SQL results are not ordered unless ORDER BY is specified.',
    traceInput: [
      '1 · Notebook · 999 · private note',
      '2 · Pen · 150 · private note',
    ],
    trace: [
      SqlTraceStep(
        'Read source',
        'Two complete rows exist in products.',
        [0, 1],
        ['2 input rows'],
      ),
      SqlTraceStep(
        'Project columns',
        'Keep id, name, and price; omit private note.',
        [0, 1],
        ['1 · Notebook · 999', '2 · Pen · 150'],
      ),
      SqlTraceStep(
        'Return result',
        'The stored rows stay unchanged.',
        [0, 1],
        ['2 visible rows'],
      ),
    ],
    check: 'Why might SELECT * be a bad choice for a public product API?',
    answer:
        'It can expose extra fields and couples the API response to future schema changes.',
  ),
  SqlLesson(
    id: 'where-null',
    unit: 'Reading data',
    title: 'Filter rows and handle NULL',
    summary: 'Keep rows whose predicate is true.',
    concept:
        'WHERE filters before projection. NULL means unknown or missing; use IS NULL or IS NOT NULL rather than = NULL.',
    why: 'Filtering in SQL avoids moving irrelevant rows into the application.',
    when:
        'Fetch one user’s records, active products, pending orders, or optional values.',
    operation:
        'Compose predicates with AND/OR, bind values, and handle NULL explicitly.',
    sql: '''SELECT id, status FROM orders
WHERE user_id = ? AND shipped_at IS NULL;''',
    result: 'Only that user’s unshipped orders are returned.',
    application:
        'An order dashboard displays pending shipments for the authenticated user.',
    appCode: '''const pending = await db.all(
  'SELECT id, status FROM orders WHERE user_id = ? AND shipped_at IS NULL',
  [userId]
);''',
    alternative:
        'An app-side filter can work for tiny in-memory lists, but it still transfers and exposes all fetched rows.',
    pitfall: 'WHERE shipped_at = NULL does not select NULL values.',
    traceInput: [
      'order 41 · user 7 · unshipped',
      'order 42 · user 7 · shipped',
      'order 43 · user 8 · unshipped',
    ],
    trace: [
      SqlTraceStep(
        'Match owner',
        'Orders 41 and 42 belong to user 7.',
        [0, 1],
        ['41', '42'],
      ),
      SqlTraceStep(
        'Check NULL',
        'Only 41 has no shipped_at value.',
        [0],
        ['41'],
      ),
      SqlTraceStep(
        'Return',
        'The result contains one pending order.',
        [0],
        ['order 41 · pending'],
      ),
    ],
    check: 'Which predicate finds rows with a missing shipped_at value?',
    answer: 'shipped_at IS NULL. Equality with NULL does not evaluate to true.',
  ),
  SqlLesson(
    id: 'sort-page',
    unit: 'Reading data',
    title: 'Sort and page results',
    summary: 'Make list order predictable.',
    concept:
        'ORDER BY sorts a result. LIMIT caps how many rows are returned; OFFSET skips rows. Stable pagination needs a tie-breaker.',
    why:
        'A feed or admin list should show a reliable order and avoid loading thousands of rows at once.',
    when:
        'Use it for recent orders, search results, leaderboards, and management tables.',
    operation: 'Order by the desired value and a unique key, then apply LIMIT.',
    sql: '''SELECT id, created_at, status FROM orders
ORDER BY created_at DESC, id DESC
LIMIT 20;''',
    result: 'The newest 20 orders appear first; id breaks equal-time ties.',
    application: 'An order feed fetches one screen of recent orders.',
    appCode: '''const page = await db.all(
  'SELECT id, created_at, status FROM orders ORDER BY created_at DESC, id DESC LIMIT ?',
  [pageSize]
);''',
    alternative:
        'For deep or frequently changing lists, keyset pagination using the last (created_at, id) is usually steadier than a large OFFSET.',
    pitfall: 'LIMIT without ORDER BY chooses no guaranteed page order.',
    traceInput: ['41 · 09:00', '42 · 10:00', '43 · 10:00'],
    trace: [
      SqlTraceStep(
        'Read rows',
        'Three orders are available.',
        [0, 1, 2],
        ['41', '42', '43'],
      ),
      SqlTraceStep(
        'Sort',
        'Time desc puts 42 and 43 first; id desc puts 43 before 42.',
        [1, 2],
        ['43', '42', '41'],
      ),
      SqlTraceStep(
        'Limit',
        'A page size of two returns only the first two.',
        [1, 2],
        ['43', '42'],
      ),
    ],
    check: 'Why add id after created_at in ORDER BY?',
    answer:
        'Two rows may share the same timestamp. A unique tie-breaker produces a stable order.',
  ),
  SqlLesson(
    id: 'aggregates',
    unit: 'Reading data',
    title: 'Count and summarize',
    summary: 'Turn many rows into one answer.',
    concept:
        'COUNT, SUM, AVG, MIN, and MAX aggregate values. COUNT(*) counts rows; COUNT(column) ignores NULL values in that column.',
    why:
        'The database can compute totals without transferring every source row to the app.',
    when: 'Show sales totals, stock counts, average rating, or minimum price.',
    operation:
        'Select an aggregate expression, optionally after WHERE filters source rows.',
    sql: '''SELECT COUNT(*) AS order_count,
       COALESCE(SUM(total_cents), 0) AS revenue_cents
FROM orders WHERE status = 'paid';''',
    result: 'One row contains the count and sum of paid orders.',
    application: 'An admin dashboard loads a compact revenue summary.',
    appCode: '''const [summary] = await db.all(
  "SELECT COUNT(*) AS order_count, COALESCE(SUM(total_cents),0) AS revenue_cents FROM orders WHERE status = ?",
  ['paid']
);''',
    alternative:
        'Precomputed counters can help high-traffic dashboards, but then writes must keep the counters correct.',
    pitfall:
        'SUM on zero matching rows returns NULL; COALESCE makes a numeric zero explicit.',
    traceInput: ['41 · paid · 900', '42 · draft · 300', '43 · paid · 600'],
    trace: [
      SqlTraceStep(
        'Filter paid',
        'Ignore the draft order.',
        [0, 2],
        ['900', '600'],
      ),
      SqlTraceStep(
        'Count',
        'Two paid orders remain.',
        [0, 2],
        ['order_count = 2'],
      ),
      SqlTraceStep(
        'Sum',
        '900 + 600 = 1500 cents.',
        [0, 2],
        ['revenue_cents = 1500'],
      ),
    ],
    check: 'What does COUNT(shipped_at) do with unshipped orders?',
    answer:
        'It ignores their NULL shipped_at values; COUNT(*) counts their rows.',
  ),
  SqlLesson(
    id: 'group-having',
    unit: 'Reading data',
    title: 'GROUP BY and HAVING',
    summary: 'Summarize each group, then filter groups.',
    concept:
        'GROUP BY forms groups of rows; aggregates calculate one result per group. WHERE filters before grouping; HAVING filters after grouping.',
    why: 'A single query can answer questions for many customers or statuses.',
    when:
        'Build per-user totals, monthly reports, category counts, or exception reports.',
    operation:
        'Filter source rows, group by the dimension, aggregate, then optionally apply HAVING.',
    sql: '''SELECT user_id, COUNT(*) AS paid_orders
FROM orders WHERE status = 'paid'
GROUP BY user_id
HAVING COUNT(*) >= 2;''',
    result: 'Only users with at least two paid orders appear.',
    application:
        'A loyalty workflow identifies customers with repeat purchases.',
    appCode: '''const repeatBuyers = await db.all(
  "SELECT user_id, COUNT(*) AS paid_orders FROM orders WHERE status = ? GROUP BY user_id HAVING COUNT(*) >= ?",
  ['paid', 2]
);''',
    alternative:
        'A nightly summary table can speed very large reports, but a live GROUP BY is simpler while data volume is moderate.',
    pitfall: 'Do not put aggregate filters such as COUNT(*) >= 2 in WHERE.',
    traceInput: ['user 7 · paid', 'user 7 · paid', 'user 8 · paid'],
    trace: [
      SqlTraceStep(
        'Group owners',
        'Rows form user 7 and user 8 groups.',
        [0, 1, 2],
        ['7: 2 rows', '8: 1 row'],
      ),
      SqlTraceStep(
        'Count',
        'Each group gets a paid-order count.',
        [0, 1, 2],
        ['7 → 2', '8 → 1'],
      ),
      SqlTraceStep(
        'Apply HAVING',
        'Only the group with count at least two remains.',
        [0, 1],
        ['user 7 → 2'],
      ),
    ],
    check: 'Which clause filters groups after COUNT is calculated?',
    answer: 'HAVING. WHERE filters individual source rows before grouping.',
  ),
  SqlLesson(
    id: 'joins',
    unit: 'Relationships',
    title: 'INNER JOIN and LEFT JOIN',
    summary: 'Combine related rows without copying data.',
    concept:
        'JOIN matches rows using a relationship. INNER JOIN keeps matches; LEFT JOIN also keeps left-side rows without a match, filling right-side columns with NULL.',
    why:
        'An application often needs attributes from more than one table, such as order ID with customer email.',
    when: 'Use joins for detail pages, reports, and parent-child lists.',
    operation:
        'Choose a join condition on keys. Use LEFT JOIN when unmatched left rows must remain.',
    sql: '''SELECT u.id, u.email, o.id AS order_id
FROM users AS u
LEFT JOIN orders AS o ON o.user_id = u.id;''',
    result: 'Users with no order still appear with a NULL order_id.',
    application:
        'A customer dashboard shows every account, including new customers without purchases.',
    appCode: '''const customers = await db.all(
  'SELECT u.id, u.email, o.id AS order_id FROM users u LEFT JOIN orders o ON o.user_id = u.id'
);''',
    alternative:
        'For one known user, separate parameterized queries can be simple. A join often reduces round trips for a list.',
    pitfall:
        'Putting o.status = ? in WHERE drops unmatched LEFT JOIN rows; put that condition in ON if those users must remain.',
    traceInput: ['user 7 · Ada', 'user 8 · Lin', 'order 41 · user 7'],
    trace: [
      SqlTraceStep(
        'Read users',
        'Both users start on the left side.',
        [0, 1],
        ['Ada', 'Lin'],
      ),
      SqlTraceStep(
        'Match order',
        'Order 41 joins to user 7.',
        [0, 2],
        ['Ada → 41'],
      ),
      SqlTraceStep(
        'Keep unmatched',
        'LEFT JOIN preserves user 8 with NULL.',
        [1],
        ['Ada → 41', 'Lin → NULL'],
      ),
    ],
    check: 'Which join keeps users who have no orders?',
    answer:
        'LEFT JOIN from users to orders. An INNER JOIN would omit unmatched users.',
  ),
  SqlLesson(
    id: 'many-to-many',
    unit: 'Relationships',
    title: 'Many-to-many with a link table',
    summary: 'Give relationships their own rows.',
    concept:
        'A link table stores each pair of related keys, often with attributes of the relationship such as quantity or price at purchase time.',
    why:
        'One order can contain many products, and a product can appear in many orders.',
    when:
        'Use a link table for memberships, tags, enrollments, and order items.',
    operation:
        'Create two foreign keys and a composite key or uniqueness rule for the pair.',
    sql: '''CREATE TABLE order_items (
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price_cents INTEGER NOT NULL,
  PRIMARY KEY (order_id, product_id)
);''',
    result:
        'Each order/product pair appears at most once and carries its quantity.',
    application:
        'A checkout service records the price paid even if the current catalog price later changes.',
    appCode: '''await db.run(
  'INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents) VALUES (?, ?, ?, ?)',
  [orderId, productId, quantity, priceAtCheckout]
);''',
    alternative:
        'If identical products must appear as separate line items, use a line_item_id key instead of making (order_id, product_id) unique.',
    pitfall:
        'Do not store product IDs as a comma-separated text column in orders.',
    traceInput: ['order 41', 'product 1 · Notebook', 'product 2 · Pen'],
    trace: [
      SqlTraceStep('Pick order', 'Order 41 is the parent.', [0], ['order 41']),
      SqlTraceStep(
        'Add first item',
        'A link row connects 41 and product 1.',
        [0, 1],
        ['41 ↔ 1 · qty 2'],
      ),
      SqlTraceStep(
        'Add second item',
        'Another link row connects 41 and product 2.',
        [0, 2],
        ['41 ↔ 1 · qty 2', '41 ↔ 2 · qty 1'],
      ),
    ],
    check: 'Where should quantity live in an order-to-product relationship?',
    answer:
        'On the order_items link row, because quantity describes that particular order/product pair.',
  ),
  SqlLesson(
    id: 'exists',
    unit: 'Relationships',
    title: 'Subqueries and EXISTS',
    summary: 'Ask whether a related row exists.',
    concept:
        'A subquery is a query inside a query. EXISTS tests whether the inner query returns at least one row for the current outer row.',
    why:
        'Existence checks express “has any” without producing duplicate parent rows.',
    when:
        'Find customers with purchases, products never ordered, or records that satisfy a related condition.',
    operation: 'Correlate inner and outer keys; use NOT EXISTS for absence.',
    sql: '''SELECT u.id, u.email FROM users AS u
WHERE EXISTS (
  SELECT 1 FROM orders AS o WHERE o.user_id = u.id
);''',
    result: 'Each user with at least one order appears once.',
    application:
        'An account badge shows whether a customer has purchased before.',
    appCode: '''const buyers = await db.all(
  'SELECT u.id, u.email FROM users u WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id)'
);''',
    alternative:
        'An INNER JOIN plus DISTINCT can produce the same user set, but EXISTS states the yes/no requirement directly.',
    pitfall:
        'A plain JOIN can duplicate a user when that user owns several orders.',
    traceInput: ['user 7', 'user 8', 'orders: 41→7, 42→7'],
    trace: [
      SqlTraceStep(
        'Check user 7',
        'The inner query finds at least one order.',
        [0, 2],
        ['7 → true'],
      ),
      SqlTraceStep(
        'Check user 8',
        'The inner query finds no order.',
        [1],
        ['7 → true', '8 → false'],
      ),
      SqlTraceStep(
        'Return buyers',
        'User 7 appears once despite two orders.',
        [0],
        ['user 7'],
      ),
    ],
    check:
        'Why can EXISTS avoid duplicate users from a one-to-many relationship?',
    answer:
        'It tests a boolean condition for each outer user row rather than emitting one row per matching order.',
  ),
  SqlLesson(
    id: 'ctes',
    unit: 'Relationships',
    title: 'CTEs for readable queries',
    summary: 'Name an intermediate result.',
    concept:
        'WITH defines a common table expression (CTE) that the following statement can read like a named result.',
    why:
        'Breaking a report into named steps helps review and reuse a derived value within that statement.',
    when:
        'A query has several logical stages, such as totals per customer before a final filter or join.',
    operation: 'Write WITH name AS (subquery), then SELECT from that name.',
    sql: '''WITH spend AS (
  SELECT user_id, SUM(total_cents) AS cents
  FROM orders WHERE status = 'paid'
  GROUP BY user_id
)
SELECT user_id, cents FROM spend WHERE cents >= 10000;''',
    result: 'Only customers with at least 10000 cents in paid orders remain.',
    application:
        'A loyalty service finds customers who qualify for a spend threshold.',
    appCode: '''const qualified = await db.all(
  `WITH spend AS (SELECT user_id, SUM(total_cents) cents FROM orders WHERE status = ? GROUP BY user_id)
   SELECT user_id, cents FROM spend WHERE cents >= ?`,
  ['paid', thresholdCents]
);''',
    alternative:
        'A derived table inside FROM can do the same work; choose the form that makes the steps easiest to read.',
    pitfall:
        'A CTE is a query structure, not automatically a persisted or faster table.',
    traceInput: [
      'user 7 · paid 6000',
      'user 7 · paid 5000',
      'user 8 · paid 3000',
    ],
    trace: [
      SqlTraceStep(
        'Aggregate',
        'The spend CTE groups paid orders by user.',
        [0, 1, 2],
        ['7 → 11000', '8 → 3000'],
      ),
      SqlTraceStep(
        'Apply threshold',
        'Only user 7 reaches 10000.',
        [0, 1],
        ['7 → 11000'],
      ),
      SqlTraceStep(
        'Return',
        'The outer SELECT returns the qualifying result.',
        [0, 1],
        ['user 7'],
      ),
    ],
    check: 'Does naming a CTE automatically store it permanently?',
    answer:
        'No. A CTE is scoped to its statement; it does not create a persistent table.',
  ),
  SqlLesson(
    id: 'windows',
    unit: 'Relationships',
    title: 'Window functions',
    summary: 'Compare rows without collapsing them.',
    concept:
        'A window function computes over related rows while retaining each input row. PARTITION BY groups the window; ORDER BY defines sequence.',
    why:
        'Rankings and running comparisons need per-row detail and group context at the same time.',
    when: 'Show each customer’s recent-order rank or a running total.',
    operation:
        'Add OVER (PARTITION BY ... ORDER BY ...) to a window-capable function.',
    sql: '''SELECT id, user_id, created_at,
       ROW_NUMBER() OVER (
         PARTITION BY user_id ORDER BY created_at DESC, id DESC
       ) AS recency_rank
FROM orders;''',
    result: 'Each order stays visible and gets a rank within its customer.',
    application: 'A report labels each customer’s newest order as rank 1.',
    appCode: '''const ranked = await db.all(
  'SELECT id, user_id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC, id DESC) AS rank FROM orders'
);''',
    alternative:
        'A correlated subquery can sometimes compute similar rankings, but a window function is usually clearer for per-row analytics.',
    pitfall:
        'ROW_NUMBER ties are arbitrary unless ORDER BY includes a deterministic tie-breaker.',
    traceInput: [
      '7 · order 41 · older',
      '7 · order 42 · newer',
      '8 · order 43',
    ],
    trace: [
      SqlTraceStep(
        'Partition',
        'Orders are grouped by user without losing rows.',
        [0, 1, 2],
        ['user 7: 41,42', 'user 8: 43'],
      ),
      SqlTraceStep(
        'Order within user',
        '42 precedes 41 for user 7.',
        [0, 1],
        ['7: 42,41', '8: 43'],
      ),
      SqlTraceStep(
        'Number rows',
        'Every order remains and receives its rank.',
        [0, 1, 2],
        ['42 → 1', '41 → 2', '43 → 1'],
      ),
    ],
    check:
        'What is the difference between GROUP BY and ROW_NUMBER over a partition?',
    answer:
        'GROUP BY produces grouped result rows; ROW_NUMBER preserves each row and adds a value computed within its partition.',
  ),
  SqlLesson(
    id: 'update-delete',
    unit: 'Reliable changes',
    title: 'UPDATE and DELETE deliberately',
    summary: 'Change only the intended rows.',
    concept:
        'UPDATE modifies matching rows; DELETE removes matching rows. A WHERE predicate is essential for targeted changes.',
    why: 'A missing or broad predicate can change an entire production table.',
    when:
        'Edit a profile, change order status, archive a record, or remove eligible data.',
    operation:
        'Preview the target with SELECT, apply a parameterized predicate, and check affected-row count.',
    sql: '''UPDATE orders SET status = 'shipped', shipped_at = ?
WHERE id = ? AND status = 'paid';''',
    result: 'Only the chosen paid order moves to shipped.',
    application:
        'A fulfillment worker prevents a draft or already-shipped order from transitioning again.',
    appCode: '''const changed = await db.run(
  "UPDATE orders SET status = 'shipped', shipped_at = ? WHERE id = ? AND status = 'paid'",
  [nowIso, orderId]
);
if (changed.rowCount !== 1) throw new Error('Order not eligible');''',
    alternative:
        'A soft-delete flag preserves records for audit or recovery; a hard DELETE is appropriate when data must truly be removed.',
    pitfall:
        'Always inspect the WHERE condition; an UPDATE or DELETE without it can affect every row.',
    traceInput: ['41 · paid', '42 · draft', '43 · shipped'],
    trace: [
      SqlTraceStep(
        'Find by id',
        'Only order 41 has the requested ID.',
        [0],
        ['41'],
      ),
      SqlTraceStep(
        'Check state',
        'The paid precondition passes.',
        [0],
        ['41 eligible'],
      ),
      SqlTraceStep(
        'Update',
        'One row changes; others are untouched.',
        [0],
        ['41 → shipped'],
      ),
    ],
    check: 'What does affected-row count zero mean for this guarded UPDATE?',
    answer:
        'No row matched both the ID and paid precondition. The order may not exist or may be in another state.',
  ),
  SqlLesson(
    id: 'transactions',
    unit: 'Reliable changes',
    title: 'Transactions and rollback',
    summary: 'Keep related writes together.',
    concept:
        'A transaction commits a group of changes together or rolls them back together. BEGIN starts it, COMMIT finishes it, and ROLLBACK abandons it.',
    why:
        'An order should not be saved without its line items, or stock reduced without the corresponding order.',
    when: 'One business action touches multiple rows or tables.',
    operation:
        'Begin, perform checked writes, commit on success, rollback on failure.',
    sql: '''BEGIN IMMEDIATE;
INSERT INTO orders (user_id, status, total_cents) VALUES (?, 'paid', ?);
INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents)
VALUES (?, ?, ?, ?);
COMMIT;''',
    result:
        'Either both the order and item are saved, or neither is saved if rolled back.',
    application:
        'Checkout commits an order and its items as one unit after validating stock.',
    appCode: '''await db.transaction(async tx => {
  const orderId = await tx.insertOrder(userId, totalCents);
  await tx.insertItems(orderId, items);
}); // Adapter commits on success, rolls back on throw''',
    alternative:
        'A saga coordinates changes across separate services, but a single database transaction is simpler when all rows share one database.',
    pitfall:
        'BEGIN ... COMMIT does not nest in SQLite; use SAVEPOINT for nested units. Keep transactions short.',
    traceInput: ['insert order 41', 'insert line item', 'commit or rollback'],
    trace: [
      SqlTraceStep(
        'Begin',
        'The writes are grouped into one transaction.',
        [0],
        ['transaction open'],
      ),
      SqlTraceStep(
        'Write both',
        'Order and item exist inside the transaction.',
        [0, 1],
        ['order 41', 'item for 41'],
      ),
      SqlTraceStep(
        'Commit',
        'Both become durable together. An error would roll both back.',
        [2],
        ['order + item saved'],
      ),
    ],
    check: 'What should happen if item insertion fails after order insertion?',
    answer:
        'Roll back the transaction so the order is not left without its item.',
  ),
  SqlLesson(
    id: 'upsert',
    unit: 'Reliable changes',
    title: 'UPSERT without duplicates',
    summary: 'Insert new data or update a known key.',
    concept:
        'UPSERT handles a uniqueness conflict by updating the existing row instead of failing or inserting a duplicate.',
    why:
        'Imports and synchronization jobs may receive the same logical record more than once.',
    when:
        'Use it when a stable UNIQUE key identifies the record to create or refresh.',
    operation:
        'Define a UNIQUE constraint, INSERT values, then specify ON CONFLICT ... DO UPDATE.',
    sql: '''INSERT INTO products (sku, name, price_cents)
VALUES (?, ?, ?)
ON CONFLICT(sku) DO UPDATE SET
  name = excluded.name,
  price_cents = excluded.price_cents;''',
    result: 'A new SKU inserts; a known SKU updates its name and price.',
    application:
        'A catalog import receives revised prices without duplicating products.',
    appCode: '''await db.run(upsertProductSql, [sku, name, priceCents]);
// sku is UNIQUE in the database.''',
    alternative:
        'SELECT-then-INSERT/UPDATE is easy to read but needs care under concurrent writers; UPSERT expresses the conflict atomically.',
    pitfall: 'The conflict target must match an actual uniqueness rule.',
    traceInput: [
      'existing SKU NB-1 · 999',
      'incoming NB-1 · 1099',
      'incoming PEN-1 · 150',
    ],
    trace: [
      SqlTraceStep(
        'Find conflict',
        'NB-1 already exists under the UNIQUE SKU rule.',
        [0, 1],
        ['NB-1: conflict'],
      ),
      SqlTraceStep(
        'Update',
        'The existing NB-1 price becomes 1099.',
        [1],
        ['NB-1 → 1099'],
      ),
      SqlTraceStep(
        'Insert new',
        'PEN-1 has no conflict and gets a new row.',
        [2],
        ['NB-1 → 1099', 'PEN-1 → 150'],
      ),
    ],
    check:
        'What database rule lets ON CONFLICT(sku) identify one existing product?',
    answer: 'A UNIQUE constraint or unique index on sku.',
  ),
  SqlLesson(
    id: 'indexes',
    unit: 'Performance & design',
    title: 'Indexes and query plans',
    summary: 'Speed up selective lookups thoughtfully.',
    concept:
        'An index stores an ordered lookup structure for one or more columns. The planner may use it instead of scanning every table row.',
    why:
        'A large order table can answer “recent orders for user 7” much faster when the lookup and sort align with an index.',
    when:
        'A measured query frequently filters, joins, or sorts on the same columns.',
    operation:
        'Measure with EXPLAIN QUERY PLAN, add an index for the access pattern, and measure again.',
    sql: '''CREATE INDEX idx_orders_user_recent
ON orders(user_id, created_at DESC, id DESC);
EXPLAIN QUERY PLAN
SELECT id, created_at FROM orders
WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT 20;''',
    result:
        'The plan may show an indexed search for user_id rather than a full table scan.',
    application: 'An order-history endpoint stays responsive as orders grow.',
    appCode: '''const plan = await db.all(
  'EXPLAIN QUERY PLAN SELECT id FROM orders WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT 20',
  [userId]
); // Inspect in development, not on every request.''',
    alternative:
        'A table scan is fine for tiny tables. An index costs storage and slows writes; add one for a measured workload.',
    pitfall:
        'Do not treat a specific EXPLAIN text string as a stable API; compare query behavior and shape instead.',
    traceInput: ['order 41 · user 7', 'order 42 · user 8', 'order 43 · user 7'],
    trace: [
      SqlTraceStep(
        'Without index',
        'A scan checks rows for user 7.',
        [0, 1, 2],
        ['41', '43'],
      ),
      SqlTraceStep(
        'Build index',
        'Entries are organized by user and recent order keys.',
        [0, 2],
        ['user 7 → 43,41', 'user 8 → 42'],
      ),
      SqlTraceStep(
        'Lookup',
        'A selective search reaches user 7’s entries directly.',
        [0, 2],
        ['43', '41'],
      ),
    ],
    check: 'Why not index every column?',
    answer:
        'Indexes use storage and must be maintained on writes; add those that help measured access patterns.',
  ),
  SqlLesson(
    id: 'normalization',
    unit: 'Performance & design',
    title: 'Normalize without losing context',
    summary: 'Keep facts in the right place.',
    concept:
        'Normalization reduces repeated facts and update anomalies. Store the current product name once, but preserve historical facts such as price paid on each order item.',
    why:
        'A product price change should not silently rewrite the economics of an old order.',
    when:
        'Design a schema with repeated values or data that changes on different schedules.',
    operation:
        'Separate entities, link by keys, and duplicate only facts that belong to a historical event or deliberate read model.',
    sql: '''SELECT oi.order_id, p.name, oi.quantity, oi.unit_price_cents
FROM order_items AS oi
JOIN products AS p ON p.id = oi.product_id
WHERE oi.order_id = ?;''',
    result:
        'The current product name is joined with the historical unit price paid.',
    application:
        'An order receipt keeps its original price even after the catalog price changes.',
    appCode: '''const receipt = await db.all(receiptSql, [orderId]);
// Display oi.unit_price_cents, not the current products.price_cents.''',
    alternative:
        'A denormalized snapshot can improve read speed or protect historical wording, but define exactly which fields are snapshots.',
    pitfall:
        'Over-normalization can add needless joins; denormalization without a clear source of truth creates inconsistencies.',
    traceInput: [
      'product 1 · now 1199 cents',
      'order 41 item · paid 999 cents',
      'receipt for order 41',
    ],
    trace: [
      SqlTraceStep(
        'Read catalog',
        'Current price is 1199.',
        [0],
        ['product: 1199'],
      ),
      SqlTraceStep(
        'Read line item',
        'The order item saved price 999 at checkout.',
        [1],
        ['paid: 999'],
      ),
      SqlTraceStep(
        'Build receipt',
        'Use the historical price for this order.',
        [1, 2],
        ['Notebook · 999 cents'],
      ),
    ],
    check:
        'Why store unit_price_cents on order_items as well as current price on products?',
    answer:
        'The order item records the historical price actually paid; the catalog price can change later.',
  ),
  SqlLesson(
    id: 'migrations',
    unit: 'Performance & design',
    title: 'Schema migrations',
    summary: 'Change a live database in versioned steps.',
    concept:
        'A migration records an ordered schema change. App versions and existing data must agree on the resulting structure.',
    why:
        'Users already have databases; changing CREATE TABLE in source code does not change their existing tables.',
    when:
        'Add a column, index, constraint, or data transformation after the app is in use.',
    operation:
        'Create a versioned migration, test it on old data, then run it once during upgrade.',
    sql: '''ALTER TABLE products
ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
CREATE INDEX idx_products_active ON products(is_active);''',
    result:
        'Existing products get is_active = 1 and new code can filter active products.',
    application:
        'A catalog release introduces product archiving without losing old rows.',
    appCode: '''// In a migration runner, execute once for schema version 2:
await db.exec(addIsActiveSql);
await db.exec('PRAGMA user_version = 2');''',
    alternative:
        'For complex SQLite table changes, create a replacement table, copy validated data, swap tables, and preserve indexes/triggers in a transaction.',
    pitfall:
        'Never rerun a non-idempotent migration on every app launch; back up and test migration paths.',
    traceInput: [
      'v1 products table',
      'add is_active default 1',
      'v2 products table',
    ],
    trace: [
      SqlTraceStep(
        'Detect v1',
        'The upgrade runner sees schema version 1.',
        [0],
        ['version 1'],
      ),
      SqlTraceStep(
        'Apply change',
        'The new column is added with a default for existing rows.',
        [1],
        ['is_active = 1'],
      ),
      SqlTraceStep(
        'Record v2',
        'The runner records the completed version.',
        [2],
        ['version 2'],
      ),
    ],
    check:
        'Why is editing a CREATE TABLE statement insufficient for existing users?',
    answer:
        'Their database already exists. A versioned migration must transform its schema and data.',
  ),
  SqlLesson(
    id: 'access-control',
    unit: 'Application practice',
    title: 'Access checks and query safety',
    summary: 'Bind values and scope data to the user.',
    concept:
        'Parameterized queries protect SQL syntax. Authorization checks ensure a user can access the specific row even if they guess its ID.',
    why:
        'A correct query can still leak another customer’s order if it filters only by order ID.',
    when: 'Every API endpoint that reads or changes user-owned data.',
    operation:
        'Authenticate the caller, use server-trusted user ID, bind values, and include ownership in the predicate.',
    sql: '''SELECT id, status, total_cents FROM orders
WHERE id = ? AND user_id = ?;''',
    result: 'An order is returned only if its ID and owner both match.',
    application:
        'An order detail API prevents one signed-in user from reading another user’s order.',
    appCode: '''const userId = auth.user.id; // trusted server-side identity
const [order] = await db.all(
  'SELECT id, status FROM orders WHERE id = ? AND user_id = ?',
  [orderId, userId]
);
if (!order) throw new NotFoundError();''',
    alternative:
        'A server database with row-level security can add another enforcement layer; SQLite itself has no built-in per-user role system.',
    pitfall:
        'Do not accept user_id from the request body as proof of ownership.',
    traceInput: [
      'signed-in user 7',
      'order 41 · owner 7',
      'order 42 · owner 8',
    ],
    trace: [
      SqlTraceStep(
        'Authenticate',
        'Server obtains trusted user ID 7.',
        [0],
        ['caller: 7'],
      ),
      SqlTraceStep(
        'Bind predicate',
        'Both order ID and owner must match.',
        [0, 1],
        ['41 allowed'],
      ),
      SqlTraceStep(
        'Reject mismatch',
        'Order 42 is not returned to user 7.',
        [2],
        ['42 hidden'],
      ),
    ],
    check: 'Why is WHERE id = ? alone not enough for a user-owned order API?',
    answer:
        'A guessed ID could retrieve another user’s order. Include the trusted owner ID in the predicate and enforce authorization.',
  ),
  SqlLesson(
    id: 'checkout-capstone',
    unit: 'Application practice',
    title: 'Capstone: checkout flow',
    summary: 'Connect modeling, safe SQL, and transactions.',
    concept:
        'A checkout combines schema rules, stock checks, historical item prices, an atomic transaction, and a query that reads the resulting receipt.',
    why:
        'Real application features combine multiple database techniques; correctness comes from the whole workflow.',
    when:
        'Use this pattern for purchases, bookings, reservations, and other multi-row business actions.',
    operation:
        'Validate request, begin transaction, check stock, insert order/items, update stock, commit, then read receipt.',
    sql: '''BEGIN IMMEDIATE;
UPDATE products SET stock = stock - ?
WHERE id = ? AND stock >= ?;
-- Check that one row changed before continuing.
INSERT INTO orders (user_id, status, total_cents)
VALUES (?, 'paid', ?);
INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents)
VALUES (?, ?, ?, ?);
COMMIT;''',
    result:
        'A successful checkout stores a consistent order and stock change. Any failed validation rolls the transaction back.',
    application:
        'A checkout endpoint uses a transaction and returns a receipt built from saved order-item prices.',
    appCode: '''await db.transaction(async tx => {
  const changed = await tx.run(decrementStockSql, [qty, productId, qty]);
  if (changed.rowCount !== 1) throw new Error('Out of stock');
  const orderId = await tx.insertOrder(userId, totalCents);
  await tx.insertItem(orderId, productId, qty, unitPriceCents);
}); // Roll back on any throw.''',
    alternative:
        'For multiple products, check and update each within the same transaction. A distributed checkout across services needs a separate coordination design.',
    pitfall:
        'Do not trust client-sent total_cents without recomputing it from server-side prices and quantities.',
    traceInput: [
      'stock 3 · request 2',
      'order + item writes',
      'commit / rollback',
    ],
    trace: [
      SqlTraceStep(
        'Reserve stock',
        '3 >= 2, so the guarded update changes stock to 1.',
        [0],
        ['stock: 1'],
      ),
      SqlTraceStep(
        'Create order',
        'Order and item capture the validated quantity and price.',
        [1],
        ['order 41', 'item qty 2'],
      ),
      SqlTraceStep(
        'Commit',
        'All three changes become durable together.',
        [0, 1, 2],
        ['stock 1', 'order 41 saved'],
      ),
    ],
    check: 'What must happen if the guarded stock UPDATE changes zero rows?',
    answer:
        'Abort and roll back; stock was unavailable or the product did not exist, so no order should be committed.',
  ),
];
