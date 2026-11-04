---
name: paper-walkthrough-slides
description: "Turn a research paper into an HTML slide deck that walks through its argument — motivation, method, theory, experiments, ablations, limitations — using the paper's key figures, rendered math, and charts of its numbers, and closes with a summary and critique. Produces English, Chinese, or both, plus a PDF on request. Use this whenever the user wants slides, a deck, a talk, or a group-meeting presentation about a paper or arXiv link (e.g. 'read this paper and give me an html slide', '把这篇论文做成slides', 'make a Chinese version of the paper slides'), even if they don't say 'walkthrough'. Requires the html-slides skill. Not for slides about the user's own results (use html-slides) or for Markdown paper summaries."
---

# Paper walkthrough slides

Build an HTML deck that lets someone who hasn't read the paper follow its argument and judge its evidence in a 15–30 minute talk. It works for any ML paper: an architecture paper, a training method, a theory paper, a benchmark, a systems paper. Let the paper's own logic decide which slides it needs.

The audience is researchers, so faithfulness comes first. Every number and figure comes from the paper. Anything you add — a derivation step the paper skips, an interpretation, a criticism — is visibly marked as yours. The closing summary and critique is where your judgment goes, kept apart from the walkthrough.

## Requires html-slides

This skill decides what the deck says. The `html-slides` skill provides the template, components, and render check. Load it before writing the deck. If it isn't installed, stop and tell the user to run `npx skills add samuelhe52/skills --skill html-slides`.

## Inputs

- **Paper:** an arXiv ID or URL, a local PDF, or a paper already in the conversation.
- **Language:** English, Chinese, or both. Default to the language the user writes in. For Chinese, follow the terminology guide in `html-slides`.
- **Location:** the user's path or the project's convention (for example an existing `docs/slides/`). Otherwise `slides/paper-<slug>.html`, with `-zh` added for Chinese, and the extracted figures in `slides/paper-<slug>-figs/`.
- **Focus:** if the user cares about a particular question (why the method works, how it scales, how it compares with something they use), give it dedicated slides.

## Workflow

### 1. Read the paper and collect its figures

Put downloads in a fresh directory, since they are untrusted. Extract the text with `pdftotext -layout` and read all of it, including the appendix. Implementation details, hyperparameters, and the ablations that justify design choices usually live there.

For figures, try the arXiv source first: `https://arxiv.org/e-print/<id>` is usually a tarball containing the original figure files. Convert PDF figures to PNG with `pdftoppm -png -r 200 -singlefile`. If there is no source, render the page with `pdftoppm -r 200 -f N -l N` and crop the figure region with `-x -y -W -H`. Check the crop by viewing it.

If an official code repository is at hand, skim its README. Errata posted there sometimes contradict the PDF, and those discrepancies belong in the deck.

### 2. Plan the slides

A typical empirical paper maps to the sequence below. Adapt it: a theory paper spends more slides on definitions and proof ideas, a benchmark paper on construction and validity, a systems paper on design and measurements.

1. **Title:** title, authors, venue or arXiv version and date, code link, a one-sentence claim, and 2–3 headline numbers.
2. **Problem and motivation:** what is hard, what prior approaches miss, and what is new here.
3. **Method overview:** usually built around the paper's main diagram.
4. **Method details:** objectives and update rules in LaTeX, algorithm pseudocode, and verbatim prompts or templates if the method depends on them.
5. **Design choices:** each one paired with the ablation that justifies it.
6. **Theory or analysis, if any:** the derivation as numbered steps, the assumptions, and what they require. When the paper argues that something works for some reason, lay out the argument as a chain and tag each link as math, assumption, or empirical, so readers can see which parts are actually proven.
7. **Setup:** data, models, baselines, metrics, and protocol (compute, tuning, seeds).
8. **Main results:** the headline comparison.
9. **Further findings:** one slide per distinct result (scaling, transfer, qualitative behavior, failure cases).
10. **Ablations:** what drives the gains, plus a one-table summary.
11. **Limitations:** as the authors state them, with costs and future work.
12. **Summary and critique:** see below.

**Summary and critique** (use two slides if needed):
- **Summary:** the contribution in 2–3 sentences, and the 3–5 findings worth remembering, each with its number.
- **Convincing:** claims with strong support, and what makes that support strong.
- **Thin:** specific claim–evidence gaps, each tied to a section or figure. Common ones:
  - the theory assumes something other than what was run
  - one dataset, model family, or scale
  - baselines not compute- or tuning-matched
  - test-set model selection
  - missing seeds or confidence intervals
  - LLM-judge grading
  - effects within noise
- **Open questions:** what you would test next.
- **Relevance:** if the conversation shows what the user works on, what the paper implies for that work.

### 3. Write the deck

Start from the `html-slides` template and follow that skill's rules for structure, components, math, and charts. Take the title and closing slides from `assets/paper-slides.html`.

- **Headlines state the finding** ("Linear attention matches softmax up to 1.3B parameters", not "Results"). The subtitle gives the context needed to read the slide. Each footer cites its source (section, table, figure, equation) and the slide number.
- **Figures from the paper:** include them when they carry information a chart or bullet can't — architecture and pipeline diagrams, qualitative samples, curves whose shape is the result, and any figure the paper's argument hinges on. Show each at a readable size and caption it "Figure N in the paper", plus a sentence on what to look at. When a result is tabulated, a native bar chart or table is usually clearer than a screenshot. When a result exists only as a plot, show the plot rather than estimating values from it.
- **Charts:** the paper's method gets the highlight, and a black tick marks a reference value such as the base model.
- **Mark your additions and the discrepancies** (`.warn`) where readers would otherwise take them as the paper's own content.
- **Large tables:** when highlighting cells by a rule (for example drops of more than 5 points), compute which cells qualify with a short script.
- **Both languages:** finish and check one deck, translate it with the same structure, then compare the numbers across the two files with a script.

### 4. Render and check

Run the render check from `html-slides` and fix what it finds, as that skill describes. Copy the PDF next to the HTML when the user wants one.

### 5. Hand off

Give the file paths, a one-line-per-slide outline, the check results, and anything the presenter should know: flagged discrepancies, numbers that exist only in plots, and your own additions.
