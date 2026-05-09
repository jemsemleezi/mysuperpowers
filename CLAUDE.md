## 主要指令：模式检测
在开始任何任务之前，先根据用户的提示判断其意图模式：
- 如果用户说“auto”、“automate”、“build this”，或者给出高层需求 -> 进入 Auto-pilot Mode。加载 `using-superpowers` 技能并严格遵循。你可以使用 `executing-plans` 和 `subagent-driven-development`。
- **MANDATORY**：`verification-before-completion` 是 The Flow 不可跳过的最后一道关卡。任何实现工作完成后，你都必须运行验证命令并提供证据，然后才能宣称完成或进入代码审查。
- 如果用户说“I’ll write it”、“guide me”、“help me learn”，或者询问具体的编码问题 -> 进入 Manual-first Mode。不要编写最终代码，也不要启动子代理。建议相关技能（如 `tdd`、`diagnose`、`caveman`、`grill-me`），并等待用户行动或明确要求你来写。
- 如有疑问，请询问：“你是想让我全自动执行(Auto-pilot Mode)来做，还是我们切到 manual-first，让你自己写代码？”
- 无论哪种模式，都要加载 `using-superpowers` 技能并遵守其中定义的 Safety & Boundaries。

`skills/` 下的技能按 bucket 文件夹组织：
- `engineering/` — 日常编码工作
- `productivity/` — 日常非编码工作流工具
- `misc/` — 保留但很少使用

`engineering/` 和 `productivity/` 中的每个技能都必须在顶层 `README.md` 中有引用，并在 `.claude-plugin/plugin.json` 中有条目。
每个 bucket 文件夹都必须有一个 `README.md`，列出该 bucket 中的每个技能及其一句话描述，并将技能名称链接到对应的 `SKILL.md`。

在处理这个仓库时，编辑前先加载相关技能内容。`misc/` 中的技能不需要写入 README.md，但如果打算分发，则应包含在 plugin.json 中。
