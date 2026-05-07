# 领域文档

MySuperPowers 技能在探索代码库时，应如何查阅本仓库的领域文档。

## 探索前请先阅读以下内容

- 仓库根目录下的 **`CONTEXT.md`**，或
- 若存在根目录下的 **`CONTEXT-MAP.md`**，则读取该文件——它会指向每个上下文对应的 `CONTEXT.md`，请阅读与主题相关的所有文件。
- **`docs/adr/`** —— 阅读涉及你即将工作的区域的架构决策记录（ADR）。在多上下文仓库中，还需检查 `src/<context>/docs/adr/` 下的上下文级决策。

若上述文件不存在，**请静默继续**。不要提示缺失，也不要建议提前创建。生产者技能（`/grill-with-docs`）会在术语或决策实际确定后按需创建这些文件。

## 文件结构

单上下文仓库（大多数仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文仓库（根目录存在 `CONTEXT-MAP.md`）：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← 系统级决策
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← 上下文级决策
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 使用术语表的词汇

当你的输出涉及领域概念时（例如问题标题、重构提案、假设、测试名称），请使用 `CONTEXT.md` 中定义的术语。不要使用术语表明确排除的同义词。

若你需要的概念尚未收录在术语表中，这是一个信号：要么你在创造项目不使用的表述（请重新考虑），要么确实存在缺口（请记录并反馈给 `/grill-with-docs`）。

## 标记 ADR 冲突

若你的输出与现有 ADR 冲突，请明确说明，不要静默覆盖：

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_

---

*本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。*
