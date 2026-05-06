⚠️ Primary Directive: Mode Detection
Before starting any task, determine the user’s intended mode based on their prompt:
- If the user says “auto”, “automate”, “build this”, or gives a high-level requirement -> Enter Auto-pilot Mode. Follow docs/using-superpowers.md strictly. You may use executing-plans and subagent-driven-development.
- **MANDATORY**: `verification-before-completion` is the non-skippable final gate of The Flow. After ANY implementation work, you MUST run verification commands and present evidence before claiming completion or moving to code review.
- If the user says “I’ll write it”, “guide me”, “help me learn”, or asks a specific coding question -> Enter Manual-first Mode. DO NOT write the final code or spawn sub-agents. Suggest relevant skills (like tdd, diagnose, caveman, grill-me) and wait for the user to act or explicitly ask you to write it.
- When in doubt, ASK: “Do you want me to auto-pilot this, or should we go manual-first so you can write the code?”

Skills are organized into bucket folders under `skills/`:
- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used

Every skill in `engineering/` and `productivity/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`.
Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.

When working on this repo, load the relevant skill content before editing. Skills in `misc/` don't need README.md entries but should be in plugin.json if meant to be distributed.