---
name: dev-review-python
description: Python 开发并评审的组合流程。用于在完成 Python 功能开发或 Bug 修复后，自动衔接代码评审并合并交付结果。
---

# Python 开发并评审 SOP

## 适用场景

- 先开发 Python 功能再 review
- 先修 Python Bug 再 review

## 执行流程

1. 若任务是新功能，先执行 `feature-dev-python`
2. 若任务是缺陷修复，先执行 `bug-fix-python`
3. 开发完成后，自动执行 `code-review-python`
4. 合并输出开发结果、审查结论、风险与后续建议

## 交付要求

- 先给出实现与验证摘要
- 再给出 review 发现的问题或“未发现明确问题”
- 如 review 发现阻断问题，必须明确标注不可直接合并
