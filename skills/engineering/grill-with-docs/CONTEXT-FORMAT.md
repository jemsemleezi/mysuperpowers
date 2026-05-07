# CONTEXT.md 格式

## 结构

```md
# {上下文名称}

{一两句描述说明这个上下文是什么以及为何存在。}

## Language

**Order**：
{该术语的简洁描述}
_Avoid_：Purchase, transaction

**Invoice**：
交付后发送给客户的付款请求。
_Avoid_：Bill, payment request

**Customer**：
下订单的个人或组织。
_Avoid_：Client, buyer, account

## Relationships

- 一个 **Order** 产生一个或多个 **Invoice**
- 一个 **Invoice** 属于恰好一个 **Customer**

## Example dialogue

> **Dev：** "当 **Customer** 下了 **Order**，我们立即创建 **Invoice** 吗？"
> **Domain expert：** "不——只有在 **Fulfillment** 确认后才生成 **Invoice**。"

## Flagged ambiguities

- "account" 被同时用于表示 **Customer** 和 **User**——已解决：这是两个不同的概念。
```

## 规则

- **要有主见。** 当同一概念有多个词汇时，选择最好的一个，将其余列为应避免的别名。
- **明确标记冲突。** 如果某个术语使用模糊，在"Flagged ambiguities"中指出并给出明确的解决方案。
- **保持定义紧凑。** 最多一句话。定义它 **是什么**，而非它做什么。
- **展示关系。** 使用加粗术语名并在明显时表达基数。
- **仅包含此项目上下文特有的术语。** 通用编程概念（超时、错误类型、工具模式）不属于这里，即使项目广泛使用它们。在添加术语之前问：这是此上下文独有的概念，还是通用编程概念？只有前者属于这里。
- **在自然聚类出现时将术语分组到子标题下。** 如果所有术语属于一个凝聚的区域，平面列表即可。
- **编写示例对话。** 一段开发者与领域专家之间的对话，展示术语如何自然交互并澄清相关概念之间的边界。

## 单上下文 vs 多上下文仓库

**单上下文（大多数仓库）：** 仓库根目录一个 `CONTEXT.md`。

**多上下文：** 仓库根目录一个 `CONTEXT-MAP.md`，列出上下文、它们的位置，以及它们之间的关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) —— 接收并跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) —— 生成发票并处理付款
- [Fulfillment](./src/fulfillment/CONTEXT.md) —— 管理仓库拣货和发货

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费它们以开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费它们以生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 和 `Money` 类型
```

技能推断适用哪种结构：

- 如果存在 `CONTEXT-MAP.md`，阅读它以找到上下文
- 如果只有根目录 `CONTEXT.md`，单上下文
- 如果都不存在，在第一个术语被确定时惰性创建根目录 `CONTEXT.md`

当存在多个上下文时，推断当前话题与哪个上下文相关。如果不清楚，询问。

---

*本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。*
