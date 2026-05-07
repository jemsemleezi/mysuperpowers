# 纵深防御验证

## 概述

修复无效数据导致的缺陷时，在单一位置添加验证似乎已经足够。但这层检查可能被不同的代码路径、重构或 mock 绕过。

**核心原则：** 在数据经过的每一层都添加验证。从结构上让缺陷无法发生。

## 为什么需要多层验证

单层验证：「我们修复了缺陷」
多层验证：「我们让缺陷不可能发生」

不同层捕获不同场景：
- 入口验证捕获大多数缺陷
- 业务逻辑捕获边缘情况
- 环境守卫防止特定上下文的危险操作
- 其他层失效时，调试日志可提供线索

## 四层防御

### 第1层：入口点验证
**目的：** 在 API 边界拒绝明显无效的输入

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### 第2层：业务逻辑验证
**目的：** 确保数据对该操作合理

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### 第3层：环境守卫
**目的：** 防止特定上下文中的危险操作

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

### 第4层：调试埋点
**目的：** 记录上下文用于问题排查

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## 应用模式

发现缺陷时：

1. **追溯数据流** - 无效值来自哪里？在哪里被使用？
2. **标记所有检查点** - 列出数据经过的每一个位置
3. **在每一层添加验证** - 入口、业务、环境、调试
4. **测试每一层** - 尝试绕过第1层，验证第2层能否捕获

## 会话案例

缺陷：空的 `projectDir` 导致在源代码目录执行 `git init`

**数据流：**
1. 测试初始化 → 空字符串
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` 在 `process.cwd()` 中执行

**添加的四层防御：**
- 第1层：`Project.create()` 验证非空/存在/可写
- 第2层：`WorkspaceManager` 验证 projectDir 非空
- 第3层：测试中 `WorktreeManager` 拒绝在 tmpdir 外执行 git init
- 第4层：git init 前记录堆栈跟踪

**结果：** 1847 个测试全部通过，缺陷无法复现

## 核心洞察

四层防御都是必要的。测试过程中，每一层都捕获了其他层遗漏的缺陷：
- 不同代码路径绕过了入口验证
- Mock 绕过了业务逻辑检查
- 不同平台的边缘情况需要环境守卫
- 调试日志定位了结构性误用

**不要止步于单一验证点。在每一层都添加检查。**
