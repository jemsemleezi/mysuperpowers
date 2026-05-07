# 深模块

摘自《软件设计哲学》：

**深模块** = 小接口 + 大量实现

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
│                     │
└─────────────────────┘
```

**浅模块** = 大接口 + 少量实现（应避免）

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

设计接口时，问自己：

- 能否减少方法数量？
- 能否简化参数？
- 能否将更多复杂度隐藏在内部？
