---
name: dev-review-shell
description: Shell 开发并评审的组合流程。用于在完成 Shell 脚本开发或 Bug 修复后，自动衔接代码评审并合并交付结果。
---

# Shell 开发并评审 SOP

## 适用场景

- 先开发 Shell 脚本再 review
- 先修 Shell 脚本问题再 review

## 执行流程

1. 若任务是新脚本或功能，先执行 `feature-dev-shell`
2. 若任务是缺陷修复，先执行 `bug-fix-shell`
3. 开发完成后，自动执行 `code-review-shell`
4. 合并输出实现结果、审查结论、风险与后续建议

> 若脚本会产生写入副作用，必须在脚本内部添加写前前置检查逻辑，并在 review 中检查该逻辑。

## 交付要求

- 先给出实现与验证摘要
- 再给出 review 发现的问题或“未发现明确问题”
- 如 review 发现阻断问题，必须明确标注不可直接合并
