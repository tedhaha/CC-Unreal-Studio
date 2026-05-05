---
name: test-setup
description: "Scaffold the Unreal Automation Testing framework + CI/CD pipeline for the project. Creates the tests/ directory structure, UE-specific test runner stubs, and a GitHub Actions workflow. Run once during Technical Setup phase before the first sprint begins."
argument-hint: "[force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Test Setup (Unreal Engine 5)

This skill scaffolds the automated testing infrastructure for the project
using **Unreal Automation Testing**. It generates the appropriate test
runner stubs, creates the standard directory layout, and wires up CI/CD so
tests run on every push.

Run this once during the Technical Setup phase, before any implementation
begins. A test framework installed at sprint start costs 30 minutes.
A test framework installed at sprint four costs 3 sprints.

**Output:** `tests/` directory + `Source/<ProjectName>Tests/` module stub +
`.github/workflows/tests.yml`

---

## Phase 1: Detect Existing State

1. **Confirm engine pin**:
   - Read `.claude/docs/technical-preferences.md` and verify `Engine: Unreal Engine 5.x`.
     This fork is Unreal-only, so this is a sanity check.

2. **Check for existing test infrastructure**:
   - Glob `tests/` — does the directory exist?
   - Glob `tests/unit/` and `tests/integration/` — do subdirectories exist?
   - Glob `.github/workflows/tests.yml` — does a CI workflow file exist?
   - Glob `Source/*Tests/` — does a UE test module exist?

3. **Report findings**:
   - "Test directory: [found / not found]. CI workflow: [found / not found]. UE test module: [found / not found]."
   - If everything already exists AND `force` was not passed:
     "Test infrastructure appears to be in place. Re-run with `/test-setup force`
     to regenerate any missing pieces. Existing test files will not be overwritten."

If `force` is passed, skip the early-exit but still do not overwrite files
that already exist.

---

## Phase 2: Present Plan

```
## Test Setup Plan — Unreal Engine 5

I will create the following (skipping any that already exist):

tests/
  unit/                    — Unit-level Automation Tests (formulas, state, logic)
  integration/             — Functional Tests / multi-system flows
  smoke/                   — Critical path test list (15-min manual gate)
  evidence/                — Screenshot and manual test sign-off records
  README.md                — Test framework documentation

Source/<ProjectName>Tests/         — UE editor-only test module
  <ProjectName>Tests.Build.cs      — Build rules (depends on AutomationTest, AutomationController)
  Public/<ProjectName>Tests.h      — Module header
  Private/<ProjectName>Tests.cpp   — Module implementation
  Private/Examples/ExampleTest.cpp — Working example (FMyExampleTest)

.github/workflows/tests.yml        — CI: run UE Automation Tests on every push

Estimated time: ~5 minutes to create all files.
```

Ask: "May I create these files? I will not overwrite any test files that
already exist at these paths."

Do not proceed without approval.

---

## Phase 3: Create Directory Structure

After approval, create the following.

### `tests/README.md`

```markdown
# Test Infrastructure

**Engine**: Unreal Engine 5.x (see `docs/engine-reference/unreal/VERSION.md`)
**Test Framework**: Unreal Automation Testing
**CI**: `.github/workflows/tests.yml`
**Setup date**: <date>

## Directory Layout

```
tests/
  unit/           # Isolated Automation Tests (formulas, state machines, logic)
  integration/    # Functional Tests (cross-system interactions, save/load, networking)
  smoke/          # Critical path test list for /smoke-check gate
  evidence/       # Screenshot logs and manual test sign-off records

Source/<ProjectName>Tests/   # UE test module — required because Automation Tests are C++
```

## Running Tests

**In editor**: `Window → Test Automation → MyGame.* → Start Tests`

**Headless / CI**:
```
UnrealEditor-Cmd <ProjectPath>.uproject \
  -ExecCmds="Automation RunTests MyGame.; Quit" \
  -nullrhi -unattended -nopause -NoLogTimes -log
```

## Test Naming

- **C++ test class**: `F<System><Feature>Test` — e.g. `FCombatDamageTest`
- **Automation category**: `MyGame.<System>.<Feature>` — e.g. `MyGame.Combat.Damage`
- **Test source files**: `<system>_<feature>_test.cpp` under `Source/<ProjectName>Tests/Private/`
- **Helper macro**: `IMPLEMENT_SIMPLE_AUTOMATION_TEST(...)` for stateless logic tests

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automation Test — must pass | `Source/<ProjectName>Tests/Private/Unit/` |
| Integration | Functional Test (in-level actor) OR documented playtest | `Content/Tests/Functional/` |
| Visual/Feel | Screenshot + lead sign-off | `tests/evidence/` |
| UI | Manual walkthrough OR interaction test | `tests/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.
```

### Engine-specific files

#### Source module stub (`Source/<ProjectName>Tests/<ProjectName>Tests.Build.cs`)

```csharp
// <ProjectName>Tests.Build.cs
using UnrealBuildTool;

public class <ProjectName>Tests : ModuleRules
{
    public <ProjectName>Tests(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[]
        {
            "Core", "CoreUObject", "Engine", "<ProjectName>"
        });
        PrivateDependencyModuleNames.AddRange(new string[]
        {
            "AutomationController", "FunctionalTesting", "UnrealEd"
        });
    }
}
```

#### Example test (`Source/<ProjectName>Tests/Private/Examples/ExampleTest.cpp`)

```cpp
#include "Misc/AutomationTest.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FMyGameExampleTest,
    "MyGame.Examples.PlaceholderArithmetic",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FMyGameExampleTest::RunTest(const FString& Parameters)
{
    TestEqual(TEXT("2 + 2 should equal 4"), 2 + 2, 4);
    return true;
}
```

#### Module header / impl

Create minimal `<ProjectName>Tests.h` and `<ProjectName>Tests.cpp` with
`IMPLEMENT_MODULE(FDefaultModuleImpl, <ProjectName>Tests)`.

Add the new module name to `<ProjectName>.uproject` under `Modules` with
`"LoadingPhase": "Default", "AdditionalDependencies": [...]` and to the
appropriate `<ProjectName>Editor.Target.cs` `ExtraModuleNames`.

---

## Phase 4: Create CI/CD Workflow

Create `.github/workflows/tests.yml`:

```yaml
name: UE Automation Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run UE Automation Tests
    # UE requires a runner with the Unreal Editor installed (and a license).
    # Self-hosted is the most common setup. game.ci/unreal-action also works
    # if you have an EpicGames container image and a valid auth flow.
    runs-on: self-hosted

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Run Automation Tests
        run: |
          "$UE_EDITOR_PATH" "${{ github.workspace }}/<ProjectName>.uproject" \
            -ExecCmds="Automation RunTests MyGame.; Quit" \
            -nullrhi -unattended -nopause -NoLogTimes -log
        shell: bash

      - name: Upload Logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ue-test-logs
          path: Saved/Logs/
```

> **Note**: UE CI requires either a self-hosted runner with Unreal Editor
> installed, or a hosted GitHub Actions runner with an Unreal container
> image. Set `UE_EDITOR_PATH` (e.g. `C:/Program Files/Epic Games/UE_5.7/Engine/Binaries/Win64/UnrealEditor-Cmd.exe`)
> as a runner environment variable.

---

## Phase 5: Create Smoke Test Seed

Create `tests/smoke/critical-paths.md`:

```markdown
# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Standalone client launches to main menu without crash
2. New game / session can be started from the main menu
3. Main menu responds to all inputs (KB+M and gamepad) without freezing
4. Editor PIE (Play In Editor) launches the test map without warnings in the Output Log

## Core Mechanic (update per sprint)

<!-- Add the primary mechanic for each sprint here as it is implemented -->
5. [Primary mechanic — update when first core system is implemented]

## Data Integrity

6. Save game completes without error (once save system is implemented)
7. Load game restores correct state (once load system is implemented)

## Performance

8. No visible frame rate drops on target hardware (60fps target)
9. No memory growth over 5 minutes of play (once core loop is implemented)
10. Stat unit / stat unitGraph stays within budget (CPU/GPU/draw thread)
```

---

## Phase 6: Post-Setup Summary

After writing all files, report:

```
Unreal test infrastructure created.

Files created:
- tests/README.md
- tests/unit/ (directory)
- tests/integration/ (directory)
- tests/smoke/critical-paths.md
- tests/evidence/ (directory)
- Source/<ProjectName>Tests/<ProjectName>Tests.Build.cs
- Source/<ProjectName>Tests/Private/Examples/ExampleTest.cpp
- Source/<ProjectName>Tests/Public/<ProjectName>Tests.h (module header)
- Source/<ProjectName>Tests/Private/<ProjectName>Tests.cpp (module impl)
- .github/workflows/tests.yml

Next steps:
1. Add the new test module to <ProjectName>.uproject and the Editor target
2. Regenerate project files (right-click .uproject → Generate Visual Studio project files)
3. Build the editor target — confirm the example test compiles
4. Open the editor → Window → Test Automation → run "MyGame.Examples.PlaceholderArithmetic"
5. Configure UE_EDITOR_PATH on your CI runner
6. Run `/qa-plan sprint` before your first sprint to classify stories
7. `/smoke-check` before every QA hand-off

Gate note: /gate-check Technical Setup → Pre-Production now requires:
- tests/ directory with unit/ and integration/ subdirectories
- .github/workflows/tests.yml
- Source/<ProjectName>Tests/ module that compiles
- At least one passing example Automation Test

Verdict: **COMPLETE** — Unreal test framework scaffolded and CI/CD wired up.
```

---

## Collaborative Protocol

- **Never overwrite existing test files** — only create files that are missing.
  If a test stub exists, leave it as-is.
- **Always ask before creating files** — Phase 2 requires explicit approval.
- **`force` flag skips the "already exists" early-exit but never overwrites.**
  It means "create any missing files even if the directory already exists."
- Do not attempt to modify `<ProjectName>.uproject` or `*.Target.cs` automatically
  unless the user explicitly asks — surface the required edits in the summary instead.
- `UE_EDITOR_PATH` and any Epic Games runner credentials must be configured
  manually by the user. Do not attempt to automate license / authentication.
