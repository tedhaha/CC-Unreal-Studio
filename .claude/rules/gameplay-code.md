---
paths:
  - "Source/**/Gameplay/**"
  - "src/gameplay/**"
---

# Gameplay Code Rules (Unreal Engine 5)

- ALL gameplay values MUST come from `UDataAsset`, `UDataTable`, or
  `UPROPERTY(EditAnywhere)` exposed config — NEVER hardcoded constants
- Use `DeltaTime` for ALL time-dependent calculations (frame-rate independence)
- NO direct references from gameplay code to UMG widget classes — use
  delegates / events for cross-system communication
- Every gameplay system must implement a clear C++ interface (`UInterface`)
  or a documented set of public functions
- State machines must have explicit transition tables (UENUM + switch, or a
  `UStateTreeComponent`) with documented states
- Write Automation Tests for all pure-logic gameplay code — separate logic
  from `UWorld` / `AActor` dependencies via plain structs and
  `UBlueprintFunctionLibrary` helpers
- Document which design doc each feature implements in C++ doc comments
- No `Singleton`-style static state — prefer `UGameInstanceSubsystem`,
  `UWorldSubsystem`, or `UGameplayMessageSubsystem` for shared state

## Examples

**Correct** (data-driven):

```cpp
// UCombatTuning is a UDataAsset edited by designers; never hardcode the value.
const float BaseDamage = CombatTuning ? CombatTuning->BaseDamage : 0.f;
const float Speed      = CharacterStats.MovementSpeed * DeltaTime;
```

**Incorrect** (hardcoded):

```cpp
const float BaseDamage = 25.f;   // VIOLATION: hardcoded gameplay value
const float Speed      = 5.f;    // VIOLATION: not from data asset, ignores DeltaTime
```
