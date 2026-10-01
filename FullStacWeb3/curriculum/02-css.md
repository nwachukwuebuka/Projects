# CSS EXPERT CURRICULUM — COMPLETE MAP

This file is intentionally larger than the CSS required by StudyLend.
Topics that are not implemented in the current interface are documented as
commented learning patterns.

The rule for this project:

**Pattern 1 — Legacy**
**Pattern 2 — Modern/recommended**
**Pattern 3 — Alternative**
**Pattern 4 — Production consideration**

---

## 1. CSS syntax and comments

```css
/* comment */
.selector {
  property: value;
}
```

Learn:
- selectors
- declarations
- properties
- values
- comments
- whitespace
- CSS parsing

---

## 2. Selectors

Master:

```css
*
element
.class
#id
[attr]
[attr="value"]
A B
A > B
A + B
A ~ B
```

Pseudo-classes:

```css
:hover
:focus
:focus-visible
:active
:visited
:checked
:disabled
:enabled
:required
:valid
:invalid
:first-child
:last-child
:nth-child()
:not()
:is()
:where()
:has()
```

Pseudo-elements:

```css
::before
::after
::first-letter
::first-line
::selection
::marker
::placeholder
```

### Pattern 1 — ID-heavy legacy

```css
#supplyButton {
  color: white;
}
```

### Pattern 2 — Component class

```css
.button-primary {
  color: white;
}
```

### Pattern 3 — Attribute/state selector

```css
button[aria-busy="true"] {
  cursor: wait;
}
```

### Pattern 4 — Production

Prefer predictable, low-specificity selectors that do not become difficult
to override.

---

## 3. Cascade

Understand:

1. origin
2. importance
3. layers
4. specificity
5. source order

Study:

```css
@layer reset, base, components, utilities;
```

### Pattern 1

Fight specificity with more specificity.

### Pattern 2

Design selectors with low specificity.

### Pattern 3

Use cascade layers.

### Pattern 4

Establish an architecture before the stylesheet becomes large.

---

## 4. Inheritance

Know which properties inherit.

Example:

```css
body {
  color: var(--text);
}
```

Child text can inherit the color.

Learn:

```css
inherit
initial
unset
revert
revert-layer
```

---

## 5. Box model

Master:

```text
content
padding
border
margin
```

Study:

```css
box-sizing: border-box;
```

Pattern 1:

```css
box-sizing: content-box;
```

Pattern 2:

```css
*, *::before, *::after {
  box-sizing: border-box;
}
```

---

## 6. Width and height

Learn:

```css
width
height
min-width
max-width
min-height
max-height
```

Modern sizing:

```css
width: min(100% - 2rem, 1180px);
```

Also study:

```css
min()
max()
clamp()
```

---

## 7. Units

Master:

```text
px
%
em
rem
ch
ex
vw
vh
vmin
vmax
dvh
svh
lvh
fr
deg
s
ms
```

Modern viewport units:

```css
min-height: 100dvh;
```

---

## 8. Colors

Learn:

```css
color
background-color
opacity
```

Color models:

```text
hex
rgb()
rgba()
hsl()
hsla()
hwb()
lab()
lch()
oklab()
oklch()
```

Study alpha transparency.

---

## 9. Custom properties

```css
:root {
  --accent: #7c9cff;
}

.button {
  background: var(--accent);
}
```

Learn:

```css
var()
```

and fallbacks:

```css
color: var(--unknown, black);
```

---

## 10. Typography

Master:

```css
font-family
font-size
font-weight
font-style
font-stretch
line-height
letter-spacing
word-spacing
text-align
text-indent
text-transform
text-decoration
text-overflow
white-space
word-break
overflow-wrap
```

Advanced:

```css
font-variation-settings
font-feature-settings
font-kerning
```

Study web fonts and `@font-face`.

---

## 11. Web fonts

```css
@font-face {
  font-family: "StudySans";
  src: url("./fonts/study-sans.woff2") format("woff2");
  font-display: swap;
}
```

Learn:

- WOFF/WOFF2
- font loading
- fallback stacks
- variable fonts
- `font-display`

---

## 12. Backgrounds

Master:

```css
background
background-color
background-image
background-size
background-position
background-repeat
background-attachment
```

Gradients:

```css
linear-gradient()
radial-gradient()
conic-gradient()
```

---

## 13. Borders

Learn:

```css
border
border-width
border-style
border-color
border-radius
outline
outline-offset
```

Important distinction:

**outline does not occupy normal layout space.**

---

## 14. Shadows

Study:

```css
box-shadow
text-shadow
```

Know when shadows harm readability.

---

## 15. Overflow

Master:

```css
overflow
overflow-x
overflow-y
overflow-wrap
```

Modern:

```css
overflow: clip;
```

---

## 16. Display

Master:

```css
block
inline
inline-block
none
flex
grid
table
contents
flow-root
```

Understand:

```css
display: contents;
```

and its accessibility caveats.

---

## 17. Normal flow

Before Flexbox/Grid, understand normal document flow.

Learn:
- block formatting
- inline formatting
- margins
- containing blocks

---

## 18. Positioning

Master:

```css
static
relative
absolute
fixed
sticky
```

Example:

```css
.site-header {
  position: sticky;
  top: 0;
}
```

Learn:
- containing blocks
- stacking contexts
- `z-index`

---

## 19. Flexbox

Master:

```css
display: flex;
flex-direction
flex-wrap
flex-flow
justify-content
align-items
align-content
gap
flex-grow
flex-shrink
flex-basis
order
align-self
```

Pattern 1:

```css
float: left;
```

Pattern 2:

```css
display: flex;
```

Pattern 3:

```css
display: grid;
```

Choose the layout system based on the problem.

---

## 20. CSS Grid

Master:

```css
display: grid;
grid-template-columns
grid-template-rows
grid-template-areas
grid-column
grid-row
gap
place-items
place-content
```

Responsive:

```css
grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
```

---

## 21. Subgrid

Advanced:

```css
grid-template-columns: subgrid;
```

Learn when nested components need to align to a parent grid.

---

## 22. Multi-column layout

Study:

```css
column-count
column-width
column-gap
column-rule
column-span
```

Useful for article-like educational content.

---

## 23. Tables in CSS

Learn:

```css
border-collapse
border-spacing
table-layout
caption-side
empty-cells
```

---

## 24. Lists

Study:

```css
list-style
list-style-type
list-style-position
list-style-image
```

Advanced:

```css
::marker
```

---

## 25. Forms

Style:

```css
input
select
textarea
button
fieldset
legend
```

States:

```css
:focus
:focus-visible
:valid
:invalid
:required
:disabled
:checked
```

Do not remove focus indicators without replacing them.

---

## 26. Responsive design

Learn:

```css
@media
```

Examples:

```css
@media (max-width: 820px) {
  ...
}
```

Also study:

- mobile-first design
- desktop-first design
- responsive typography
- responsive images
- touch targets

---

## 27. Container queries

Advanced modern CSS:

```css
.card-wrapper {
  container-type: inline-size;
}

@container (min-width: 500px) {
  .card {
    grid-template-columns: 1fr 1fr;
  }
}
```

This lets components respond to their container rather than viewport.

---

## 28. Logical properties

Instead of:

```css
margin-left
padding-right
```

learn:

```css
margin-inline-start
padding-inline-end
```

Also:

```css
block-size
inline-size
inset-inline
inset-block
```

Useful for internationalization and RTL layouts.

---

## 29. Aspect ratio

```css
video {
  aspect-ratio: 16 / 9;
}
```

---

## 30. Object fitting

For images/video:

```css
object-fit: cover;
object-position: center;
```

---

## 31. Transforms

Master:

```css
transform
translate()
scale()
rotate()
skew()
```

3D:

```css
translate3d()
rotateX()
rotateY()
perspective()
```

---

## 32. Transitions

```css
transition
transition-property
transition-duration
transition-delay
transition-timing-function
```

Example:

```css
.button {
  transition: transform .2s ease;
}
```

---

## 33. Animations

Master:

```css
@keyframes
animation-name
animation-duration
animation-delay
animation-iteration-count
animation-direction
animation-fill-mode
animation-play-state
animation-timing-function
```

---

## 34. Reduced motion

Accessibility:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms;
    animation-iteration-count: 1;
    scroll-behavior: auto;
    transition-duration: 0.01ms;
  }
}
```

---

## 35. Media preferences

Study:

```css
prefers-color-scheme
prefers-reduced-motion
prefers-contrast
forced-colors
```

---

## 36. Dark/light themes

```css
:root {
  color-scheme: dark;
}

[data-theme="light"] {
  ...
}
```

Also study:

```css
@media (prefers-color-scheme: dark) { ... }
```

---

## 37. CSS nesting

Modern:

```css
.card {
  padding: 1rem;

  & h2 {
    margin: 0;
  }

  &:hover {
    transform: translateY(-2px);
  }
}
```

Learn browser support and when nesting improves readability.

---

## 38. CSS layers

```css
@layer reset, base, components, utilities;
```

Useful for controlling cascade architecture.

---

## 39. `@supports`

Progressive enhancement:

```css
@supports (container-type: inline-size) {
  ...
}
```

---

## 40. Feature queries and fallbacks

Pattern:

```css
/* fallback */
display: flex;

/* enhancement */
@supports (display: grid) {
  display: grid;
}
```

---

## 41. `calc()`

```css
width: calc(100% - 2rem);
```

Combine units.

---

## 42. `clamp()`

Excellent for responsive typography:

```css
font-size: clamp(2rem, 6vw, 5rem);
```

---

## 43. `min()` and `max()`

```css
width: min(100%, 1200px);
padding: max(1rem, 3vw);
```

---

## 44. `color-mix()`

Advanced color manipulation:

```css
color: color-mix(in srgb, var(--accent) 80%, white);
```

---

## 45. CSS math

Study:

```css
calc()
min()
max()
clamp()
round()
mod()
rem()
sin()
cos()
tan()
```

Some advanced math features have varying browser support; check compatibility.

---

## 46. Masks and clipping

Advanced visual CSS:

```css
clip-path
mask
mask-image
```

---

## 47. Filters

```css
filter
backdrop-filter
```

Use carefully because effects can be expensive.

---

## 48. Blend modes

Study:

```css
mix-blend-mode
background-blend-mode
```

---

## 49. Generated content

```css
.card::before {
  content: "";
}
```

Do not put essential information only inside generated content.

---

## 50. Counters

```css
counter-reset
counter-increment
content: counter(section);
```

Useful for documentation-style pages.

---

## 51. Scroll behavior

Study:

```css
scroll-behavior
scroll-margin
scroll-padding
overscroll-behavior
scroll-snap-type
scroll-snap-align
```

---

## 52. Anchor positioning

Advanced modern CSS topic:

```css
anchor-name
position-anchor
position-area
```

Use only after understanding normal positioning.

---

## 53. View transitions

Study the View Transition API and its CSS pseudo-elements.

This is useful for polished app navigation but should remain progressive enhancement.

---

## 54. Accessibility

Learn:

- focus visibility
- contrast
- reduced motion
- readable line length
- target sizes
- forced colors
- zoom
- text resizing
- not conveying meaning through color alone

---

## 55. Architecture

Study:

### Pattern 1 — One giant stylesheet

Easy at first, difficult later.

### Pattern 2 — Component CSS

```text
base.css
layout.css
components.css
pages.css
```

### Pattern 3 — CSS Modules

Component-scoped classes.

### Pattern 4 — Design system

Tokens → primitives → components → compositions.

---

## 56. Naming systems

Learn:

- BEM
- utility classes
- component naming
- design tokens
- semantic naming

Example BEM:

```text
card
card__title
card--featured
```

---

## 57. CSS frameworks

Know what exists even if this project does not use them:

- Bootstrap
- Tailwind CSS
- Bulma
- Foundation
- CSS Modules
- styled-components
- Emotion

Learn the underlying CSS first.

---

## 58. CSS preprocessing

Study:

- Sass/SCSS
- Less
- PostCSS

Know why modern native CSS has reduced the need for some preprocessor features.

---

## 59. Performance

Learn:

- selector complexity
- CSS size
- unused CSS
- render blocking
- layout
- paint
- compositing
- animation performance

Prefer transform/opacity for many animations.

---

## 60. Debugging

Use browser DevTools:

- Elements
- Styles
- Computed
- Layout
- Flexbox inspector
- Grid inspector
- responsive mode
- accessibility tree
- performance tools

---

## 61. CSS expert StudyLend exercises

1. Rebuild the dashboard using Grid.
2. Rebuild it using Flexbox.
3. Compare both.
4. Add a light theme.
5. Add reduced-motion support.
6. Add container queries.
7. Add a responsive transaction table.
8. Add skeleton loading states.
9. Add accessible focus states.
10. Build a design-token system.
11. Recreate the interface using BEM.
12. Recreate it with utility classes.
13. Measure CSS performance.
14. Create a reusable DeFi component library.
