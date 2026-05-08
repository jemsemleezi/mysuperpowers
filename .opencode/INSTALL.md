# MySuperPowers for OpenCode

## 安装

### 步骤 1：将技能复制到 OpenCode 全局技能目录（必需）

当前 OpenCode 版本（含 v1.14.40）**无法仅通过插件注册向代理暴露 `skill` 功能工具**（[superpowers#1492](https://github.com/obra/superpowers/issues/1492)）。技能必须放置在全局技能目录中：

```powershell
# 将整个 skills 文件夹复制到 OpenCode 的全局技能目录
Copy-Item -Recurse -Path "<path-to-mysuperpowers>\skills" -Destination "$env:USERPROFILE\.config\opencode\skills\mysuperpowers"
```

这样所有技能即可被 OpenCode 的原生技能扫描器发现。

### 步骤 2：添加插件引用（可选）

```json
{
  "plugin": ["<path-to-mysuperpowers>"]
}
```

或通过 git 安装：

```json
{
  "plugin": ["mysuperpowers@git+https://github.com/your-org/mysuperpowers.git"]
}
```

> **注意**：仅注册插件可启用钩子和消息转换，但 `skill` 工具仍然不可用。在 OpenCode 解决功能工具缺口之前，**必须执行步骤 1**（复制技能目录）。

## 使用方法

使用 OpenCode 原生的 `skill` 工具列出和加载技能：

```
skill tool to list skills
skill tool to load mysuperpowers/brainstorming
```

## 工具映射

| Claude Code 工具 | OpenCode 等效工具 |
|---|---|
| `TodoWrite` | `todowrite` |
| `Task` 搭配子代理 | 使用 OpenCode 的 `task` 工具 |
| `Skill` 工具 | OpenCode 原生的 `skill` 工具 |
| 文件操作 | OpenCode 原生工具 |
