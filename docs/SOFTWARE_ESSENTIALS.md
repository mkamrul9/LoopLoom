# Software Essentials courses

Software Essentials is a separate learning area from interview roadmaps. Its three courses use a small shop as a continuing example: the database stores products and orders, the backend exposes guarded operations, and the browser presents the catalog and checkout flow. A learner may open any lesson without completing earlier ones.

## Courses

- **Databases & SQL — 21 lessons:** relational modeling, constraints, reads and filters, joins, many-to-many data, grouping, window functions, transactions, upserts, indexes, normalization, migrations, access control, and a checkout example. Examples use SQLite syntax.
- **Backend Engineering — 16 lessons:** request flow, HTTP methods and status, routing, validation, data boundaries, transactions, authentication, authorization, errors, idempotency, jobs, caching, pagination, tests, observability, and deployment.
- **Frontend Engineering — 16 lessons:** semantic HTML, CSS layout, responsive design, events and state, forms, fetch, asynchronous states, URLs, components, keyboard access, design tokens, browser tests, performance, safe text rendering, offline behavior, and release checks.

Every lesson has a concept, reason, use case, operating steps, focused code, expected result, an application example, an alternative, a common mistake, a three-step visual explanation, and a short question with a revealed answer. The visual traces are authored examples and do not run the code. Code snippets are focused teaching examples: snippets that mention a store, queue, router, test page, or UI helper assume that adapter exists in a larger application. The app does not currently provide a SQL, backend, or browser-code sandbox for these courses.

Completion is stored in the local learner preferences and included when study preferences are restored from a workbook backup. Course progress counts only lessons in that course. Completing a course does not mark interview problems solved.

## Editorial references

The course explanations and examples are original LoopLoom content. Technical behavior was checked against primary references:

- [MDN HTTP methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods) and [status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status)
- [OWASP input validation](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) and [authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)
- [MDN HTML forms](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/HTML_forms), [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API), and [web performance](https://developer.mozilla.org/en-US/docs/Web/Performance)
- [SQLite SELECT](https://www.sqlite.org/lang_select.html), [transactions](https://www.sqlite.org/lang_transaction.html), and [foreign keys](https://www.sqlite.org/foreignkeys.html)

Before calling the courses production-grade training, each lesson and code example still needs independent technical review and learner testing. The app labels illustrative code and traces accordingly.
