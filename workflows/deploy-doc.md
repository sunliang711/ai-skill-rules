---
description: 部署文档自动生成 — 按语言分派，提取配置、环境变量、迁移、依赖和发布步骤
---

# /deploy-doc 工作流

当用户使用 `/deploy-doc` 命令或明确提出“生成部署文档/发布清单”时，严格按以下步骤执行。

## 步骤 1：识别语言与部署范围
- 根据变更文件、服务类型、构建配置和用户描述判断语言：Java / Go / Rust / Python / Shell
- 明确涉及服务、模块、任务、脚本、配置和目标环境
- 若变更范围或目标环境不明确，先追问

## 步骤 2：加载对应需求澄清协议

| 语言 | 需求澄清 Skill | 部署文档 Skill |
|------|----------------|----------------|
| Java | `.agents/skills/requirement-clarify-java/SKILL.md` | `.agents/skills/deploy-doc-java/SKILL.md` |
| Go | `.agents/skills/requirement-clarify-go/SKILL.md` | `.agents/skills/deploy-doc-go/SKILL.md` |
| Rust | `.agents/skills/requirement-clarify-rust/SKILL.md` | `.agents/skills/deploy-doc-rust/SKILL.md` |
| Python | `.agents/skills/requirement-clarify-python/SKILL.md` | `.agents/skills/deploy-doc-python/SKILL.md` |
| Shell | `.agents/skills/requirement-clarify-shell/SKILL.md` | `.agents/skills/deploy-doc-shell/SKILL.md` |

按照对应 Skill 的必问项确认变更范围、涉及服务、目标环境和发布方式。

## 步骤 3：提取部署信息
按对应部署文档 Skill 执行，至少检查：
- 环境变量和配置项
- 数据库迁移、回滚脚本和执行顺序
- 依赖版本、构建产物和启动命令
- 中间件、队列、缓存、定时任务或系统服务
- 权限、证书、密钥、网络和文件路径
- 发布顺序、验证步骤和回滚方案

## 步骤 4：交叉验证
- 与代码、配置、Dockerfile、CI、README、已有部署文档交叉核对
- 文档中的命令、路径、配置名和服务名必须来自现有项目或用户明确输入
- 不得编造不存在的环境变量、脚本或发布步骤

## 步骤 5：交付文档
输出最终部署说明。如用户要求落盘，写入 `docs/deploy/` 目录。

## 使用示例
```text
/deploy-doc 基于最近一次 commit 的改动生成部署清单
/deploy-doc 本次 Go 服务新增 Redis 缓存和两个环境变量，帮我生成部署文档
/deploy-doc 整理这个 Shell 定时任务的发布和回滚步骤
```
