# 术语规范

本技能所有建议使用的共享术语表。请严格使用以下术语，不得替换为“组件”“服务”“API”或“边界”。保持术语一致性是核心目标。

## 术语定义

**Module**
指任何包含接口（interface）和实现（implementation）的单元。刻意保持规模无关性——可同等适用于函数、类、包或跨层级的切片。
_避免使用_：unit、component、service。

**Interface**
调用方正确使用该 module 所需知晓的全部信息。包括类型签名，以及不变量、顺序约束、错误模式、所需配置和性能特征。
_避免使用_：API、signature（范围过窄——仅指代类型层面的表面定义）。

**Implementation**
指 module 内部的代码主体。与 **Adapter** 不同：一个 adapter 可以是小 adapter 配大 implementation（如 Postgres 仓库），也可以是大 adapter 配小 implementation（如内存 fake）。讨论 seam 时优先使用“adapter”，其他情况使用“implementation”。

**Depth**
接口层面的杠杆效应——调用方（或测试）每学习一个单位的接口所能调用的行为量。若大量行为隐藏在小接口之后，则该 module 为**深模块（deep）**；若接口复杂度与 implementation 相当，则为**浅模块（shallow）**。

**Seam** _(源自 Michael Feathers)_
指可在不修改该处代码的前提下改变行为的位置。即 module 接口所在的*位置*。选择 seam 的放置位置是独立的设计决策，与接口背后的实现无关。
_避免使用_：boundary（与 DDD 的限界上下文含义冲突，存在重载）。

**Adapter**
指在 seam 处满足接口的具体实现。描述*角色*（填充的插槽），而非实质内容（内部实现）。

**Leverage**
调用方从深度（depth）中获得的收益。每学习一个单位的接口可获得更多能力。一个 implementation 可在 N 个调用点和 M 个测试中复用。

**Locality**
维护方从深度（depth）中获得的收益。变更、缺陷、知识和验证都集中在单一位置，而非分散到各个调用方。一次修复，全局生效。

## 设计原则

- **深度（Depth）是接口的属性，而非实现的属性。** 深模块内部可以由小的、可 mock、可替换的部件组成——这些部件只是不属于接口的一部分。一个 module 可以同时拥有**内部 seam**（仅实现内部可见，供自身测试使用）和接口处的**外部 seam**。
- **删除测试。** 想象删除该 module。若复杂度随之消失，说明该 module 没有隐藏任何内容（只是透传层）。若复杂度分散到 N 个调用方，说明该 module 发挥了价值。
- **接口即测试面。** 调用方和测试都通过同一个 seam。若你需要测试*越过*接口的内容，说明该 module 的设计形状可能有误。
- **一个 adapter 意味着假设性 seam，两个 adapter 意味着真实 seam。** 除非确实有变化跨越 seam，否则不要引入 seam。

## 术语关系

- 一个 **Module** 有且仅有一个 **Interface**（面向调用方和测试暴露的表面）。
- **Depth** 是 **Module** 的属性，通过其 **Interface** 衡量。
- **Seam** 是 **Module** 的 **Interface** 所在的位置。
- **Adapter** 位于 **Seam** 处，满足 **Interface** 的要求。
- **Depth** 为调用方带来 **Leverage**，为维护方带来 **Locality**。

## 不采纳的定义方式

- **将深度定义为实现行数与接口行数的比值**（Ousterhout）：会鼓励无意义地扩充实现。我们采用“深度即杠杆效应”的定义。
- **将“Interface”等同于 TypeScript 的 `interface` 关键字或类的公共方法**：范围过窄——此处的 interface 包含调用方必须知晓的所有信息。
- **“Boundary”**：与 DDD 的限界上下文含义冲突，存在重载。请使用 **seam** 或 **interface**。

---

*本技能源自 Matt Pocock Skills，已针对 MySuperPowers 适配。*
