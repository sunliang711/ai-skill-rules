# AI 规则跨平台通用化方案

> **源仓库**: `D:\ideaworkspace\functionBranch\ai-rules-skills`
> **日期**: 2026-03-31

---

## 一、核心结论

| 结论 | 说明 |
|------|------|
| 内容无需改动 | 7 规范 + 16 Skill + 5 Workflow 内容已很完善 |
| 改的是载体 | `.mdc` → `.md`，路径 `.cursor/` → `.agents/` |
| AGENTS.md 是统一入口 | 行业事实标准，9 大工具均支持或兼容 |
| 一套内容多处适配 | 用生成脚本产出各工具的专属格式 |

---

## 二、各平台配置差异速查

| 平台 | 项目级配置文件 | 格式要求 | 备注 |
|------|--------------|---------|------|
| **Cursor** | `.cursor/rules/*.mdc` | Markdown + YAML frontmatter | 已原生适配 |
| **Copilot** | `.github/copilot-instructions.md` | 纯 Markdown（单文件） | 需合并所有规则 |
| **Claude Code** | `CLAUDE.md`（项目根） | 纯 Markdown | 建议 ≤300 行 |
| **Codex** | `AGENTS.md`（项目根） | 纯 Markdown | 原生读取 |
| **Antigravity** | `AGENTS.md` + `.agents/skills/` | Markdown + YAML frontmatter(skill) | 原生支持 Skills |
| **Gemini CLI** | `GEMINI.md`（项目根） | 纯 Markdown | 层级覆盖 |
| **Windsurf** | `.windsurfrules`（项目根） | 纯文本/Markdown | ≤6000 字符为佳 |
| **Aider** | `CONVENTIONS.md` + `.aider.conf.yml` | 纯 Markdown + YAML | 需配置自动加载 |
| **通义灵码** | `.lingma/rules/*.md` | 纯 Markdown | 单文件 ≤10000 字符 |

---

## 三、方案：一键生成脚本

在源仓库 `ai-rules-skills/tools/` 下提供两个脚本，功能完全一致：

| 脚本 | 适用系统 |
|------|---------|
| `generate-for-platform.ps1` | Windows (PowerShell) |
| `generate-for-platform.sh` | macOS / Linux (Bash) |

### Windows 用法

```powershell
# 查看帮助
.\tools\generate-for-platform.ps1 -Help

# 生成指定平台格式 → 输出到目标项目
.\tools\generate-for-platform.ps1 -Platform copilot -TargetDir "D:\your-project"
.\tools\generate-for-platform.ps1 -Platform claude -TargetDir "D:\your-project"
.\tools\generate-for-platform.ps1 -Platform antigravity -TargetDir "D:\your-project"

# 生成所有平台格式
.\tools\generate-for-platform.ps1 -Platform all -TargetDir "D:\your-project"
```

### macOS / Linux 用法

```bash
# 添加执行权限（首次使用）
chmod +x tools/generate-for-platform.sh

# 查看帮助
./tools/generate-for-platform.sh --help

# 生成指定平台格式 → 输出到目标项目
./tools/generate-for-platform.sh copilot /path/to/your-project
./tools/generate-for-platform.sh claude /path/to/your-project
./tools/generate-for-platform.sh antigravity /path/to/your-project

# 生成所有平台格式
./tools/generate-for-platform.sh all /path/to/your-project
```

### 支持的 `-Platform` 参数

| 参数值 | 生成内容 | 输出位置 |
|--------|---------|---------|
| `cursor` | `.mdc` 规则 + skills + workflows | `目标/.cursor/` |
| `copilot` | 合并后的单文件 | `目标/.github/copilot-instructions.md` |
| `claude` | 精简版项目指南 | `目标/CLAUDE.md` |
| `codex` | AGENTS.md（去 Cursor 化） | `目标/AGENTS.md` |
| `antigravity` | AGENTS.md + skills + workflows | `目标/AGENTS.md` + `目标/.agents/` |
| `gemini` | 精简版项目指南 | `目标/GEMINI.md` |
| `windsurf` | 全局 + 安全规则摘要 | `目标/.windsurfrules` |
| `aider` | CONVENTIONS.md + 配置文件 | `目标/CONVENTIONS.md` + `.aider.conf.yml` |
| `lingma` | 拆分后的规则文件 | `目标/.lingma/rules/` |
| `all` | 以上全部 | 各自对应位置 |

---

## 四、生成后如何在各平台使用 Rules、Skills 和 Workflows

跨平台生成的最大难点在于**并非所有工具都有 Skills 和 Workflows 的原生概念**。本章节详细分析如何在使用这些工具时应用你的三层架构知识库。

### 1. 原生支持级：Cursor & Antigravity (Google)
这两款工具拥有最完整的 Agentic 架构，原生支持 SOP 指令。

*   **Rules (规范)**：
    *   **Cursor**：通过 `.cursor/rules/*.mdc` 的 `globs` 实现**自动静默激活**。编辑 Java 时只亮起 Java 规则。
    *   **Antigravity**：默认加载 `AGENTS.md` 和 `.agents/rules/` 作为项目大内存上下文。
*   **Skills & Workflows (技能与工作流)**：
    *   **Cursor**：在对话框输入 `@` 或 `/` 即可列出 `.cursor/skills` 和 `.cursor/workflows` 里的名称。输入 `/feature-dev`，Cursor 就会按照你的 12 步 SOP 一步一步执行。
    *   **Antigravity**：本身具备自动工具链发现能力。当你指令“按照标准流程开发该功能”时，它会自动在 `.agents/skills/feature-dev-java/SKILL.md` 中寻找 SOP 指引并应用。

### 2. 全局配置级：GitHub Copilot & 通义灵码
由于缺乏多文件协调能力，这部分助手主要依靠“文件合并注入”或“IDE 搜索拦截”。

*   **Rules (规范)**：
    *   **Copilot**：只要你打开项目工作区，它就会自动将 `.github/copilot-instructions.md`（我们将所有规组合并成了此文件）附加到所有 `chat` 请求的系统提示中。
    *   **通义灵码**：会读取 `.lingma/rules/` 下的分割规则。部分规则会在触发单元测试/注释生成等特定操作时被模型自主提取（Model Decision）。
*   **Skills & Workflows (技能与工作流)**：这两款工具**不原生支持**技能。
    *   **Copilot**：需要在对话中使用 `#file` 或 `@workspace` 手动引入，例如：“请参考 `#SKILL.md` 的规范修复这个 Bug”。
    *   **通义灵码**：使用 `#rule` 命令唤出具体的规则，或者手动将 SOP 文件的文本作为需求前置说明发送。

### 3. CLI 与对话级：Claude Code, Aider, Gemini & Windsurf
这类工具通过 CLI 启动或主打极简轻量级，通常依靠一个统一入口点（如 `CLAUDE.md`）来实现。

*   **Rules (规范)**：
    *   **Claude Code/Gemini**：通过阅读 `CLAUDE.md` / `GEMINI.md` 获取到项目的安全红线摘要和外链提醒。
    *   **Windsurf/Aider**：分别开局载入 `.windsurfrules` 和 `CONVENTIONS.md` 作为护栏，确保不会犯低级安全错误。
*   **Skills & Workflows (技能与工作流)**：
    *   **Claude/Gemini/Windsurf**：在你的 `CLAUDE.md` 摘要中，脚本已经帮你生成了**参考表格**（例如记录了写测试要看哪个文件）。向 AI 提问时可以直接说：“遇到 Bug，请阅读 `.agents/skills/bug-fix-java/SKILL.md` 然后帮我修复分析”。
    *   **Aider**：在 Aider 命令行模式内，必须手动执行扩展加载命令介入 SOP：
        ```bash
        /read .agents/skills/bug-fix-java/SKILL.md
        /message 按照刚刚读取的规范修复 user 模块的空指针异常
        ```

---

## 五、注意事项

1. **Cursor 的 `globs` 自动激活是专有能力** — 其他平台主要通过自然语言让 AI 自行判断适用范围或全局堆叠。
2. **Skill/Workflow 极简哲学** — 因为只有 Cursor 和 Antigravity 原生支持分离式的步骤 SOP，使用其他平台时，请务必在 Prompt 中加入：“**请先阅读 `.agents/skills/xxx/SKILL.md`**” 的强指引。
3. **通义灵码不支持符号链接** — 必须复制/生成实际文件（生成脚本已处理该缺陷）。
4. **建议将生成文件加入 `.gitignore`** — 只维护源仓库，目标项目按需生成，不污染代码基础。

---

## 六、自动化脚本架构解析

为了支撑上述从单一规则源（SSOT）向 9 种不同格式衍生，我们在 `tools/` 中提供的生成脚本（`generate-for-platform.ps1` 和 `generate-for-platform.sh`）承载了跨平台编译器的职能。

### 1. 数据预处理引擎
*   **去除专有元数据 (`strip_frontmatter`)**：它会扫描文件头部，利用正则引擎将 `---` 之间的内容（如 Cursor 的 `globs` 和 `alwaysApply`）全部裁切掉，只提取纯净的 Markdown 正文，防止其他 AI 将这些设定误认为是业务指引。
*   **路径热替换 (`read_agents_md`)**：自动将总导航中的 `.cursor/rules/` 等游离路径引用替换为 `.agents/` 中立规范路径。

### 2. 多态生成路由 (Platform Adapters)
脚本针对 9 个不同平台处理文本上限和结构的特性，采取了四套生成策略：
*   **文件夹整体平移** (`Cursor` / `Antigravity` / `Codex`)：建立平行子空间 `.agents/`，支持无限期长文件和海量规则挂载。
*   **分片引擎** (`通义灵码`)：针对其 10,000 字符硬限制，脚本会自动依据 Markdown 的 `##` 标题段落进行分片计算，安全地将其切成 `part1`、`part2` 多个子块。
*   **全家桶合并** (`Copilot`)：剥除元数据后，像串糖葫芦一样把全局规范、Java规范、Go规范... 按字典序合并成一个高达 30+KB 的单体指令库 `copilot-instructions.md`。
*   **极简兜底 + 链接路由** (`Claude` / `Gemini` / `Windsurf`)：针对无法承载海量上下文或依靠统一入口的工具，采用“**保命手册 + 藏宝图**”策略：
    *   **极简兜底**：出于对大模型“注意力稀释”与平台硬性字符限制的考量，将**全局规范和生死攸关的安全红线（如防注入、禁明文密钥）提取硬编码嵌入**。保证 AI 哪怕不去检索外部文件，也绝对不会打破安全下限。
    *   **链接路由（按需加载）**：针对具体业务（Java/Go 开发规范）和特定任务（Bug 修复 SOP），自动化构建一张 Markdown 路由检索表附加在兜底文件末尾。当用户提出开发需求时，AI 通过阅读索引“地图”，就会使用工具自主去精确读取对应的文件，实现了低成本的 RAG（检索增强生成）按需挂载。

### 3. 可靠性设计
*   **免环境依赖**：核心代码和输出管道强制只使用英文和 ANSI 字符包裹逻辑流，这成功规避了由于 Windows PowerShell 默认 GBK 环境造成的控制台乱码和 BOM 解析异常问题，无论是在 Git Bash (LF) 还是传统终端 (CRLF) 都能健壮执行。
