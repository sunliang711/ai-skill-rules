---
description: AI 辅助测试生成 — 按语言分派，设计并实现单元测试、集成测试或脚本验证
---

# /testing 工作流

当用户使用 `/testing` 命令或明确提出“写测试/补测试/验证脚本”时，严格按以下步骤执行。

## 步骤 1：识别语言与测试目标
- 根据目标文件、模块、测试框架和用户描述判断语言：Java / Go / Rust / Python / Shell
- 明确测试类型：单元测试、集成测试、接口测试、脚本检查或手工验证
- 若目标范围或测试类型不清楚，先追问

## 步骤 2：加载对应需求澄清协议

| 语言 | 需求澄清 Skill | 测试 Skill |
|------|----------------|------------|
| Java | `.agents/skills/requirement-clarify-java/SKILL.md` | `.agents/skills/testing-java/SKILL.md` |
| Go | `.agents/skills/requirement-clarify-go/SKILL.md` | `.agents/skills/testing-go/SKILL.md` |
| Rust | `.agents/skills/requirement-clarify-rust/SKILL.md` | `.agents/skills/testing-rust/SKILL.md` |
| Python | `.agents/skills/requirement-clarify-python/SKILL.md` | `.agents/skills/testing-python/SKILL.md` |
| Shell | `.agents/skills/requirement-clarify-shell/SKILL.md` | `.agents/skills/testing-shell/SKILL.md` |

按照对应 Skill 的必问项确认测试范围、测试类型、关键分支和外部依赖隔离方式。

## 步骤 3：设计测试用例
按对应测试 Skill 输出测试设计，至少覆盖：
- 正常路径
- 错误路径
- 边界条件
- 权限、超时、并发、资源释放或危险操作保护
- 外部依赖 mock / fake / 隔离策略

测试设计需要用户确认时，先等待确认再写测试代码。

## 步骤 4：编写测试或验证脚本
- 读取项目根目录 `AGENTS.md` 以及相关语言规则
- 沿用项目已有测试框架、目录结构和命名风格
- 禁止为测试引入不必要的新框架或依赖
- 测试数据不得包含真实密钥、Token、手机号、邮箱或生产连接串

## 步骤 5：运行验证
优先使用项目现有命令，例如：
- Java：`mvn test`、`./gradlew test`
- Go：`go test ./...`
- Rust：`cargo test`
- Python：`pytest`
- Shell：`shellcheck`、`bats`

若不能运行测试，必须说明原因，并给出可执行的手工验证步骤。

## 步骤 6：交付
输出：
- 新增或修改的测试文件
- 覆盖的场景
- 执行的验证命令与结果
- 未覆盖的风险或后续建议

## 使用示例
```text
/testing 给 BitcoinService 写单元测试
/testing 给 TransactionController 的所有接口写集成测试
/testing 给这个 Shell 脚本补 shellcheck 和 dry-run 验证
```
