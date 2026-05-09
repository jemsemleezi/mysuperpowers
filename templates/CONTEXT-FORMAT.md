# CONTEXT.md 格式模板

配合 grill-with-docs 技能使用。

# CONTEXT.md 格式

## 结构

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
A request from a customer to purchase goods or services.
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.
```

## 规则

- **观点明确。** 当同一概念有多个表述时，选择最合适的那个，将其余表述列为需避免的别名。
- **明确标记冲突。** 如果某个术语存在歧义，在「标记歧义」部分明确指出并给出明确解决方案。
- **定义简洁。** 最多一句话。定义它是什么，而非它做什么。
- **展示关联关系。** 使用加粗的术语名称，在显而易见的地方说明基数关系。
- **仅收录项目专属术语。** 通用编程概念（如超时、错误类型、工具函数模式）即使项目广泛使用也不应纳入。添加术语前请先确认：这是该上下文独有的概念，还是通用编程概念？仅前者符合要求。
- **按子标题分组术语** 当术语自然形成集群时，按子标题分组。如果所有术语都属于同一完整领域，使用平铺列表即可。
- **编写示例对话。** 一段开发者与领域专家之间的对话，展示术语如何自然交互，并厘清相关概念的边界。

## 单上下文与多上下文仓库

**单上下文（大多数仓库）：** 仓库根目录下仅保留一份 `CONTEXT.md`。

**多上下文：** 仓库根目录下的 `CONTEXT-MAP.md` 列出所有上下文、其存放位置及相互关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

技能会自动推断适用的结构：

- 若存在 `CONTEXT-MAP.md`，读取该文件以查找所有上下文
- 若仅存在根目录 `CONTEXT.md`，则为单上下文
- 若两者都不存在，在解析首个术语时惰性创建根目录 `CONTEXT.md`

当存在多个上下文时，推断当前主题属于哪个上下文。若不明确，请询问用户。
