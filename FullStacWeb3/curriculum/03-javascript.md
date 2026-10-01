# JAVASCRIPT EXPERT CURRICULUM — COMPLETE MAP

This project uses browser JavaScript without a framework so you can learn the
language itself. Topics that are not needed by the first StudyLend UI are
included as learning patterns.

---

## 1. JavaScript execution

Understand:

- engine
- runtime
- call stack
- heap
- event loop
- task queue
- microtask queue
- browser APIs

Mental model:

```text
JavaScript
  ↓
Call stack
  ↓
Web APIs
  ↓
Tasks / microtasks
  ↓
Event loop
```

---

## 2. Variables

Modern:

```js
const value = 10;
let counter = 0;
```

Legacy:

```js
var oldValue = 10;
```

Prefer `const`; use `let` when reassignment is required.

---

## 3. Primitive types

Master:

```text
string
number
bigint
boolean
undefined
null
symbol
```

Plus objects.

---

## 4. BigInt for DeFi

Blockchain amounts often exceed safe integer precision.

```js
const amount = 1000000000000000000n;
```

Do not use floating-point `Number` for token accounting.

---

## 5. Operators

Learn:

```text
+
-
*
/
%
**
==
===
!=
!==
>
<
>=
<=
&&
||
??
?.
```

Prefer strict equality:

```js
value === other;
```

---

## 6. Type coercion

Understand:

```js
"10" + 5
"10" - 5
Boolean("")
Number("42")
String(42)
```

Learn why implicit coercion causes bugs.

---

## 7. Control flow

Master:

```js
if
else
switch
for
while
do...while
for...of
for...in
break
continue
```

---

## 8. Functions

Legacy:

```js
function add(a, b) {
  return a + b;
}
```

Modern:

```js
const add = (a, b) => a + b;
```

Also learn:
- parameters
- defaults
- rest
- spread
- return values
- closures
- callbacks

---

## 9. Scope

Master:

```text
global
module
function
block
```

Understand lexical scope.

---

## 10. Closures

```js
function createCounter() {
  let count = 0;

  return () => ++count;
}
```

Closures are fundamental to JavaScript.

---

## 11. Objects

```js
const wallet = {
  address: "0x...",
  connected: true
};
```

Learn:
- properties
- methods
- computed properties
- prototypes

---

## 12. Arrays

Master:

```js
map
filter
reduce
find
findIndex
some
every
includes
sort
slice
splice
push
pop
shift
unshift
```

Understand mutation vs immutable operations.

---

## 13. Destructuring

```js
const { address, chainId } = wallet;
const [first, second] = values;
```

---

## 14. Spread/rest

```js
const copy = { ...wallet };
const values = [ ...items ];
```

---

## 15. Optional chaining/nullish coalescing

```js
user?.wallet?.address
```

```js
value ?? fallback
```

---

## 16. Classes

Legacy/common OOP style:

```js
class WalletManager {
  connect() {}
}
```

Learn:
- constructor
- methods
- inheritance
- private fields
- static members

Also understand that JavaScript's underlying inheritance model is prototype-based.

---

## 17. Prototypes

Study:

```js
Object.getPrototypeOf(value);
Object.create(proto);
```

Understand the prototype chain even if you normally use classes.

---

## 18. Modules

Modern:

```js
export function connect() {}
```

```js
import { connect } from "./wallet.js";
```

Legacy:

```html
<script src="a.js"></script>
<script src="b.js"></script>
```

Pattern 2 is preferred for this project.

---

## 19. DOM

Master:

```js
querySelector
querySelectorAll
getElementById
createElement
append
remove
replaceChildren
classList
dataset
textContent
```

Avoid unnecessary `innerHTML` when inserting untrusted content.

---

## 20. Events

Learn:

```js
addEventListener
removeEventListener
```

Events:
- click
- submit
- input
- change
- focus
- blur
- keyboard
- pointer
- drag
- clipboard

---

## 21. Event delegation

Pattern 1:

Add listeners to every child.

Pattern 2:

```js
container.addEventListener("click", (event) => {
  const button = event.target.closest("button");
  if (!button) return;
});
```

Useful for dynamic lists.

---

## 22. Forms

Study:

```js
FormData
event.preventDefault()
checkValidity()
reportValidity()
```

Use native HTML validation before custom validation.

---

## 23. Fetch

```js
const response = await fetch("/api/data");
const data = await response.json();
```

Learn:
- HTTP
- headers
- status codes
- JSON
- POST
- PUT
- PATCH
- DELETE
- aborting requests

---

## 24. Async JavaScript

Master:

```js
Promise
async
await
try
catch
finally
```

Legacy:

```js
promise.then(...).catch(...);
```

Modern:

```js
try {
  await promise;
} catch {}
```

Know both.

---

## 25. Promise combinators

Learn:

```js
Promise.all()
Promise.allSettled()
Promise.race()
Promise.any()
```

StudyLend uses `Promise.all()` for independent reads.

---

## 26. AbortController

```js
const controller = new AbortController();

fetch(url, {
  signal: controller.signal
});

controller.abort();
```

Useful for cancelling stale requests.

---

## 27. Error handling

Learn:

```js
throw new Error("...");
try {}
catch {}
finally {}
```

Also understand:
- operational errors
- programming errors
- user rejection
- network errors
- contract reverts

---

## 28. Error types

Study:

```text
Error
TypeError
RangeError
SyntaxError
ReferenceError
URIError
```

---

## 29. JSON

```js
JSON.stringify(value);
JSON.parse(text);
```

Know JSON limitations.

---

## 30. Storage

Browser storage:

```js
localStorage
sessionStorage
```

IndexedDB for larger structured data.

Never store private keys in browser storage.

---

## 31. Cookies

Understand:
- cookies
- HttpOnly
- Secure
- SameSite

Know that cookies are different from localStorage.

---

## 32. Web Crypto

Study:

```js
crypto.getRandomValues(...)
crypto.subtle
```

Do not implement cryptography from scratch.

---

## 33. Dates and time

Legacy:

```js
new Date()
```

Learn:
- UTC
- time zones
- ISO 8601
- timestamps

Also study modern Temporal APIs as browser support evolves.

---

## 34. Internationalization

Master:

```js
Intl.NumberFormat
Intl.DateTimeFormat
Intl.RelativeTimeFormat
```

For DeFi:

```js
new Intl.NumberFormat("en", {
  maximumFractionDigits: 2
});
```

---

## 35. Regular expressions

Learn:

```js
/0x[a-fA-F0-9]{40}/
```

Use carefully; do not validate Ethereum addresses with simplistic regexes alone.

---

## 36. Iterators and generators

Study:

```js
function* generate() {
  yield 1;
  yield 2;
}
```

Learn iterables and `for...of`.

---

## 37. Map and Set

```js
const addresses = new Set();
const balances = new Map();
```

Often better than objects for keyed collections.

---

## 38. WeakMap / WeakSet

Advanced memory-sensitive structures.

---

## 39. Symbols

Study:

```js
Symbol("id")
```

And well-known symbols.

---

## 40. Proxies

Advanced:

```js
new Proxy(target, handler);
```

Useful for metaprogramming, but avoid unnecessary complexity.

---

## 41. Typed arrays

Study:

```text
Uint8Array
Uint16Array
Uint32Array
ArrayBuffer
DataView
```

Important when dealing with binary data.

---

## 42. Encoding

Learn:
- UTF-8
- hex
- base64
- ArrayBuffer
- TextEncoder
- TextDecoder

This becomes relevant when working with signed messages and raw blockchain data.

---

## 43. Web Workers

```js
new Worker("./worker.js");
```

Move CPU-heavy work away from the UI thread.

---

## 44. Service Workers

Learn:
- caching
- offline support
- PWA architecture
- background behavior

---

## 45. WebSockets

Study real-time communication.

DeFi use:
- block updates
- transaction events
- live prices

---

## 46. Server-Sent Events

Alternative to WebSockets for server → browser streams.

---

## 47. Browser APIs

Know the existence of:

```text
Clipboard API
Notifications API
Geolocation API
History API
URL API
IntersectionObserver
ResizeObserver
MutationObserver
BroadcastChannel
Web Workers
Service Workers
WebSocket
WebRTC
```

---

## 48. IntersectionObserver

Useful for:
- lazy loading
- infinite scrolling
- analytics
- animations

---

## 49. ResizeObserver

Useful for component-aware layout behavior.

---

## 50. URL and URLSearchParams

```js
const url = new URL(location.href);
url.searchParams.set("chain", "31337");
```

---

## 51. History API

Study:

```js
history.pushState()
history.replaceState()
popstate
```

Foundation for SPA routing.

---

## 52. Security

Master:

- XSS
- CSRF
- clickjacking
- CSP
- DOM injection
- dependency security
- phishing
- wallet security

Never inject untrusted content with:

```js
element.innerHTML = userInput;
```

without appropriate sanitization.

---

## 53. Web3 wallet concepts

Study:

```text
EOA
smart account
chain ID
RPC
provider
signer
transaction
signature
nonce
gas
receipt
logs
```

---

## 54. Ethereum provider

Study EIP-1193 concepts:

```js
window.ethereum.request({
  method: "eth_requestAccounts"
});
```

The project uses ethers on top of this provider.

---

## 55. ethers

Study:

```text
Provider
BrowserProvider
Signer
Contract
TransactionResponse
TransactionReceipt
Interface
parseUnits
formatUnits
```

---

## 56. ABI encoding

Understand that:

```js
contract.supply(amount)
```

eventually becomes encoded calldata.

Study:
- function selectors
- ABI encoding
- decoding
- event topics

---

## 57. Contract reads

```js
const total = await lending.totalSupplied();
```

Read operations do not require wallet signatures.

---

## 58. Contract writes

```js
const tx = await lending.supply(amount);
await tx.wait();
```

Learn:
- wallet prompt
- gas
- transaction hash
- pending state
- confirmation
- revert

---

## 59. Token approval

Understand:

```text
approve
allowance
transferFrom
```

Typical flow:

```text
approve(pool, amount)
        ↓
pool.supply(amount)
        ↓
token.transferFrom(user, pool, amount)
```

---

## 60. Events

Learn:

```js
contract.on("Supplied", handler);
```

Also learn how logs differ from normal return values.

---

## 61. Frontend state management

Start with plain variables.

Then study:

- reducer pattern
- finite-state machines
- signals
- reactive frameworks
- Redux-like stores
- Zustand-like stores

Frameworks are tools, not substitutes for understanding state.

---

## 62. React/Vue/Svelte awareness

Know the ecosystem:

- React
- Vue
- Svelte
- Angular
- Solid

But master JavaScript before relying on a framework.

---

## 63. TypeScript

Strongly recommended after JavaScript.

Study:
- types
- interfaces
- unions
- generics
- narrowing
- type-safe ABIs

Production DeFi frontends commonly benefit from TypeScript.

---

## 64. Testing

Study:

```text
unit tests
integration tests
DOM tests
browser tests
end-to-end tests
property tests
```

Tools to know:
- Vitest
- Jest
- Playwright
- Cypress

---

## 65. Build tools

Learn:

- npm
- package.json
- semver
- npm scripts
- Vite
- bundlers
- tree shaking
- code splitting
- source maps

---

## 66. Performance

Study:

- rendering
- layout thrashing
- batching DOM updates
- lazy loading
- code splitting
- memoization
- caching
- Web Workers

---

## 67. Debugging

Master DevTools:

- Console
- Sources
- Network
- Application
- Performance
- Memory
- Security
- Lighthouse

---

## 68. JavaScript expert StudyLend exercises

1. Refactor wallet code into modules.
2. Add transaction state machine.
3. Add event subscriptions.
4. Add cancellation.
5. Add local transaction history.
6. Add robust error decoding.
7. Add TypeScript.
8. Add unit tests.
9. Add Playwright tests.
10. Add WebSocket block updates.
11. Build a reusable contract client.
12. Build a state store without a framework.
