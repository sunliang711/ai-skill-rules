---
description: 标准功能开发流程 — 按语言分派，从需求澄清到验证交付
---

# /feature-dev 工作流

当用户使用 `/feature-dev` 命令或明确提出“开发/实现功能”时，严格按以下步骤执行。

## 步骤 1：识别语言与入口
- 根据用户描述、目标文件扩展名、项目结构和框架配置判断语言：Java / Go / Rust / Python / Shell
- 若用户已明确指定语言，以用户指定为准
- 若无法判断语言或影响范围，先追问，不得默认按 Java 处理

## 步骤 2：加载对应需求澄清协议

| 语言 | 需求澄清 Skill | 功能开发 Skill |
|------|----------------|----------------|
| Java | `.agents/skills/requirement-clarify-java/SKILL.md` | `.agents/skills/feature-dev-java/SKILL.md` |
| Go | `.agents/skills/requirement-clarify-go/SKILL.md` | `.agents/skills/feature-dev-go/SKILL.md` |
| Rust | `.agents/skills/requirement-clarify-rust/SKILL.md` | `.agents/skills/feature-dev-rust/SKILL.md` |
| Python | `.agents/skills/requirement-clarify-python/SKILL.md` | `.agents/skills/feature-dev-python/SKILL.md` |
| Shell | `.agents/skills/requirement-clarify-shell/SKILL.md` | `.agents/skills/feature-dev-shell/SKILL.md` |

按照对应 Skill 的必问项完成信息充分度检查。必问项未确认前，禁止进入编码阶段。

## 步骤 3：输出实现方案
按对应功能开发 Skill 的方案模板输出：
- 目标与边界
- 影响范围与文件清单
- 入口 / 接口 / 命令设计
- 数据、配置、依赖变更
- 安全、并发、事务、资源释放等风险
- 验证方式

必须等待用户明确确认后再编码。

## 步骤 4：编码实现
- 读取项目根目录 `AGENTS.md` 以及相关语言规则
- 按对应语言 Skill 的实现顺序进行最小变更
- 禁止引入与本功能无关的重构、依赖升级或风格化改动

## 步骤 5：验证
优先从项目现有文档、构建文件和 CI 配置中识别验证命令，例如：
- Java：`mvn test`、`mvn compile`、`./gradlew test`
- Go：`go test ./...`
- Rust：`cargo test`、`cargo clippy`
- Python：`pytest`、`ruff`、`mypy`
- Shell：`shellcheck`、`bats`

若项目没有明确验证命令，说明推断依据，并选择最小可行验证；仍无法判断时向用户确认。

## 步骤 6：交付
输出：
- 变更摘要
- 验证结果
- 配置、数据库、依赖、部署影响
- 残余风险与后续建议

只有用户明确要求提交代码时，才执行 `git add` / `git commit`。

## 使用示例
```text
/feature-dev 新增一个根据交易哈希查询交易详情的接口
/feature-dev 给这个 Go 服务实现批量导入任务
/feature-dev 给这个 Shell 脚本增加 dry-run 参数
```
