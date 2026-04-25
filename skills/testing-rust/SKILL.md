---
name: testing-rust
description: Rust 测试生成流程。用于为 Rust 模块、函数、Handler、Service 或 CLI 设计并实现单元测试、集成测试和异步测试。
---

# Rust 测试生成 SOP

> 当用户提出“给这个 Rust 模块写测试”、“补 cargo test 用例”等请求时使用。

## 前置：需求澄清

> 必须先执行 `requirement-clarify-rust`，至少确认 `TR-01` ~ `TR-02`。

## 步骤 1：分析被测目标
- 明确模块、函数、handler、command 的核心职责
- 找出正常路径、错误路径、边界条件和并发/超时场景
- 判断依赖是 mock、fake 还是隔离环境更合适

## 步骤 2：先输出测试设计

```markdown
## 测试用例设计
- 目标文件 / 模块：
- 测试类型：单元 / 集成 / HTTP / CLI / 异步
- 关键场景：
- 依赖隔离策略：
- 运行命令：
```

## 步骤 3：编写测试
- 单元测试优先与源码同模块
- 集成测试放在 `tests/`
- 异步测试使用 `#[tokio::test]` 或项目既有运行时方案
- 覆盖正常路径、错误路径、边界条件和并发/取消场景
- 外部依赖优先 mock、fake 或隔离环境

## 步骤 4：输出交付结果

```markdown
## 测试完成摘要
- 测试文件：
- 覆盖目标：
- Mock / Fake 依赖：
- 运行命令：
- 未覆盖场景：
```

### 步骤 5：任务交付文档
在 `docs/delivery/` 下生成：`docs/delivery/{YYYY-MM-DD-HH-mm-ss}-test-rust-{模块简称}.md`
