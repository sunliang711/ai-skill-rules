# AI Rules, Skills, and Workflows

本仓库用于维护团队的 AI 协作规范体系，包括规则文件、技能 SOP、工作流定义与配套说明文档。

它的目标不是存放业务代码，而是沉淀一套可复用的 AI 开发方法，让 Cursor 或其他 AI 编码助手在不同项目里保持一致的行为方式、审查标准与交付流程。

---

## 仓库内容

### 1. Rules

`rules/` 目录存放通用规则与语言/场景专项规范：

| 文件 | 作用 |
|------|------|
| [`rules/00-global.mdc`](rules/00-global.mdc) | 全局沟通、最小变更原则、工作流程基线 |
| [`rules/01-java-backend.mdc`](rules/01-java-backend.mdc) | Java 后端分层架构、命名、编码质量规范 |
| [`rules/02-java-security.mdc`](rules/02-java-security.mdc) | Java/Spring 安全红线：密钥、认证、日志、注入、传输与依赖安全 |
| [`rules/03-java-api-design.mdc`](rules/03-java-api-design.mdc) | Java/Spring API 统一响应、参数校验、HTTP 语义、异常处理 |
| [`rules/04-go-backend.mdc`](rules/04-go-backend.mdc) | Go 后端项目结构、Fx、Viper、Zerolog、GORM 等规范 |
| [`rules/05-go-security.mdc`](rules/05-go-security.mdc) | Go 安全红线：密钥、鉴权、日志、注入、传输与依赖安全 |
| [`rules/06-go-api-design.mdc`](rules/06-go-api-design.mdc) | Go API 统一响应、参数校验、HTTP 语义、错误处理与接口文档 |

### 2. Skills

`skills/` 目录存放可被 AI 按需调用的 SOP：

| Skill | 作用 |
|------|------|
| [`skills/requirement-clarify-java/SKILL.md`](skills/requirement-clarify-java/SKILL.md) | Java 需求澄清协议，作为 Java 流程的前置环节 |
| [`skills/feature-dev-java/SKILL.md`](skills/feature-dev-java/SKILL.md) | Java 功能开发流程 |
| [`skills/bug-fix-java/SKILL.md`](skills/bug-fix-java/SKILL.md) | Java Bug 修复流程 |
| [`skills/refactor-java/SKILL.md`](skills/refactor-java/SKILL.md) | Java 代码重构流程 |
| [`skills/code-review-java/SKILL.md`](skills/code-review-java/SKILL.md) | Java 安全、规范、质量三维度代码评审 |
| [`skills/testing-java/SKILL.md`](skills/testing-java/SKILL.md) | Java 单元测试/集成测试编写流程 |
| [`skills/deploy-doc-java/SKILL.md`](skills/deploy-doc-java/SKILL.md) | Java 部署文档提取与生成流程 |
| [`skills/dev-review-java/SKILL.md`](skills/dev-review-java/SKILL.md) | Java 开发或修复完成后自动衔接评审的组合流程 |
| [`skills/feature-dev-go/SKILL.md`](skills/feature-dev-go/SKILL.md) | Go 功能开发流程 |
| [`skills/bug-fix-go/SKILL.md`](skills/bug-fix-go/SKILL.md) | Go Bug 修复流程 |
| [`skills/refactor-go/SKILL.md`](skills/refactor-go/SKILL.md) | Go 代码重构流程 |
| [`skills/code-review-go/SKILL.md`](skills/code-review-go/SKILL.md) | Go 安全、规范、质量三维度代码评审 |
| [`skills/testing-go/SKILL.md`](skills/testing-go/SKILL.md) | Go 单元测试/集成测试编写流程 |
| [`skills/deploy-doc-go/SKILL.md`](skills/deploy-doc-go/SKILL.md) | Go 部署文档提取与生成流程 |
| [`skills/dev-review-go/SKILL.md`](skills/dev-review-go/SKILL.md) | Go 开发或修复完成后自动衔接评审的组合流程 |

### 3. Workflows

`workflows/` 目录存放面向用户触发的工作流说明：

| Workflow | 作用 |
|------|------|
| [`workflows/feature-dev.md`](workflows/feature-dev.md) | `/feature-dev` 功能开发流程 |
| [`workflows/bug-fix.md`](workflows/bug-fix.md) | `/bug-fix` 问题修复流程 |
| [`workflows/code-review.md`](workflows/code-review.md) | `/code-review` 代码审查流程 |
| [`workflows/testing.md`](workflows/testing.md) | `/testing` 测试生成流程 |
| [`workflows/deploy-doc.md`](workflows/deploy-doc.md) | `/deploy-doc` 部署文档生成流程 |

### 4. Docs

`docs/` 目录存放说明文档：

| 文件 | 作用 |
|------|------|
| [`docs/ai-dev-workflow.md`](docs/ai-dev-workflow.md) | 面向日常使用者的操作指南 |

### 5. Project-Level Guidance

| 文件 | 作用 |
|------|------|
| [`AGENTS.md`](AGENTS.md) | 项目级 AI 协作总纲，描述规则体系、Skill 体系与 Agent 人设 |
| [`README.md`](README.md) | 本仓库总览索引 |

---

## 目录结构

```text
.
├── AGENTS.md
├── README.md
├── docs/
│   └── ai-dev-workflow.md
├── rules/
│   ├── 00-global.mdc
│   ├── 01-java-backend.mdc
│   ├── 02-java-security.mdc
│   ├── 03-java-api-design.mdc
│   ├── 04-go-backend.mdc
│   ├── 05-go-security.mdc
│   └── 06-go-api-design.mdc
├── skills/
│   ├── bug-fix-java/
│   │   └── SKILL.md
│   ├── code-review-java/
│   │   └── SKILL.md
│   ├── deploy-doc-java/
│   │   └── SKILL.md
│   ├── dev-review-java/
│   │   └── SKILL.md
│   ├── feature-dev-java/
│   │   └── SKILL.md
│   ├── refactor-java/
│   │   └── SKILL.md
│   ├── requirement-clarify-java/
│   │   └── SKILL.md
│   ├── testing-java/
│   │   └── SKILL.md
│   ├── bug-fix-go/
│   │   └── SKILL.md
│   ├── code-review-go/
│   │   └── SKILL.md
│   ├── deploy-doc-go/
│   │   └── SKILL.md
│   ├── dev-review-go/
│   │   └── SKILL.md
│   ├── feature-dev-go/
│   │   └── SKILL.md
│   ├── refactor-go/
│   │   └── SKILL.md
│   ├── requirement-clarify-go/
│   │   └── SKILL.md
│   └── testing-go/
│       └── SKILL.md
└── workflows/
    ├── bug-fix.md
    ├── code-review.md
    ├── deploy-doc.md
    ├── feature-dev.md
    └── testing.md
```

---

## 典型使用方式

### 在 Cursor 类工具中

1. 项目根目录的 `AGENTS.md` 作为项目级上下文。
2. `rules/*.mdc` 作为可复用规则文件，按工具能力决定是自动加载还是手动引用。
3. `skills/*/SKILL.md` 用于定义 AI 在特定任务下应遵循的 SOP。
4. `workflows/*.md` 用于定义面向用户的触发入口与执行顺序。

### 常见任务映射

| 任务 | 推荐入口 | 依赖关系 |
|------|----------|----------|
| 开发新功能（Java） | `/feature-dev-java` | `requirement-clarify-java` -> `feature-dev-java` |
| 修复问题（Java） | `/bug-fix-java` | `requirement-clarify-java` -> `bug-fix-java` |
| 审查代码（Java） | `/code-review-java` | `requirement-clarify-java` -> `code-review-java` |
| 编写测试（Java） | `/testing-java` | `requirement-clarify-java` -> `testing-java` |
| 生成部署文档（Java） | `/deploy-doc-java` | `requirement-clarify-java` -> `deploy-doc-java` |
| 开发并自动评审（Java） | 自然语言触发或组合请求 | `feature-dev-java`/`bug-fix-java` -> `dev-review-java` -> `code-review-java` |

---

## 维护建议

- 新增规则时，优先放入 `rules/`，并在 `AGENTS.md` 中补充索引关系。
- 新增技能时，使用独立目录并提供清晰的 `SKILL.md` 说明。
- 新增工作流时，应明确前置 Skill、执行顺序和退出条件。
- 修改规则或 SOP 后，同步更新本 `README.md`，避免目录说明失效。
