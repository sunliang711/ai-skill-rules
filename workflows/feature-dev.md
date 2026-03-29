---
description: 标准功能开发流程 — 从需求澄清到编码交付的全链路 SOP
---

# /feature-dev 工作流

当用户使用 `/feature-dev` 命令时，严格按以下步骤执行：

## 步骤 1：需求澄清
使用 `view_file` 工具读取 `.agents/skills/requirement-clarify-java/SKILL.md`，按照「feature-dev 专属问题清单」执行需求澄清流程。

**在所有 🔴 必问项（F-01 ~ F-04）都已确认之前，禁止进入下一步。**

## 步骤 2：方案设计
使用 `view_file` 工具读取 `.agents/skills/feature-dev-java/SKILL.md`，按照阶段一输出实现方案：
- 影响范围、文件清单
- 数据库变更、接口设计
- 核心业务逻辑、安全考量

通知用户审阅方案。

## 步骤 3：方案辩论
- 用户提出质疑和问题
- 逐一回答、解释设计决策
- 根据反馈修改方案
- **必须等待用户明确说"同意"/"开始"/"执行"后才进入编码阶段**

## 步骤 4：编码实现
使用 `view_file` 工具读取项目根目录 `AGENTS.md` 中的安全规范章节（第四章：安全红线），确保代码符合所有 🔴 强制规则。

按照 `feature-dev-java` Skill 阶段二的分层顺序编码：
- 数据库脚本 → Entity → DTO → Repository → Service → Controller

## 步骤 5：代码审阅
- 列出所有修改的文件和关键变更点
- **必须等待用户确认代码无问题后才继续**

## 步骤 6：编译验证
// turbo
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && mvn compile -q 2>&1 | tail -10 && echo "BUILD_OK"
```
- 编译失败 → 修复后重新编译
- 编译通过 → 继续下一步

## 步骤 7：自检与交付
按照 `feature-dev-java` Skill 阶段三执行：
- 自检清单逐项检查
- 输出变更摘要 + ChangeLog

## 步骤 8：提交代码
- 查看变更文件
// turbo
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && git status --short && git diff --stat
```
- 提交（需要用户确认 commit message）
```bash
cd /d/ideaworkspace/exchange-cold-wallet-backend && git add -A && git commit -m "<commit message>"
```

## 使用示例
```
/feature-dev 新增一个根据交易哈希查询交易详情的接口
/feature-dev 实现地址余额批量查询功能
```
