# CC-Unreal-Studio -- Unreal Engine 5 Game Studio Agent Architecture

Indie game development on **Unreal Engine 5** managed through 39 coordinated
Claude Code subagents. Each agent owns a specific domain, enforcing separation
of concerns and quality.

## Technology Stack

- **Engine**: Unreal Engine 5.7
- **Language**: C++ (game logic, performance-critical systems) + Blueprint (rapid iteration, UI, prototyping)
- **Version Control**: Git with trunk-based development (Git LFS for binary assets)
- **Build System**: UnrealBuildTool (UBT); project files via `GenerateProjectFiles`
- **Asset Pipeline**: UE Editor authoring → UAT cooking → platform packaging

> **Note**: Unreal-specialist agents include `unreal-specialist` (lead) plus
> 4 sub-specialists: `ue-gas-specialist`, `ue-blueprint-specialist`,
> `ue-replication-specialist`, `ue-umg-specialist`.

## Project Structure

@.claude/docs/directory-structure.md

## Quick Lookup -- "I'm looking for ..."

| Looking for | Entry point |
|-------------|-------------|
| Project vision, pillars, core loop | `design/gdd/game-concept.md` |
| All systems + dependencies + priority tiers | `design/gdd/systems-index.md` |
| Specific system rules/formulas/edge cases | `design/gdd/<system>.md` (8-section GDD) |
| Architecture decisions (ADRs) | `docs/architecture/` |
| Agent roster + when to use which | `.claude/docs/agent-roster.md` |
| Who can delegate to whom + escalation | `.claude/docs/agent-coordination-map.md` |
| Phase-by-phase workflow (Concept -> Release) | `docs/WORKFLOW-GUIDE.md` |
| Atomic task -> exact command sequence | `.claude/docs/atomic-task-routing.md` |
| Slash commands by category | `.claude/docs/skills-reference.md` |
| UE 5.7 architecture & coding mental model (drift prevention) | `docs/engine-reference/unreal/ai-coding-guide.md` |
| UE 5.7 breaking changes / deprecated APIs | `docs/engine-reference/unreal/` |
| Path-scoped coding rules (e.g. `src/gameplay/`) | `.claude/rules/` |
| Current session state (ephemeral) | `production/session-state/active.md` |
| Sprint plans, milestones, releases | `production/` |

> **Decision principle**: when an answer can be derived from the file system, prefer reading the entry point above directly over asking. When the answer is a *judgment call* (scope, vision, priority), use the 5-step Collaborative Protocol.

## Engine Version Reference

@docs/engine-reference/unreal/VERSION.md

## UE 5.7 AI Coding Guide & Project Architecture

Always-loaded architectural mental model for drift prevention. Read this
before any non-trivial UE work — it governs WHAT to choose, project state,
layer/state ownership, intent routing, and pre-flight checks.

@docs/engine-reference/unreal/ai-coding-guide.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Atomic Task Routing

@.claude/docs/atomic-task-routing.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

> **Agent posture**: Agents are *design partners*, not executors. Before acting, consider:
> (a) ripple effects across systems (use `agent-coordination-map.md` "Cross-Domain Communication Protocols"),
> (b) whether a simpler approach exists,
> (c) whether the decision constrains future iteration.
> Reasoned options beat one-shot execution.
>
> **Use the right agent**: every domain has a designated owner (see `agent-roster.md`).
> Bypassing the hierarchy -- e.g. `gameplay-programmer` editing GAS files instead of consulting `ue-gas-specialist`,
> or any specialist editing files outside their delegated path -- silently breaks the
> path-scoped rules system, hook validation, and audit trail. When in doubt, ASK before acting.
> Atomic task -> agent mapping: see `.claude/docs/atomic-task-routing.md`.

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no game concept yet, run `/start` to
> begin the guided onboarding flow. The engine is already pinned to Unreal 5.7.

## Coding Standards

@.claude/docs/coding-standards.md

## LLM Coding Guidelines

@.claude/docs/andrej-karpathy-skills.md

## Context Management

@.claude/docs/context-management.md

## Git Conflict Resolution

When conflicts arise from `git stash pop`, `merge`, `rebase`, or `pull --rebase --autostash`,
**do not blanket-select with `--ours` or `--theirs`**. Read both sides (`HEAD` and
`Updated upstream`) and compare: does the discarded side contain useful logic, config,
or in-progress work that is missing from the other? Discarding without inspection
silently loses prior work -- including your own working-copy changes when `autostash`
pop fails.

When in doubt: stash, inspect, ASK. Manual 3-way merge is preferred over fast-but-lossy
resolution. This applies equally to design docs (GDDs, ADRs) -- a "conflicting" doc edit
often encodes a decision the other side missed.

## 환경 제약 (Environment Constraints)

- **크로스 플랫폼 호환**: 개발 환경은 Windows / macOS / Linux 모두 지원해야 한다. 빌드 설정·경로·스크립트에 특정 OS 경로를 하드코딩하지 않는다. OS별 설정이 필요하면 로컬 전용 파일로 분리한다.
- **WebSearch 우회**: WebSearch는 Vertex AI 조직 정책으로 **Opus에서 차단**된다. 웹 검색이 필요한 경우 `Agent` 도구에 `model="sonnet"`을 지정하여 sub-agent를 spawn한다. Sonnet agent는 WebSearch를 사용할 수 있으므로, Opus 메인 세션에서 검색이 필요한 작업(예: `/setup-engine refresh`, 외부 API 사양 조회 등)은 sonnet agent에 위임한다.
  - 패턴: `Agent({ model: "sonnet", subagent_type: "general-purpose", prompt: "검색해서 결과만 요약해서 리턴" })`
  - WebFetch는 Opus에서도 작동하지만, Epic Games 공식 docs (`docs.unrealengine.com`, `dev.epicgames.com`, `unrealengine.com/blog`)는 종종 HTTP 403을 반환한다. 이런 경우에도 sonnet agent의 WebSearch가 우회 경로가 된다.
