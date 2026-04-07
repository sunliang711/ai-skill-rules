---
name: api-doc-go
description: Go API 文档生成流程。用于为 Go HTTP 接口输出完整接口定义、鉴权说明、错误码、示例请求响应与 curl 用法。
---

# Go API 文档 SOP

> 当用户提出“生成 Go API 文档”、“整理接口说明”、“补 curl 示例”、“给 Gin 接口出文档”等请求时使用。

## 前置：需求澄清

> 必须先执行 `requirement-clarify-go`，至少确认 `AG-01` ~ `AG-03`。

## 步骤 1：确认文档范围
- 涉及哪些 Handler、Router、模块或服务
- 文档给谁使用：前端、第三方调用方、测试联调还是内部服务
- 输出目标是 Markdown、Swagger / OpenAPI 注释补全，还是两者都要

重点扫描：
- `handler/`、`router/`、`transport/http/`
- Request / Response DTO
- 鉴权中间件、限流 / 超时 / traceID 相关代码
- 错误码定义、统一响应封装、Recovery / 错误转换逻辑
- 现有 Swagger / OpenAPI 注释、README、联调文档

## 步骤 2：提取接口契约

### 2.1 入口与语义
- HTTP 方法、路径、版本号、资源语义
- 接口用途、是否公开、是否幂等

### 2.2 请求信息
- Path / Query / Header / Cookie / JSON Body 字段
- 类型、是否必填、默认值、范围、枚举、分页约束
- 鉴权 Header、签名、traceID、幂等键

### 2.3 响应信息
- 成功响应结构
- 失败响应结构
- HTTP 状态码、业务码、错误消息
- 分页字段、追踪字段、脱敏字段

### 2.4 示例信息
- `curl` 调用示例
- 请求体示例
- 成功响应示例
- 常见错误示例

## 步骤 3：生成 API 文档

````markdown
# API 文档

## 基本信息
- 服务 / 模块：
- 文档范围：
- 目标读者：
- Base URL：

## 鉴权与通用约定
- 鉴权方式：
- 必需 Header：
- 分页 / 排序约定：
- traceID / 幂等 / 限流说明：

## 接口清单
| 方法 | 路径 | 功能 | 鉴权 |
|------|------|------|------|

## 接口详情

### 1. [接口名称]
- **方法**:
- **路径**:
- **用途**:
- **鉴权要求**:

#### 请求参数
| 位置 | 字段 | 类型 | 必填 | 说明 |
|------|------|------|:---:|------|

#### 请求体示例
```json
{}
```

#### curl 示例
```bash
curl -X GET 'https://example.com/api/v1/xxx?page_num=1&page_size=20' \
  -H 'Authorization: Bearer <token>' \
  -H 'X-Trace-ID: <trace-id>'
```

#### 成功响应示例
```json
{
  "code": 200,
  "data": {},
  "message": "success"
}
```

#### 错误码
| HTTP 状态码 | 业务码 | 说明 |
|-------------|--------|------|

## 备注
- [兼容性、限流、超时、重试、联调注意事项]
````

## 步骤 4：同步现有文档机制
- 若项目已有 Swagger / OpenAPI 注释方案，同步补齐注释
- 若项目已有自动生成文档入口，确保新增说明与代码一致
- 若用户要求 spec 文件，优先基于现有方案生成或补齐，不手写脱离实现的定义

## 步骤 5：交叉验证
- 路由、方法、鉴权要求与 Router / Handler 实现一致
- DTO 的 `json`、`binding`、`validate` 语义已反映到文档
- 错误码与统一错误转换逻辑一致
- `curl` 示例中的 URL、Header、Body 可直接用于联调
- 示例数据已脱敏，未暴露真实凭据和敏感标识

## 步骤 6：任务交付文档
在 `docs/api/` 下生成：`docs/api/{YYYY-MM-DD}-api-doc-go-{模块简称}.md`

建议包含：
- 文档范围
- 提取来源
- API 文档正文
- 与 Swagger / OpenAPI 的同步情况
- 风险与待确认项
