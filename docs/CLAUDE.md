# Docs Directory

When authoring or editing files in this directory, follow these standards.

## Architecture Decision Records (`docs/architecture/`)

Use the ADR template: `.claude/docs/templates/architecture-decision-record.md`

**Required sections:** Title, Status, Context, Decision, Consequences,
ADR Dependencies, Engine Compatibility, GDD Requirements Addressed

**Status lifecycle:** `Proposed` → `Accepted` → `Superseded`
- Never skip `Accepted` — stories referencing a `Proposed` ADR are auto-blocked
- Use `/architecture-decision` to create ADRs through the guided flow

**TR Registry:** `docs/architecture/tr-registry.yaml`
- Stable requirement IDs (e.g. `TR-MOV-001`) that link GDD requirements to stories
- Never renumber existing IDs — only append new ones
- Updated by `/architecture-review` Phase 8

**Control Manifest:** `docs/architecture/control-manifest.md`
- Flat programmer rules sheet: Required / Forbidden / Guardrails per layer
- Date-stamped `Manifest Version:` in header
- Stories embed this version; `/story-done` checks for staleness

**Validation:** Run `/architecture-review` after completing a set of ADRs.

## Engine Reference (`docs/engine-reference/`)

Version-pinned engine API snapshots. **Always check here before using any
engine API** — the LLM's training data predates the pinned engine version.

Key files (UE 5.7):

| File | Role | Loaded |
|---|---|---|
| `unreal/VERSION.md` | Pinned version, knowledge gaps, verification dates | Always (root CLAUDE.md `@`-import) |
| `unreal/ai-coding-guide.md` | AI architecture mental model, intent routing, drift prevention | Always (root CLAUDE.md `@`-import) |
| `unreal/current-best-practices.md` | UE 5.7 code patterns + snippets (HOW to write code) | On-demand (read before generating engine code) |
| `unreal/learning-roadmap.md` | Human study guide (URLs, courses, Lyra path) | On-demand (rarely needed by AI) |
| `unreal/PLUGINS.md` | Per-plugin status (production / beta / experimental) | On-demand |
| `unreal/breaking-changes.md` | UE 5.3 → 5.7 breaking changes | On-demand |
| `unreal/deprecated-apis.md` | APIs to avoid + replacements | On-demand |
| `unreal/modules/*.md` | Per-area API references (animation, audio, input, etc.) | On-demand |
| `unreal/plugins/*.md` | Per-plugin deep references (GAS, CommonUI, PCG, etc.) | On-demand |

Current engine: see `unreal/VERSION.md` (pinned at Unreal Engine 5.x — this fork is UE5-only).
