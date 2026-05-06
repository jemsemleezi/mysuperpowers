---
name: diagnose
description: Disciplined debugging diagnosis loop. Use when encountering bugs, test failures, unexpected behavior, or performance regressions - before proposing fixes.
---

# Diagnose

> Merged from Superpowers (Obra) and Matt Pocock Skills.

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed root cause analysis, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The Phases

Complete each phase before proceeding to the next.

### Phase 0: Build a Feedback Loop

**This is the skill.** Everything else is mechanical. If you have a fast, deterministic, agent-runnable pass/fail signal for the bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume that signal. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

#### Ways to Construct a Loop

Try in roughly this order:

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimal subset of the system (one service, mocked deps) that exercises the bug code path with a single function call.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.
10. **HITL bash script.** Last resort. If a human must click, drive _them_ with a structured loop script so the loop is still repeatable. Captured output feeds back to you.

Build the right feedback loop, and the bug is 90% fixed.

#### Iterate on the Loop Itself

Treat the loop as a product. Once you have _a_ loop, ask:
- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

A 30-second flaky loop is barely better than no loop. A 2-second deterministic loop is a debugging superpower.

#### Non-Deterministic Bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the trigger 100×, parallelise, add stress, narrow timing windows, inject sleeps. A 50%-flake bug is debuggable; 1% is not — keep raising the rate until it's debuggable.

#### When You Genuinely Cannot Build a Loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it, (b) a captured artifact (HAR file, log dump, core dump, screen recording with timestamps), or (c) permission to add temporary production instrumentation. Do **not** proceed to hypothesise without a loop.

Do not proceed to Phase 1 until you have a loop you believe in.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Reproduce Consistently**
   - Run your Phase 0 loop. Watch the bug appear.
   - Can you trigger it reliably? What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess
   - [ ] The loop produces the failure mode the **user** described — not a different failure that happens to be nearby. Wrong bug = wrong fix.
   - [ ] You have captured the exact symptom (error message, wrong output, slow timing) so later phases can verify the fix actually addresses it.

2. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**
   - For each component boundary, log what data enters and exits
   - Verify environment/config propagation
   - Check state at each layer
   - Run once to gather evidence showing WHERE it breaks
   - THEN analyze evidence to identify failing component

5. **Trace Data Flow**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom
   - See @root-cause-tracing.md for the complete backward tracing technique

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY
   - Don't skim — read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis

**Scientific method with ranked hypotheses:**

1. **Generate 3–5 Ranked Hypotheses**
   - **Single-hypothesis generation anchors on the first plausible idea.** Force yourself to generate multiple.
   - Each hypothesis must be **falsifiable**: state the prediction it makes.
   - Format: *"If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."*
   - If you cannot state the prediction, the hypothesis is a vibe — discard or sharpen it.

2. **Show the Ranked List to the User**
   - They often have domain knowledge that re-ranks instantly ("we just deployed a change to #3"), or know hypotheses they've already ruled out.
   - Cheap checkpoint, big time saver.
   - Don't block on it — proceed with your ranking if the user is AFK.

3. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

4. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - **Change one variable at a time**
   - Don't fix multiple things at once

5. **Verify Before Continuing**
   - Did it work? Yes → proceed to fix
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

6. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

### Phase 4: Instrument + Fix

**Instrumentation:**

Each probe must map to a specific prediction from Phase 3.

Tool preference:
1. **Debugger / REPL inspection** if the env supports it. One breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`. Cleanup at the end becomes a single grep. Untagged logs survive; tagged logs die.

**Perf branch.** For performance regressions, logs are usually wrong. Instead: establish a baseline measurement (timing harness, `performance.now()`, profiler, query plan), then bisect. Measure first, fix second.

**Fix:**

1. **Write Regression Test BEFORE the Fix**
   - Only if there is a **correct seam** for it.
   - A correct seam is one where the test exercises the **real bug pattern** as it occurs at the call site.
   - If the only available seam is too shallow (unit test that can't replicate the chain that triggered the bug), a regression test there gives false confidence.
   - **If no correct seam exists, that itself is the finding.** Note it. The codebase architecture is preventing the bug from being locked down. Flag this.

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Regression test passes?
   - No other tests broken?
   - Re-run the Phase 0 feedback loop against the original (un-minimised) scenario.
   - Issue actually resolved?

4. **Apply defense-in-depth:** Add validation at multiple layers to make the bug structurally impossible. See @defense-in-depth.md.

5. **If Fix Doesn't Work**
   - STOP
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - **If ≥ 3: STOP and question the architecture**

6. **If 3+ Fixes Failed: Question Architecture**

   **Pattern indicating architectural problem:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   **Discuss with your human partner before attempting more fixes.**

   This is NOT a failed hypothesis — this is a wrong architecture.

### Phase 5: Cleanup + Post-Mortem

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 0 loop)
- [ ] Regression test passes (or absence of seam is documented)
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix)
- [ ] Throwaway prototypes deleted (or moved to a clearly-marked debug location)
- [ ] The hypothesis that turned out correct is stated in the commit / PR message — so the next debugger learns
- [ ] Defense-in-depth validation at each layer data passes through

**Then ask: what would have prevented this bug?** If the answer involves architectural change (no good test seam, tangled callers, hidden coupling), hand off to an architecture improvement skill with the specifics. Make the recommendation **after** the fix is in, not before — you have more information now than when you started.

## Supporting Techniques

These techniques are available in this directory:

- **@root-cause-tracing.md** — Trace bugs backward through call stack to find original trigger
- **@defense-in-depth.md** — Add validation at multiple layers after finding root cause
- **@condition-based-waiting.md** — Replace arbitrary timeouts with condition polling

**Related skills:**
- **mysuperpowers:tdd** — For writing failing test cases
- **mysuperpowers:verification-before-completion** — Verify fix works before claiming success

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **0. Feedback Loop** | Build fast, deterministic pass/fail signal | Can reproduce bug on demand |
| **1. Root Cause** | Read errors, reproduce, check changes, trace data | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Generate ranked list, test minimally | Confirmed or new hypothesis |
| **4. Instrument + Fix** | Create test, instrument, fix, verify | Bug resolved, tests pass |
| **5. Cleanup** | Remove instrumentation, regression test, post-mortem | Bug locked down |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |
| "I can fix it without a feedback loop" | Without a repro signal you're flying blind. Build the loop first. |
| "Just log everything and grep" | Targeted logs at hypothesis boundaries beat firehose every time. |

## Red Flags — STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 0 or Phase 1.**

**If 3+ fixes failed:** Question the architecture.

## When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.
