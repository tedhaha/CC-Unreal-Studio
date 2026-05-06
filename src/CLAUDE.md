# Source Directory

When writing or editing game code in this directory, follow these standards.

## Engine Version Warning

The LLM's training data predates the pinned engine version.
**Always check `docs/engine-reference/` before using any engine API.**
Do not guess at post-cutoff API signatures — look them up first.

Quick reference order before writing engine code:

1. `docs/engine-reference/unreal/ai-coding-guide.md` — auto-loaded; covers
   WHAT to choose (intent routing, layer/state ownership, forbidden patterns,
   pre-flight checks). Already in your context.
2. `docs/engine-reference/unreal/current-best-practices.md` — HOW to write
   the code (UE 5.7 patterns + snippets). Read on-demand before generating.
3. `docs/engine-reference/unreal/modules/[area].md` and `plugins/[name].md` —
   per-area API specifics for the system you're touching.
4. `docs/engine-reference/unreal/deprecated-apis.md` — verify you're not
   using anything removed/superseded in 5.7.

## Coding Standards

- All public APIs require doc comments
- Gameplay values must be **data-driven** (external config files), never hardcoded
- Prefer dependency injection over singletons for testability
- Every new system needs a corresponding ADR in `docs/architecture/`
- Commits must reference the relevant story ID or design document

## File Routing

Match the engine-specialist agent to the file type being written.
See `CLAUDE.md` → Technical Preferences → Engine Specialists → File Extension Routing.

When in doubt, use the primary engine specialist configured in `CLAUDE.md`.

## Tests

Tests live in `tests/` — not in `src/`.
Run `/test-setup` to scaffold the test framework if it doesn't exist yet.
Every gameplay system should have unit tests covering its formulas and edge cases.

## Verification-Driven Development

Write tests first when adding gameplay systems.
For UI changes, verify with screenshots.
Compare expected output to actual output before marking work complete.
