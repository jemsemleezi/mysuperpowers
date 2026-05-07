# 可测试性的接口设计

良好的接口让测试更自然：

1. **接收依赖，而非自行创建**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
      const gateway = new StripeGateway();
   }
   ```

2. **返回结果，而非产生副作用**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
      cart.total -= discount;
   }
   ```

3. **接口表面积小**
   - 方法越少，所需测试越少
   - 参数越少，测试设置越简单
