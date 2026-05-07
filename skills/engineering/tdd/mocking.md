# 何时使用 Mock

仅在**系统边界**使用 mock：

- 外部 API（支付、邮件等）
- 数据库（优先使用测试数据库）
- 时间或随机数
- 文件系统（视情况）

不要 mock 以下内容：

- 自有类或模块
- 内部协作组件
- 任何你可控的组件

## 为可 mock 性设计接口

在系统边界处，设计易于 mock 的接口：

**1. 使用依赖注入**

传入外部依赖，而非在内部创建：

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 优先使用 SDK 风格接口，而非通用请求函数**

为每个外部操作创建专用函数，而非用一个带条件逻辑的通用函数：

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK 风格的优势：

- 每个 mock 返回固定结构
- 测试设置中无需条件逻辑
- 易于查看测试调用了哪些端点
- 每个端点有独立的类型安全
