# HTML Expert Curriculum — Complete Reference for StudyLend

This curriculum is intentionally broader than the HTML used by the current UI.
The goal is to make you comfortable reading and building real HTML before
you depend on a framework.

---

# 1. HTML foundations

Learn:

- `<!doctype html>`
- `<html>`
- `<head>`
- `<body>`
- comments
- attributes
- nesting
- whitespace
- entities
- global attributes

Important global attributes:

```html
id=""
class=""
title=""
lang=""
hidden
tabindex=""
data-*
aria-*
```

### Pattern 1 — Legacy

```html
<div id="main">...</div>
```

### Pattern 2 — Semantic

```html
<main id="main">...</main>
```

Use an element whose meaning matches the content.

---

# 2. Document metadata

Study:

```html
<title>
<meta charset="utf-8">
<meta name="viewport">
<meta name="description">
<link rel="stylesheet">
<link rel="icon">
```

Also learn:

- canonical URLs
- robots metadata
- Open Graph basics
- theme color
- language declarations

Exercise:
Make StudyLend have a useful title and description when shared online.

---

# 3. Semantic page structure

Master:

```html
<header>
<nav>
<main>
<section>
<article>
<aside>
<footer>
```

Understand when `section` and `article` are appropriate.

### Pattern 1 — Generic containers

```html
<div class="header">...</div>
<div class="content">...</div>
```

### Pattern 2 — Semantic elements

```html
<header>...</header>
<main>...</main>
```

---

# 4. Headings and text

Learn:

```html
<h1> <h2> <h3> <h4> <h5> <h6>
<p>
<strong>
<em>
<mark>
<small>
<del>
<ins>
<sub>
<sup>
<abbr>
<cite>
<q>
<blockquote>
<code>
<pre>
<kbd>
<samp>
<var>
```

Do not choose headings because they "look bigger".
Heading levels communicate document structure.

---

# 5. Links

Learn:

```html
<a href="/dashboard">Dashboard</a>
<a href="#borrow">Borrow</a>
<a href="https://example.com">External</a>
<a href="mailto:hello@example.com">Email</a>
<a href="tel:+123456789">Call</a>
```

Understand:

- absolute vs relative URLs
- fragment links
- download links
- `target="_blank"`
- `rel="noopener noreferrer"`

---

# 6. Images

Master:

```html
<img
  src="./assets/protocol.png"
  alt="StudyLend dashboard"
  width="1200"
  height="800"
  loading="lazy"
>
```

Learn:

- `alt`
- intrinsic dimensions
- lazy loading
- responsive images
- decorative images

### Pattern 1 — Basic

```html
<img src="image.jpg" alt="Description">
```

### Pattern 2 — Responsive image

```html
<picture>
  <source media="(min-width: 900px)" srcset="desktop.webp">
  <source media="(min-width: 500px)" srcset="tablet.webp">
  <img src="mobile.webp" alt="Description">
</picture>
```

### Pattern 3 — Resolution-aware

```html
<img
  src="small.jpg"
  srcset="small.jpg 480w, large.jpg 1200w"
  sizes="(max-width: 700px) 100vw, 700px"
  alt="Description"
>
```

---

# 7. Audio

This was intentionally missing from the first version. It belongs in your
HTML curriculum.

Master:

```html
<audio controls>
  <source src="./assets/lesson.mp3" type="audio/mpeg">
  <source src="./assets/lesson.ogg" type="audio/ogg">
  Your browser does not support audio.
</audio>
```

Learn:

- `controls`
- `autoplay`
- `muted`
- `loop`
- `preload`
- `<source>`
- fallback content

### Pattern 1 — Legacy/simple

```html
<audio src="lesson.mp3" controls></audio>
```

### Pattern 2 — Multiple formats

```html
<audio controls>
  <source src="lesson.webm" type="audio/webm">
  <source src="lesson.mp3" type="audio/mpeg">
</audio>
```

### Pattern 3 — JavaScript API

```js
const audio = document.querySelector("audio");
audio.play();
audio.pause();
audio.currentTime = 30;
```

### Pattern 4 — Production

Provide transcripts and accessible controls. Do not assume autoplay will work.

---

# 8. Video

Master:

```html
<video controls width="800" poster="./assets/poster.jpg">
  <source src="./assets/lesson.mp4" type="video/mp4">
  <source src="./assets/lesson.webm" type="video/webm">
  Your browser does not support video.
</video>
```

Learn:

- `controls`
- `poster`
- `autoplay`
- `muted`
- `loop`
- `playsinline`
- `preload`
- multiple sources
- fallback content

---

# 9. Video captions and subtitles

For accessibility, study `<track>`:

```html
<video controls>
  <source src="lesson.mp4" type="video/mp4">

  <track
    kind="captions"
    src="captions-en.vtt"
    srclang="en"
    label="English"
    default
  >
</video>
```

Learn WebVTT (`.vtt`).

Also understand:

- captions vs subtitles
- transcript
- audio descriptions
- accessibility requirements

Exercise:
Create a five-minute DeFi lesson video with captions.

---

# 10. Embedded content

Master:

```html
<iframe
  src="https://example.com"
  title="Example content"
  loading="lazy"
  allowfullscreen
></iframe>
```

Also study:

```html
<embed>
<object>
```

Understand why untrusted embedded content needs careful sandboxing.

Example:

```html
<iframe
  src="..."
  sandbox
  title="Embedded content"
></iframe>
```

---

# 11. Lists

Master:

```html
<ul>
  <li>Supply</li>
  <li>Borrow</li>
</ul>
```

```html
<ol>
  <li>Connect wallet</li>
  <li>Approve token</li>
  <li>Supply</li>
</ol>
```

```html
<dl>
  <dt>TVL</dt>
  <dd>Total value locked.</dd>
</dl>
```

Know when each is semantically appropriate.

---

# 12. Tables

DeFi dashboards need tables.

Master:

```html
<table>
  <caption>Recent transactions</caption>
  <thead>
    <tr>
      <th scope="col">Action</th>
      <th scope="col">Amount</th>
      <th scope="col">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Supply</td>
      <td>100 STUDY</td>
      <td>Confirmed</td>
    </tr>
  </tbody>
</table>
```

Learn:

- `caption`
- `thead`
- `tbody`
- `tfoot`
- `tr`
- `th`
- `td`
- `scope`
- `colspan`
- `rowspan`

---

# 13. Forms

This is one of the most important HTML areas.

Master:

```html
<form>
<label>
<input>
<textarea>
<select>
<option>
<optgroup>
<button>
<fieldset>
<legend>
<datalist>
<output>
```

Input types:

```text
text
email
password
number
tel
url
search
date
time
datetime-local
month
week
color
file
checkbox
radio
range
hidden
submit
reset
button
```

Study:

```html
required
min
max
step
minlength
maxlength
pattern
autocomplete
inputmode
placeholder
readonly
disabled
```

### Pattern 1 — Basic

```html
<input type="text">
```

### Pattern 2 — Semantic type

```html
<input type="email" autocomplete="email">
```

### Pattern 3 — Native validation

```html
<input
  type="number"
  min="0"
  step="0.01"
  required
>
```

### Pattern 4 — Production

Use native validation first, then enhance it with JavaScript.
Never rely only on client-side validation for security.

---

# 14. Fieldsets and complex forms

Example:

```html
<fieldset>
  <legend>Borrow position</legend>

  <label>
    Collateral
    <input type="number" name="collateral">
  </label>

  <label>
    Debt
    <input type="number" name="debt">
  </label>
</fieldset>
```

Exercise:
Refactor StudyLend's borrow form using a fieldset and legend.

---

# 15. Buttons

Understand the difference:

```html
<button type="button">Open</button>
<button type="submit">Supply</button>
<button type="reset">Reset</button>
```

### Pattern 1 — Bad for actions

```html
<a href="#" onclick="supply()">Supply</a>
```

### Pattern 2 — Correct semantic control

```html
<button type="button" id="supplyButton">Supply</button>
```

Links navigate.
Buttons perform actions.

---

# 16. Dialogs

Modern HTML supports `<dialog>`.

```html
<dialog id="transactionDialog">
  <h2>Transaction submitted</h2>
  <p>Your transaction is waiting for confirmation.</p>
  <button type="button" onclick="this.closest('dialog').close()">
    Close
  </button>
</dialog>
```

JavaScript:

```js
transactionDialog.showModal();
transactionDialog.close();
```

Learn:
- modal vs non-modal
- focus behavior
- accessible close controls

---

# 17. Details and disclosure

Useful for educational interfaces:

```html
<details>
  <summary>Why do I need approval?</summary>
  <p>
    The token contract must allow StudyLend to transfer the tokens.
  </p>
</details>
```

Use this to put explanations directly beside difficult DeFi concepts.

---

# 18. Progress and meter

Learn:

```html
<progress value="65" max="100">65%</progress>
```

For a measured value within a known range:

```html
<meter min="0" max="100" value="65">65%</meter>
```

Potential DeFi use:
- utilization
- health factor visualization
- transaction progress

Do not confuse `<progress>` with `<meter>`.

---

# 19. Time and dates

Master:

```html
<time datetime="2026-09-01T11:00:00+01:00">
  September 1, 2026
</time>
```

Useful for:
- transaction timestamps
- block times
- protocol events
- historical data

---

# 20. Figures and captions

Use:

```html
<figure>
  <img src="architecture.png" alt="StudyLend architecture">
  <figcaption>Frontend-to-contract architecture.</figcaption>
</figure>
```

This is useful for diagrams and educational material.

---

# 21. SVG

SVG is part of the HTML ecosystem you should understand.

Inline:

```html
<svg
  viewBox="0 0 100 100"
  role="img"
  aria-labelledby="title"
>
  <title id="title">Simple circle</title>
  <circle cx="50" cy="50" r="40"></circle>
</svg>
```

Learn:
- viewBox
- paths
- circles
- rectangles
- groups
- accessibility

DeFi use:
- charts
- protocol diagrams
- icons
- health indicators

---

# 22. Canvas

Learn the `<canvas>` element:

```html
<canvas
  id="utilizationChart"
  width="800"
  height="400"
  aria-label="Utilization chart"
></canvas>
```

JavaScript can draw onto it.

Important:
Canvas itself does not automatically make a chart accessible.

For important information, provide an accessible textual/table representation.

---

# 23. Templates

Learn:

```html
<template id="activityTemplate">
  <article class="activity-item">
    <strong class="activity-action"></strong>
    <span class="activity-amount"></span>
  </article>
</template>
```

JavaScript:

```js
const template = document.querySelector("#activityTemplate");
const clone = template.content.cloneNode(true);
```

This is a good bridge between HTML and JavaScript.

---

# 24. Data attributes

Learn:

```html
<button
  data-action="supply"
  data-market="study"
>
  Supply
</button>
```

JavaScript:

```js
button.dataset.action;
button.dataset.market;
```

Use `data-*` for custom non-semantic data that belongs to an element.

---

# 25. Accessibility

Study:

- semantic HTML
- keyboard navigation
- focus
- labels
- heading hierarchy
- alternative text
- captions
- transcripts
- accessible names
- ARIA
- live regions
- reduced motion
- color contrast

### Pattern 1 — ARIA everywhere

Avoid adding ARIA when native HTML already provides the correct semantics.

### Pattern 2 — Native HTML first

```html
<button>Connect wallet</button>
```

is usually better than:

```html
<div role="button" tabindex="0">Connect wallet</div>
```

Learn the rule:

**No ARIA is better than incorrect ARIA.**

---

# 26. ARIA

Study:

```html
aria-label
aria-labelledby
aria-describedby
aria-live
aria-expanded
aria-controls
aria-current
aria-busy
aria-hidden
role
```

Use ARIA to communicate states that native HTML cannot adequately express.

---

# 27. Accessibility for wallet transactions

Study the transaction lifecycle:

```text
Idle
↓
Wallet confirmation requested
↓
Transaction submitted
↓
Waiting for confirmation
↓
Confirmed
```

Expose the state in HTML:

```html
<p id="transactionStatus" aria-live="polite">
  Ready
</p>
```

This allows assistive technology to receive important updates.

---

# 28. Internationalization

Learn:

```html
<html lang="en">
```

Also study:

```html
dir="ltr"
dir="rtl"
lang="fr"
lang="ar"
```

Understand:
- localization
- formatting
- translated content
- bidirectional text

---

# 29. Special characters and entities

Study:

```html
&amp;
&lt;
&gt;
&quot;
&nbsp;
```

Prefer UTF-8 and literal Unicode where appropriate.

---

# 30. `<script>`, loading and modules

### Pattern 1 — Legacy

```html
<script src="app.js"></script>
```

### Pattern 2 — Deferred

```html
<script src="app.js" defer></script>
```

### Pattern 3 — Module

```html
<script type="module" src="main.js"></script>
```

Understand:
- blocking scripts
- `defer`
- `async`
- modules
- import/export
- execution order

---

# 31. `<link>` and external resources

Study:

```html
<link rel="stylesheet" href="styles.css">
<link rel="icon" href="favicon.ico">
```

Then learn resource hints:

```html
preconnect
preload
prefetch
```

Use them intentionally rather than adding every possible hint.

---

# 32. Security-related HTML

Learn:

- safe external links
- iframe sandboxing
- CSP concepts
- form actions
- untrusted content
- file uploads
- `autocomplete`
- avoiding inline event handlers

Example:

```html
<a
  href="https://example.com"
  target="_blank"
  rel="noopener noreferrer"
>
  External site
</a>
```

---

# 33. SEO fundamentals

Learn:

- meaningful `<title>`
- meta description
- semantic headings
- canonical URL
- structured content
- descriptive links
- useful alt text

Do not try to "SEO" a DeFi app by stuffing keywords.

---

# 34. Performance

Study:

- image dimensions
- lazy loading
- responsive images
- script loading
- reducing DOM complexity
- caching
- preloading only critical resources

Learn why:

```html
<img width="1200" height="800">
```

helps the browser reserve layout space.

---

# 35. Web components

Advanced HTML:

```js
class WalletStatus extends HTMLElement {
  connectedCallback() {
    this.textContent = "Wallet connected";
  }
}

customElements.define("wallet-status", WalletStatus);
```

HTML:

```html
<wallet-status></wallet-status>
```

Study:
- custom elements
- shadow DOM
- templates
- slots

This is optional for the first StudyLend version but useful for becoming an HTML expert.

---

# 36. Progressive enhancement

Core principle:

```text
HTML works
    ↓
CSS improves it
    ↓
JavaScript enhances it
```

For StudyLend, JavaScript is necessary for blockchain transactions, but the
HTML should still communicate the interface and content clearly before JS runs.

---

# 37. HTML validation

Use an HTML validator during learning.

Look for:

- invalid nesting
- missing attributes
- duplicate IDs
- invalid ARIA
- malformed markup

Do not treat a framework's JSX compiler as your only HTML education.

---

# 38. Expert HTML project exercises

## Exercise A — Media lesson

Create a "Learn DeFi" page containing:

- video
- poster image
- captions
- transcript
- audio lesson
- downloadable transcript
- figure with architecture diagram

## Exercise B — Protocol dashboard

Create:

- navigation
- summary cards
- supply form
- borrow form
- repayment form
- withdrawal form
- transaction table
- utilization meter
- health factor progress
- accessible transaction status

## Exercise C — Advanced UI

Add:

- dialog for transaction details
- details/summary explanations
- template-based activity cards
- SVG protocol diagram
- canvas chart
- responsive images

## Exercise D — Accessibility audit

Test:

1. Keyboard only.
2. Screen reader.
3. Zoom.
4. 320px viewport.
5. High contrast.
6. Reduced motion.
7. Video with captions.
8. Audio with transcript.

---

# 39. HTML mastery checklist

Before calling yourself comfortable with HTML, you should be able to explain:

- semantic HTML
- forms and native validation
- tables
- lists
- links
- images
- `<picture>`
- responsive images
- audio
- video
- `<track>`
- captions
- transcripts
- iframe
- dialog
- details/summary
- progress
- meter
- time
- figure
- SVG
- canvas
- templates
- data attributes
- accessibility
- ARIA
- metadata
- scripts/modules
- performance
- security basics
- SEO basics
- internationalization
- progressive enhancement
- web components

The goal is not to memorize every element.

The goal is to know **which semantic tool solves which problem**, and then
know where to look up exact syntax.
