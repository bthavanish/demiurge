# Platform-Native Alternatives

The lazy senior dev's first question: does the platform already do this?

## HTML Elements

| You think you need | What the platform has |
|---|---|
| Date picker library | `<input type="date">` |
| Time picker library | `<input type="time">` |
| Color picker library | `<input type="color">` |
| Range slider library | `<input type="range">` |
| Progress bar component | `<progress value="70" max="100">` |
| Meter/gauge component | `<meter value="0.7">` |
| Modal/dialog library | `<dialog>` + `dialog.showModal()` |
| Accordion/FAQ component | `<details><summary>Title</summary>...</details>` |
| Tooltip library | `title` attribute + CSS `::before`/`::after` |
| Searchable dropdown | `<input list="id"> <datalist id="id">` |
| Auto-growing textarea | `field-sizing: content` (CSS) |
| Sticky header | `position: sticky; top: 0` (CSS) |

## CSS Capabilities

| You think you need JS for | What CSS has |
|---|---|
| Responsive font size | `font-size: clamp(1rem, 2.5vw, 2rem)` |
| Fluid spacing | `padding: clamp(1rem, 5vw, 3rem)` |
| Dark mode | `@media (prefers-color-scheme: dark)` |
| Reduced motion | `@media (prefers-reduced-motion: reduce)` |
| Responsive layout | `grid-template-columns: repeat(auto-fill, minmax(250px, 1fr))` |
| Component-level responsive | `@container` queries |
| Global design tokens | CSS custom properties (`--color-primary: #7c3aed`) |
| Smooth scroll | `scroll-behavior: smooth` |
| Scroll-snap carousel | `scroll-snap-type: x mandatory` + `scroll-snap-align: start` |
| Aspect ratio | `aspect-ratio: 16 / 9` |
| Text truncation | `overflow: hidden; text-overflow: ellipsis; white-space: nowrap` |
| Multi-line clamp | `-webkit-line-clamp: 3` |
| Cascade layers | `@layer base, components, utilities` |
| Native nesting | Native CSS nesting (no preprocessor) |
| Parent selector | `:has(input:checked)` |

## JavaScript / Browser APIs

| You think you need | What the platform has |
|---|---|
| `query-string` / `qs` | `new URLSearchParams(location.search)` |
| `lodash.clonedeep` | `structuredClone(obj)` |
| `lodash.groupby` | `Object.groupBy(arr, fn)` |
| `lodash.debounce` | `let t; const debounce = (fn, ms) => (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };` |
| `numeral` / `accounting` | `new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })` |
| `date-fns` format | `new Intl.DateTimeFormat("en-US", { dateStyle: "long" }).format(date)` |
| `clipboard.js` | `navigator.clipboard.writeText(text)` |
| `uuid` (v4) | `crypto.randomUUID()` |
| Infinite scroll | `new IntersectionObserver(cb).observe(sentinel)` |
| Resize listener | `new ResizeObserver(cb).observe(element)` |
| DOM mutation watcher | `new MutationObserver(cb).observe(el, options)` |
| Abort fetch on timeout | `AbortSignal.timeout(5000)` passed to `fetch` |
| Custom event bus | `new EventTarget()` / `dispatchEvent(new CustomEvent("x", { detail }))` |

## Node.js Standard Library

| You think you need | What Node has |
|---|---|
| `mkdirp` | `fs.mkdirSync(path, { recursive: true })` |
| `rimraf` | `fs.rmSync(path, { recursive: true, force: true })` |
| `uuid` (v4) | `crypto.randomUUID()` |
| `object-assign` | `Object.assign()` / spread |
| `array-uniq` | `[...new Set(arr)]` |
| `array-flatten` | `arr.flat(Infinity)` |
| `path-exists` | `fs.existsSync(path)` |
| `load-json-file` | `JSON.parse(fs.readFileSync(path, "utf8"))` |
| `write-json-file` | `fs.writeFileSync(path, JSON.stringify(obj, null, 2))` |

## Python Standard Library

| You think you need | What Python has |
|---|---|
| `python-dateutil` (basic) | `datetime.fromisoformat()` (3.7+) |
| `pytz` | `zoneinfo.ZoneInfo("America/New_York")` (3.9+) |
| `attrs` (simple data) | `@dataclass` |
| `six` | drop it, Python 2 is gone |
| `pathlib2` | `pathlib.Path` (built-in since 3.4) |
| `simplejson` (basic) | `json` (stdlib) |
| `click` (single command) | `argparse` (stdlib) |
| `mergedeep` | `dict \| other_dict` (3.9+) |

## Database

| You think you need app code for | What the database has |
|---|---|
| Pagination | `LIMIT 20 OFFSET 40` |
| Running totals | `SUM(...) OVER (ORDER BY date)` |
| Rank within group | `RANK() OVER (PARTITION BY category ORDER BY score DESC)` |
| Deduplication | `SELECT DISTINCT` / `ON CONFLICT DO NOTHING` |
| Tree traversal | Recursive CTE (`WITH RECURSIVE`) |
| Full-text search | `tsvector` / `MATCH AGAINST` / `FTS5` |
| UUID generation | `gen_random_uuid()` (Postgres) |
| Enforce uniqueness | `UNIQUE` constraint |
| Enforce referential integrity | `FOREIGN KEY` |
| Enforce value ranges | `CHECK (price > 0)` |

## The Pattern

Platform team solves problem. Package author wraps it. You install wrapper. Wrapper goes unmaintained. You debug wrapper. Skip the wrapper.
