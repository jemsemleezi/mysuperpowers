# 测试反模式

**加载本参考文档的时机：** 编写或修改测试、添加 mock，或想在生产代码中添加仅测试用的方法时。

## 概述

测试必须验证真实行为，而非 mock 的行为。Mock 是隔离手段，而非测试对象。

**核心原则：** 测试代码的实际行为，而非 mock 的行为。

**遵循严格的 TDD 可避免这些反模式。**

## 铁律

```
1. NEVER test mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding dependencies
```

## 反模式 1：测试 Mock 行为

**违规行为：**

```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**错误原因：**
- 你验证的是 mock 是否有效，而非组件是否有效
- mock 存在时测试通过，不存在时失败
- 无法反映真实行为

**你的人类伙伴的纠正：** “我们是在测试 mock 的行为吗？”

**修复方法：**

```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

### 门控函数

```
BEFORE asserting on any mock element:
  Ask: "Am I testing real component behavior or just mock existence?"

  IF testing mock existence:
    STOP - Delete the assertion or unmock the component

  Test real behavior instead
```

## 反模式 2：生产代码中的仅测试用方法

**违规行为：**

```typescript
// ❌ BAD: destroy() only used in tests
class Session {
  async destroy() {  // Looks like production API!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... cleanup
  }
}

// In tests
afterEach(() => session.destroy());
```

**错误原因：**
- 生产类被仅测试用的代码污染
- 生产环境中误调用会有风险
- 违反 YAGNI 原则和关注点分离
- 混淆对象生命周期与实体生命周期

**修复方法：**

```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() - it's stateless in production

// In test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In tests
afterEach(() => cleanupSession(session));
```

### 门控函数

```
BEFORE adding any method to production class:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Don't add it
    Put it in test utilities instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## 反模式 3：不理解依赖就 Mock

**违规行为：**

```typescript
// ❌ BAD: Mock breaks test logic
test('detects duplicate server', () => {
  // Mock prevents config write that test depends on!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // Should throw - but won't!
});
```

**错误原因：**
- Mock 的方法有测试依赖的副作用（写入配置）
- 为了“安全”过度 mock 会破坏实际行为
- 测试因错误原因通过，或无故失败

**修复方法：**

```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager');  // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

### 门控函数

```
BEFORE mocking any method:
  STOP - Don't mock yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects?"
  3. Ask: "Do I fully understand what this test needs?"

  IF depends on side effects:
    Mock at lower level (the actual slow/external operation)
    OR use test doubles that preserve necessary behavior
    NOT the high-level method the test depends on

  IF unsure what test depends on:
    Run test with real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal mocking at the right level

  Red flags:
    - "I'll mock this to be safe"
    - "This might be slow, better mock it"
    - Mocking without understanding the dependency chain
```

## 反模式 4：不完整的 Mock

**违规行为：**

```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```
**错误原因：**

- **部分 mock 隐藏结构假设**，你只 mock 了已知的字段
- **下游代码可能依赖你未包含的字段**，静默失败
- **测试通过但集成失败**，mock 不完整，真实 API 完整
- **虚假信心**，测试无法证明真实行为

**铁律：** Mock 必须完整反映真实存在的数据结构，而非仅你当前测试用到的字段。

**修复方法：**

```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

### 门控函数

```
BEFORE creating mock responses:
  Check: "What fields does the real API response contain?"

  Actions:
    1. Examine actual API response from docs/examples
    2. Include ALL fields system might consume downstream
    3. Verify mock matches real response schema completely

  Critical:
    If you're creating a mock, you must understand the ENTIRE structure
    Partial mocks fail silently when code depends on omitted fields

  If uncertain: Include all documented fields
```

## 反模式 5：集成测试作为事后补充

**违规行为：**

```
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

**错误原因：**
- 测试是实现的一部分，而非可选的后置步骤
- TDD 本可避免这种情况
- 没有测试就不能宣称完成

**修复方法：**

```
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete
```

## 当 Mock 过于复杂时

**警告信号：**
- Mock 设置比测试逻辑还长
- 为了测试通过 mock 所有内容
- Mock 缺少真实组件有的方法
- Mock 变更时测试失败

**你的人类伙伴的疑问：** “我们真的需要在这里用 mock 吗？”

**考虑：** 使用真实组件的集成测试往往比复杂的 mock 更简单。

## TDD 可避免这些反模式

**TDD 的作用：**
1. **先写测试** → 迫使你思考实际要测试什么
2. **观察测试失败** → 确认测试验证的是真实行为，而非 mock
3. **最小化实现** → 不会出现仅测试用的方法
4. **真实依赖** → 在 mock 前明确测试的实际需求

**如果你在测试 mock 行为，说明你违反了 TDD**，你没先观察测试对真实代码失败就添加了 mock。

## 快速参考

| 反模式 | 修复方法 |
|--------------|-----|
| 对 mock 元素断言 | 测试真实组件或取消 mock |
| 生产代码中的仅测试用方法 | 移到测试工具中 |
| 不理解依赖就 Mock | 先理解依赖，最小化 mock |
| 不完整的 Mock | 完整镜像真实 API |
| 测试作为事后想法 | TDD，先写测试 |
| 过于复杂的 Mock | 考虑集成测试 |

## 危险信号

- 断言检查 `*-mock` 测试 ID
- 仅在测试文件中调用的方法
- Mock 设置占测试 50% 以上
- 移除 mock 后测试失败
- 无法解释为何需要 mock
- 为了“安全”而 mock

## 核心结论

**Mock 是隔离工具，而非测试对象。**

如果 TDD 暴露你在测试 mock 行为，说明你走偏了。

**修复：测试真实行为，或反思为何要 mock。**
