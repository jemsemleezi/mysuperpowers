# 问题追踪：GitLab

本仓库的问题（Issues）和产品需求文档（PRDs）均以 GitLab Issues 形式存在。所有操作请使用 [`glab`](https://gitlab.com/gitlab-org/cli) 命令行工具。

## 操作规范

- **创建问题**：`glab issue create --title "..." --description "..."`。多行描述请使用 heredoc 语法。传入 `--description -` 可打开编辑器编辑。
- **查看问题**：`glab issue view <number> --comments`。添加 `-F json` 可获取机器可读的 JSON 输出。
- **列出问题**：`glab issue list --state opened -F json`，按需添加 `--label` 过滤条件。注意 GitLab 的状态值使用 `opened`（而非 `open`）。
- **评论问题**：`glab issue note <number> --message "..."`。GitLab 将评论称为 "notes"。
- **添加/移除标签**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可用逗号分隔或重复添加该参数。
- **关闭问题**：`glab issue close <number>`。`glab issue close` 不支持添加关闭评论，请先通过 `glab issue note <number> --message "..."` 发布说明，再执行关闭。
- **合并请求**：GitLab 将拉取请求（PR）称为 "合并请求（merge requests）"。使用 `glab mr create`、`glab mr view`、`glab mr note` 等命令，格式与 `gh pr ...` 类似，仅将 `pr` 替换为 `mr`，`comment`/`--body` 替换为 `note`/`--message`。

`glab` 会自动从 `git remote -v` 推断仓库信息，在克隆目录中运行时无需额外配置。

## 当技能提到「发布到问题追踪器」时

创建一个 GitLab 问题。

## 当技能提到「获取相关工单」时

运行 `glab issue view <number> --comments`。
