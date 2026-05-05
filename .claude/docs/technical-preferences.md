# Technical Preferences

<!-- Engine pinned at fork time. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Unreal Engine 5.7
- **Language**: C++ (game logic, performance-critical systems) + Blueprint (rapid iteration, UI, designer-facing tuning)
- **Rendering**: Default UE5 deferred renderer; Lumen + Nanite recommended for 3D, Substrate for new materials
- **Physics**: Chaos (Unreal default)

## Input & Platform

<!-- Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: [TO BE CONFIGURED — e.g., PC (Steam), Console, etc.]
- **Input Methods**: [TO BE CONFIGURED — e.g., Keyboard/Mouse, Gamepad, Mixed]
- **Primary Input**: [TO BE CONFIGURED — the dominant input for this game]
- **Gamepad Support**: [TO BE CONFIGURED — Full / Partial / None]
- **Touch Support**: [TO BE CONFIGURED — Full / Partial / None]
- **Platform Notes**: [TO BE CONFIGURED — any platform-specific UX constraints]

## Naming Conventions

Following standard Unreal Engine conventions:

- **C++ Classes**: `PascalCase` with prefix (`A` for Actors, `U` for UObjects, `F` for structs, `I` for interfaces, `E` for enums) — e.g. `AMyCharacter`, `UInventoryComponent`, `FItemData`
- **Variables**: `PascalCase` — e.g. `Health`, `MaxAmmo`
- **Booleans**: `b` prefix — e.g. `bIsDead`, `bCanFire`
- **Functions**: `PascalCase` verb-first — e.g. `ApplyDamage()`, `OpenInventory()`
- **Blueprint Assets**: type prefix — `BP_` (Blueprint class), `WBP_` (Widget Blueprint), `M_` (Material), `MI_` (Material Instance), `T_` (Texture), `SK_` (Skeletal Mesh), `SM_` (Static Mesh), `A_` (Animation), `AB_` (AnimBlueprint), `S_` (Sound), `MX_` (Mix), `DT_` (DataTable), `DA_` (DataAsset)
- **Files**: match the class name exactly (e.g. `MyCharacter.h` / `MyCharacter.cpp` for `AMyCharacter`)
- **Folders**: `PascalCase` — `Content/Game/Characters/Player/`
- **Constants**: `PascalCase` for `static constexpr`; `ALL_CAPS` only for `#define` macros

## Performance Budgets

- **Target Framerate**: [TO BE CONFIGURED — e.g., 60 FPS on target hardware]
- **Frame Budget**: [TO BE CONFIGURED — e.g., 16.67 ms per frame at 60 FPS]
- **Draw Calls**: [TO BE CONFIGURED — e.g., < 2000 per frame]
- **Memory Ceiling**: [TO BE CONFIGURED — depends on target platform]

## Testing

- **Framework**: Unreal Automation Testing (`FAutomationTestBase`, `IMPLEMENT_SIMPLE_AUTOMATION_TEST`); functional tests for gameplay flows; Gauntlet for end-to-end automation
- **Headless CI**: `UnrealEditor-Cmd <ProjectPath> -ExecCmds="Automation RunTests <TestFilter>; Quit" -nullrhi -unattended -nopause`
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: Balance formulas, gameplay systems, networking (replication tests for any server-authoritative system)

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved UE plugins / third-party dependencies here -->
- [None configured yet — list approved UE plugins as decisions accumulate (e.g. GAS, CommonUI, Enhanced Input, etc.)]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

- **Primary**: `unreal-specialist` — UE5 lead (Blueprint vs C++ decisions, UE subsystems, optimization)
- **GAS Specialist**: `ue-gas-specialist` — abilities, gameplay effects, attribute sets, tags, prediction
- **Blueprint Specialist**: `ue-blueprint-specialist` — BP/C++ boundary, graph standards, BP optimization
- **Replication Specialist**: `ue-replication-specialist` — property replication, RPCs, prediction, relevancy, bandwidth
- **UMG/UI Specialist**: `ue-umg-specialist` — UMG, CommonUI, widget hierarchy, data binding, UI performance
- **Routing Notes**: For cross-cutting Unreal questions, route to `unreal-specialist` first; the lead delegates to sub-specialists.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| `*.h` / `*.cpp` (C++ game code) | `unreal-specialist` (or relevant programmer agent) |
| `*.uasset` Blueprint class | `ue-blueprint-specialist` |
| `WBP_*.uasset` Widget Blueprint | `ue-umg-specialist` |
| `*.usf` / `*.ush` (shader files) | `technical-artist` (UE shader/material work) |
| `*.umap` (level files) | `level-designer` |
| GAS-related assets (`GA_*`, `GE_*`, `AS_*`) | `ue-gas-specialist` |
| Networked / replicated systems | `ue-replication-specialist` |
| General Unreal architecture review | `unreal-specialist` |
