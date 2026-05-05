# Engine Reference Documentation

This directory contains curated, version-pinned documentation snapshots for
**Unreal Engine 5**, the engine used in this project. These files exist because
**LLM knowledge has a cutoff date** and Unreal ships major updates regularly.

## Why This Exists

Claude's training data has a knowledge cutoff (currently May 2025). Unreal
Engine ships major updates (5.4 → 5.5 → 5.6 → 5.7 …) that introduce breaking
API changes, new features (Megalights, Substrate, production-ready PCG), and
deprecated patterns. Without these reference files, agents will suggest
outdated code.

## Structure

```
unreal/
├── VERSION.md              # Pinned UE version, verification date, knowledge gap window
├── breaking-changes.md     # API changes between UE versions, organized by risk level
├── deprecated-apis.md      # "Don't use X → Use Y" lookup tables
├── current-best-practices.md  # New practices not in model training data
├── PLUGINS.md              # Plugin index
├── modules/                # Per-subsystem quick references (~150 lines max each)
│   ├── rendering.md
│   ├── physics.md
│   └── ...
└── plugins/                # Per-plugin notes (GAS, CommonUI, PCG, etc.)
```

## How Agents Use These Files

Engine-specialist agents are instructed to:

1. Read `VERSION.md` to confirm the current engine version
2. Check `deprecated-apis.md` before suggesting any engine API
3. Consult `breaking-changes.md` for version-specific concerns
4. Read relevant `modules/*.md` for subsystem-specific work

## Maintenance

### When to Update

- After upgrading the engine version
- When the LLM model is updated (new knowledge cutoff)
- After running `/refresh-docs` (if available)
- When you discover an API the model gets wrong

### How to Update

1. Update `VERSION.md` with the new engine version and date
2. Add new entries to `breaking-changes.md` for the version transition
3. Move newly deprecated APIs into `deprecated-apis.md`
4. Update `current-best-practices.md` with new patterns
5. Update relevant `modules/*.md` with API changes
6. Set "Last verified" dates on all modified files

### Quality Rules

- Every file must have a "Last verified: YYYY-MM-DD" date
- Keep module files under 150 lines (context budget)
- Include code examples showing correct/incorrect patterns
- Link to official documentation URLs for verification
- Only document things that differ from the model's training data
