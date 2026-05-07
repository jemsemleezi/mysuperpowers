# 视觉辅助指南

基于浏览器的视觉头脑风暴辅助工具，用于展示线框图、图表和选项。

## 使用场景

按问题而非会话决定使用场景。判断标准：**用户通过视觉查看是否比阅读文字更容易理解内容？**

**使用浏览器**的场景：

- **UI 线框图** — 线框、布局、导航结构、组件设计
- **架构图** — 系统组件、数据流、关系映射
- **并排视觉对比** — 对比两种布局、两套配色方案、两个设计方向
- **设计打磨** — 当问题涉及外观质感、间距、视觉层级时
- **空间关系** — 状态机、流程图、实体关系图等可视化渲染内容

**使用终端**的场景：

- **需求与范围问题** — "X 是什么意思？"、"哪些功能属于范围？"
- **概念性 A/B/C 选项** — 从文字描述的方法中选择
- **权衡列表** — 优缺点、对比表格
- **技术决策** — API 设计、数据建模、架构方案选择
- **澄清问题** — 答案以文字而非视觉偏好呈现的所有问题

涉及 UI 主题的问题并不自动属于视觉问题。「你想要哪种向导？」属于概念性问题 — 使用终端。「这些向导布局哪个更合适？」属于视觉问题 — 使用浏览器。

## 工作原理

服务端会监听目录中的 HTML 文件，并将最新的文件提供给浏览器。你向 `screen_dir` 写入 HTML 内容，用户即可在浏览器中查看，并可通过点击选择选项。用户的选择会记录到 `state_dir/events` 中，供你在下一轮对话中读取。

**内容片段 vs 完整文档：** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头，服务端会原样提供（仅注入辅助脚本）。否则，服务端会自动将你的内容包裹在框架模板中 — 添加页头、CSS 主题、选择指示器以及所有交互基础设施。**默认编写内容片段。** 仅当你需要完全控制页面时，才编写完整文档。

## 启动会话

```bash
# Start server with persistence (mockups saved to project)
scripts/start-server.sh --project-dir /path/to/project

# Returns: {"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从响应中保存 `screen_dir` 和 `state_dir`。告知用户打开该 URL。

**查找连接信息：** 服务端会将启动 JSON 写入 `$STATE_DIR/server-info`。如果你在后台启动服务端且未捕获 stdout，可读取该文件获取 URL 和端口。使用 `--project-dir` 时，可在 `<项目根目录>/.superpowers/brainstorm/` 下查找会话目录。

**注意：** 将项目根目录作为 `--project-dir` 传入，这样线框图会持久保存在 `.superpowers/brainstorm/` 中，且服务端重启后不会丢失。若不传入该参数，文件会保存到 `/tmp` 并会被自动清理。提醒用户如果尚未将 `.superpowers/` 添加到 `.gitignore`，请尽快添加。

**按平台启动服务端：**

**Claude Code（macOS / Linux）：**
```bash
# Default mode works — the script backgrounds the server itself
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code（Windows）：**
```bash
# Windows auto-detects and uses foreground mode, which blocks the tool call.
# Use run_in_background: true on the Bash tool call so the server survives
# across conversation turns.
scripts/start-server.sh --project-dir /path/to/project
```
通过 Bash 工具调用时，请设置 `run_in_background: true`。然后在下一轮对话中读取 `$STATE_DIR/server-info` 获取 URL 和端口。

**Codex：**
```bash
# Codex reaps background processes. The script auto-detects CODEX_CI and
# switches to foreground mode. Run it normally — no extra flags needed.
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI：**
```bash
# Use --foreground and set is_background: true on your shell tool call
# so the process survives across turns
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**其他环境：** 服务端必须在多轮对话中持续在后台运行。如果你的环境会回收脱离的进程，请使用 `--foreground` 参数，并通过你所在平台的后台执行机制启动命令。

如果浏览器无法访问该 URL（常见于远程/容器化环境），可绑定非回环主机地址：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

使用 `--url-host` 控制返回的 URL JSON 中打印的主机名。

## 循环流程

1. **检查服务端是否运行**，然后向 `screen_dir` 中的新文件**写入 HTML**：
   - 每次写入前，检查 `$STATE_DIR/server-info` 是否存在。如果不存在（或 `$STATE_DIR/server-stopped` 存在），说明服务端已关闭 — 请先使用 `start-server.sh` 重启，再继续操作。服务端在无活动 30 分钟后会自动退出。
   - 使用语义化文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **禁止重复使用文件名** — 每个页面使用全新文件
   - 使用 Write 工具 — **禁止使用 cat/heredoc**（会在终端输出冗余内容）
   - 服务端会自动提供最新的文件

2. **告知用户预期内容并结束你的回合：**
   - 提醒用户 URL（每一步都要提醒，不止首次）
   - 简要文字说明页面内容（例如：「正在展示首页的 3 种布局选项」）
   - 请用户在终端回复：「请查看后告知你的想法。如需选择选项，可点击对应内容。」

3. **下一轮对话** — 用户在终端回复后：
   - 如果 `$STATE_DIR/events` 存在，读取该文件 — 其中包含用户浏览器交互记录（点击、选择等），格式为 JSON 行
   - 结合用户的终端文字回复，获取完整反馈
   - 终端消息是主要反馈来源；`state_dir/events` 提供结构化的交互数据

4. **迭代或推进** — 如果反馈需要修改当前页面，编写新文件（例如 `layout-v2.html`）。仅当当前步骤验证通过后，再进入下一个问题。

5. **返回终端时卸载内容** — 当下一步不需要浏览器时（例如澄清问题、权衡讨论），推送等待页面以清除过期内容：

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这样可以避免用户在对话已进入下一环节时，仍盯着已处理完成的选择页面。当下一个视觉问题出现时，按常规推送新的内容文件即可。

6. 重复上述步骤直到完成。

## 编写内容片段

仅编写页面内部的内容即可。服务端会自动将内容包裹在框架模板中（包含页头、主题 CSS、选择指示器以及所有交互基础设施）。

**最小示例：**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

就是这么简单。无需编写 `<html>`、CSS 或 `<script>` 标签，服务端会提供所有这些内容。

## 可用 CSS 类

框架模板为你的内容提供以下 CSS 类：

### 选项（A/B/C 选择）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**多选：** 给容器添加 `data-multiselect` 属性，允许用户选择多个选项。每次点击会切换选中状态。指示器栏会显示已选数量。

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### 卡片（视觉设计）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### 线框图容器

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### 分屏视图（并排）

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### 优缺点

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### 模拟元素（线框图组件）

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 排版与区块

- `h2` — 页面标题
- `h3` — 区块标题
- `.subtitle` — 标题下方的辅助文字
- `.section` — 带底部边距的内容块
- `.label` — 小型大写标签文字

## 浏览器事件格式

用户在浏览器中点击选项时，交互记录会写入 `$STATE_DIR/events`（每行一个 JSON 对象）。推送新页面时，该文件会自动清空。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流会展示用户的探索路径 — 用户可能在最终确定前点击多个选项。最后一个 `choice` 事件通常是最终选择，但点击模式可能反映出犹豫或偏好，值得进一步询问。

如果 `$STATE_DIR/events` 不存在，说明用户未与浏览器交互 — 仅使用其终端文字回复即可。

## 设计技巧

- **根据问题调整保真度** — 布局问题用线框图，打磨问题用高保真设计
- **每个页面明确说明问题** — 例如「哪种布局更显专业？」而非仅「选一个」
- **推进前先迭代** — 如果反馈需要修改当前页面，先编写新版本
- 每个页面最多 **2-4 个选项**
- **必要时使用真实内容** — 例如摄影作品集使用实际图片（Unsplash）。占位内容会掩盖设计问题。
- **保持线框图简洁** — 聚焦布局和结构，无需追求像素级精确

## 文件命名

- 使用语义化名称：`platform.html`、`visual-style.html`、`layout.html`
- 禁止重复使用文件名 — 每个页面必须使用新文件
- 迭代版本：添加版本后缀，例如 `layout-v2.html`、`layout-v3.html`
- 服务端按修改时间提供最新文件

## 清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果会话使用了 `--project-dir`，线框图文件会持久保存在 `.superpowers/brainstorm/` 中供后续参考。仅 `/tmp` 中的会话会在停止时被删除。

## 参考

- 框架模板（CSS 参考）：`scripts/frame-template.html`
- 辅助脚本（客户端）：`scripts/helper.js`

---

本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。
