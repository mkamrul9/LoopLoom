part of 'engineering_course.dart';

const frontendLessons = <EngineeringLesson>[
  EngineeringLesson(
    id: 'frontend-semantic-html',
    unit: 'Browser foundations',
    title: 'Structure meaningful HTML',
    summary: 'Choose elements for their job.',
    concept:
        'Semantic HTML gives content and controls meaning before CSS or JavaScript runs. Headings, landmarks, links, buttons, and forms communicate structure to browsers and assistive technology.',
    why:
        'Built-in browser behavior reduces custom code and helps keyboard and screen-reader users.',
    when:
        'Start every page and component with the element that matches its purpose.',
    how:
        'Use headings in order, main for primary content, links for navigation, and buttons for actions.',
    codeLabel: 'HTML · PRODUCT CARD',
    code: '''<main>
  <h1>Shop products</h1>
  <article>
    <h2>Canvas bag</h2>
    <p>Durable everyday carry.</p>
    <a href="/products/12">View details</a>
    <button type="button">Add to cart</button>
  </article>
</main>''',
    result:
        'The product has a heading, navigation link, and distinct action button.',
    application:
        'The shop catalog remains understandable when CSS loads slowly or a learner navigates using a keyboard.',
    appCode: '''<nav aria-label="Primary">
  <a href="/products">Products</a>
  <a href="/cart">Cart</a>
</nav>''',
    alternative:
        'A component framework can render this markup, but the resulting HTML still needs correct semantics.',
    pitfall:
        'A clickable div does not automatically behave like a button for keyboard and assistive technology.',
    traceInput: ['page title', 'product card', 'add action'],
    trace: [
      EngineeringTraceStep(
        'Landmark',
        'The main region identifies primary page content.',
        [0],
        ['main · Shop products'],
      ),
      EngineeringTraceStep(
        'Structure',
        'The product heading gives the article a name.',
        [1],
        ['article · Canvas bag'],
      ),
      EngineeringTraceStep(
        'Action',
        'The button exposes a real action control.',
        [2],
        ['button · Add to cart'],
      ),
    ],
    check: 'Should Add to cart be a link or a button?',
    answer:
        'Use a button because it performs an action. Use a link when the user navigates to another destination.',
  ),
  EngineeringLesson(
    id: 'frontend-css-layout',
    unit: 'Browser foundations',
    title: 'Build layout with CSS',
    summary: 'Let content flow before adding rules.',
    concept:
        'CSS controls presentation through selectors, the cascade, and layout systems. Grid works well for page or card tracks; flexbox works well for one-dimensional groups.',
    why:
        'A layout built from content and flexible tracks survives different labels, text sizes, and screen widths.',
    when: 'Arrange a navigation bar, product cards, or page columns.',
    how:
        'Start with normal document flow, then add grid or flex where the relationship needs it.',
    codeLabel: 'CSS · PRODUCT GRID',
    code: '''.products {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}
.product-card { padding: 1rem; border: 1px solid #ccc; }''',
    result: 'Cards fill available space and wrap without a fixed column count.',
    application:
        'The shop catalog uses the same markup on a narrow phone and a wide desktop, with CSS deciding the columns.',
    appCode: '''<section class="products" aria-label="Products">
  <article class="product-card">...</article>
  <article class="product-card">...</article>
</section>''',
    alternative:
        'Flexbox can wrap cards too; grid gives more explicit shared column tracks.',
    pitfall:
        'Fixed widths and large minimums can create horizontal overflow on small screens.',
    traceInput: [
      'available width: 320px',
      'card minimum: up to 16rem',
      'gap: 1rem',
    ],
    trace: [
      EngineeringTraceStep(
        'Measure',
        'The container has a narrow available width.',
        [0],
        ['320px'],
      ),
      EngineeringTraceStep(
        'Fit',
        'Only one card track fits.',
        [1, 2],
        ['one column'],
      ),
      EngineeringTraceStep(
        'Wrap',
        'More cards flow onto new rows.',
        [0, 1, 2],
        ['stacked cards'],
      ),
    ],
    check: 'Why use a flexible grid track instead of a fixed 400px card width?',
    answer:
        'The flexible track can shrink and wrap for narrow viewports and larger text without forcing horizontal scrolling.',
  ),
  EngineeringLesson(
    id: 'frontend-responsive',
    unit: 'Browser foundations',
    title: 'Design across screen sizes',
    summary: 'Adapt to space and input.',
    concept:
        'Responsive design lets content and controls reflow to the available space. Mobile usability also depends on tap targets, text scaling, and avoiding accidental horizontal scroll.',
    why:
        'A desktop screenshot cannot prove a form or catalog works on a phone.',
    when: 'Every page that may open on a phone, tablet, or desktop.',
    how:
        'Use a viewport meta tag, flexible dimensions, and a breakpoint only where the content needs a different arrangement.',
    codeLabel: 'HTML + CSS · RESPONSIVE SHELL',
    code:
        '''<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  .shell { display: grid; gap: 1rem; }
  @media (min-width: 48rem) {
    .shell { grid-template-columns: 14rem minmax(0, 1fr); }
  }
</style>''',
    result:
        'The shell stacks on small screens and gains a sidebar when enough width exists.',
    application:
        'The shop filter panel appears above products on a phone and beside them on desktop.',
    appCode: '''<div class="shell">
  <aside aria-label="Product filters">...</aside>
  <main>...</main>
</div>''',
    alternative:
        'Container queries adapt a component to its own width when the surrounding page layout varies.',
    pitfall: 'Do not disable zoom or rely on hover-only controls.',
    traceInput: ['phone · 360px', 'tablet · 700px', 'desktop · 1100px'],
    trace: [
      EngineeringTraceStep(
        'Phone',
        'Filters stack above products.',
        [0],
        ['single column'],
      ),
      EngineeringTraceStep(
        'Tablet',
        'Content still prioritizes readable width.',
        [1],
        ['single column'],
      ),
      EngineeringTraceStep(
        'Desktop',
        'Sidebar and main content fit together.',
        [2],
        ['two columns'],
      ),
    ],
    check: 'What should determine a breakpoint?',
    answer:
        'The point where the content needs a different arrangement, not a particular device model name.',
  ),
  EngineeringLesson(
    id: 'frontend-events',
    unit: 'Browser foundations',
    title: 'Connect events to state',
    summary: 'One action, one predictable update.',
    concept:
        'An event reports user input. Application state records what should be displayed next. Rendering should follow state rather than scattering unrelated DOM changes.',
    why: 'Predictable state makes cart counts and button labels stay in sync.',
    when: 'A control changes what the user sees or what the app will submit.',
    how:
        'Listen to the action, update the state, then render the affected view.',
    codeLabel: 'JAVASCRIPT · CART COUNT',
    code: '''let cartCount = 0;
const add = document.querySelector('#add');
const count = document.querySelector('#count');
add.addEventListener('click', () => {
  cartCount += 1;
  count.textContent = String(cartCount);
});''',
    result: 'Each click increments both state and the visible count.',
    application:
        'The shop cart badge changes when a product is added without reloading the page.',
    appCode: '''<button id="add" type="button">Add to cart</button>
<output id="count" aria-live="polite">0</output>''',
    alternative:
        'A UI framework can render from state automatically; the event → state → view reasoning stays the same.',
    pitfall:
        'Updating the badge without updating the underlying cart state makes later checkout inconsistent.',
    traceInput: ['count = 0', 'click Add', 'count display'],
    trace: [
      EngineeringTraceStep(
        'Initial',
        'State and view both show zero.',
        [0],
        ['0'],
      ),
      EngineeringTraceStep(
        'Event',
        'The click handler increments state.',
        [1],
        ['cartCount = 1'],
      ),
      EngineeringTraceStep(
        'Render',
        'The output reflects the new state.',
        [2],
        ['display = 1'],
      ),
    ],
    check: 'Which is the source of truth: the badge text or the cart state?',
    answer: 'The cart state. The badge is a view derived from it.',
  ),
  EngineeringLesson(
    id: 'frontend-forms',
    unit: 'Application flow',
    title: 'Build usable forms',
    summary: 'Label, validate, and submit clearly.',
    concept:
        'A form groups related inputs and gives the browser useful submission behavior. Labels, input types, constraints, and error messages help people complete it.',
    why:
        'A checkout form with unclear fields or silent validation failure costs trust and time.',
    when: 'Collecting search, contact, shipping, or checkout details.',
    how:
        'Associate every field with a label, mark required values, handle submit, and present specific errors near the relevant field.',
    codeLabel: 'HTML · SHIPPING FORM',
    code: '''<form id="shipping">
  <label for="email">Email</label>
  <input id="email" name="email" type="email" required>
  <label for="postcode">Postcode</label>
  <input id="postcode" name="postcode" autocomplete="postal-code" required>
  <button type="submit">Continue</button>
</form>''',
    result:
        'The browser can focus, label, and check required fields before submission.',
    application:
        'The shop checkout collects a receipt address and delivery postcode with usable labels on phone and desktop.',
    appCode:
        '''document.querySelector('#shipping').addEventListener('submit', (event) => {
  event.preventDefault();
  const data = new FormData(event.currentTarget);
  submitShipping(Object.fromEntries(data));
});''',
    alternative:
        'A framework form library can manage state and validation, but the final controls still need accessible labels and server validation.',
    pitfall:
        'Placeholder text is not a persistent label and should not be the only field description.',
    traceInput: ['email field', 'postcode field', 'Continue button'],
    trace: [
      EngineeringTraceStep(
        'Enter',
        'The learner fills named fields.',
        [0, 1],
        ['email + postcode'],
      ),
      EngineeringTraceStep(
        'Check',
        'Browser constraints catch missing required values.',
        [0, 1],
        ['valid form'],
      ),
      EngineeringTraceStep(
        'Submit',
        'The handler reads named form data.',
        [2],
        ['shipping payload'],
      ),
    ],
    check: 'Why is a label better than only a placeholder?',
    answer:
        'A label remains available and is associated with the input for focus and assistive technology; a placeholder disappears as the user types.',
  ),
  EngineeringLesson(
    id: 'frontend-fetch',
    unit: 'Application flow',
    title: 'Fetch and parse API data',
    summary: 'Handle the response contract.',
    concept:
        'fetch sends a request and returns a Response. HTTP error statuses still produce a response object, so the application must inspect response.ok before using the body.',
    why:
        'A catalog screen should not treat an API failure body as a valid product array.',
    when: 'Loading data from the backend or submitting a change.',
    how:
        'Send the request, check status, parse the expected body, then update view state.',
    codeLabel: 'JAVASCRIPT · CATALOG REQUEST',
    code: '''async function loadProducts() {
  const response = await fetch('/api/products');
  if (!response.ok) throw new Error('Could not load products');
  return response.json();
}''',
    result:
        'A 2xx JSON response becomes product data; a 4xx/5xx becomes an error.',
    application:
        'The shop catalog loads products from the API and passes them to its product-list view.',
    appCode: '''try {
  const products = await loadProducts();
  renderProducts(products);
} catch {
  showCatalogError('Products are unavailable. Try again.');
}''',
    alternative:
        'A data-fetching library can add request deduplication and caching; begin by understanding the response lifecycle.',
    pitfall:
        'fetch does not reject merely because the server returned 404 or 500.',
    traceInput: ['GET /api/products', 'response: 200', 'JSON array'],
    trace: [
      EngineeringTraceStep(
        'Request',
        'The browser asks for products.',
        [0],
        ['pending'],
      ),
      EngineeringTraceStep(
        'Check',
        'A 200 status passes response.ok.',
        [1],
        ['success'],
      ),
      EngineeringTraceStep(
        'Parse',
        'The JSON body becomes product data.',
        [2],
        ['render products'],
      ),
    ],
    check: 'Does fetch reject automatically for an HTTP 500 response?',
    answer:
        'No. Check response.ok or response.status; fetch rejects for network-level failures and some other request errors.',
  ),
  EngineeringLesson(
    id: 'frontend-async-states',
    unit: 'Application flow',
    title: 'Show loading, empty, and error',
    summary: 'Make every state understandable.',
    concept:
        'An asynchronous screen has more than success. Pending, empty, failed, and ready are distinct states with distinct user needs.',
    why:
        'Without explicit states, a blank catalog can look broken or falsely look empty.',
    when: 'Any view that waits for network or local data.',
    how:
        'Represent the status in one state value, render the right message, and offer a retry for recoverable failure.',
    codeLabel: 'TYPESCRIPT · VIEW STATE',
    code: '''type CatalogState =
  | { kind: 'loading' }
  | { kind: 'empty' }
  | { kind: 'error'; message: string }
  | { kind: 'ready'; products: Product[] };''',
    result: 'Rendering can handle each state deliberately.',
    application:
        'The shop shows a progress message during loading, an empty-state suggestion for no matches, and Retry after a network failure.',
    appCode: '''if (state.kind === 'loading') showStatus('Loading products…');
if (state.kind === 'empty') showStatus('No products match.');
if (state.kind === 'error') showRetry(state.message);
if (state.kind === 'ready') renderProducts(state.products);''',
    alternative:
        'A state machine library can formalize more complex flows; a small discriminated union is enough for a simple list.',
    pitfall: 'Do not show “No products” while the request is still loading.',
    traceInput: ['request begins', 'response: []', 'network failure'],
    trace: [
      EngineeringTraceStep(
        'Pending',
        'The request has started but no result exists.',
        [0],
        ['loading'],
      ),
      EngineeringTraceStep(
        'Empty',
        'A successful empty array is an empty state.',
        [1],
        ['no matches'],
      ),
      EngineeringTraceStep(
        'Failed',
        'A rejected request needs an error and retry.',
        [2],
        ['retry available'],
      ),
    ],
    check: 'How does an empty result differ from a failed request?',
    answer:
        'Empty means the request succeeded and returned no items. Failed means the app could not establish a valid result.',
  ),
  EngineeringLesson(
    id: 'frontend-routing',
    unit: 'Application flow',
    title: 'Make URLs useful',
    summary: 'Keep navigation and state shareable.',
    concept:
        'A URL identifies a location and can encode shareable view state such as product ID, category, or search term. Browser history should reflect navigation.',
    why:
        'A shopper should be able to share a product link and use Back without losing their place.',
    when:
        'A view should be bookmarkable, shareable, or part of back/forward navigation.',
    how:
        'Read and validate URL state, render the matching view, and update history for navigations.',
    codeLabel: 'JAVASCRIPT · URL STATE',
    code: '''const url = new URL(window.location.href);
const category = url.searchParams.get('category') ?? 'all';
const productPath = url.pathname.match(new RegExp('^/products/([0-9]+)\$'));''',
    result:
        '/products/12 identifies a detail page; ?category=bags identifies a catalog filter.',
    application:
        'The shop’s product detail is shareable, while the catalog filter survives refresh and Back.',
    appCode: '''function chooseCategory(category) {
  const url = new URL(window.location.href);
  url.searchParams.set('category', category);
  history.pushState({}, '', url);
  renderCatalog(category);
}''',
    alternative:
        'A router library handles path matching and history events for larger apps.',
    pitfall:
        'pushState does not automatically render the new view or handle popstate; wire both directions.',
    traceInput: ['catalog · all', 'choose bags', 'press Back'],
    trace: [
      EngineeringTraceStep(
        'Initial',
        'The URL has no category filter.',
        [0],
        ['all products'],
      ),
      EngineeringTraceStep(
        'Navigate',
        'A category is written into history.',
        [1],
        ['?category=bags'],
      ),
      EngineeringTraceStep(
        'Back',
        'The browser restores the previous URL.',
        [2],
        ['all products again'],
      ),
    ],
    check:
        'What extra event must an app handle when a user presses browser Back?',
    answer:
        'Handle popstate or let a router do it, then re-render from the restored URL.',
  ),
  EngineeringLesson(
    id: 'frontend-components',
    unit: 'Quality and access',
    title: 'Split UI by responsibility',
    summary: 'Make reusable pieces with clear inputs.',
    concept:
        'A component owns a small piece of interface and accepts explicit data and actions. Reuse is valuable when behavior and meaning repeat.',
    why:
        'Product cards should render consistently across catalog, search, and recommendations.',
    when:
        'A repeated interaction has a stable contract and can be tested independently.',
    how:
        'Define inputs, render one responsibility, and send actions upward instead of reaching into unrelated state.',
    codeLabel: 'TYPESCRIPT · COMPONENT CONTRACT',
    code: '''type ProductCardProps = {
  product: { id: number; name: string; priceCents: number };
  onAdd: (id: number) => void;
};
function formatPrice(cents: number): string {
  return (cents / 100).toFixed(2);
}''',
    result:
        'A card receives product data and an Add action; formatting stays consistent.',
    application:
        'The shop uses the same product-card contract in catalog and search results.',
    appCode: '''function addProduct(id: number) {
  cart = [...cart, id];
  renderCartCount(cart.length);
}
renderProductCard({ product, onAdd: addProduct });''',
    alternative:
        'For a tiny static page, a simple function or template may be clearer than a component framework.',
    pitfall:
        'A component that directly modifies global cart state is harder to reuse and test.',
    traceInput: ['product data', 'ProductCard', 'onAdd callback'],
    trace: [
      EngineeringTraceStep(
        'Input',
        'The parent supplies one product.',
        [0],
        ['Canvas bag · 19.00'],
      ),
      EngineeringTraceStep(
        'Render',
        'The card formats and displays it.',
        [1],
        ['visible card'],
      ),
      EngineeringTraceStep(
        'Action',
        'The card reports the selected ID.',
        [2],
        ['onAdd(12)'],
      ),
    ],
    check: 'Why pass an onAdd callback into a product card?',
    answer:
        'The card reports the action while the parent owns cart state and decides what adding means.',
  ),
  EngineeringLesson(
    id: 'frontend-keyboard',
    unit: 'Quality and access',
    title: 'Support keyboard and focus',
    summary: 'Make the journey usable without a mouse.',
    concept:
        'Keyboard users move through interactive controls with focus. Order, visible focus, and dialog behavior are part of the interface contract.',
    why:
        'A button that cannot be focused or activated blocks some users entirely.',
    when: 'Designing navigation, menus, dialogs, forms, or custom controls.',
    how:
        'Prefer native controls, keep DOM order logical, preserve focus styles, and return focus after closing a dialog.',
    codeLabel: 'HTML + CSS · FOCUSABLE CONTROL',
    code: '''<button type="button" id="open-cart">Open cart</button>
<style>
  button:focus-visible { outline: 3px solid #914b36; outline-offset: 3px; }
</style>''',
    result:
        'Tab reaches the button; focus is visible; Enter or Space activates it.',
    application:
        'The shop cart dialog returns focus to Open cart after closing.',
    appCode: '''const trigger = document.querySelector('#open-cart');
trigger.addEventListener('click', () => cartDialog.showModal());
cartDialog.addEventListener('close', () => trigger.focus());''',
    alternative:
        'A tested accessible dialog component can manage focus, but verify its actual keyboard behavior.',
    pitfall:
        'Do not remove outlines without providing an equally visible focus state.',
    traceInput: ['Tab', 'Open cart button', 'Close dialog'],
    trace: [
      EngineeringTraceStep(
        'Focus',
        'Tab moves to a native button.',
        [0, 1],
        ['focus ring visible'],
      ),
      EngineeringTraceStep(
        'Open',
        'Keyboard activation opens the cart.',
        [1],
        ['dialog open'],
      ),
      EngineeringTraceStep(
        'Return',
        'Closing restores focus to the trigger.',
        [2],
        ['focus: Open cart'],
      ),
    ],
    check: 'What should happen to focus after a modal cart dialog closes?',
    answer: 'It should return to the opener or another logical next location.',
  ),
  EngineeringLesson(
    id: 'frontend-design-system',
    unit: 'Quality and access',
    title: 'Use consistent design tokens',
    summary: 'Keep color, spacing, and type coherent.',
    concept:
        'Design tokens name reusable decisions such as surface color, text color, spacing, and focus style.',
    why:
        'Consistency makes interface changes safer and keeps light and dark themes readable.',
    when: 'A product has more than a few screens or needs multiple themes.',
    how:
        'Define semantic tokens, apply them to components, and check contrast and text scaling in each theme.',
    codeLabel: 'CSS · SEMANTIC TOKENS',
    code: ''':root {
  --surface: #f7f3ef;
  --text: #25292b;
  --accent: #914b36;
  --space: 1rem;
}
.card { background: var(--surface); color: var(--text); padding: var(--space); }''',
    result: 'Cards share one readable surface and text pairing.',
    application:
        'The shop uses the same spacing and focus cues in catalog, cart, and checkout.',
    appCode: '''@media (prefers-color-scheme: dark) {
  :root { --surface: #25292b; --text: #f7f3ef; }
}''',
    alternative:
        'A UI library may provide tokens; customize them around real product needs.',
    pitfall:
        'A token called red-500 does not communicate purpose; semantic names make theme changes clearer.',
    traceInput: ['surface token', 'text token', 'dark preference'],
    trace: [
      EngineeringTraceStep(
        'Define',
        'Light tokens provide the base pairing.',
        [0, 1],
        ['paper + charcoal'],
      ),
      EngineeringTraceStep(
        'Apply',
        'Components read tokens instead of fixed values.',
        [0, 1],
        ['consistent cards'],
      ),
      EngineeringTraceStep(
        'Adapt',
        'Dark preference swaps semantic values.',
        [2],
        ['dark surface + light text'],
      ),
    ],
    check: 'Why name a token --surface rather than --cream?',
    answer:
        'Its purpose remains the same when another theme uses a non-cream value.',
  ),
  EngineeringLesson(
    id: 'frontend-testing',
    unit: 'Quality and access',
    title: 'Test user-visible behavior',
    summary: 'Check actions and states, not internals.',
    concept:
        'A frontend test should prove that a user can find a control, perform an action, and understand the result.',
    why:
        'A component can render while its Add button is hidden, unfocusable, or fails silently.',
    when: 'Before changing a flow such as catalog search, cart, or checkout.',
    how:
        'Test loading, success, empty, failure, keyboard navigation, and a narrow viewport.',
    codeLabel: 'TYPESCRIPT · BROWSER TEST SKETCH',
    code: '''await page.goto('/products');
await page.getByRole('button', { name: 'Add to cart' }).first().click();
await expect(page.getByRole('status')).toHaveText('1 item in cart');''',
    result: 'The test checks the visible cart outcome after a user action.',
    application:
        'The shop smoke test opens the catalog on a phone viewport and completes a cart action.',
    appCode: '''await page.setViewportSize({ width: 390, height: 844 });
await page.goto('/checkout');
await expect(page.getByLabel('Email')).toBeVisible();''',
    alternative:
        'Unit tests are useful for pure formatters; browser tests cover markup and focus.',
    pitfall:
        'A test that only checks a function call can miss whether the shopper saw the correct result.',
    traceInput: ['catalog page', 'Add to cart', 'cart status'],
    trace: [
      EngineeringTraceStep(
        'Open',
        'The browser renders the catalog.',
        [0],
        ['products visible'],
      ),
      EngineeringTraceStep(
        'Act',
        'A user activates Add to cart.',
        [1],
        ['click'],
      ),
      EngineeringTraceStep(
        'Assert',
        'The page reports the change.',
        [2],
        ['1 item in cart'],
      ),
    ],
    check:
        'What does a browser test catch that a price-formatting unit test does not?',
    answer:
        'It can catch broken markup, controls, routing, and visible state changes across components.',
  ),
  EngineeringLesson(
    id: 'frontend-performance',
    unit: 'Ship and improve',
    title: 'Make the first view fast',
    summary: 'Prioritize useful content.',
    concept:
        'Page speed depends on download, parsing, rendering, and interaction work. Load what is needed for the current view before optional assets.',
    why:
        'A catalog slow to show products feels broken even when it eventually loads.',
    when:
        'Images, scripts, or data make startup slow on real devices or networks.',
    how:
        'Measure first, compress assets, size images, defer offscreen work, and reduce render-blocking scripts.',
    codeLabel: 'HTML · RESPONSIBLE IMAGE',
    code: '''<img src="bag-480.webp" width="480" height="480"
     loading="lazy" alt="Canvas bag, front view">''',
    result:
        'The browser knows the dimensions and can defer an offscreen image.',
    application:
        'The shop loads visible products promptly while later images load as needed.',
    appCode: '''const images = document.querySelectorAll('img[loading="lazy"]');
console.info('Deferred product images:', images.length);''',
    alternative:
        'Server rendering or static generation may improve the first view for content-heavy pages.',
    pitfall:
        'Do not lazy-load a first-screen hero image without measuring the effect.',
    traceInput: ['HTML', 'first product image', 'offscreen image'],
    trace: [
      EngineeringTraceStep(
        'Parse',
        'The browser receives meaningful HTML.',
        [0],
        ['content structure'],
      ),
      EngineeringTraceStep(
        'Prioritize',
        'Visible content loads early.',
        [1],
        ['first product shown'],
      ),
      EngineeringTraceStep(
        'Defer',
        'Offscreen media waits.',
        [2],
        ['less startup work'],
      ),
    ],
    check: 'Why set width and height on product images?',
    answer:
        'The browser reserves space before images load, reducing layout shifts.',
  ),
  EngineeringLesson(
    id: 'frontend-security',
    unit: 'Ship and improve',
    title: 'Render untrusted text safely',
    summary: 'Keep data out of executable HTML.',
    concept:
        'Product names, reviews, and API text may contain untrusted characters. Render them as text rather than HTML.',
    why:
        'Injecting unsanitized strings into HTML can create cross-site scripting paths.',
    when: 'Displaying any user-generated or external content.',
    how:
        'Use textContent or framework text interpolation that escapes by default; sanitize only when rich HTML is required.',
    codeLabel: 'JAVASCRIPT · SAFE TEXT RENDER',
    code: '''const title = document.createElement('h2');
title.textContent = product.name;
card.append(title);''',
    result:
        'Angle brackets in a product name appear as text, not a new element or script.',
    application:
        'The shop product page displays vendor-supplied names without interpreting them as HTML.',
    appCode: '''// Avoid: card.innerHTML = product.name;
const description = document.createElement('p');
description.textContent = product.description;''',
    alternative:
        'If rich content is required, use a maintained sanitizer with a narrow allowed markup policy.',
    pitfall:
        'Client rendering safety does not replace server authorization or input validation.',
    traceInput: ['name from API', '<script> text', 'product card'],
    trace: [
      EngineeringTraceStep(
        'Receive',
        'The API supplies an untrusted name.',
        [0, 1],
        ['raw text'],
      ),
      EngineeringTraceStep(
        'Assign',
        'textContent treats the value as text.',
        [1],
        ['escaped display'],
      ),
      EngineeringTraceStep(
        'Render',
        'The card shows the name without new HTML.',
        [2],
        ['safe title'],
      ),
    ],
    check: 'Which is safer for a plain product name: textContent or innerHTML?',
    answer:
        'textContent, because it renders the value as text rather than parsing it as HTML.',
  ),
  EngineeringLesson(
    id: 'frontend-offline',
    unit: 'Ship and improve',
    title: 'Plan for weak connectivity',
    summary: 'Cache carefully and show fresh status.',
    concept:
        'A web app can cache its shell or selected data for offline use. The UI must distinguish cached content from fresh server results.',
    why:
        'A shopper may lose signal after opening the catalog or during checkout.',
    when: 'The product should remain useful on slow or intermittent networks.',
    how:
        'Cache stable assets, show connection state, retry safe reads, and never claim a purchase succeeded without confirmation.',
    codeLabel: 'JAVASCRIPT · ONLINE STATUS',
    code:
        '''window.addEventListener('offline', () => showStatus('Offline · showing saved data'));
window.addEventListener('online', () => refreshCatalog());''',
    result:
        'The interface explains why catalog data may be stale and refreshes on reconnection.',
    application:
        'The shop can show viewed products offline but holds checkout as pending until the API confirms the order.',
    appCode: '''try {
  const order = await submitCheckout(cart);
  showOrderConfirmation(order.id);
} catch {
  showStatus('Order not confirmed. Check your connection.');
}''',
    alternative:
        'An offline-first app can queue writes, but needs conflict resolution and a visible pending state.',
    pitfall:
        'Navigator.onLine is only a hint; an API request can fail while it reports online.',
    traceInput: ['catalog cached', 'connection lost', 'checkout attempt'],
    trace: [
      EngineeringTraceStep(
        'Read',
        'Previously cached catalog data remains available.',
        [0],
        ['saved products'],
      ),
      EngineeringTraceStep(
        'Explain',
        'The UI marks it as potentially stale.',
        [1],
        ['offline status'],
      ),
      EngineeringTraceStep(
        'Protect',
        'Checkout is not marked complete without confirmation.',
        [2],
        ['not confirmed'],
      ),
    ],
    check:
        'Can the UI mark an order complete when the checkout request times out?',
    answer:
        'No. The server may or may not have committed; show uncertainty and reconcile safely, ideally with an idempotency key.',
  ),
  EngineeringLesson(
    id: 'frontend-release',
    unit: 'Ship and improve',
    title: 'Release and observe the experience',
    summary: 'Build, verify, deploy, learn.',
    concept:
        'A frontend release includes assets, environment configuration, routing, caching, and monitoring. A deploy is complete when real navigation works.',
    why:
        'A page can load at / while deep links, service-worker updates, or checkout API calls fail.',
    when:
        'Before publishing a web application or replacing an existing version.',
    how:
        'Run a production build, test key flows on phone and desktop, verify deep links and API URL, then watch user-visible failures.',
    codeLabel: 'JAVASCRIPT · BASIC RELEASE CHECK',
    code: '''const response = await fetch('/api/health');
if (!response.ok) showStatus('Service temporarily unavailable');''',
    result: 'The UI can detect an unavailable required backend.',
    application:
        'After deploying the shop, verify product URLs, cart, checkout, and an updated installable app on a real phone.',
    appCode: '''await page.goto('/products/12');
await expect(page.getByRole('heading', { name: 'Canvas bag' }))
  .toBeVisible();
await page.goto('/cart');
await expect(page.getByRole('heading', { name: 'Cart' }))
  .toBeVisible();''',
    alternative:
        'A platform may automate upload and rollback, but product-specific smoke checks remain necessary.',
    pitfall:
        'A green build does not prove deep links or stale browser caches behave after release.',
    traceInput: ['production build', 'deep-link check', 'real phone'],
    trace: [
      EngineeringTraceStep(
        'Build',
        'Release assets compile.',
        [0],
        ['artifact ready'],
      ),
      EngineeringTraceStep(
        'Verify',
        'Direct URLs and API calls are checked.',
        [1],
        ['routes work'],
      ),
      EngineeringTraceStep(
        'Observe',
        'A phone test checks update and interaction quality.',
        [2],
        ['usable release'],
      ),
    ],
    check: 'Why test /products/12 directly after deployment?',
    answer:
        'A direct deep link may fail if the host does not serve the app shell for nested routes.',
  ),
];
