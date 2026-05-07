# 代码质量审查员提示词模板

分派代码质量审查员子代理时，请使用此模板。

**用途：** 核实实现是否构建良好（代码整洁、经过测试、易于维护）

**仅在规格合规审查通过后分派。**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**除标准代码质量问题外，审查员还需检查：**
- 每个文件是否职责单一，且接口定义清晰？
- 单元拆分是否合理，能否独立理解和测试？
- 实现是否遵循计划中的文件结构？
- 本次实现是否创建了体积过大的新文件，或显著增大了现有文件？（无需标记原有文件的体积问题，仅关注本次变更的影响。）

**代码审查员返回内容：** 优点、问题（严重/重要/次要）、评估结论
