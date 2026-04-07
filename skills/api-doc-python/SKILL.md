---
name: api-doc-python
description: Python API 文档生成流程。用于为 Python HTTP 接口输出完整接口定义、鉴权说明、错误码、示例请求响应与 curl 用法。
---

# Python API 文档 SOP

> 当用户提出“生成 Python API 文档”、“整理 FastAPI 接口说明”、“补 curl 示例”等请求时使用。

## 前置：需求澄清

> 必须先执行 `requirement-clarify-python`，至少确认 `AP-01` ~ `AP-03`。

## 步骤 1：确认文档范围
- 涉及哪些 Router、View、API 模块或服务
- 文档面向对象和联调场景是什么
- 输出 Markdown、OpenAPI 说明，还是同时维护两者

重点扫描：
- `api/`、`routers/`、`views/`
- Pydantic Schema / DTO
- 鉴权依赖、异常处理、错误码定义
- 现有 OpenAPI / Swagger、README、对接文档

## 步骤 2：提取接口契约
- 方法、路径、版本号、用途
- Path / Query / Header / Body 参数及校验规则
- 成功响应、错误响应、业务码与 HTTP 状态码
- 鉴权、分页、排序、幂等、超时、限流要求
- `curl` 示例、请求示例、响应示例

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
- 幂等 / 限流 / 超时说明：

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
curl -X POST 'https://example.com/api/v1/xxx' \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

#### 成功响应示例
```json
{}
```

#### 错误码
| HTTP 状态码 | 业务码 | 说明 |
|-------------|--------|------|
````

## 步骤 4：同步现有文档机制
- 若项目已启用 FastAPI / OpenAPI，确保代码声明与输出文档一致
- 若已有独立文档目录，沿用既有命名和组织方式
- 若仅要求 Markdown 文档，也要说明对应的 OpenAPI 来源或缺失点

## 步骤 5：交叉验证
- 路由、方法、Schema 字段与代码一致
- 鉴权依赖、错误处理、响应模型与实现一致
- `curl` 示例可映射到真实请求
- 示例值已脱敏，无敏感 Token、手机号、邮箱或内部地址

## 步骤 6：任务交付文档
在 `docs/api/` 下生成：`docs/api/{YYYY-MM-DD}-api-doc-python-{模块简称}.md`
