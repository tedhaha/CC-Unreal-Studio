# Atomic Task Routing -- "I want to ..."

> Companion to `WORKFLOW-GUIDE.md` (7-phase lifecycle) and
> `agent-coordination-map.md` (Patterns 1-9 process flows).
> This file maps **single concrete actions** to the shortest reliable
> command + agent sequence.

## Why this file exists

In a 39-agent + 72-skill + 12-hook + 11-rule system, **the cost of taking
the wrong path is asymmetric**: one bypassed handoff can silently
invalidate hours of downstream work. Examples of harm we are guarding
against:

- A `gameplay-programmer` edits GAS files directly -> `ue-gas-specialist`
  domain knowledge skipped, prediction/replication subtleties missed,
  bug surfaces in multiplayer 3 sprints later.
- Direct `git commit` of a balance change without `/quick-design` ->
  hardcoded value lands in source, `validate-commit.sh` blocks push,
  and the change is never linked to a design intent.
- Skipping `/design-review` for a new system -> 8-section GDD missing
  required sections, dependent systems built on incomplete spec,
  `/review-all-gdds` later flags contradictions across 4+ documents.
- Editing `src/gameplay/` files without consulting the path-scoped rule
  in `.claude/rules/` -> rule violation lands in code, lead-programmer
  re-review burden in next code review.

This file does NOT replace judgment. It encodes **the canonical path
for routine atomic tasks** so that the question "did I follow the
right sequence?" has a deterministic answer.

## How to use

1. Find your task in the table below.
2. Run the sequence exactly as listed.
3. If your task is not in the table, fall back to:
   - `WORKFLOW-GUIDE.md` for phase-aligned planning
   - `agent-coordination-map.md` Patterns 1-9 for cross-department flows
   - `agent-roster.md` to identify the correct owner, then ASK before acting.

## Routing Table

| I want to ... | Sequence | Critical owner | Wrong-path harm |
|---------------|----------|----------------|-----------------|
| Add a new GAS Ability | `/dev-story` -> `ue-gas-specialist` consultation -> `gameplay-programmer` impl -> `/code-review` -> `/test-evidence-review` | `ue-gas-specialist` | Prediction/replication regression in MP, attribute set drift |
| Refactor a Blueprint graph | `ue-blueprint-specialist` audit -> `lead-programmer` review of plan -> impl -> `/code-review` | `ue-blueprint-specialist` | BP/C++ boundary violation, graph standards drift |
| Diagnose a replication bug | `/bug-report` -> `ue-replication-specialist` repro -> `network-programmer` fix -> `/regression-suite` (multiplayer slice) | `ue-replication-specialist` | Bandwidth/relevancy regression, prediction desync |
| Build a UMG screen | `/ux-design` (if new flow) -> `ue-umg-specialist` widget plan -> `ui-programmer` impl -> `/design-review` for visual QA | `ue-umg-specialist` | CommonUI input handling break, widget hierarchy drift |
| Tune a balance value | `/quick-design "<change>"` -> data file edit -> `qa-tester` regression -> `analytics-engineer` post-monitor | `economy-designer` (review) | Hardcoded value, no design intent linkage, `validate-commit.sh` block |
| Add a new system | `/map-systems next` (or `/design-system <name>`) -> 8-section GDD -> `/design-review` -> `/review-all-gdds` -> impl -> `/gate-check` | `game-designer` | Cross-system contradictions surface only at `/review-all-gdds` after multiple impls |
| Cut a release | `/release-checklist` -> `qa-lead` regression sign-off -> `release-manager` build+tag -> `/changelog` -> deploy + 48h monitor | `release-manager` | Untested regression in shipped build, missing changelog entry |
| Profile a performance issue | `/perf-profile` -> `performance-analyst` triage -> `technical-director` if architectural -> impl -> re-profile | `performance-analyst` | Premature optimization, missed root cause, budget violation undocumented |
| Investigate a crash | `production/session-logs/` recent -> `qa-tester` repro -> `lead-programmer` root-cause -> fix -> regression | `lead-programmer` | Symptom-only fix, root cause re-surfaces |
| Resume after compaction | Read `production/session-state/active.md` + diff of files since last checkpoint | (self) | Lost context, redundant re-exploration of already-decided design |
| Onboard a new contributor | `/start` (Path D2 if existing project) -> `/project-stage-detect` -> `/adopt` if brownfield | `producer` | Skipping `/adopt` -> agents miss existing GDDs/ADRs, propose duplicates |
| Add an asset (art/audio/vfx) | `/asset-spec` -> author asset -> `validate-assets.sh` (auto on commit) -> `/asset-audit` periodically | `art-director` or `audio-director` | Naming/structure violation, build pipeline failure downstream |

## When NOT to use this file

- **Planning a new project phase** -> use `docs/WORKFLOW-GUIDE.md` (7-phase pipeline + gates)
- **Multi-department orchestration** (full release, level launch, live event) -> use Patterns 1-9 in `agent-coordination-map.md`
- **Selecting which agent to invoke** when task is novel -> use `.claude/docs/agent-roster.md` first, then ASK
- **Conflict resolution** -> escalation paths in `agent-coordination-map.md`, NOT a row here

## Anti-patterns (do not do this)

1. **Skipping the critical owner column** -- the listed owner is not optional. If you cannot consult them, ASK before proceeding.
2. **Inventing a shorter sequence** -- if a sequence feels too long, raise it as a process improvement to `producer`, do not silently shortcut.
3. **Adding rows for one-off tasks** -- this file holds *recurring* atomic tasks only. Single-use sequences belong in the phase narrative.
4. **Using this file when the task is a judgment call** -- routing tables answer *how*, not *whether*. New systems, scope changes, vision pivots use the 5-step Collaborative Protocol.

## Update rule

Add a row when a new atomic task pattern is observed **3+ times** across
session logs (`production/session-logs/`). Single-use sequences belong in
the WORKFLOW-GUIDE phase narrative, not here. Keep this file under
**30 rows** -- if it grows past that, split by domain (gameplay-routing.md,
art-routing.md, etc.) rather than diluting the signal.

When adding, include all four columns. The "Wrong-path harm" column is
not optional -- it is the justification for the row's existence.
