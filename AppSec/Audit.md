### Auth & session flows
- **Token handling:** new uses of `localStorage`/`sessionStorage`/`indexedDB`/`postMessage` or cookies with `access|auth|id|jwt|token`. Alert on tokens stored outside httpOnly cookies; watch for `SameSite=None` without `Secure`.
- **OAuth/OIDC:** new/changed `redirect_uri`, `post_logout_redirect_uri`, altered PKCE/state usage; addition of social login providers.
- **Password reset / magic links:** new endpoints with `reset`, `recovery`, `verify`, `otp`, `code`, `token`.

### Privilege & feature-controls (beyond user flags)
- **Feature flags / AB tests:** discovery of new flags like `enableAdmin`, `betaPayments`, `bypassKyc`. Monitor for flags checked only client-side.
- **Role leakage:** strings like `isStaff`, `isInternal`, `entitlements`, `scopes`. Alert when code gates UI only in JS.

### Endpoint discovery (beyond declarations)
- **Hidden APIs:** scrape JS bundles for URLs: `/(wss?|https?):\/\/[^"' )]+/`. Include **GraphQL** (`/graphql`) and **WebSocket** endpoints.
- **Method/verb expansion:** watch for `DELETE`, `PUT`, `PATCH`, `OPTIONS` becoming allowed on existing paths.
- **Parameter shape drift:** new query/body fields, especially `role`, `price`, `discount`, `is_admin`, `user_id`, `owner_id`, `redirect`, `returnTo`.

### Source maps & build artifacts
- **Leaked source maps:** `.map` files yielding readable source, comments, internal endpoints, secrets, or TODOs.
- **Debug builds / env leakage:** `__DEV__`, `NEXT_PUBLIC_*`, `REACT_APP_*`, Vite `import.meta.env.*` appearing with sensitive data.

### Client-side sinks & sanitization
- **XSS-prone sinks:** `innerHTML`, `outerHTML`, `insertAdjacentHTML`, `document.write`, jQuery `.html()`, React `dangerouslySetInnerHTML`.
- **Template eval:** usage of `new Function`, `eval`, `setTimeout(string)`, `handlebars.compile` of untrusted input.
- **URL handling:** dynamic `location`, `window.open`, `document.location = param`, client-side redirects; watch for `next=`/`redirect=` params.

### Cross-origin surfaces
- **CORS changes:** `Access-Control-Allow-Origin: *` or new origins; credentials allowed; new `OPTIONS` responses.
- **postMessage:** new message types; missing `origin` checks; wildcard  targets.
- **SRI/CSP drift:** weaker CSP (e.g., `unsafe-inline` added) or SRI removed from critical third-party scripts.

### File & content handling (beyond content types)
- **Uploads:** endpoints handling `multipart/form-data`, image manipulation, or document viewers; check MIME sniffing, transformation, and metadata parsing.
- **Downloads:** new `Content-Disposition: inline` on HTML/JS, type mismatches (`text/html` served for user-controlled content).
- **Markdown/renderers:** any renderer libraries added/updated (MD, MDX, YAML frontmatter).

### Service Workers & caching
- **Service Worker registration:** new/changed SW scripts; cache rules for HTML/JSON; possible cache poisoning or offline auth bypass.
- **Cache-control drift:** public caching of sensitive endpoints.

### Third-party & supply chain
- **New third-party scripts:** analytics, chat widgets, payment SDKs (Stripe/Adyen), feature flag clients. Monitor for permission scopes, DOM access, and iframes with `allow` attributes.
- **WASM & crypto libs:** sudden addition of `.wasm` or crypto libs can hint at sensitive logic moved client-side.

### Framework-specific hotspots
- **Next.js / Nuxt:** new `/api/*` routes, rewrites/redirects, middleware; public env vars; SSR vs. CSR path changes.
- **GraphQL:** introspection enabled, new mutations, authorization directives disappearing, file upload scalar enabled.
- **tRPC/REST wrappers:** new procedures bypassing traditional auth middleware.

---

# What to *extract* automatically from JS

- **All absolute/relative URLs** (HTTP/WS), plus path templates (`/v1/users/:id`).
- **Regexes & validation** patterns (help craft payloads).
- **Feature flag keys & default states.**
- **Role/permission strings** and checks.

# Triggers worth paging on

- Token written to `localStorage` or `postMessage` with .
- Any `admin`/`internal` route or flag found client-side.
- New `PUT/PATCH/DELETE` supported on previously read-only endpoints.
- Source map becomes available (or diff changes > X% of mappable files).
- Service Worker added or scope widened (e.g., `/` instead of `/app`).
- New third part scripts or injected iframes

# Handy regex/snippet examples

- **URLs:** `/(https?:|wss?:)\/\/[^\s"'<>)]+/g`
- **Role/flag keys:** `/(is_|has_|can_)?(admin|staff|internal|premium|beta)\b/i`
- **Dangerous sinks:** `\b(innerHTML|outerHTML|insertAdjacentHTML|document\.write|dangerouslySetInnerHTML|eval|new Function)\b`
- **Tokens in storage:** `localStorage\.(setItem|getItem)\(['"]([^'"]*token[^'"]*)['"]`
- **GraphQL endpoints:** `/\/graphql(?:\/?|[\?#])/i`
- **Feature flags (common libs):** `launchdarkly|unleash|splitio|growthbook|optimizely`
