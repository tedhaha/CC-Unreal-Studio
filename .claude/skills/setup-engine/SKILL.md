---
name: setup-engine
description: "Refresh or upgrade the Unreal Engine reference docs. The engine itself is pinned to Unreal Engine 5 in this fork — this skill handles version refresh, upgrade migration plans, and rebuilding `docs/engine-reference/unreal/` from up-to-date sources."
argument-hint: "refresh | upgrade [old-version] [new-version] | no args for status check"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, Task, AskUserQuestion
---

When this skill is invoked:

## 0. Engine Is Already Pinned

This project is **Unreal Engine 5 only**. The engine choice was made at fork
time and is recorded in `CLAUDE.md` and `.claude/docs/technical-preferences.md`.

This skill no longer asks "which engine?" — it only manages the **version**
of Unreal you are pinned to and the freshness of the reference docs in
`docs/engine-reference/unreal/`.

If you want to switch to a different engine entirely, this is the wrong fork
of the template — see the upstream
[Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)
for the multi-engine version.

---

## 1. Parse Arguments

Three modes:

- **No args** (`/setup-engine`): show current pinned version + last-verified
  date and ask whether to refresh or upgrade.
- **`/setup-engine refresh`**: re-verify the docs against the currently
  pinned version (Section 3).
- **`/setup-engine upgrade [old-version] [new-version]`**: produce a
  migration plan and update the pinned version (Section 4).

---

## 2. Status Check (No Args)

1. Read `docs/engine-reference/unreal/VERSION.md`.
2. Print the **Engine Version**, **Project Pinned**, **Last Docs Verified**
   dates, and a short summary of post-cutoff versions.
3. Ask via `AskUserQuestion`:
   - `Refresh current version docs` — re-check the docs are current
   - `Upgrade to a newer UE version` — migration plan + version bump
   - `Just show status, do nothing else` — exit

Route to Section 3 or Section 4 based on the answer.

---

## 3. Refresh Mode

Re-verify the docs in `docs/engine-reference/unreal/` against the currently
pinned version.

1. Read all of `docs/engine-reference/unreal/`:
   - `VERSION.md`, `breaking-changes.md`, `current-best-practices.md`,
     `deprecated-apis.md`, `PLUGINS.md`
   - `modules/*.md`
   - `plugins/*.md`
2. For each file, use `WebSearch` / `WebFetch` to confirm the documented
   APIs against current Unreal docs (https://docs.unrealengine.com/<version>/).
3. Flag any drift: APIs that have changed, new deprecations, or new best
   practices since "Last verified".
4. Show the user a summary diff before proposing edits.
5. **Always ask** before writing: "May I update `docs/engine-reference/unreal/<file>` with these corrections?"
6. Update the `Last Docs Verified` date in `VERSION.md` after a successful refresh.

---

## 4. Upgrade Mode

Migrate from one UE version to another.

Arguments: `[old-version] [new-version]` (e.g. `5.7 5.8`).

If the user did not provide both, ask via `AskUserQuestion` which version they
are upgrading from and to. Use the latest stable release as a hint via
`WebSearch` if needed.

### Migration plan structure

Produce a plan covering:

1. **Breaking changes** — list every API removal / signature change between
   the two versions, grouped by subsystem (Animation, Rendering, GAS, etc.).
   Source from the official "Upgrading projects" page at
   `https://docs.unrealengine.com/<new-version>/en-US/upgrading-projects/`.
2. **Deprecations introduced** — APIs that still work but should be migrated.
3. **New features** that the project may want to adopt (Substrate, Megalights,
   PCG updates, etc.).
4. **Plugin compatibility** — review `docs/engine-reference/unreal/PLUGINS.md`
   and check whether each enabled plugin supports the new version.
5. **Project-specific impact** — grep the codebase for any APIs flagged in
   step 1 and produce a file-by-file impact list.

### Execution

1. Show the migration plan to the user. **Do not edit any code.**
2. Ask: "May I update `docs/engine-reference/unreal/VERSION.md` and the
   reference docs to reflect UE `<new-version>`?"
3. On approval:
   - Update `VERSION.md` (Engine Version, Release Date, Project Pinned, Last Docs Verified)
   - Append a new section to `breaking-changes.md` describing the transition
   - Update `current-best-practices.md` and `deprecated-apis.md`
   - Update affected `modules/*.md` and `plugins/*.md`
4. Update `CLAUDE.md` Technology Stack line `**Engine**: Unreal Engine <new-version>`.
5. Update `.claude/docs/technical-preferences.md` Engine line.
6. Print a checklist of follow-up actions for the user (regenerate project
   files via `GenerateProjectFiles`, recompile, run smoke tests, etc.).

---

## 5. Knowledge Cutoff Reminder

The LLM's training data has a cutoff date that may be earlier than the
currently pinned UE version. **Always trust the reference docs in
`docs/engine-reference/unreal/` over your training memory** when there is a
conflict — and when in doubt, fetch the official documentation via
`WebFetch` rather than answering from memory.

---

## 6. What This Skill Does NOT Do

- It does **not** install or download Unreal Engine — that is a manual user step.
- It does **not** modify project source code (`Source/**`, `Content/**`).
  Code migration is handled by `dev-story` once the migration plan is approved.
- It does **not** switch engines. This fork is Unreal-only.
