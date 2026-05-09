# Claude Code Skills Tests

Automated tests for MySuperPowers skills using Claude Code CLI.

## 前置条件

- Claude Code CLI 已安装且位于 PATH 中 (`claude --version`)
- 本地插件已启用（参考主 README.md 的安装说明）
- **必须从 MySuperPowers 根目录运行**（技能只有在目标目录下才能加载）

## 运行测试

### 快速测试（推荐）：
```bash
./run-skill-tests.sh
```

### 集成测试（较慢，10-30 分钟）：
```bash
./run-skill-tests.sh --integration
```

### 运行特定测试：
```bash
./run-skill-tests.sh --test test-subagent-driven-development.sh
```

### 详细输出：
```bash
./run-skill-tests.sh --verbose
```

### 自定义超时：
```bash
./run-skill-tests.sh --timeout 1800  # 30 分钟用于集成测试
```

## 测试结构

### test-helpers.sh
测试辅助函数：
- `run_claude "prompt" [timeout]` — 运行 Claude
- `assert_contains output pattern name` — 验证存在
- `assert_not_contains output pattern name` — 验证不存在
- `assert_count output pattern count name` — 验证精确数量
- `assert_order output pattern_a pattern_b name` — 验证顺序
- `create_test_project` — 创建临时目录
- `create_test_plan project_dir` — 创建示例计划文件

### 测试脚本列表

#### 快速测试（默认运行）

| 脚本 | 说明 | 耗时 |
|------|------|------|
| `test-subagent-driven-development.sh` | 验证技能内容和流程正确性 | ~2 分钟 |

#### 集成测试（使用 --integration）

| 脚本 | 说明 | 耗时 |
|------|------|------|
| `test-subagent-driven-development-integration.sh` | 完整工作流执行测试 | 10-30 分钟 |
| `test-requesting-code-review.sh` | 代码审查行为测试 | ~5 分钟 |

## 添加新测试

1. 创建 `test-<skill-name>.sh`
2. source test-helpers.sh
3. 使用 `run_claude` 和断言函数编写测试
4. 添加到 `run-skill-tests.sh` 的测试列表
5. `chmod +x test-<skill-name>.sh`

## CI/CD 集成

```bash
./run-skill-tests.sh --timeout 900
# 退出码 0 = 成功，非零 = 失败
```

## 注意

- 快速测试验证技能<strong>指令</strong>，不执行完整工作流
- 集成测试会调用真实的 Claude Code 会话
- 测试应具有确定性
- 避免测试实现细节
