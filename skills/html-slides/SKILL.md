---
name: html-slides
description: "Build, edit, render-check, or export to PDF a 16:9 HTML slide deck from a bundled template with math, charts, tables, figures, light and dark themes, zoom-safe navigation, and in-browser highlights and notes. Use whenever the user wants HTML slides, a browser deck, or a talk or group-meeting presentation on any topic, including when they ask for slides and name no file format (e.g. 'make slides for my results', '做一份组会slides'). Provides the deck frame and tools; what the deck says comes from the user or the calling skill. Not for .pptx or .potx files, which the pptx skill handles."
---

# HTML slides

This skill provides a slide frame, components, and a render check. It has no opinion on what a deck should say: the content, structure, and tone come from the user or from a skill that builds on this one.

## Start a deck

Copy `assets/template.html` to the deck's path, then replace the example slides. Keep the CSS and scripts. The examples show the components and are not a suggested slide order.

Use the user's path or the project's convention. Otherwise write `slides/<slug>.html`, add `-zh` for Chinese, and put images in `slides/<slug>-figs/`.

Set `<title>`, and set `lang="zh-CN"` on `<html>` for Chinese decks, which also switches the highlight and note UI to Chinese. When writing in Chinese, follow `references/zh-terminology.md`.

## Slide structure

```html
<div class="page"><div class="slide">
  <header><h1>Headline</h1><p>Subtitle</p></header>
  <div class="body c2"> … </div>
  <footer><span>Footer text</span><span>2</span></footer>
</div></div>
```

- Every slide needs all three rows: `header`, `.body`, and `footer`. Slide numbers are written by hand, so renumber after adding or removing a slide.
- For a title slide, use `class="page title"` as in the template.
- Layout classes for `.body`: `.c2`, `.c3`, `.c21` (wide left), `.c12` (wide right). With none, it is a single column. Use `.stack` to pile blocks inside a column.

## Components

Each one appears in the template; copy the markup from there.

| Component | Markup |
|---|---|
| Panel | `<section>` with an `<h2>` |
| Stat tiles | `.key` holding `.kpi`, each with `.v` and `.l`; three per row |
| Display equation | `<div class="eq">$$...$$<span class="lbl">(1)</span></div>` |
| Figure | `<figure class="fig">` with `<img>` and `<figcaption>`, in a `<section style="display:flex;flex-direction:column">` |
| Bar chart | `.chart` holding `.bar` rows, then `.legend` |
| Table | `<table>`; rows `.ours` (highlight) and `.basel` (muted); cells `.bad` (red); `th.grp` for column groups; `.cap` for the caption |
| Pseudocode | `.algo`, one `<div>` per numbered line; `.in1` and `.in2` indent; `.cm` for comments |
| Two-box flow | `.flow` holding `.role`, `.arrow`, `.role`; `.role.t` is green, `.role.s` is red |
| Verbatim text | `.prompt`; `<i>` marks placeholders |
| Chain of steps | `.chain` holding `.step` and `.op`, sized for three steps; tags `.tagm.math`, `.tagm.assume`, `.tagm.emp` |
| List markers | `<li class="ok">`, `no`, `q` |
| Text styles | `.mute`, `.warn` |

## Colors

The template has light and dark themes, set through CSS variables on `html`. In any custom markup, use the variables instead of fixed colors, or it will break in dark mode: `--ink`, `--mute`, `--line`, `--paper` (slide), `--bg` (panel), `--card` (box inside a panel), `--blue`, `--red`, `--green`, `--amber`, `--hl`, `--neutral`, `--track`. Inline SVG can use them too, for example `style="fill:var(--ink)"`.

Images keep a white background in both themes. Printed slides and PDFs are always light.

## Math

Write `$...$` for inline math and `$$...$$` inside `.eq` for display math. Write `\lt` and `\gt` rather than raw angle brackets, which HTML parsing would eat.

## Charts

Add `.hl` to the bar for the deck's subject; other bars stay neutral gray. Label every value, and state the axis range in `.legend`. A `.ref` tick marks a reference value.

Compute widths from the values, with a short script when there are many:

- **Plain bars:** `.fill` width and `.ref` left are the value's percentage of the axis range.
- **Diverging bars:** a negative bar's width is `|value| / axis max`, as a percentage of its half of the track. A positive bar's width is half that, because it is a percentage of the whole track.

## Render and check

```bash
bash <skill-dir>/scripts/render_check.sh path/to/deck.html [out-dir]
```

The script reports rendered formulas and KaTeX errors, prints the PDF (and warns if the page count differs from the slide count, which usually means a slide overflowed), rasterizes the pages, and writes 2×2 contact sheets. It exits nonzero on KaTeX errors.

Look at every sheet, and at formula- or figure-heavy slides at higher resolution. Fix overflow, collisions, and unreadable figures, and rerun until it's clean.

It needs Chrome or Chromium, poppler, and Pillow for the contact sheets. The PDF lands in the output directory; copy it next to the HTML when the user wants one.

KaTeX loads from a CDN, so the HTML needs network access to show math. The PDF embeds fonts and figures and works offline.

## Presenting

The deck shows one slide at a time, and the URL keeps the slide number (`#5`), so a reload stays put and a link can open a given slide.

- **Move between slides:** arrow keys, PageUp and PageDown, space, Home and End, the mouse wheel or a trackpad scroll, or a swipe on a touch screen.
- **Zoom:** pinch to zoom, then pan with a scroll. The view stays on the current slide, and the wheel turns slides again after zooming back out. Browser zoom (⌘+) doesn't enlarge a slide, because slides always fit the window.
- **Theme:** press D or use the button at the top right. It follows the system until a choice is made, and the choice is remembered across decks.
- **Highlights and notes:** selecting text offers both. They are saved in the presenter's browser, per file name, and survive reloads.
