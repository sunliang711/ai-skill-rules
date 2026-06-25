---
description: Bug 修复标准流程 — 按语言分派，从问题定位到验证交付
---

# /bug-fix 工作流

当用户使用 `/bug-fix` 命令或明确提出“修复/排查问题”时，严格按以下步骤执行。

## 步骤 1：识别语言与问题范围
- 根据报错、文件路径、服务模块、扩展名和项目结构判断语言：Java / Go / Rust / Python / Shell
- 若用户已明确指定语言，以用户指定为准
- 若问题跨语言，先列出影响边界，再选择主修复 Skill
- 若无法判断复现条件或期望行为，先追问，不得直接猜测修改

## 步骤 2：加载对应需求澄清协议

| 语言 | 需求澄清 Skill | Bug 修复 Skill |
|------|----------------|----------------|
| Java | `.agents/skills/requirement-clarify-java/SKILL.md` | `.agents/skills/bug-fix-java/SKILL.md` |
| Go | `.agents/skills/requirement-clarify-go/SKILL.md` | `.agents/skills/bug-fix-go/SKILL.md` |
| Rust | `.agents/skills/requirement-clarify-rust/SKILL.md` | `.agents/skills/bug-fix-rust/SKILL.md` |
| Python | `.agents/skills/requirement-clarify-python/SKILL.md` | `.agents/skills/bug-fix-python/SKILL.md` |
| Shell | `.agents/skills/requirement-clarify-shell/SKILL.md` | `.agents/skills/bug-fix-shell/SKILL.md` |

按照对应 Skill 的必问项确认问题现象、复现条件和期望行为。必问项未确认前，禁止修改代码。

## 步骤 3：定位根因
按对应 Bug 修复 Skill 的定位流程执行：
- 阅读相关代码和调用链
- 区分逻辑、数据、配置、并发、依赖、权限或环境问题
- 输出根因分析和最小修复方案

根因不明确时，先补充观测或复现步骤，不得扩大修改范围。

## 步骤 4：修复实施
- 读取项目根目录 `AGENTS.md` 以及相关语言规则
- 只修改与 Bug 直接相关的代码、配置或脚本
- 涉及接口契约、配置语义或数据结构时，同步排查调用方和文档影响
- 禁止借修复机会做无关重构

## 步骤 5：验证
优先复现原问题并验证已消除，再运行项目现有检查，例如：
- Java：`mvn test`、`mvn compile`、`./gradlew test`
- Go：`go test ./...`
- Rust：`cargo test`、`cargo clippy`
- Python：`pytest`、`ruff`、`mypy`
- Shell：`shellcheck`、`bats`

若无法完整复现，必须说明原因，并给出替代验证或手工验证步骤。

## 步骤 6：交付
输出：
- 问题现象
- 根因分析
- 修复内容
- 验证结果
- 残余风险

只有用户明确要求提交代码时，才执行 `git add` / `git commit`。

## 使用示例
```text
/bug-fix 转账接口偶发超时，日志中有 Connection reset 异常
/bug-fix 这个 Go worker 退出后 goroutine 没有释放
/bug-fix Shell 脚本路径带空格时执行失败
```
