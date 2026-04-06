---
name: code-review-python
description: Python 代码评审流程。用于审查 Python 服务、任务和脚本的安全性、分层规范、资源管理、错误处理和测试质量。
---

# Python 代码评审 SOP

> 当用户提出“review Python 代码”、“帮我审一下这个 Python PR”等请求时使用。

## 前置：需求澄清

> 必须先执行 `requirement-clarify-python`，至少确认 `RP-01` ~ `RP-02`。

## 步骤 1：准备审查
- 确认范围和业务背景
- 若用户给的是目录或 PR，先列出待审文件

## 步骤 2：按三维度系统审查

> 审查基线为 `rules/10-python-backend.mdc` 与 `rules/11-python-security.mdc`；如涉及 HTTP API，再叠加 `rules/12-python-api-design.mdc`。

### 维度一：安全
- 凭据、Token、连接串是否硬编码
- 日志和错误是否泄露敏感信息
- SQL、shell、路径、URL 是否存在注入风险
- 鉴权、权限、TLS、DEBUG 模式是否存在安全缺口

### 维度二：规范
- 分层是否清晰
- ORM Model、Schema、DTO 是否混用
- 类型注解、命名、配置读取方式是否一致
- 入口层是否承载业务逻辑

### 维度三：质量
- 异常是否被吞掉或返回不正确
- 会话、文件、连接、任务和线程是否正确释放
- 分页、事务、重试、超时、N+1 风险是否合理
- 关键路径和错误路径是否有测试

## 步骤 3：输出报告

```markdown
## Python 代码评审报告
- 审查文件：
- 发现的问题：
- 严重等级：阻断 / 警告 / 建议
- 总体评价：
```

### 步骤 4：若无问题
明确写出“未发现明确问题”，并补充残余风险或测试缺口。

### 步骤 5：任务交付文档
在 `docs/` 下生成：`docs/{YYYY-MM-DD}-review-python-{模块简称}.md`
