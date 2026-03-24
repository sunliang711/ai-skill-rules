# Exchange Cold Wallet Backend — AI 开发框架文档

> 本目录是 `.agents/` 和 `~/.gemini/GEMINI.md` 中实际生效的约束、规范、Skills、Workflows 的**存档副本**，
> 供团队成员查阅和了解 AI 辅助开发框架的完整内容。

---

## ⚡ Workflows（工作流 — 斜杠命令触发）

通过 `/命令名` 快捷触发执行，每个 workflow 会自动串联所需的 skills。

| 命令 | 职责 |
|------|------|
| `/feature-dev` | 完整开发流程：需求澄清 → 方案设计 → 方案辩论 → 编码 → 审阅 → 编译 → 自检 → 提交 |
| `/bug-fix` | Bug 修复流程：信息收集 → 问题定位 → 修复实施 → 编译 → 自检 → 提交 |
| `/code-review` | 代码评审流程：确认范围 → 三维度审查（安全/规范/质量） → 输出报告 |
| `/deploy-doc` | 部署文档生成：确认变更 → 提取配置/环境变量/SQL → 生成部署清单 |
| `/testing` | 测试生成流程：确认范围 → 设计用例 → 编写测试 → 运行验证 |

---

## 🛠 Skills（技能 — 按需调用）

可复用的专项能力模块，被 workflow 自动引用或手动触发。

| 技能 | 职责 | 触发方式 |
|------|------|---------| 
| [requirement-clarify](cursor/skills/requirement-clarify/SKILL.md) | 需求澄清协议 — 强制追问机制 | 被所有 workflow 自动引用 |
| [feature-dev](cursor/skills/feature-dev/SKILL.md) | 功能开发 SOP — 分层编码规范 | `/feature-dev` 或 AI 自动判断 |
| [bug-fix](cursor/skills/bug-fix/SKILL.md) | Bug 修复 SOP — 定位到验证 | `/bug-fix` 或 AI 自动判断 |
| [code-review](cursor/skills/code-review/SKILL.md) | 代码评审 SOP — 三维度审查 | `/code-review` 或 AI 自动判断 |
| [deploy-doc](cursor/skills/deploy-doc/SKILL.md) | 部署文档生成 SOP | `/deploy-doc` 或 AI 自动判断 |
| [testing](cursor/skills/testing/SKILL.md) | 测试生成 SOP | `/testing` 或 AI 自动判断 |

---

## 📏 规范层级

本项目的 AI 编码规范分两层，生效范围从大到小：

| 层级 | 文件 | 生效范围 | 说明 |
|------|------|---------|------|
| L1 全局 | `~/.gemini/GEMINI.md` | 所有项目的每次对话（自动注入） | 格式规范 + 安全编码基线精简版 |
| L2 项目 | `AGENTS.md`（项目根目录） | 本项目（workflow 中引用读取） | 分层架构 + 命名 + API 设计 + 安全红线完整版 |

---

## 📁 目录结构

```
docs/ai-dev-framework/
├── README.md                            # 本文件 — 总览索引
│
├── cursor/                              # 规范与技能（适配 Cursor 等 AI 工具）
│   ├── rules/                           #   规范文件（.mdc 格式）
│   │   ├── 00-global.mdc               #     全局强制规范
│   │   ├── 01-java-backend.mdc         #     Java 后端编码与架构规范
│   │   ├── 02-security.mdc             #     安全红线规范
│   │   └── 03-api-design.mdc           #     API 接口设计规范
│   │
│   └── skills/                          #   技能（SOP 流程定义）
│       ├── requirement-clarify/         #     需求澄清协议
│       │   └── SKILL.md
│       ├── feature-dev/                 #     功能开发 SOP
│       │   └── SKILL.md
│       ├── bug-fix/                     #     Bug 修复 SOP
│       │   └── SKILL.md
│       ├── code-review/                 #     代码评审 SOP
│       │   └── SKILL.md
│       ├── deploy-doc/                  #     部署文档生成 SOP
│       │   └── SKILL.md
│       └── testing/                     #     测试生成 SOP
│           └── SKILL.md
│
├── workflows/                           # 工作流（斜杠命令定义）
│   ├── feature-dev.md                   #   /feature-dev
│   ├── bug-fix.md                       #   /bug-fix
│   ├── code-review.md                   #   /code-review
│   ├── deploy-doc.md                    #   /deploy-doc
│   └── testing.md                       #   /testing
│
└── docs/                                # 使用文档
    └── ai-dev-workflow.md              #   日常使用指南
```

---

## 🔗 引用关系

```
/feature-dev ──→ requirement-clarify (F-01~F-04)
             ──→ feature-dev Skill (阶段一~三)
             ──→ AGENTS.md 安全红线 (编码阶段)

/bug-fix ────→ requirement-clarify (B-01~B-03)
             ──→ bug-fix Skill (阶段一~三)
             ──→ AGENTS.md 安全红线 (修复阶段)

/code-review ─→ requirement-clarify (R-01~R-02)
             ──→ AGENTS.md 安全红线 (审查基线)
             ──→ code-review Skill (三维度审查)

/deploy-doc ──→ requirement-clarify (D-01~D-02)
             ──→ deploy-doc Skill (提取+生成)

/testing ────→ requirement-clarify (T-01~T-02)
             ──→ testing Skill (设计+编码)
             ──→ AGENTS.md 安全红线 (测试编码)
```

---

## 📅 同步记录

| 日期 | 同步内容 |
|------|----------|
| 2026-03-24 | 从 `.agents/` 和 `~/.gemini/GEMINI.md` 完整同步所有 skills、workflows、规范文件 |
