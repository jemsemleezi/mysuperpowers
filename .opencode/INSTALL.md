# MySuperPowers for OpenCode

## 安装

### 添加插件引用

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

### 可选：

```powershell
# 将整个 skills 文件夹复制到 OpenCode 的全局技能目录
Copy-Item -Recurse -Path "<path-to-mysuperpowers>\skills" -Destination "$env:USERPROFILE\.config\opencode\skills\mysuperpowers"
```

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
