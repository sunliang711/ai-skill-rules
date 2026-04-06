---
name: code-review-rust
description: Rust 代码评审流程。用于审查 Rust 服务、库和脚本的安全性、分层规范、异步并发、错误处理和测试质量。
---

# Rust 代码评审 SOP

> 当用户提出“review Rust 代码”、“帮我审一下这个 Rust PR”等请求时使用。

## 前置：需求澄清

> 必须先执行 `requirement-clarify-rust`，至少确认 `RR-01` ~ `RR-02`。

## 步骤 1：准备审查
- 确认审查范围和业务背景
- 若用户给的是目录或 PR，先列出待审文件

## 步骤 2：按三维度系统审查

> 审查基线为 `rules/07-rust-backend.mdc` 与 `rules/08-rust-security.mdc`；如涉及 HTTP API，再叠加 `rules/09-rust-api-design.mdc`。

### 维度一：安全
- 凭据是否硬编码
- 日志或错误是否泄露敏感信息
- SQL、命令、路径、外部 URL 是否存在注入风险
- 鉴权、权限控制、TLS 是否存在绕过或关闭风险

### 维度二：规范
- 模块分层是否清晰
- Handler / Service / Repository 职责是否混淆
- DTO 与持久化模型是否分离
- 命名、配置、日志和错误建模是否一致

### 维度三：质量
- 是否误用 `unwrap()` / `expect()` 处理可恢复错误
- async、锁、共享状态和后台任务是否存在竞态或泄漏风险
- 超时、资源释放、分页、事务边界是否合理
- 关键路径是否有测试覆盖

## 步骤 3：输出报告

```markdown
## Rust 代码评审报告
- 审查文件：
- 发现的问题：
- 严重等级：阻断 / 警告 / 建议
- 总体评价：
```

### 步骤 4：若无问题
明确写出“未发现明确问题”，并补充残余风险或测试缺口。

### 步骤 5：任务交付文档
在 `docs/` 下生成：`docs/{YYYY-MM-DD}-review-rust-{模块简称}.md`
