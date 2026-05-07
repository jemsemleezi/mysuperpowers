# 测试 MySuperPowers 技能

本文档描述如何测试 MySuperPowers 技能，特别是涉及子代理、工作流和复杂交互的集成测试。

## 概述

测试技能需要运行真实的代理会话，并通过会话转录文本来验证行为。对于涉及 `subagent-driven-development`、`brainstorming`、`executing-plans` 等复杂技能，必须通过真实会话验证。

## 测试结构

```
tests/
├── claude-code/                    # Claude Code 集成测试
│   ├── test-helpers.sh             # 共享测试工具函数
│   ├── test-subagent-driven-development.sh
│   ├── test-requesting-code-review.sh
│   ├── analyze-token-usage.py      # Token 分析工具
│   └── run-skill-tests.sh          # 测试运行器
├── opencode/                       # OpenCode 集成测试
│   ├── test-plugin-loading.sh      # 插件加载测试
│   ├── test-bootstrap-caching.sh   # 启动缓存测试
│   ├── test-priority.sh            # 技能优先级测试
│   └── run-tests.sh                # OpenCode 测试运行器
├── skill-triggering/               # 验证自动触发逻辑
│   ├── prompts/                    # 触发提示词样本
│   ├── run-test.sh                 # 单个触发测试
│   └── run-all.sh                  # 批量触发测试
└── subagent-driven-dev/            # 子代理开发集成测试
    ├── go-fractals/                # Go 分形项目测试
    ├── svelte-todo/                # Svelte Todo 测试
    └── run-test.sh                 # 运行子代理测试
```

## 运行测试

### 快速测试（推荐）

```bash
# 运行所有快速测试
cd tests/claude-code
./run-skill-tests.sh

# 运行特定测试
./run-skill-tests.sh --test test-subagent-driven-development.sh

# 详细输出
./run-skill-tests.sh --verbose
```

### 集成测试（较慢，10-30 分钟）

```bash
# 运行完整工作流测试
./run-skill-tests.sh --integration

# 自定义超时时间
./run-skill-tests.sh --timeout 1800  # 30 分钟
```

### OpenCode 测试

```bash
cd tests/opencode
./run-tests.sh
```

### Token 分析

使用 Token 分析脚本来了解每次技能调用的成本：

```bash
python3 tests/claude-code/analyze-token-usage.py ~/.claude/projects/<project-dir>/<session-id>.jsonl
```

## 集成测试详解

### subagent-driven-development 集成测试

#### 测试内容

该集成测试验证 `subagent-driven-development` 技能是否正确：

1. **计划加载**：在开始时一次性读取计划
2. **完整任务文本**：向子代理提供完整的任务描述（不让他们自己读文件）
3. **自我审查**：确保子代理在报告前执行自我审查
4. **审查顺序**：先运行规范符合性审查，再运行代码质量审查
5. **审查循环**：发现问题时使用审查循环
6. **独立验证**：规范审查员独立阅读代码，不信任实现者的报告

#### 工作原理

1. **设置**：创建一个带有最小化实现计划的临时 Node.js 项目
2. **执行**：在 headless 模式下运行代理并应用技能
3. **验证**：解析会话转录文本（`.jsonl` 文件）以验证：
   - 技能工具被调用
   - 子代理被分派（Task 工具）
   - 使用 TodoWrite 进行跟踪
   - 实现文件被创建
   - 测试通过
   - Git 提交显示正确的工作流
4. **Token 分析**：显示每个子代理的 Token 用量

#### 测试输出示例

```
========================================
  Integration Test: subagent-driven-development
========================================

Test project: /tmp/tmp.xyz123

=== Verification Tests ===

Test 1: Skill tool invoked...
  [PASS] subagent-driven-development skill was invoked

Test 2: Subagents dispatched...
  [PASS] 7 subagents dispatched

Test 3: Task tracking...
  [PASS] TodoWrite used 5 time(s)

Test 6: Implementation verification...
  [PASS] src/math.js created
  [PASS] add function exists
  [PASS] multiply function exists
  [PASS] test/math.test.js created
  [PASS] Tests pass

Test 7: Git commit history...
  [PASS] Multiple commits created (3 total)

Test 8: No extra features added...
  [PASS] No extra features added

========================================
  Token Usage Analysis
========================================

Usage Breakdown:
----------------------------------------------------------------------------------------------------
Agent           Description                          Msgs      Input     Output      Cache     Cost
----------------------------------------------------------------------------------------------------
main            Main session (coordinator)             34         27      3,996  1,213,703 $   4.09
3380c209        implementing Task 1: Create Add Function     1          2        787     24,989 $   0.09
34b00fde        implementing Task 2: Create Multiply Function     1          4        644     25,114 $   0.09
3801a732        reviewing whether an implementation matches...   1          5        703     25,742 $   0.09
4c142934        doing a final code review...                    1          6        854     25,319 $   0.09
5f017a42        a code reviewer. Review Task 2...               1          6        504     22,949 $   0.08
a6b7fbe4        a code reviewer. Review Task 1...               1          6        515     22,534 $   0.08
f15837c0        reviewing whether an implementation matches...   1          6        416     22,485 $   0.07
----------------------------------------------------------------------------------------------------

TOTALS:
  Total messages:         41
  Input tokens:           62
  Output tokens:          8,419
  Cache creation tokens:  132,742
  Cache read tokens:      1,382,835

  Total input (incl cache): 1,515,639
  Total tokens:             1,524,058

  Estimated cost: $4.67
  (at $3/$15 per M tokens for input/output)

========================================
  Test Summary
========================================

STATUS: PASSED
```

### requesting-code-review 集成测试

#### 测试内容

该测试验证代码审查技能的行为（约 5 分钟）：

- 构建一个带有基线提交的小型项目
- 添加第二个提交，植入两个真实 bug（SQL 注入、明文密码处理）
- 通过 `requesting-code-review` 技能分派代码审查员
- 验证审查员标记出植入的严重/重要级别 bug，并拒绝批准

#### 测试目的

- 技能确实分派了可用的代码审查员子代理
- 审查员模板产生的审查员能够捕获明显的安全 bug
- 审查员不是谄媚的 —— 不会批准带有严重问题的 diff

## 编写新测试

### 测试模板

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

# 创建测试项目
TEST_PROJECT=$(create_test_project)
trap "cleanup_test_project $TEST_PROJECT" EXIT

# 设置测试文件...
cd "$TEST_PROJECT"

# 运行 Claude 并应用技能
PROMPT="你的测试提示词"
cd "$SCRIPT_DIR/../.." && timeout 1800 claude -p "$PROMPT" \
  --allowed-tools=all \
  --add-dir "$TEST_PROJECT" \
  --permission-mode bypassPermissions \
  2>&1 | tee output.txt

# 查找并分析会话
WORKING_DIR_ESCAPED=$(echo "$SCRIPT_DIR/../.." | sed 's/[\/]/_/g' | sed 's/^_//')
SESSION_DIR="$HOME/.claude/projects/$WORKING_DIR_ESCAPED"
SESSION_FILE=$(find "$SESSION_DIR" -name "*.jsonl" -type f -mmin -60 | sort -r | head -1)

# 通过解析会话转录文本验证行为
if grep -q '"name":"Skill".*"skill":"your-skill-name"' "$SESSION_FILE"; then
    echo "[PASS] Skill was invoked"
fi

# 显示 Token 分析
python3 "$SCRIPT_DIR/analyze-token-usage.py" "$SESSION_FILE"
```

### 最佳实践

1. **始终清理**：使用 trap 清理临时目录
2. **解析转录文本**：不要 grep 面向用户的输出 —— 解析 `.jsonl` 会话文件
3. **授予权限**：使用 `--permission-mode bypassPermissions` 和 `--add-dir`
4. **从插件目录运行**：只有从 MySuperPowers 目录运行时技能才会加载
5. **显示 Token 用量**：始终包含 Token 分析以便了解成本
6. **测试真实行为**：验证实际创建的文件、通过的测试、创建的提交

## Token 分析工具

### 使用方法

分析任何 Claude Code / OpenCode 会话的 Token 用量：

```bash
python3 tests/claude-code/analyze-token-usage.py <session-file>.jsonl
```

### 查找会话文件

会话转录文本存储在 `~/.claude/projects/` 或 `~/.opencode/projects/` 中，工作目录路径已编码：

```bash
# 对于 /Users/yourname/Documents/GitHub/mysuperpowers
SESSION_DIR="$HOME/.claude/projects/-Users-yourname-Documents-GitHub-mysuperpowers"

# 查找最近的会话
ls -lt "$SESSION_DIR"/*.jsonl | head -5
```

### 输出内容

- **主会话用量**：协调员（你或主 Claude 实例）的 Token 用量
- **每个子代理的明细**：每次 Task 调用包含：
  - 代理 ID
  - 描述（从提示词中提取）
  - 消息数
  - 输入/输出 Token
  - 缓存用量
  - 预估成本
- **总计**：整体 Token 用量和成本预估

### 理解输出

- **高缓存读取**：良好 —— 意味着提示词缓存正在工作
- **主会话输入 Token 高**：预期 —— 协调员拥有完整上下文
- **每个子代理成本相似**：预期 —— 每个子代理获得相似的任务复杂度
- **每个任务的成本**：典型范围在 $0.05-$0.15 之间，取决于任务

## OpenCode 测试

OpenCode 测试位于 `tests/opencode/` 目录，包含：

- **test-plugin-loading.sh**：验证插件是否正确加载
- **test-bootstrap-caching.sh**：测试启动缓存机制
- **test-priority.sh**：验证技能优先级排序
- **test-tools.sh**：测试工具可用性

### 运行 OpenCode 测试

```bash
cd tests/opencode
./run-tests.sh
```

## 技能触发测试

`tests/skill-triggering/` 目录包含验证技能自动触发逻辑的工具：

- **prompts/**：包含各种可能触发技能的提示词样本
- **run-test.sh**：运行单个触发测试
- **run-all.sh**：批量运行所有触发测试

## 故障排查

### 技能未加载

**问题**：运行 headless 测试时找不到技能

**解决方案**：
1. 确保从 MySuperPowers 目录运行：`cd /path/to/MySuperPowers && tests/claude-code/...`
2. 检查 `~/.claude/settings.json` 或 `~/.opencode/settings.json` 中已启用插件
3. 验证技能存在于 `skills/` 目录中

### 权限错误

**问题**：Claude 无法写入文件或访问目录

**解决方案**：
1. 使用 `--permission-mode bypassPermissions` 标志
2. 使用 `--add-dir /path/to/temp/dir` 授予测试目录访问权限
3. 检查测试目录的文件权限

### 测试超时

**问题**：测试耗时过长并超时

**解决方案**：
1. 增加超时时间：`timeout 1800 claude ...`（30 分钟）
2. 检查技能逻辑中是否存在无限循环
3. 审查子代理任务复杂度

### 找不到会话文件

**问题**：测试运行后无法找到会话转录文本

**解决方案**：
1. 检查 `~/.claude/projects/` 或 `~/.opencode/projects/` 中的正确项目目录
2. 使用 `find ~/.claude/projects -name "*.jsonl" -mmin -60` 查找最近的会话
3. 验证测试实际运行（检查输出是否有错误）

## 会话转录文本格式

会话转录文本是 JSONL（JSON Lines）文件，其中每一行都是表示消息或工具结果的 JSON 对象。

### 关键字段

```json
{
  "type": "assistant",
  "message": {
    "content": [...],
    "usage": {
      "input_tokens": 27,
      "output_tokens": 3996,
      "cache_read_input_tokens": 1213703
    }
  }
}
```

### 工具结果

```json
{
  "type": "user",
  "toolUseResult": {
    "agentId": "3380c209",
    "usage": {
      "input_tokens": 2,
      "output_tokens": 787,
      "cache_read_input_tokens": 24989
    },
    "prompt": "You are implementing Task 1...",
    "content": [{"type": "text", "text": "..."}]
  }
}
```

`agentId` 字段链接到子代理会话，`usage` 字段包含该特定子代理调用的 Token 用量。

## CI/CD 集成

在 CI 环境中运行：

```bash
# 为 CI 环境设置显式超时
cd tests/claude-code && ./run-skill-tests.sh --timeout 900

# 退出代码 0 = 成功，非零 = 失败
```

## 注意事项

- 测试验证技能*指令*，而不是完整执行
- 完整工作流测试会非常慢
- 专注于验证关键技能需求
- 测试应该是确定性的
- 避免测试实现细节
