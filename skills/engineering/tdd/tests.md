# 好的测试与坏的测试

## 好的测试

**集成风格**：通过真实接口测试，而非内部组件的 mock。

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特征：

- 测试用户或调用者关心的行为
- 仅使用公共 API
- 内部重构时不会失效
- 描述「做什么」而非「怎么做」
- 每个测试仅包含一个逻辑断言

## 坏的测试

**实现细节测试**：与内部结构强耦合。

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危险信号：

- mock 内部协作组件
- 测试私有方法
- 断言调用次数或顺序
- 重构未改变行为时测试仍会失败
- 测试名称描述「怎么做」而非「做什么」
- 通过外部手段而非接口验证

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```
