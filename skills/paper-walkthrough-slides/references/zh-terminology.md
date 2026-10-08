# Chinese decks: terminology

Chinese ML researchers write in a mix: Chinese for ordinary words and for terms with a settled translation, and English for terms whose translations are unsettled or sound stilted. A deck that translates everything ("同策略", "信赖域", "残差流") reads like machine translation and makes readers map each term back to the English they know. A deck that keeps too much English reads as untranslated.

**Rule:** keep a term in English when it has no single, universally used Chinese translation and researchers normally say it in English. Use Chinese when the translation is standard and natural. All prose, headings, explanations, and critique are in Chinese.

## Usually English

The user approved this precedent; extend it by the same rule to whatever field the paper is in.

- **Method and model names, benchmarks, datasets, and task names:** Transformer, ViT, DiT, GRPO, ImageNet, MMLU, Tool Use, and so on. Keep the paper's names rather than translating them.
- **Learning setups:** on-policy, off-policy, offline/online, in-context learning (ICL), RLHF, SFT, RAG, self-supervised, contrastive, distillation (蒸馏 is also standard), scaling law, inverse RL.
- **Architecture:** backbone, encoder/decoder, attention head, residual stream, MoE, router, tokenizer, embedding, latent, adapter, LoRA, KV cache.
- **Training:** prompt, rollout, batch size, learning rate, epoch, warmup, checkpoint, seed, EMA, FLOPs, wall-clock, token, logit.
- **Math and optimization:** forward/reverse KL, trust region, policy gradient, advantage, estimator, importance sampling, score function, Pareto front.
- **Evaluation:** OOD, pass@k, top-1, FID, BLEU, oracle, upper bound, LLM judge.

## Usually Chinese

预训练, 微调, 全参数微调, 强化学习, 扩散模型, 注意力 (as a general concept), 损失函数, 梯度, 采样, 推理, 泛化, 灾难性遗忘, 持续学习, 教师/学生, 奖励, 策略, 准确率, 归一化, 正则化, 数据集, 基座模型, 上下文, 假设.

Some terms are fine either way (ablation / 消融, baseline / 基线); pick one and use it consistently within a deck.

## Typography

- Put a space between Chinese characters and an adjacent English word or number, including across `<b>` and `<i>` tags: "on-policy 训练", "约 2.5 倍", "蒸馏是 <b>on-policy</b> 的".
- Use full-width punctuation (，。：；（）“”) in Chinese sentences and half-width punctuation inside English phrases and math.
- Keep quoted prompts, paper titles, and author names in their original language.

## Examples

| Too Chinese | Right | Too English |
|---|---|---|
| 同策略蒸馏 | on-policy 蒸馏 | on-policy distillation |
| 每题一次采样轨迹 | 每题一次 rollout | one rollout per prompt |
| 混合专家路由器 | MoE router | — |
| 检查点 | checkpoint | checkpoint |
| 灾难性遗忘 | 灾难性遗忘 | catastrophic forgetting |
| 在 ImageNet 上预训练 | 在 ImageNet 上预训练 | 在 ImageNet 上 pretrain |
