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
| [`rules/02-go-backend.mdc`](rules/02-go-backend.mdc) | Go 后端项目结构、Fx、Viper、Zerolog 等规范 |
| [`rules/02-security.mdc`](rules/02-security.mdc) | 安全红线：密钥、认证、日志、注入、传输与依赖安全 |
| [`rules/03-api-design.mdc`](rules/03-api-design.mdc) | API 统一响应、参数校验、HTTP 语义、异常处理 |

### 2. Skills

`skills/` 目录存放可被 AI 按需调用的 SOP：

| Skill | 作用 |
|------|------|
| [`skills/requirement-clarify/SKILL.md`](skills/requirement-clarify/SKILL.md) | 需求澄清协议，作为其他流程的前置环节 |
| [`skills/feature-dev/SKILL.md`](skills/feature-dev/SKILL.md) | 功能开发流程 |
| [`skills/bug-fix/SKILL.md`](skills/bug-fix/SKILL.md) | Bug 修复流程 |
| [`skills/code-review/SKILL.md`](skills/code-review/SKILL.md) | 安全、规范、质量三维度代码评审 |
| [`skills/testing/SKILL.md`](skills/testing/SKILL.md) | 单元测试/集成测试编写流程 |
| [`skills/deploy-doc/SKILL.md`](skills/deploy-doc/SKILL.md) | 部署文档提取与生成流程 |
| [`skills/dev-review/SKILL.md`](skills/dev-review/SKILL.md) | 开发或修复完成后自动衔接评审的组合流程 |

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
│   ├── 02-go-backend.mdc
│   ├── 02-security.mdc
│   └── 03-api-design.mdc
├── skills/
│   ├── bug-fix/
│   │   └── SKILL.md
│   ├── code-review/
│   │   └── SKILL.md
│   ├── deploy-doc/
│   │   └── SKILL.md
│   ├── dev-review/
│   │   └── SKILL.md
│   ├── feature-dev/
│   │   └── SKILL.md
│   ├── requirement-clarify/
│   │   └── SKILL.md
│   └── testing/
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
| 开发新功能 | `/feature-dev` | `requirement-clarify` -> `feature-dev` |
| 修复问题 | `/bug-fix` | `requirement-clarify` -> `bug-fix` |
| 审查代码 | `/code-review` | `requirement-clarify` -> `code-review` |
| 编写测试 | `/testing` | `requirement-clarify` -> `testing` |
| 生成部署文档 | `/deploy-doc` | `requirement-clarify` -> `deploy-doc` |
| 开发并自动评审 | 自然语言触发或组合请求 | `feature-dev`/`bug-fix` -> `dev-review` -> `code-review` |

---

## 维护建议

- 新增规则时，优先放入 `rules/`，并在 `AGENTS.md` 中补充索引关系。
- 新增技能时，使用独立目录并提供清晰的 `SKILL.md` 说明。
- 新增工作流时，应明确前置 Skill、执行顺序和退出条件。
- 修改规则或 SOP 后，同步更新本 `README.md`，避免目录说明失效。
