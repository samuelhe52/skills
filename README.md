# Agent skills

A collection of skills for coding agents. Each directory under `skills/` is an independently installable skill.

## Install

Install one skill with [`npx skills`](https://www.npmjs.com/package/skills), replacing `<skill-name>` with a name from the list below:

```sh
npx skills add samuelhe52/agent-skills --skill <skill-name>
```

## Skills

- `experiment-infra-design`: Design or review experiment infrastructure, including failure handling, recovery, observability, and evidence retention.
- `paper-summarization`: Turn a paper or long report into a section-by-section reading guide and an analytical synthesis.
- `paper-walkthrough-slides`: Turn a paper into an HTML slide deck (English, Chinese, or both) that walks through its argument with the paper's figures, rendered math, and charts, ending in a summary and critique.
- `remote-gpu-experiments`: Inspect remote GPU hosts, run and monitor workloads, and retrieve results over SSH or a scheduler.
- `test-value-audit`: Assess tests' defect-detection value, maintenance cost, redundancy, and meaningful coverage gaps.

## License

[MIT](LICENSE)
