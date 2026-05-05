# Skill Test Spec: /setup-engine

## Skill Summary

`/setup-engine` (Unreal-only fork) manages the pinned UE version and the
freshness of `docs/engine-reference/unreal/`. The engine itself is fixed at
fork time — there is no engine-selection step. The skill has three modes:

- No args → status check + interactive choice (refresh / upgrade / nothing)
- `refresh` → re-verify the docs against the currently pinned UE version
- `upgrade [old] [new]` → produce a migration plan and bump the pinned version

For any change to `docs/engine-reference/unreal/*`, `CLAUDE.md`, or
`technical-preferences.md`, the skill presents a draft and asks
"May I write…?" before writing. There are no director gates — this is a
technical configuration utility. The verdict is always COMPLETE when the
chosen mode finishes successfully.

---

## Static Assertions (Structural)

Verified automatically by `/skill-test static` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains "May I write" / "May I update" collaborative protocol language before edits
- [ ] Has a next-step handoff (e.g., note about regenerating project files / running smoke tests after an upgrade)

---

## Director Gate Checks

None. `/setup-engine` is a technical configuration skill. No director gates apply.

---

## Test Cases

### Case 1: Status check (no args) — Reports current pin, offers actions

**Fixture:**
- `docs/engine-reference/unreal/VERSION.md` exists with `Engine Version: Unreal Engine 5.7`
- No argument provided

**Input:** `/setup-engine`

**Expected behavior:**
1. Skill reads `VERSION.md` and prints engine version + last-verified date
2. Skill asks via `AskUserQuestion`: refresh / upgrade / do nothing
3. If user picks "do nothing" → exit cleanly, verdict COMPLETE
4. If user picks "refresh" → routes to Case 2 flow
5. If user picks "upgrade" → routes to Case 3 flow

**Assertions:**
- [ ] Skill does NOT prompt for engine selection (engine is pinned)
- [ ] Status output includes `Engine Version`, `Project Pinned`, `Last Docs Verified`
- [ ] User is given an explicit choice, not silently advanced
- [ ] Verdict is COMPLETE for the "do nothing" branch

---

### Case 2: Refresh mode — Re-verifies docs against pinned UE version

**Fixture:**
- `docs/engine-reference/unreal/` exists with VERSION pinned at UE 5.7
- `Last Docs Verified` date is older than today

**Input:** `/setup-engine refresh`

**Expected behavior:**
1. Skill reads all of `docs/engine-reference/unreal/`
2. Skill uses `WebSearch`/`WebFetch` to verify documented APIs against current UE 5.7 docs
3. Skill produces a drift summary (APIs that changed, new deprecations, new best practices)
4. Skill asks "May I update `docs/engine-reference/unreal/<file>` with these corrections?" for each affected file
5. On approval, writes corrections and updates `Last Docs Verified` date in `VERSION.md`

**Assertions:**
- [ ] Skill does NOT silently overwrite reference docs without showing the diff first
- [ ] Skill does NOT change the pinned `Engine Version` (refresh ≠ upgrade)
- [ ] `Last Docs Verified` date is updated to today after a successful refresh
- [ ] Verdict is COMPLETE

---

### Case 3: Upgrade mode — Produces migration plan + bumps pin

**Fixture:**
- `VERSION.md` pinned at UE 5.7
- Project source files exist under `Source/`

**Input:** `/setup-engine upgrade 5.7 5.8`

**Expected behavior:**
1. Skill produces a migration plan covering:
   - Breaking changes between 5.7 and 5.8 (sourced from official upgrading-projects docs)
   - New deprecations introduced in 5.8
   - New features the project may want to adopt
   - Plugin compatibility check (against `docs/engine-reference/unreal/PLUGINS.md`)
   - Project-specific impact (greps `Source/` for any flagged APIs)
2. Skill shows the plan to the user — does NOT touch any code
3. Skill asks "May I update `docs/engine-reference/unreal/VERSION.md` and the reference docs?"
4. On approval, writes:
   - Updated `VERSION.md` (Engine Version, Release Date, Project Pinned, Last Docs Verified)
   - Appended section in `breaking-changes.md` describing the 5.7 → 5.8 transition
   - Updated `CLAUDE.md` Technology Stack engine line
   - Updated `.claude/docs/technical-preferences.md` Engine line
5. Prints a follow-up checklist (regenerate project files, recompile, run smoke tests)

**Assertions:**
- [ ] Migration plan is shown BEFORE any file edits
- [ ] Skill does NOT modify any file under `Source/` or `Content/`
- [ ] After approval, all four files (VERSION.md, breaking-changes.md, CLAUDE.md, technical-preferences.md) reflect the new version
- [ ] Verdict is COMPLETE

---

### Case 4: Refusal — Out-of-domain "switch engine" request

**Fixture:**
- This fork is Unreal-only; user asks to switch to Godot

**Input:** `/setup-engine godot 4.6`

**Expected behavior:**
1. Skill recognises the engine argument as not-Unreal
2. Skill refuses cleanly: "This fork is Unreal Engine 5 only. To switch engines, use the upstream Donchitos/Claude-Code-Game-Studios template."
3. Skill does NOT modify any file
4. Verdict is COMPLETE (refusal is a successful outcome, not a failure)

**Assertions:**
- [ ] No file is written
- [ ] Refusal message references the upstream template
- [ ] Skill does NOT silently fall back to refresh / upgrade

---

### Case 5: Director gate check — No gate; setup-engine is a utility skill

**Fixture:**
- Any fixture

**Input:** `/setup-engine refresh`

**Expected behavior:**
1. Skill completes refresh
2. No director agents are spawned at any point
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is COMPLETE without any gate check

---

## Protocol Compliance

- [ ] Presents diff/plan before asking to write
- [ ] Asks "May I write/update …?" before any file edit
- [ ] Refuses non-Unreal engine arguments cleanly (does not pretend to support them)
- [ ] In upgrade mode, never modifies project source code — only reference docs and config
- [ ] Verdict is COMPLETE after the chosen mode finishes

---

## Coverage Notes

- Engine-selection-step removal vs upstream is intentional; this fork is
  Unreal-only and the skill no longer asks "which engine?"
- Per-UE-version performance budget defaults are surfaced by the skill in
  the migration plan but exact numeric defaults are not assertion-tested.
- Plugin compatibility checks against `PLUGINS.md` are exercised in Case 3
  but the per-plugin assertion list is not enumerated here.
