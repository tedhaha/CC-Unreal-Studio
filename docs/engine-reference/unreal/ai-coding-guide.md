# UE 5.7 AI Coding Guide & Project Architecture

**Always loaded into every session via root `CLAUDE.md` `@`-import.**
**Purpose**: Drift prevention — AI must read this before any non-trivial work.
**Last updated**: 2026-05-06
**Project state**: Pre-production (fresh fork — no GDD / ADR / src code yet)

---

## How to Use This File

This file is the always-loaded **architectural mental model** for the project.
It exists because:

1. The LLM's training data ends at January 2026 and reliably covers Unreal up
   to ~5.3 only. UE 5.4–5.7 standards must be **injected**, not recalled.
2. Even within a session, AI tends to **drift**: forgetting which subsystems
   are in use, re-inventing patterns, putting state in the wrong holder, or
   re-deciding questions that were already settled in an ADR.
3. Sub-agents start with no conversation history — this file is their
   common ground.

**Read order during a session**:

1. Section 0 (setup progress) — know where in the project lifecycle we are.
2. Sections 1–4 (project identity) — know what we're building.
3. Sections 22–23 (pre-flight + drift self-check) — apply before any non-trivial response.

This file is authoritative for **WHAT to choose**. For **HOW to write the
code** see `current-best-practices.md`. For **WHERE to find detail** see
Section 25 (cross-references).

---

## Status Marker Convention

Every section is tagged. Markers tell you the section's evolution rules:

| Marker | Meaning |
|---|---|
| 🟢 **PERMANENT** | UE 5.7 universal pattern. Does not change with project evolution. |
| 🟡 **LIVING** | Starts TBD; gets populated during setup. Stays as a summary thereafter. |
| 🔵 **INDEX** | Becomes a pointer/index to fuller content in `docs/` as that content accumulates. |
| 🔴 **SETUP** | Useful only during initial setup; collapses or shrinks once setup is done. |

When updating any section, **preserve its marker**.

---

## Section 0. Setup Progress Tracker  🔴 SETUP

> Tells AI exactly what's done and what's pending. When an AI response would
> require an unfinished step's output, AI must instead suggest running that
> skill first.

| # | Step | Skill | Output | Status |
|---|---|---|---|---|
| 1 | Onboarding | `/start` | Initial decisions in `technical-preferences.md` | ❌ |
| 2 | Game concept | `/brainstorm` | `design/concept.md` | ❌ |
| 3 | System map | `/map-systems` | `design/systems-index.md` | ❌ |
| 4 | Per-system GDDs | `/design-system [each]` | `design/gdd/*.md` | ❌ 0/? |
| 5 | Art bible | `/art-bible` | `design/art-bible.md` | ❌ |
| 6 | UX specs | `/ux-design [each]` | `design/ux/*.md` | ❌ 0/? |
| 7 | Master architecture | `/create-architecture` | `docs/architecture/MASTER.md` | ❌ |
| 8 | ADRs | `/architecture-decision` (per decision) | `docs/architecture/ADR-*.md` | ❌ 0 |
| 9 | Control manifest | `/create-control-manifest` | `docs/architecture/control-manifest.md` | ❌ |
| 10 | Test framework | `/test-setup` | `tests/` scaffold | ❌ |
| 11 | Epics | `/create-epics` | `production/epics/` | ❌ |
| 12 | First sprint | `/sprint-plan` | `production/sprints/sprint-001.md` | ❌ |

**AI behavior rules**:

- If user requests gameplay code AND steps 2–4 are ❌ → respond:
  *"프로젝트 컨셉/시스템 GDD가 아직 없습니다. `/brainstorm` 으로 시작할까요?"*
- If user requests system architecture AND steps 7–9 are ❌ → respond:
  *"아키텍처 마스터 문서가 없습니다. `/create-architecture` 가 먼저 필요합니다."*
- If user requests `src/` code AND step 8 (ADR) is ❌ for the relevant
  decision → ask *"이 결정에 ADR이 있나요? 없으면 `/architecture-decision` 부터."*
- Once **all rows ✅**, replace this entire Section 0 with a single line:
  `Setup complete as of YYYY-MM-DD. Active sprint: production/sprints/sprint-NNN.md`

---

# PART A — PROJECT IDENTITY & STATE

## Section 1. Game Concept Snapshot  🟡 LIVING

**Update trigger**: After `/brainstorm` completes.
**Source of truth**: `design/concept.md`
**Permanent role**: 3–5 line summary stays here even after populated; full GDD lives in source-of-truth file.

──── CURRENT STATE ────

❌ **TBD.** `/brainstorm` not run. AI must NOT make gameplay decisions or
generate gameplay code in this state. If user asks for gameplay work,
redirect:
*"프로젝트 컨셉이 아직 정의되지 않았습니다. `/brainstorm` 으로 컨셉부터 잡을까요?"*

──── POPULATED FORM (replace block above with this once `/brainstorm` done) ────

```
- Title:           [project codename]
- Genre:           [e.g., 3D action roguelike]
- Pillars:         [3 core experience pillars, 1 line each]
- Target audience: [platform / age / session length]
- Reference games: [3 anchor titles]
- Tone:            [1 line]
- Source of truth: design/concept.md  (synced YYYY-MM-DD)
```

---

## Section 2. Target Platform & Scale  🟡 LIVING

**Update trigger**: During `/start` onboarding or first ADR on platform.
**Source of truth**: `.claude/docs/technical-preferences.md` "Input & Platform"
**Permanent role**: One-table summary; details remain in `technical-preferences.md`.

──── CURRENT STATE ────

❌ **TBD.** All `technical-preferences.md` platform fields show
`[TO BE CONFIGURED]`. AI must NOT make platform-specific decisions
(controller layouts, rendering tier, performance budgets, asset memory limits)
until populated.

──── POPULATED FORM ────

| Field | Value |
|---|---|
| Primary platform | [PC Steam / PS5 / Switch / Mobile / etc.] |
| Secondary platforms | [list or N/A] |
| Primary input | [KB+M / Gamepad / Touch] |
| Gamepad support | [Full / Partial / None] |
| Target framerate | [60 / 30 / 120 FPS] |
| Online | [Single-player / Co-op / MP / MMO] |

---

## Section 3. Project Phase  🟡 LIVING

**Update trigger**: At each phase gate (`/gate-check` PASS).

──── CURRENT STATE ────

**Pre-production** (Phase 0). No GDDs, ADRs, src code, or sprints exist yet.

What this means for AI:

- ❌ Do not generate `src/` code.
- ❌ Do not author ADRs without user direction.
- ❌ Do not run `/dev-story` (no stories exist).
- ✅ OK: help with onboarding skills (`/start`, `/brainstorm`, `/map-systems`).
- ✅ OK: discuss UE 5.7 patterns at architecture-talk level.
- ✅ OK: read engine-reference and Lyra docs for the user.

──── PHASE LIFECYCLE ────

```
Pre-production → Production → Polish → Release → Live-ops
```

After each `/gate-check` PASS, update this section with the new phase and
its constraints.

---

## Section 4. Decision State Map  🟡 LIVING

> Quick lookup: "Is this question already decided?" Drift is most common
> when AI re-decides settled questions or invents answers to undecided ones.

| Question | Status | Source |
|---|---|---|
| Engine version | ✅ DECIDED — UE 5.7 | `VERSION.md` |
| Engine subsystem standard stack | ✅ DECIDED — Section 5 below | this file |
| Naming conventions | ✅ DECIDED | `technical-preferences.md` |
| Coding standards | ✅ DECIDED | `.claude/docs/coding-standards.md` |
| Test evidence per story type | ✅ DECIDED | `coding-standards.md` "Testing Standards" |
| Layer model + dependency direction | ✅ DECIDED — Section 8 below | this file |
| State ownership map | ✅ DECIDED — Section 9 below | this file |
| Game concept | ❌ TBD | run `/brainstorm` |
| Target platform | ❌ TBD | `technical-preferences.md` placeholders |
| Performance budgets | ❌ TBD | `technical-preferences.md` placeholders |
| Game-specific architecture | ❌ TBD | run `/create-architecture` |
| Per-system ADRs | ❌ TBD (0 ADRs) | run `/architecture-decision` |
| Forbidden patterns (game-specific) | ❌ TBD | populated as ADRs accept |
| Allowed plugins (game-specific) | ❌ TBD | populated as ADRs accept |
| Multiplayer scope | ❌ TBD | depends on concept |

**AI rule**: If a user request hinges on a ❌ row, **ASK before answering**.
If on a ✅ row, **use the existing decision** without re-deriving it.

---

# PART B — ENGINE STACK (HARD DECISIONS, ALREADY MADE)

## Section 5. UE 5.7 Default Stack  🟢 PERMANENT

> When generating UE 5.7 code, default to these. Deviation requires explicit
> user direction or an ADR. See `PLUGINS.md` for current status verification.

| Concern | Use This | Status in 5.7 | Notes |
|---|---|---|---|
| Real-time GI | **Lumen** | Production | Default for new projects |
| Geometry | **Nanite** | Production | Auto-LOD high-poly meshes |
| Lighting (massive) | **MegaLights** | Beta | Confirm with user before using |
| Materials (new) | **Substrate** | Production (5.7) | Modular, physically accurate |
| Input | **Enhanced Input** | Production | IA + IMC pattern (mirror Lyra) |
| UI (menus / HUD) | **CommonUI** | Production | Activatable widgets, input routing |
| VFX | **Niagara** | Production | GPU-accelerated |
| Audio (complex / parameterized) | **MetaSounds** | Production | Procedural audio graph |
| Audio (simple oneshot) | **Sound Cue or MetaSound** | Production | Either acceptable for trivial cases |
| World streaming | **World Partition** | Production | One-File-Per-Actor (OFPA) |
| Abilities / buffs / cooldowns | **GAS** (Gameplay Ability System) | Production | Mirror Lyra ASC pattern |
| AI decision logic | **StateTree** | Production | New default; supersedes BehaviorTree for new work |
| Async asset loading | **AssetManager** + Primary Assets | Production | No raw `LoadObject` for game content |
| Procedural content | **PCG Framework** | Production (5.7) | Just promoted from Beta |
| Character movement | **CharacterMovementComponent (CMC)** | Production | Mover plugin is experimental — NOT default |
| Camera | **Standard (SpringArm + CameraComponent)** | Production | GameplayCameras experimental — NOT default |
| Replication | **Standard property replication** | Production | Iris is Beta — NOT default |
| Cross-cutting services | **WorldSubsystem / GameInstanceSubsystem** | Production | Replaces global singletons |
| Save / Load | **`USaveGame`** + AsyncSave | Production | Slot-based save |
| Physics | **Chaos** | Production | UE5 default |
| Animation | **Animation Blueprint + State Machines** | Production | Motion Matching (5.4+) optional, sample available |
| Modular content | **Game Features + Game Feature Actions** | Production | Lyra demonstrates this pattern |
| Tunable data | **`UDataTable` / `UDataAsset` / `UPrimaryDataAsset`** | Production | Per `coding-standards.md` data-driven rule |

---

## Section 6. Forbidden / Deprecated Stack  🟢 PERMANENT

> AI must NOT generate code using these. If existing code uses them, flag for
> migration but do not migrate without user approval.

| Forbidden | Why | Use Instead |
|---|---|---|
| **Cascade** (particles) | Deprecated in UE5 | Niagara |
| **Legacy Input** (`InputComponent` direct binding) | Superseded | Enhanced Input |
| **Legacy Material System** (for new materials) | Superseded in 5.7 | Substrate |
| **Streaming Levels** (for open worlds) | Superseded | World Partition |
| **Action RPG / Shooter Game patterns** (UE4 samples) | Unmaintained | Lyra Starter Game |
| **Raw `UPROPERTY()` pointers** | GC-unsafe pattern | `TObjectPtr<T>` |
| **BehaviorTree** (for new AI logic) | Superseded by StateTree | StateTree |
| **Static singletons** for game services | Untestable, lifecycle-confused | WorldSubsystem / GameInstanceSubsystem |
| **`GetAllActorsOfClass()` in Tick** | O(n) per frame | Cache result; subscribe to spawn/despawn events |
| **Direct attribute writes** (in GAS) | Bypasses prediction/replication | `UGameplayEffect` |
| **Tick polling** to detect value changes | Wasteful, racy | Delegates / events |
| **Blueprint Tick** for non-frame-critical work | Performance | Timer / event-driven |
| **Hardcoded gameplay values** | Per `coding-standards.md` | Data-driven (DataTable / DataAsset / config) |
| **`UGameInstance` for per-player data** | Wrong owner (single instance, all players share) | `APlayerState` / `APlayerController` |
| **Engine code depending on gameplay code** | Per `engine-code.md` rule | Refactor; engine MUST NOT import gameplay |

---

## Section 7. Experimental / Beta Features — User Confirmation Required  🟢 PERMANENT

> AI must NOT use these without explicit user confirmation:
> *"이 기능은 UE 5.7에서 [Experimental/Beta]입니다. 사용해도 될까요?"*

| Feature | Status in 5.7 | Replaces (eventually) | Notes |
|---|---|---|---|
| **Iris Replication** | Beta | Standard replication / Replication Graph | Bandwidth gains real, but API churn risk; not used in default Lyra |
| **MegaLights** | Beta | Standard dynamic lights at scale | Performance benefits real; promoted from experimental in 5.5 |
| **Mover** plugin | Experimental | `CharacterMovementComponent` | DON'T use yet — major API churn expected |
| **GameplayCameras** | Experimental | Hand-written camera code | DON'T use yet — Lyra still uses standard SpringArm |
| **Nanite Foliage** | Experimental (NEW in 5.7) | Standard foliage | Performance real but newer than other Nanite paths |
| **AI Assistant** (in-editor) | Experimental | N/A (new tool) | Editor feature, not runtime — irrelevant to game code |

For full plugin status, see `PLUGINS.md`.

---

# PART C — ARCHITECTURAL LAYERS

## Section 8. Layer Model & Dependency Direction  🟢 PERMANENT

> Drift comes most often from putting code in the wrong layer or coupling
> across layer boundaries the wrong direction.

```
                ┌────────────────────────────┐
                │  src/ui/        (UI layer) │   ← knows about: gameplay, networking
                ├────────────────────────────┤
                │  src/networking/           │   ← knows about: gameplay
                ├────────────────────────────┤
                │  src/ai/        (AI layer) │   ← knows about: gameplay
                ├────────────────────────────┤
                │  src/gameplay/             │   ← knows about: core
                ├────────────────────────────┤
                │  src/core/    (engine ext) │   ← knows about: nothing else in src/
                └────────────────────────────┘
                            ▲
                  ┌─────────┴─────────┐
                  │  src/tools/       │  Editor-only. Independent module.
                  └───────────────────┘
```

**Rules** (enforced via `.claude/rules/engine-code.md`):

- Dependency direction is strict: upper layers may include lower; **never the reverse**.
- `src/core/` engine code MUST NOT include any gameplay headers. It must be
  reusable across games.
- `src/tools/` is editor-only (`-Editor` build target). Runtime modules MUST
  NOT include `src/tools/`.
- Cross-cutting services that span layers go into a **subsystem** (Section 9),
  not a static singleton.
- A new directory under `src/` requires an ADR.

---

## Section 9. State Ownership Map  🟢 PERMANENT

> "Where does this data live?" — most-common drift question. Use this table
> before placing any state.

| Data type | Owner | Replicated? | Lifetime |
|---|---|---|---|
| Persistent player profile | `USaveGame` (slot) | N/A (disk) | Across sessions |
| Cross-level persistent state (settings, save handle) | `UGameInstance` | No | App lifetime |
| Cross-level persistent service | `UGameInstanceSubsystem` | No | App lifetime |
| Per-world transient service | `UWorldSubsystem` | No | World lifetime |
| Per-local-player UI/input | `ULocalPlayerSubsystem` | No | Local player |
| Server-only game rules | `AGameModeBase` | NO (server-only) | Match |
| Replicated game-wide state (score, timer) | `AGameStateBase` | Yes (server→all) | Match |
| Replicated per-player state (name, score) | `APlayerState` | Yes (server→all) | Player session |
| Local input + UI ownership | `APlayerController` | Owner-only | Player session |
| Physical pawn state (location, etc.) | `APawn` / `ACharacter` | Yes (movement) | Possessed lifetime |
| Numeric gameplay state (HP, mana, damage stats) | `UAttributeSet` (GAS) | Yes (predicted) | ASC lifetime |
| Granted abilities / cooldowns / tags | `UAbilitySystemComponent` (GAS) | Yes (predicted) | Owner lifetime |
| Inventory / equipment | `UActorComponent` on Pawn (SP) or PlayerState (MP) | Yes (visibility-dependent) | Owner lifetime |
| AI black-board / decision state | `UStateTreeComponent` on `AAIController` | No (AI is server-side) | AI lifetime |
| Per-asset config (item def, weapon stats) | `UDataAsset` / `UPrimaryDataAsset` | N/A (asset) | Permanent |
| Gameplay tuning tables | `UDataTable` | N/A (asset) | Permanent |
| Visual-only effects state | Pawn or component (cosmetic, often non-replicated) | No | Frame-scoped |

**Rule**: If unsure where data goes, **ASK**. Wrong owner is the #1 source
of refactor pain (data on `GameMode` instead of `GameState` → no clients see
it; per-player data on `GameInstance` → all players share it; etc.).

---

## Section 10. Data Flow Patterns  🟢 PERMANENT

```
Input  →  PlayerController  →  Pawn  →  AbilitySystemComponent
                                                ↓
                                          GameplayEffect
                                                ↓
                                          AttributeSet  →  GameplayCue / UI binding
```

**Key flow rules**:

1. **Server-authoritative** by default. Client sends *input*; server validates
   and produces the authoritative result; server replicates back.
2. **Event > polling.** Use UE delegates (`DECLARE_DYNAMIC_MULTICAST_DELEGATE_*`)
   to notify UI / AI of state changes. Do NOT Tick to detect changes.
3. **GAS modifies attributes via `GameplayEffect`**, never by direct write.
   This preserves prediction and replication.
4. **UI binds to model via delegate or attribute change callback**, not by
   polling actors every frame. CommonUI activatable widgets handle their own
   visibility lifecycle.
5. **AI decides via StateTree**, executes via the same gameplay APIs the
   player uses (GAS, movement). Do NOT branch internal AI code paths that
   bypass gameplay rules.
6. **Cross-actor messaging**: prefer Gameplay Messages plugin (Lyra uses this)
   over hard references between actors that don't own each other.

---

# PART D — CODE-LEVEL DEFAULTS

## Section 11. Hard C++ Defaults  🟢 PERMANENT

> See `current-best-practices.md` for full code samples. Listed here for
> always-loaded reference.

| Rule | Why |
|---|---|
| Use `TObjectPtr<T>` for `UPROPERTY` pointers | UE5 type-safe, lazy-load aware |
| Always pair pointer fields with `UPROPERTY()` | Otherwise GC may collect them mid-frame |
| Use `UFUNCTION(BlueprintCallable, Category="X")` for BP-exposed C++ | Discoverable, categorized |
| Use `UFUNCTION(BlueprintImplementableEvent)` for designer-overridable hooks | Allows BP override without C++ changes |
| Use `UFUNCTION(Server, Reliable, WithValidation)` for server RPCs | Validation prevents trivial cheats |
| `IWYU` (`#include` what you use) | Faster compiles, fewer hidden deps |
| Forward-declare in headers, include in `.cpp` | Reduces compile cascade |
| `static constexpr` for compile-time constants | Avoid `#define` macros |
| `enum class` (not C-style enum) | Type safety |
| Initialize members at declaration when possible | Avoid uninitialized state |
| Mark hot-path data with `TInlineAllocator<N>` if size known | Avoid heap alloc in Tick |
| **Zero allocations** in `Tick`, `PhysicsTick`, render thread | Per `engine-code.md` |
| `DECLARE_LOG_CATEGORY_EXTERN` per module; never spam `LogTemp` in production code | Filterable logs |

---

## Section 12. Naming Conventions (compact reminder)  🟢 PERMANENT

Full spec: `.claude/docs/technical-preferences.md` "Naming Conventions".
Most-violated quick reference:

```
A___ — Actor              (e.g., AMyCharacter)
U___ — UObject component  (e.g., UInventoryComponent)
F___ — Plain struct       (e.g., FItemData)
I___ — Interface          (e.g., IDamageable)
E___ — Enum               (e.g., EWeaponType)
b___ — Boolean            (e.g., bIsDead)

BP_   — Blueprint class           WBP_  — Widget Blueprint
M_    — Material                  MI_   — Material Instance
T_    — Texture                   SM_   — Static Mesh
SK_   — Skeletal Mesh             A_    — Animation
AB_   — Anim Blueprint            S_    — Sound
DT_   — DataTable                 DA_   — DataAsset
GA_   — Gameplay Ability          GE_   — Gameplay Effect
AS_   — Attribute Set
```

Functions are PascalCase, verb-first: `ApplyDamage()`, `OpenInventory()`.

---

## Section 13. Asset Pipeline Rules  🟢 PERMANENT

```
Content/
└── Game/
    ├── Characters/
    │   ├── Player/      (BP_, SK_, AB_, A_, M_, etc.)
    │   └── Enemies/
    ├── Weapons/
    ├── UI/              (WBP_, T_, M_)
    ├── Environment/
    ├── Audio/           (S_, MX_)
    ├── VFX/             (Niagara systems, M_)
    ├── Data/            (DT_, DA_)
    └── GAS/             (GA_, GE_, AS_)
```

**Rules**:

- Naming prefixes are **mandatory** (Section 12). No prefix → asset audit fails.
- Binary assets (`.uasset`, `.umap`, textures, audio, FBX) go through Git LFS
  (configured in `.gitattributes`).
- No spaces in asset names. PascalCase: `BP_PlayerCharacter`,
  not `BP Player Character`.
- Assets must live under `Content/Game/[category]/`, never at `Content/` root.
- Test assets go in `Content/TestData/` (excluded from cooking).
- Designer-tweakable values live in `DT_*` / `DA_*`, not in BP graphs.

---

# PART E — INTENT → STACK ROUTING

## Section 14. Intent → Stack Routing  🟡 LIVING

> When user requests "make X", route to the right UE 5.7 stack. Game-specific
> systems get added to this table as they are designed.

──── CORE ROUTING (always available) ────

| User intent (keywords) | Standard implementation | Reference path |
|---|---|---|
| "ability / skill / spell / power" | GAS `UGameplayAbility` + `UGameplayEffect` + `UAttributeSet` | Lyra: `Source/LyraGame/AbilitySystem/` |
| "menu / HUD / screen / overlay" | CommonUI `UCommonActivatableWidget` | Lyra: `Source/LyraGame/UI/` |
| "input / keybind / controller" | Enhanced Input `UInputAction` + `UInputMappingContext` | Lyra: `Source/LyraGame/Input/` |
| "open world / streaming / large map" | World Partition + Data Layers | UE docs: World Partition |
| "particle / explosion / VFX" | Niagara `UNiagaraSystem` | UE docs: Niagara |
| "sound / music / audio cue" | MetaSound (complex) or Sound Cue (trivial) | UE docs: MetaSounds |
| "save / load / progress" | `USaveGame` + `UGameplayStatics::Async*` | UE docs: SaveGame |
| "load asset at runtime" | `UAssetManager` + Primary Data Asset | UE docs: AssetManager |
| "character / pawn / movement" | `ACharacter` + CMC | Lyra: `Source/LyraGame/Character/` |
| "AI / enemy / behavior" | `AAIController` + StateTree | UE docs: StateTree |
| "camera / follow / first-person / third-person" | `USpringArmComponent` + `UCameraComponent` | UE samples |
| "match rules / scoring / win condition" | `AGameStateBase` (replicated) + `AGameModeBase` (server rules) | Lyra: `Source/LyraGame/GameModes/` |
| "player data / name / progression" | `APlayerState` (replicated) | Lyra: `Source/LyraGame/Player/` |
| "inventory / loot / pickup" | `UActorComponent` on Pawn (SP) or PlayerState (MP) + `UDataAsset` for items | Lyra: `Source/LyraGame/Inventory/` |
| "tuning numbers / balance / stats" | `UDataTable` or `UPrimaryDataAsset` | UE docs: DataTable |
| "damage / health / death" | GAS `UGameplayEffect` + `UAttributeSet` | Lyra ASC pattern |
| "multiplayer state replication" | Standard `UPROPERTY(Replicated)` + `GetLifetimeReplicatedProps` | UE docs: Replication |
| "RPC (server call from client)" | `UFUNCTION(Server, Reliable, WithValidation)` | UE docs: RPCs |
| "modular feature / plugin-style content" | Modular Game Features + Game Feature Action | Lyra GameFeatures |
| "procedural spawning / placement" | PCG Graph | UE docs: PCG |
| "cross-actor message without hard reference" | Gameplay Messages plugin | Lyra: extensive use |
| "team / faction / friend-or-foe" | `UTeamSubsystem` (custom, mirror Lyra) | Lyra: `Source/LyraGame/Teams/` |
| "experience / game mode swap" | Lyra Experience pattern (`ULyraExperienceDefinition`) | Lyra: `Source/LyraGame/GameModes/` |

──── GAME-SPECIFIC ROUTING (populated as systems are designed) ────

After `/map-systems` and each `/design-system`, append rows here for
game-specific systems. Template:

```
| "[game-specific keyword]" | [chosen implementation] | [GDD path + Lyra mirror if any] |
```

---

## Section 15. Lyra Mirror Map  🟢 PERMANENT

> Lyra Starter Game is the canonical UE 5.7 reference implementation. When
> implementing similar concepts, **mirror the Lyra approach** unless an ADR
> documents a deviation.

| Concept | Lyra path | What to study |
|---|---|---|
| ASC (AbilitySystemComponent) usage | `Source/LyraGame/AbilitySystem/` | Custom ASC, attribute sets, effect contexts |
| Gameplay abilities | `Source/LyraGame/AbilitySystem/Abilities/` | Activation patterns, cost/cooldown, prediction |
| Attributes | `Source/LyraGame/AbilitySystem/Attributes/` | AttributeSet definitions, MetaAttributes |
| Input pipeline | `Source/LyraGame/Input/` | IMC layering, ability-by-tag binding |
| UI activatable widgets | `Source/LyraGame/UI/` | CommonUI layer stack, input mode routing |
| Player controller | `Source/LyraGame/Player/` | Setup ordering, ASC ownership |
| Game modes / experiences | `Source/LyraGame/GameModes/` | Experience-based mode swapping |
| Modular features | `Source/LyraGame/GameFeatures/` | Plugin-style content injection |
| Character / pawn | `Source/LyraGame/Character/` | Pawn data, ability granting |
| Equipment / inventory | `Source/LyraGame/Equipment/` `Inventory/` | Replicated stack pattern |
| Teams | `Source/LyraGame/Teams/` | TeamSubsystem, attitude resolution |
| Camera | `Source/LyraGame/Camera/` | Camera mode stack |
| Settings | `Source/LyraGame/Settings/` | Game settings + apply pattern |

**Local Lyra location**: ❌ TBD — once the user downloads Lyra, record the
absolute path here so AI can reference specific files. Until then, the table
above is a conceptual mirror map only.

For broader Lyra learning resources (URLs, study order), see
`learning-roadmap.md` Phase 2.

---

# PART F — TESTING & QUALITY

## Section 16. Testing Strategy  🟢 PERMANENT

Per `.claude/docs/coding-standards.md` "Testing Standards":

| Story type | Required evidence | Location | Gate |
|---|---|---|---|
| **Logic** (formulas, AI, FSM) | Automated unit test | `tests/unit/[system]/` | BLOCKING |
| **Integration** (multi-system) | Integration test or playtest doc | `tests/integration/[system]/` | BLOCKING |
| **Visual / Feel** | Screenshot + lead sign-off | `production/qa/evidence/` | ADVISORY |
| **UI** (menus, HUD) | Walkthrough doc or interaction test | `production/qa/evidence/` | ADVISORY |
| **Config / Data** (balance) | Smoke check pass | `production/qa/smoke-[date].md` | ADVISORY |

**Headless CI command**:

```
UnrealEditor-Cmd <ProjectPath>.uproject \
  -ExecCmds="Automation RunTests <TestFilter>; Quit" \
  -nullrhi -unattended -nopause -NoLogTimes -log
```

**Hard rules**:

- Tests must be **deterministic** (no random seeds, no time-dependent assertions).
- Tests must isolate setup/teardown; no inter-test dependencies.
- Never disable failing tests to make CI green — fix the root cause.
- Replication-bearing systems must have a replication test.
- Tests live in `tests/`, not in `src/`.

---

## Section 17. Performance Budgets  🟡 LIVING

**Update trigger**: After target platform decided (Section 2).
**Source of truth**: `.claude/docs/technical-preferences.md` "Performance Budgets"

──── CURRENT STATE ────

❌ TBD. No platform set. Use general UE 5.7 guidance:

- Hot paths (`Tick`, `PhysicsTick`, render thread): **zero allocations**
- Profile **before AND after** each optimization
- No optimization without measurement

──── POPULATED FORM ────

| Metric | Budget |
|---|---|
| Target framerate | [60 / 30 / 120 FPS] |
| Frame budget | [16.67 / 33.33 / 8.33 ms] |
| Draw call budget | [< 2000 / < 5000] |
| Memory ceiling | [GB by target platform] |
| GPU budget | [% by feature: GI, shadows, transparency, post] |
| Streaming budget | [MB/s for World Partition cells] |

---

# PART G — NETWORKING

## Section 18. Networking Model  🟡 LIVING

──── PERMANENT BASELINE ────

| Decision | Default | Notes |
|---|---|---|
| Authority model | Server-authoritative | Client sends input; server validates |
| Replication system | Standard property replication | Iris is Beta — opt-in only |
| RPC reliability | Reliable for state changes; Unreliable for cosmetic | Use sparingly for bandwidth |
| Prediction | GAS prediction for abilities; CMC prediction for movement | Built-in |
| Lag compensation | Custom per game (no built-in) | Dead-reckoning, server rewind as needed |

──── GAME-SPECIFIC (LIVING) ────

❌ TBD until multiplayer scope decided. Once decided, populate:

```
- Bandwidth budget per player: [KB/s up, KB/s down]
- Tick rate: server [Hz], client [Hz]
- Max concurrent players: [N]
- Authority model deviations (if any)
- Prediction policy per ability category
- Anti-cheat strategy
```

---

# PART H — DECISION GOVERNANCE

## Section 19. ADR System  🔵 INDEX

**Location**: `docs/architecture/`
**Skill**: `/architecture-decision`
**Template**: `.claude/docs/templates/architecture-decision-record.md`
**Lifecycle**: `Proposed` → `Accepted` → `Superseded`
**Validation**: `/architecture-review` after a batch of ADRs accepts.

──── CURRENT (0 ADRs) ────

`docs/architecture/` is empty (only `tr-registry.yaml` placeholder). The
engine choice (UE 5.7) is recorded in `VERSION.md` but has no ADR. First
ADRs are typically:

- Input system (likely → Enhanced Input)
- UI framework (likely → CommonUI)
- Ability system (use GAS or not)
- Networking architecture (single / co-op / dedicated MP)
- Save format
- Modular vs monolithic architecture (Lyra Game Features pattern or not)

**AI rule**: When the user makes a binding technical decision, suggest
`/architecture-decision` to record it. Do not silently encode decisions in
code — they must be discoverable in `docs/architecture/`.

──── POPULATED (when ≥ 1 ADR exists, replace the block above) ────

| ADR # | Title | Status | Affects |
|---|---|---|---|
| 001 | [title] | Accepted | [systems] |
| ... | ... | ... | ... |

(Full bodies in `docs/architecture/ADR-*.md`. This table is index only.)

---

## Section 20. TR Registry  🔵 INDEX

**Location**: `docs/architecture/tr-registry.yaml`
**Role**: Stable IDs (`TR-MOV-001`) linking GDD requirements ↔ ADRs ↔ stories.
**Rule**: Never renumber existing IDs — only append.
**Updated by**: `/architecture-review` Phase 8

──── CURRENT ────

`tr-registry.yaml` exists but is empty. No TR IDs assigned (no GDDs yet).

──── POPULATED ────

`N TR IDs registered across M systems. See tr-registry.yaml.`

---

## Section 21. Control Manifest  🔵 INDEX

**Location**: `docs/architecture/control-manifest.md` (when created)
**Skill**: `/create-control-manifest`
**Role**: Flat programmer rule sheet — Required / Forbidden / Guardrails per layer.
**Versioning**: Date-stamped header; stories embed the version they targeted.
**Staleness check**: `/story-done` validates the version a story targeted is current.

──── CURRENT ────

Not created yet. Run `/create-control-manifest` after enough ADRs accept to
have meaningful per-layer rules.

──── POPULATED ────

```
Manifest version: YYYY-MM-DD
Last refresh:     YYYY-MM-DD (after ADR # N)
Sections:         [count of layer sections]
Full content:     docs/architecture/control-manifest.md
```

---

# PART I — DRIFT PREVENTION

## Section 22. Pre-flight Checklist (before code/design generation)  🟢 PERMANENT

Before writing or planning ANY non-trivial UE-related code or design, AI MUST
mentally check:

1. ☐ **Section 0**: Are the relevant setup steps ✅?
2. ☐ **Section 1**: Is the game concept defined? (If ❌ and request is gameplay-related → halt and ask.)
3. ☐ **Section 4**: Is the underlying decision in the Decision State Map ✅?
   If ❌, ask the user instead of guessing.
4. ☐ **Section 5/6/7**: Is the chosen subsystem in the standard stack, or is
   it forbidden, or experimental?
5. ☐ **Section 8**: What layer does this code belong to? Is the dependency
   direction OK?
6. ☐ **Section 9**: What state holder owns this data?
7. ☐ **Section 14**: Is there a Lyra mirror to study?
8. ☐ **Section 19**: Does an ADR govern this? If a binding decision is being
   made, suggest creating one.
9. ☐ `deprecated-apis.md`: Is anything I'm about to use deprecated?
10. ☐ `current-best-practices.md`: Are there code-level patterns I should mirror?
11. ☐ Per-module API: For specific UE API signatures, read `modules/[area].md`
    or `plugins/[name].md`.

If any check fails or is unknown, **ASK before proceeding**.

---

## Section 23. Drift Self-Check Questions  🟢 PERMANENT

Before sending each response involving project work, AI asks itself:

| Question | If yes → action |
|---|---|
| Am I generating gameplay code without a GDD for that system? | STOP. Suggest `/design-system`. |
| Am I making an architecture decision without an ADR? | STOP. Suggest `/architecture-decision`. |
| Am I about to put state in a holder that Section 9 says is wrong? | STOP. Re-route per Section 9. |
| Am I inventing a subsystem when one already exists per Section 5? | STOP. Use the standard. |
| Am I using an experimental feature (Section 7) without user OK? | STOP. Confirm first. |
| Am I deviating from the Lyra mirror (Section 15) for no documented reason? | Pause. Justify or align. |
| Am I re-deciding a question already ✅ in Section 4? | STOP. Use the existing decision. |
| Am I generating code for a story that doesn't exist? | STOP. Run `/dev-story` flow or create the story. |
| Am I crossing a layer boundary (Section 8) the wrong way? | STOP. Refactor or move code. |
| Am I assuming a target platform that's not yet decided (Section 2 ❌)? | STOP. Ask user. |
| Am I writing to `src/` but the project phase (Section 3) is Pre-production? | STOP. Surface the phase mismatch to user. |

---

## Section 24. Living Sections — Update Triggers  🟢 PERMANENT

Whenever one of the events below happens, the corresponding section MUST be
updated. AI should suggest the update if it notices the trigger occurring.

| Trigger | Update | Section |
|---|---|---|
| `/start` runs to completion | Fill platform decisions | Section 2, 17 |
| `/brainstorm` runs to completion | Fill concept summary | Section 1 |
| `/map-systems` runs to completion | Add system rows; mark game-arch decisions | Section 4, 14 |
| `/design-system` per-system completes | Add row to routing if new pattern | Section 14 |
| `/architecture-decision` ACCEPT | Add ADR row to index | Section 19 |
| `/create-control-manifest` runs | Convert Section 21 to populated form | Section 21 |
| `/gate-check` PASS to next phase | Update phase | Section 3 |
| Any Section 0 row completes | Mark ✅ | Section 0 |
| All Section 0 rows ✅ | Collapse Section 0 to 1 line | Section 0 |
| Multiplayer scope decided | Fill networking specifics | Section 18 |
| Lyra downloaded locally | Record absolute path | Section 15 |

---

# CROSS-REFERENCES

## Section 25. Other Docs (Role Separation)  🟢 PERMANENT

> Each doc has a distinct role. Don't duplicate content; cross-reference.

| Doc | Role | Loaded |
|---|---|---|
| **this file** (`ai-coding-guide.md`) | WHAT to choose + project mental model | Always (root CLAUDE.md `@`-import) |
| `current-best-practices.md` | HOW to write the code (patterns + snippets) | On-demand (docs/CLAUDE.md directive) |
| `learning-roadmap.md` | Human study guide (URLs, courses, Lyra path) | On-demand (rarely needed by AI) |
| `VERSION.md` | Engine version pin + verification dates + knowledge gaps | Always (root CLAUDE.md `@`-import) |
| `PLUGINS.md` | Per-plugin status (production/beta/experimental) | On-demand |
| `breaking-changes.md` | UE 5.3 → 5.7 breaking changes | On-demand |
| `deprecated-apis.md` | APIs to avoid + replacements | On-demand |
| `modules/*.md` | Per-area API references (animation, audio, etc.) | On-demand |
| `plugins/*.md` | Per-plugin deep references (GAS, CommonUI, PCG, etc.) | On-demand |
| `docs/architecture/ADR-*.md` | Per-decision records | On-demand |
| `docs/architecture/control-manifest.md` | Programmer rule sheet | On-demand |
| `docs/architecture/tr-registry.yaml` | TR ID ↔ GDD ↔ story tracking | On-demand |
| `.claude/docs/coding-standards.md` | Universal coding standards | Always (root CLAUDE.md `@`-import) |
| `.claude/docs/technical-preferences.md` | Project-wide tech config | Always (root CLAUDE.md `@`-import) |
| `.claude/docs/coordination-rules.md` | Agent coordination protocol | Always (root CLAUDE.md `@`-import) |
| `design/concept.md` (when exists) | Game concept (full GDD) | On-demand |
| `design/gdd/*.md` (when exists) | Per-system GDDs | On-demand |
| `production/sprints/*.md` (when exists) | Sprint plans / story files | On-demand (current sprint) |

---

## Section 26. Setup-Phase Cleanup Guide  🟢 PERMANENT (meta)

> This file should evolve as setup progresses. Below is the cleanup playbook.

| When | What to update in this file |
|---|---|
| After `/start` | Section 2 (platform), Section 17 (perf budgets) — fill placeholders |
| After `/brainstorm` | Section 1 (concept) — replace TBD with summary |
| After `/map-systems` | Section 4 (decision map) — add game systems; Section 14 — add system-specific routes |
| After each `/design-system` | Section 14 — add per-system routing row if it deviates from defaults |
| After first ADR `Accepted` | Section 19 — switch from "0 ADRs" block to populated table |
| After `/create-control-manifest` | Section 21 — switch to populated form |
| After `/test-setup` | Section 16 — confirm CI command paths if customized |
| After `/gate-check` PASS | Section 3 — update phase |
| After ALL Section 0 rows ✅ | Section 0 — collapse to 1 line: `Setup complete YYYY-MM-DD. Active sprint: ...` |
| Periodically (each sprint end) | Section 4 — re-verify decision states are current |

**Anti-bloat rule**: Each LIVING / INDEX section's *populated form* must remain
≤ 10 lines. Detail belongs in the source-of-truth file, not here. This file
exists for **AI conditioning**, not project documentation.

**Anti-staleness rule**: Update the `Last updated:` field at the top of this
file whenever any section changes. Stale always-loaded context is worse than
no context.

---

*End of file.*
