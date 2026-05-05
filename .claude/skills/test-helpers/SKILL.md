---
name: test-helpers
description: "Generate Unreal-specific test helper libraries for the project's test suite. Reads existing test patterns and produces tests/helpers/ with assertion macros, factory functions, and world-creation utilities tailored to the project's systems. Reduces boilerplate in new Automation Tests and Functional Tests."
argument-hint: "[system-name | all | scaffold]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

# Test Helpers (Unreal Engine 5)

Writing Automation Tests is faster and more consistent when common setup,
teardown, and assertion patterns are abstracted into helpers. This skill
generates a `tests/helpers/` library tailored to **Unreal Engine 5** and the
project's actual systems — so every developer writes less boilerplate and
more assertions.

**Output:** `tests/helpers/` directory with UE-specific helper files
(C++ headers/macros, plus optional Blueprint Function Library stubs).

**When to run:**
- After `/test-setup` scaffolds the framework (first time)
- When multiple test files repeat the same setup boilerplate
- When starting to write tests for a new system

---

## 1. Parse Arguments

**Modes:**
- `/test-helpers [system-name]` — generate helpers for a specific system
  (e.g., `/test-helpers combat`)
- `/test-helpers all` — generate helpers for all systems with test files
- `/test-helpers scaffold` — generate only the base helper library (no
  system-specific helpers); use this on first run
- No argument — run `scaffold` if no helpers exist, else `all`

---

## 2. Confirm Engine Pin

Read `.claude/docs/technical-preferences.md` and verify
`Engine: Unreal Engine 5.x`. This fork is Unreal-only — if anything else is
configured, surface the discrepancy and stop.

Also confirm the test module exists (created by `/test-setup`):
- `Source/<ProjectName>Tests/`

If it does not exist: "Test module not found. Run `/test-setup` first, then re-run `/test-helpers`."

---

## 3. Load Existing Test Patterns

Scan the test directory for patterns already in use:

```
Glob pattern="Source/<ProjectName>Tests/Private/**/*.cpp"
Glob pattern="Content/Tests/**/*.uasset"
```

For a representative sample (up to 5 files), read existing test sources and extract:
- How `IMPLEMENT_SIMPLE_AUTOMATION_TEST` / `BEGIN_DEFINE_SPEC` are used
- Common `TestEqual` / `TestTrue` / `AddExpectedError` patterns
- How temporary worlds and actors are constructed for tests
- How GAS attribute sets, replication, or UMG widgets are exercised in tests

This ensures generated helpers match the project's existing style, not a
generic template.

Also read:
- `design/gdd/systems-index.md` — to know which systems exist
- In-scope GDD(s) — to understand what data types and value bounds need testing
- `docs/architecture/tr-registry.yaml` — to map requirements to tested systems

---

## 4. Generate Base Helpers (UE Automation Tests)

### `Source/<ProjectName>Tests/Public/Helpers/GameTestHelpers.h`

```cpp
#pragma once

#include "CoreMinimal.h"
#include "Misc/AutomationTest.h"
#include "Engine/World.h"
#include "Engine/Engine.h"

/**
 * Game-specific assertion macros and helpers for <ProjectName> automation tests.
 * Include in any test file that needs domain-specific assertions.
 *
 * Usage:
 *   GAME_TEST_ASSERT_IN_RANGE(this, DamageValue, 10.0f, 50.0f, TEXT("Damage"));
 */

// Assert a float value is within inclusive range [Min, Max].
// `Test` is the FAutomationTestBase pointer (usually `this` inside RunTest).
#define GAME_TEST_ASSERT_IN_RANGE(Test, Value, Min, Max, Label) \
    Test->TestTrue( \
        FString::Printf(TEXT("%s (%.2f) in range [%.2f, %.2f]"), Label, Value, Min, Max), \
        (Value) >= (Min) && (Value) <= (Max) \
    )

// Assert a UObject pointer is valid (not null, not pending kill).
#define GAME_TEST_ASSERT_VALID(Test, Ptr, Label) \
    Test->TestTrue( \
        FString::Printf(TEXT("%s is valid"), Label), \
        IsValid(Ptr) \
    )

// Assert an Actor was spawned successfully.
#define GAME_TEST_ASSERT_SPAWNED(Test, ActorPtr, ClassName) \
    Test->TestNotNull( \
        *FString::Printf(TEXT("Spawned actor of class %s"), TEXT(#ClassName)), \
        ActorPtr \
    )

// Assert two FGameplayTag values are equal (matches by exact tag).
#define GAME_TEST_ASSERT_TAG_EQUAL(Test, Actual, Expected) \
    Test->TestTrue( \
        FString::Printf(TEXT("Tag '%s' == '%s'"), *Actual.ToString(), *Expected.ToString()), \
        Actual == Expected \
    )

namespace GameTestHelpers
{
    /**
     * Create a minimal test world.
     * Caller is responsible for calling DestroyTestWorld() in teardown.
     */
    inline UWorld* CreateTestWorld(const FString& WorldName = TEXT("TestWorld"))
    {
        UWorld* World = UWorld::CreateWorld(EWorldType::Game, /*bInformEngineOfWorld=*/false, FName(*WorldName));
        FWorldContext& WorldContext = GEngine->CreateNewWorldContext(EWorldType::Game);
        WorldContext.SetCurrentWorld(World);
        return World;
    }

    inline void DestroyTestWorld(UWorld* World)
    {
        if (!World) { return; }
        GEngine->DestroyWorldContext(World);
        World->DestroyWorld(false);
    }

    /** Spawn an Actor in a test world with default transform. */
    template<typename T>
    inline T* SpawnTestActor(UWorld* World)
    {
        if (!World) { return nullptr; }
        return World->SpawnActor<T>();
    }
}
```

### `Source/<ProjectName>Tests/Public/Helpers/GameTestFactory.h`

Lightweight factory helpers for common gameplay objects (no scene loading required):

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameTestHelpers.h"
// Forward-declare project types as needed.

namespace GameTestFactory
{
    // Replace with the actual character / pawn types from your project.
    // Example signature:
    //   APlayerCharacter* MakePlayer(UWorld* World, float Health = 100.f);
}
```

> The factory header starts as a stub because the actual types only exist
> once gameplay code is written. `/test-helpers <system>` populates this with
> system-specific factories as the project grows.

---

## 5. Generate System-Specific Helpers

For `[system-name]` or `all` modes, generate one helper per system.

Read the system's GDD to extract:
- Data types (entity types, component names, attribute set names, gameplay tags)
- Formula variables and their bounds (Damage min/max, Crit chance range, etc.)
- Common test scenarios mentioned in **Edge Cases**

Generate `Source/<ProjectName>Tests/Public/Helpers/<System>TestFactory.h` with
factory functions and bounds constants specific to that system.

Example pattern for a `combat` system:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameTestHelpers.h"

/**
 * Factory and bounds helpers for Combat system tests.
 * Generated by /test-helpers combat on <date>.
 * Based on: design/gdd/combat.md
 */
namespace CombatTestFactory
{
    constexpr float DamageMin = 0.f;
    constexpr float DamageMax = 999.f;   // From GDD: damage formula upper bound
    constexpr float CritChanceMin = 0.f;
    constexpr float CritChanceMax = 1.f;

    /** Create a minimal attacker actor for damage formula tests. */
    AActor* MakeAttacker(UWorld* World, float Attack = 10.f, float CritChance = 0.f);

    /** Create a minimal target actor for damage receive tests. */
    AActor* MakeTarget(UWorld* World, float Defense = 0.f, float Health = 100.f);

    /** Assert a damage output is within GDD-specified bounds. */
    inline void AssertDamageInBounds(FAutomationTestBase* Test, float Damage)
    {
        GAME_TEST_ASSERT_IN_RANGE(Test, Damage, DamageMin, DamageMax, TEXT("Damage"));
    }
}
```

Include a matching `.cpp` stub when the function bodies need real
project-type knowledge — leave a `// TODO: implement once <type> exists` line
inside the stub rather than guessing.

---

## 6. Optional: Blueprint Function Library

If the project uses Functional Tests authored as Blueprint actors in
`Content/Tests/Functional/`, also generate a `UBlueprintFunctionLibrary`
exposing the same assertion helpers to BP graphs:

```cpp
// Source/<ProjectName>Tests/Public/Helpers/GameTestBPLibrary.h
UCLASS()
class UGameTestBPLibrary : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category = "Tests|Assertions")
    static bool AssertInRange(float Value, float Min, float Max, FString Label);
};
```

---

## 7. Write Output

Present a summary of what will be created:

```
## Test Helpers to Create (Unreal Engine 5)

Base helpers:
- Source/<ProjectName>Tests/Public/Helpers/GameTestHelpers.h
- Source/<ProjectName>Tests/Public/Helpers/GameTestFactory.h
[Optional: GameTestBPLibrary.h/.cpp]

System helpers (<mode>):
- Source/<ProjectName>Tests/Public/Helpers/<System>TestFactory.h  ← from <system> GDD
```

Ask: "May I write these helper files?"

**Never overwrite existing files.** If a file already exists, report:
"Skipping `<path>` — already exists. Remove the file manually if you want it
regenerated."

After writing:

```
Verdict: COMPLETE — UE test helpers created.

To use them in a test:
  #include "Helpers/GameTestHelpers.h"
  #include "Helpers/<System>TestFactory.h"

Then build the editor target so the new files compile in.
```

---

## Collaborative Protocol

- **Never overwrite existing helpers** — they may contain hand-written
  customisations. Only generate new files that don't exist yet.
- **Generated code is a starting point** — the generated factory functions
  use placeholder signatures; adapt to the real project class structure
  once the code exists.
- **Helpers should reflect the GDD** — bounds and constants in helpers
  should trace to GDD Formulas sections, not invented values.
- **Ask before writing** — always confirm before creating files under `Source/<ProjectName>Tests/`.

## Next Steps

- Run `/test-setup` if the test module has not been scaffolded yet.
- Use `/dev-story` to implement stories — helpers reduce boilerplate in new test files.
- Run `/skill-test` to validate other skills that may need helper coverage.
