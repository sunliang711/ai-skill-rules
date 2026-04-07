---
description: API 文档生成流程 — 输出完整接口定义、鉴权说明、错误码、示例请求响应与 curl 用法
---

# /api-doc 工作流

当用户使用 `/api-doc` 命令或明确提出“生成 API 文档”时，严格按以下步骤执行：

## 步骤 1：识别语言与范围
- 判断任务属于 Java、Go、Python 还是 Rust
- 确认需要输出文档的服务、模块、接口分组或路由范围

## 步骤 2：执行对应的需求澄清协议
- Java：读取 `skills/requirement-clarify-java/SKILL.md`
- Go：读取 `skills/requirement-clarify-go/SKILL.md`
- Python：读取 `skills/requirement-clarify-python/SKILL.md`
- Rust：读取 `skills/requirement-clarify-rust/SKILL.md`

至少确认以下三类信息：
- 文档范围
- 输出形态（Markdown / OpenAPI / 两者）
- 鉴权方式与调用前提

## 步骤 3：执行对应的 API 文档 Skill
- Java：读取 `skills/api-doc-java/SKILL.md`
- Go：读取 `skills/api-doc-go/SKILL.md`
- Python：读取 `skills/api-doc-python/SKILL.md`
- Rust：读取 `skills/api-doc-rust/SKILL.md`

按 Skill 要求：
- 提取接口定义
- 整理鉴权说明
- 输出参数 / 响应 / 错误码
- 补 `curl`、请求示例、响应示例
- 与现有 Swagger / OpenAPI 机制交叉验证

## 步骤 4：交付文档
- 输出最终 API 文档
- 如用户要求落盘，写入 `docs/api/` 目录
- 明确说明哪些内容来自现有代码，哪些示例为脱敏示例值

## 使用示例
```text
/api-doc 给这个 Spring Boot 模块生成完整接口文档，带 curl 示例
/api-doc 整理这个 Gin 服务的接口说明和错误码表
/api-doc 给这个 FastAPI 路由补联调用文档
```
