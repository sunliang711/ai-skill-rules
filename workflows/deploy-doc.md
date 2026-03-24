---
description: 部署文档自动生成 — 扫描代码变更自动提取配置项、环境变量、数据库变更等
---

# /deploy-doc 工作流

当用户使用 `/deploy-doc` 命令时，严格按以下步骤执行：

## 步骤 1：读取需求澄清协议
使用 `view_file` 工具读取 `.agents/skills/requirement-clarify/SKILL.md`，按照「deploy-doc 专属问题清单」确认变更范围和涉及服务。

**在所有 🔴 必问项（D-01 ~ D-02：变更范围、涉及服务）都已确认之前，禁止进入下一步。**

## 步骤 2：读取部署文档生成 SOP
使用 `view_file` 工具读取 `.agents/skills/deploy-doc/SKILL.md`，严格按照其中定义的步骤逐步执行：
- 步骤 1：确定变更范围
- 步骤 2：逐项提取变更信息
- 步骤 3：生成部署文档
- 步骤 4：交叉验证

## 使用示例
```
/deploy-doc 本次改动新增了 Redis 缓存和两个环境变量，帮我生成部署文档
/deploy-doc 基于最近一次 commit 的改动生成部署清单
```
