---
description: AI 辅助测试生成 — 根据业务代码系统性生成单元测试和集成测试
---

# /testing 工作流

当用户使用 `/testing` 命令时，严格按以下步骤执行：

## 步骤 1：确认测试范围
使用 `view_file` 工具读取 `.agents/skills/requirement-clarify-java/SKILL.md`，按照「testing 专属问题清单」确认测试范围和类型。

**在所有 🔴 必问项（T-01 ~ T-02：测试范围、测试类型）都已确认之前，禁止进入下一步。**

## 步骤 2：设计测试用例
使用 `view_file` 工具读取 `.agents/skills/testing-java/SKILL.md`，按照步骤 1~2 分析目标代码并输出测试用例设计表。

**等待用户确认测试用例后再编写代码。**

## 步骤 3：编写测试代码
使用 `view_file` 工具读取项目根目录 `AGENTS.md` 中的安全规范章节（第四章：安全红线），确保测试代码也符合安全规范（禁止硬编码凭据、日志脱敏等）。

按照 `testing-java` Skill 步骤 3 的规范编写测试代码。

## 步骤 4：运行测试
// turbo
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && mvn test -pl <module> 2>&1 | tail -30
```
- 测试失败 → 修复后重新运行
- 全部通过 → 继续下一步

## 步骤 5：输出交付
按照 `testing-java` Skill 步骤 4 输出测试完成摘要。

## 使用示例
```
/testing 给 BitcoinService 写单元测试
/testing 给 TransactionController 的所有接口写集成测试
```
