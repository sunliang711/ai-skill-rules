---
description: AI 代码评审流程 — 从安全、规范、质量三个维度系统性审查代码
---

# /code-review 工作流

当用户使用 `/code-review` 命令时，严格按以下步骤执行：

## 步骤 1：确认审查范围
使用 `view_file` 工具读取 `.agents/skills/requirement-clarify/SKILL.md`，按照「code-review 专属问题清单」确认审查范围和背景。

**在所有 🔴 必问项（R-01 ~ R-02：审查范围、代码业务背景）都已确认之前，禁止进入下一步。**

## 步骤 2：读取安全规范
// turbo
使用 `view_file` 工具读取项目根目录 `AGENTS.md` 中的安全规范章节（第四章：安全红线），将其作为审查基线。

## 步骤 3：系统审查
使用 `view_file` 工具读取 `.agents/skills/code-review/SKILL.md`，按照三维度审查流程逐项检查：
- 🔴 安全审查（优先级最高）
- 🟡 规范审查
- 🟢 质量审查

## 步骤 4：输出审查报告
按照 `code-review` Skill 的报告模板输出结果。

## 步骤 5：协助修复（可选）
如果用户要求协助修复：
- 按严重等级从高到低依次修复
- 修复完成后重新输出审查报告

## 使用示例
```
/code-review 审查 EthereumManager.java 的最近改动
/code-review 审查 cold-service-online 模块的 Controller 层
```
