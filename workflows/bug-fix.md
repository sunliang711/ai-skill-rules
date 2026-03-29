---
description: Bug 修复标准流程 — 从问题定位到修复验证的全链路 SOP
---

# /bug-fix 工作流

当用户使用 `/bug-fix` 命令时，严格按以下步骤执行：

## 步骤 1：信息收集
使用 `view_file` 工具读取 `.agents/skills/requirement-clarify-java/SKILL.md`，按照「bug-fix 专属问题清单」执行信息收集。

**在所有 🔴 必问项（B-01 ~ B-03：问题现象、复现条件、期望行为）都已确认之前，禁止进入下一步。**

## 步骤 2：问题定位
使用 `view_file` 工具读取 `.agents/skills/bug-fix-java/SKILL.md`，按照阶段一执行：
- 阅读相关代码，追踪调用链
- 区分问题类型（逻辑/数据/配置/并发/依赖）
- 输出定位分析报告
- **等待用户确认分析结论后再进入修复阶段**

## 步骤 3：修复实施
使用 `view_file` 工具读取项目根目录 `AGENTS.md` 中的安全规范章节（第四章：安全红线），确保修复代码符合所有 🔴 强制规则。

按照 `bug-fix-java` Skill 阶段二执行：
- 只修改与 Bug 直接相关的代码，严禁"顺手"重构
- 必要时进行防御性加固

## 步骤 4：编译验证
// turbo
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && mvn compile -q 2>&1 | tail -10 && echo "BUILD_OK"
```
- 编译失败 → 修复后重新编译

## 步骤 5：自检与交付
按照 `bug-fix-java` Skill 阶段三执行：
- 自检清单逐项检查
- 输出修复摘要 + ChangeLog

## 步骤 6：提交代码
- 查看变更文件
// turbo
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && git status --short && git diff --stat
```
- 提交（需要用户确认 commit message）
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && git add -A && git commit -m "fix: <问题描述>"
```

## 使用示例
```
/bug-fix 转账接口偶发超时，日志中有 Connection reset 异常
/bug-fix 区块扫描在高度 850000 之后停止推进
```
