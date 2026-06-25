---
description: AI 代码评审流程 — 按语言分派，从安全、规范、质量三个维度审查代码
---

# /code-review 工作流

当用户使用 `/code-review` 命令或明确提出“审查/review 代码”时，严格按以下步骤执行。

## 步骤 1：识别语言与审查范围
- 根据用户指定范围、变更文件、扩展名和项目结构判断语言：Java / Go / Rust / Python / Shell
- 若审查范围跨语言，按语言分别加载对应 Skill
- 若审查范围或业务背景不明确，先追问

## 步骤 2：加载对应需求澄清协议

| 语言 | 需求澄清 Skill | 代码评审 Skill |
|------|----------------|----------------|
| Java | `.agents/skills/requirement-clarify-java/SKILL.md` | `.agents/skills/code-review-java/SKILL.md` |
| Go | `.agents/skills/requirement-clarify-go/SKILL.md` | `.agents/skills/code-review-go/SKILL.md` |
| Rust | `.agents/skills/requirement-clarify-rust/SKILL.md` | `.agents/skills/code-review-rust/SKILL.md` |
| Python | `.agents/skills/requirement-clarify-python/SKILL.md` | `.agents/skills/code-review-python/SKILL.md` |
| Shell | `.agents/skills/requirement-clarify-shell/SKILL.md` | `.agents/skills/code-review-shell/SKILL.md` |

按照对应 Skill 的必问项确认审查范围、业务背景、运行环境和重点关注方向。

## 步骤 3：读取审查基线
- 读取项目根目录 `AGENTS.md`
- 按语言读取对应 `rules/` 规范
- 涉及安全、鉴权、密钥、日志、命令执行、路径或 TLS 时，必须叠加对应安全规则

## 步骤 4：系统审查
按对应代码评审 Skill 执行，重点检查：
- 安全风险
- 架构分层和职责边界
- 错误处理、并发、资源释放和超时
- API 契约、配置兼容性和数据迁移影响
- 测试缺口和验证不足

## 步骤 5：输出审查报告
发现问题时，按严重程度排序并标注：
- 阻断：必须修复后才能合入
- 警告：建议修复或补充验证
- 建议：可后续优化

若未发现明确问题，必须写明“未发现明确问题”，并补充残余风险或测试缺口。

## 步骤 6：协助修复
只有用户明确要求修复时，才按严重程度从高到低修改代码。修复后重新执行审查。

## 使用示例
```text
/code-review 审查最近一次提交
/code-review 审查这个 Go worker 的并发处理
/code-review 审查 deploy.sh 的路径和删除保护
```
