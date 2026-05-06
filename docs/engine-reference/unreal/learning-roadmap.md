# UE 5.7 Learning Roadmap (Human Study Guide)

**Last verified**: 2026-05-06
**Audience**: Software engineer, new to Unreal, learning UE 5.7 in 2026

> **This file is for human reading.** AI conditioning lives in `ai-coding-guide.md`.
> AI may consult this file when the user asks about learning materials, but it
> is not auto-loaded into every session.

---

## How to Use This Guide

1. Phases 1–4 are sequential **for the human student**. Don't skip ahead.
2. Phase 3 (subsystems) is studied **in parallel with Phase 2** (Lyra) — Lyra
   is your reference implementation while reading subsystem docs.
3. Phase 4 is on-demand: read only when you actually need that feature.
4. Each entry is annotated:
   - **AI-accessible**: `Yes` (text-heavy docs, AI can WebFetch), `Partial`
     (mixed text/video), `No` (video-only)
   - **Time**: rough human reading/study estimate
5. When you find a great Epic blog or community deep-dive worth keeping for AI
   reference, add it to `ai-coding-guide.md` Section 25 cross-references.

---

## Phase 1: Foundation (1~2 weeks)

Goal: get the editor in your hands, build something trivial, understand the
five core concepts (Actor / Component / GameMode / PlayerController / World).

| # | Name | URL | Time | AI-accessible | Why |
|---|---|---|---|---|---|
| 1 | **2025 Crash Course for New Unreal Engine Developers** ⭐ | https://dev.epicgames.com/community/learning/paths/Yaz/2025-crash-course-for-new-unreal-engine-developers | 4–6 h | Partial (video + slides) | GDC 2025 by Matt Oztalay — explicitly targets developers switching to Unreal in 2025. Best single starting point for software engineers. |
| 2 | **Understanding the Basics of Unreal Engine** | https://dev.epicgames.com/documentation/en-us/unreal-engine/understanding-the-basics-of-unreal-engine | 3–4 h | Yes | Conceptual foundations: Actors, Components, Levels, World, Game framework. Read before touching the editor. |
| 3 | **UE 5.7 Starter Course** | https://dev.epicgames.com/community/learning/tutorials/bE7Z/unreal-engine-5-7-starter-course | 2–3 h | Partial | 5.7-specific editor workflow, scene setup, packaging. |
| 4 | **Getting Started Guide** | https://dev.epicgames.com/documentation/en-us/unreal-engine/get-started | 1 h | Yes | Setup checklist, first-time workflow. |
| 5 | **Welcome to Unreal Engine** (learning path) | https://dev.epicgames.com/community/learning/paths/7a/welcome-to-unreal-engine | 6–8 h | Partial | Structured intro covering major UE5 features with mini-demos. |
| 6 | **Stack O Bot** (download + tinker) | https://www.fab.com/listings/b4dfff49-0e7d-4c4b-a6c5-8a0315831c9c | 4–8 h | Yes (docs) | Blueprint-only beginner sample. Build something small in BP first. Documentation: https://dev.epicgames.com/documentation/en-us/unreal-engine/stack-o-bot-sample-game-in-unreal-engine |

**Phase 1 exit criteria**:
- You can start UE 5.7, create an empty project, place actors, and play in editor
- You understand: Actor vs Component, GameMode vs GameState, PlayerController vs Pawn
- You've built one trivial Blueprint or modified Stack O Bot to do something new

---

## Phase 2: Lyra Dissection (2~4 weeks) ⭐ Core

> **Lyra Starter Game is the canonical UE 5.7 reference implementation.**
> Epic maintains it as "this is how you build a modern UE5 game in 2025." Most
> of your subsystem learning happens by reading Lyra alongside official docs.

### Lyra Resources

| # | Name | URL | Time | AI-accessible | Why |
|---|---|---|---|---|---|
| 7 | **Download Lyra Starter Game** | https://www.fab.com/listings/93faede1-4434-47c0-85f1-bf27c0820ad0 | 1 h (download + open) | Yes (source code) | Get the project locally. Note the version — make sure it's the 5.7-compatible release. |
| 8 | **Lyra → 5.7 Upgrade Guide** | https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-the-lyra-starter-game-to-the-latest-engine-release-in-unreal-engine | 30 min | Yes | Epic's official upgrade notes per UE version. Always check this before touching Lyra after an engine update. |
| 9 | **Lyra Starter Game Overview** (Epic talk) | https://dev.epicgames.com/community/learning/talks-and-demos/yrrn/lyra-starter-game-overview | 1 h | Partial (video) | Epic's introduction to Lyra's architecture philosophy. Watch before diving into code. |
| 10 | **Lyra Learning Path** | https://dev.epicgames.com/community/learning/paths/Z4/lyra-starter-game | 8–12 h | Partial | Structured curriculum from Epic walking through Lyra's systems. |
| 11 | **Exploring Lyra (Part 1)** | https://dev.epicgames.com/community/learning/tutorials/3749/exploring-lyra-part-1 | 4–6 h (full series) | Partial | Tutorial series breaking down Lyra subsystem by subsystem. |
| 12 | **X157 Lyra Deep-Dive** ⭐ | https://x157.github.io/UE5/LyraStarterGame/ | 10–20 h | Yes | Comprehensive community-written architecture analysis. **Best AI reference companion** — when asking AI about Lyra, paste the relevant X157 page URL too. |

### Lyra Study Order (suggested)

Read by subsystem, not file-by-file. For each, pair Lyra source with the
subsystem docs in Phase 3:

1. **Game Modes / Experiences** (`Source/LyraGame/GameModes/`) — start here, it's the entry point
2. **Player + Pawn** (`Source/LyraGame/Player/`, `Character/`)
3. **Input** (`Source/LyraGame/Input/`) — pair with Phase 3 Enhanced Input
4. **Ability System** (`Source/LyraGame/AbilitySystem/`) — pair with Phase 3 GAS
5. **UI** (`Source/LyraGame/UI/`) — pair with Phase 3 CommonUI
6. **Inventory + Equipment** (`Source/LyraGame/Inventory/`, `Equipment/`)
7. **Teams** (`Source/LyraGame/Teams/`)
8. **Game Features** (`Source/LyraGame/GameFeatures/`) — modular content pattern
9. **Camera** (`Source/LyraGame/Camera/`)
10. **Settings** (`Source/LyraGame/Settings/`)

**Phase 2 exit criteria**:
- You can navigate Lyra's source and explain the role of each top-level folder
- You understand how a player input becomes an ability activation through GAS
- You can identify which Lyra patterns to mirror when implementing similar concepts in your game

---

## Phase 3: Subsystem Deep Dives (parallel with Phase 2)

Studied alongside Lyra. Each subsystem: read official docs → find the matching
Lyra implementation → trace one full example end-to-end.

| Subsystem | Official URL | Lyra reference | UE 5.7 status |
|---|---|---|---|
| **GAS** (Gameplay Ability System) | https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-ability-system-for-unreal-engine | `Source/LyraGame/AbilitySystem/` | Production |
| **GAS — Understanding** | https://dev.epicgames.com/documentation/en-us/unreal-engine/understanding-the-unreal-engine-gameplay-ability-system | (same) | Production |
| **GAS — 60-min Quickstart** | https://dev.epicgames.com/community/learning/tutorials/8Xn9/unreal-engine-epic-for-indies-your-first-60-minutes-with-gameplay-ability-system | (same) | Production |
| **Enhanced Input** | https://dev.epicgames.com/documentation/en-us/unreal-engine/enhanced-input-in-unreal-engine | `Source/LyraGame/Input/` | Production |
| **Enhanced Input — Lyra Settings** | https://dev.epicgames.com/documentation/en-us/unreal-engine/lyra-input-settings-in-unreal-engine | (same) | Production |
| **CommonUI — Quickstart** | https://dev.epicgames.com/documentation/en-us/unreal-engine/common-ui-quickstart-guide-for-unreal-engine | `Source/LyraGame/UI/` | Production |
| **CommonUI — Overview** | https://dev.epicgames.com/documentation/en-us/unreal-engine/overview-of-advanced-multiplatform-user-interfaces-with-common-ui-for-unreal-engine | (same) | Production |
| **CommonUI — Plugin Reference** | https://dev.epicgames.com/documentation/en-us/unreal-engine/common-ui-plugin-for-advanced-user-interfaces-in-unreal-engine | (same) | Production |
| **CommonUI + Enhanced Input integration** | https://dev.epicgames.com/documentation/en-us/unreal-engine/using-commonui-with-enhnaced-input-in-unreal-engine | (same) | Production |
| **StateTree** (AI logic) | (UE 5.7 docs hub) | (Lyra uses StateTree in places) | Production |
| **World Partition** | (UE 5.7 docs hub) | n/a (Lyra arenas are small) | Production |
| **Niagara** | (UE 5.7 docs hub) | scattered VFX in Lyra | Production |
| **MetaSounds** | (UE 5.7 docs hub) | scattered audio in Lyra | Production |
| **AssetManager** | (UE 5.7 docs hub) | Lyra Experience system uses heavily | Production |
| **Modular Game Features** | (UE 5.7 docs hub) | `Source/LyraGame/GameFeatures/` | Production |

**Hub for all UE 5.7 docs**: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-documentation

**Phase 3 exit criteria**:
- For each system Lyra uses, you can trace one end-to-end example
- You can explain when to choose each system (vs. alternatives, vs. rolling your own)

---

## Phase 4: When-You-Need-It (defer until needed)

Don't pre-study these. Read when you actually need the feature.

| Feature | When to study | URL | UE 5.7 status |
|---|---|---|---|
| **Iris Replication** | When designing networked gameplay and standard replication is bandwidth-bound | https://dev.epicgames.com/documentation/en-us/unreal-engine/introduction-to-iris-in-unreal-engine | Beta (opt-in only) |
| **Iris — Getting Started** | (same) | https://dev.epicgames.com/community/learning/tutorials/Xexv/unreal-engine-experimental-getting-started-with-iris | Beta |
| **PCG Framework** | When building procedural content (vegetation, levels, decoration) | (UE 5.7 docs hub — PCG section) | Production (5.7) |
| **Substrate Materials** | When authoring complex layered materials | (UE 5.7 docs hub — Substrate section) | Production (5.7) |
| **MegaLights** | When you have many dynamic shadow-casting lights | https://dev.epicgames.com/documentation/en-us/unreal-engine/megalights-in-unreal-engine | Beta |
| **GameplayCameras** | When standard SpringArm camera isn't expressive enough | (UE 5.7 docs hub) | Experimental — DO NOT use yet |
| **Mover** plugin | (don't yet — major API churn expected) | (UE 5.7 docs hub) | Experimental — DO NOT use yet |
| **Nanite Foliage** | When you have huge foliage scenes and standard foliage is GPU-bound | (UE 5.7 docs hub) | Experimental |
| **Game Animation Sample** (Motion Matching) | When authoring rich animation systems | https://www.unrealengine.com/tech-blog/explore-the-updates-to-the-game-animation-sample-project-in-ue-5-7 | Production sample |
| **City Sample (Matrix Demo)** | When studying World Partition + Mass AI at scale | https://www.fab.com/listings/4898e707-7855-404b-af0e-a505ee690e68 | Production sample |
| **Content Examples** | Reference for "how do I do X feature" — keep installed as a dictionary | https://www.fab.com/listings/4d251261-d98c-48e2-baee-8f4e47c67091 | Production sample |

---

## Sample Projects — Comparison

| Project | UE 5.7 status | Use for | Don't use for |
|---|---|---|---|
| **Lyra Starter Game** ⭐ | Maintained (5.7 release exists) | Architecture patterns, modern subsystem usage, AAA reference | Beginner editor tutorial |
| **Stack O Bot** | Maintained (5.6 rebuild, 5.7 compatible) | Blueprint-only beginner project, StateTree intro | Multiplayer reference, GAS reference |
| **City Sample** | Maintained | World Partition / Nanite / Lumen / Mass AI at scale | Small-scope game patterns (it's a tech demo) |
| **Content Examples** | Maintained | Per-feature lookup ("how do I do X?") | End-to-end game architecture |
| **Game Animation Sample (GASP)** | Maintained (5.7 update) | Motion Matching, modern animation authoring | General gameplay architecture |
| ~~Action RPG~~ | **Deprecated** (UE4) | — | Anything. Use Lyra. |
| ~~Shooter Game~~ | **Deprecated** (UE4) | — | Anything. Use Lyra. |

---

## Epic Talks & Deep-Dives (supplemental)

- **GDC 2025 Sessions hub**: https://www.unrealengine.com/en-US/events/gdc-2025
- **UE 5.7 announcement post**: https://www.unrealengine.com/news/unreal-engine-5-7-is-now-available
- **UE 5.7 release notes**: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- **Game Animation Sample 5.7 update post**: https://www.unrealengine.com/tech-blog/explore-the-updates-to-the-game-animation-sample-project-in-ue-5-7

---

## Caveats

### WebFetch 403 on Epic docs

`dev.epicgames.com` and `docs.unrealengine.com` sometimes return HTTP 403 to
plain WebFetch from AI agents. The URLs in this file are valid, but if
WebFetch fails:

- Use the parent project's **sonnet sub-agent + WebSearch** workaround
  (see root `CLAUDE.md` "환경 제약" section). Sonnet can WebSearch on Vertex
  AI; Opus cannot.
- Alternative: open the URL in a browser yourself and paste the relevant
  section into the conversation.

### Lyra version matching

Lyra is shipped as a separate project on Fab, with **a different release
per UE version**. When upgrading the engine, always:

1. Check Epic's Lyra Upgrade Guide (entry #8 above) for that version
2. Download the matching Lyra release (don't just upgrade your existing copy)
3. Re-record the local Lyra path in `ai-coding-guide.md` Section 15

### Beta / Experimental warnings

Features marked Beta or Experimental in 5.7 are fine to **learn** but should
not be **shipped** without:

- Explicit user decision recorded in an ADR
- Verification that the API hasn't churned since you last used it
- Awareness of the migration cost when the feature graduates

Currently affected: Iris, MegaLights, Mover, GameplayCameras, Nanite Foliage,
AI Assistant.

### UE4-era samples

If you find a tutorial pointing at **Action RPG** or **Shooter Game**,
treat it as historical only. Both are UE4 samples; their patterns predate
the modern UE5 stack (GAS conventions, CommonUI, Enhanced Input, Modular
Features). Lyra supersedes both.

### Video-heavy content

Some Epic learning paths are video-first. AI cannot directly consume
unstructured video. When following a video resource:

- Take notes on the patterns shown
- Save key code snippets to the conversation
- Cross-reference with the corresponding text docs

---

## Cross-References

| Doc | Role |
|---|---|
| `ai-coding-guide.md` | The always-loaded AI architecture reference. Code routing, decisions, drift prevention. |
| `current-best-practices.md` | UE 5.7 code patterns AI uses when generating code. |
| `VERSION.md` | Pinned engine version + verification dates + LLM knowledge gaps. |
| `PLUGINS.md` | Per-plugin status (production / beta / experimental). |
| `breaking-changes.md` | What changed UE 5.3 → 5.7. |
| `deprecated-apis.md` | What to avoid + replacements. |
| `modules/*.md` | Per-area API references. |
| `plugins/*.md` | Per-plugin deep references (GAS, CommonUI, PCG, etc.). |

---

*This document is a living roadmap. When you find a great resource not
listed here, add it. When a URL goes stale, fix it. When a phase feels too
long or too short, rebalance it for the next person.*
