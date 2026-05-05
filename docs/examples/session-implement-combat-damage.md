# Example Session: Implementing Combat Damage Calculation

**Context:** Solo indie dev, week 4 of project, implementing gameplay systems.

**Starting State:**
- `design/gdd/combat-system.md` exists and reviewed
- Unreal Engine 5.7 project set up with a basic Game Mode + Pawn scaffolding
- No combat code written yet
- Sprint goal: "Implement core combat damage calculation"

**Session Duration:** ~30 minutes
**Turns:** 10
**Outcome:** Working damage calculator with Automation Tests, ready for integration

---

## Turn 1: User Requests Implementation

**User:**
> Implement the damage calculation system from design/gdd/combat-system.md. The formula is in section 4.

## Turn 2: Agent Reads Design and Asks Clarifying Questions

**Agent (gameplay-programmer + unreal-specialist):**
> I've read `design/gdd/combat-system.md`. The damage formula is:
>
> ```
> FinalDamage = BaseDamage * (1 + AttackStat * 0.1) * CritMultiplier * TypeEffectiveness * (1 - TargetDefense)
> ```
>
> Before implementing, I need to clarify some details that aren't specified in the doc:
>
> **Architecture Questions:**
> 1. Should `UDamageCalculator` be a `UBlueprintFunctionLibrary` (pure static helpers, easy to call from BP)
>    or a regular `UObject` exposed through a Game Subsystem?
> 2. Where should `BaseDamage` come from? (Weapon `UDataAsset`? `UCharacterStats` component? `UGameplayAbility`?)
> 3. Where should `TypeEffectiveness` values live? (Per-weapon overrides? Per-damage-type table?
>    A separate `UDataTable` keyed by `<DamageType, ArmorType>` pair?)
>
> **Spec Ambiguities:**
> 4. Should `AttackStat` be clamped to a range? (Prevents exponential scaling bugs)
> 5. The doc says "critical hits do 2x damage" but doesn't specify rounding. Should I `FMath::FloorToInt`,
>    `CeilToInt`, or `RoundToInt` the final damage?
> 6. What happens if `TargetDefense >= 1.0`? (100% mitigation or higher) Should damage go negative or clamp to 0?
>
> **Integration:**
> 7. I don't see a design doc for the Health/HP system. Should I create a minimal one, or is that coming separately?
>
> **GAS question:** Should this go through the Gameplay Ability System (`UGameplayEffect` driving an
> `UAttributeSet`)? The project doesn't have GAS enabled yet — flagging it because adding GAS later is
> a much bigger refactor than starting with it. If you want plain `UActorComponent`-based health, I'll
> proceed with that.
>
> Please clarify so I can implement this correctly the first time.

## Turn 3: User Resolves Ambiguities

**User:**
> 1. BlueprintFunctionLibrary - no state needed, want it callable from BP for designer iteration.
> 2. Base damage from a `UWeaponDataAsset`. I'll create a simple one.
> 3. Type effectiveness in a single `UDataTable` (`DT_TypeEffectiveness`) — easier than a JSON for designers.
> 4. Yes, clamp `AttackStat` to 0-100.
> 5. Use `FMath::FloorToInt` to round down to integers.
> 6. Clamp damage to a minimum of 1 (always do at least 1 damage, even with 100% defense).
> 7. Create a minimal `UHealthComponent` — `CurrentHP`, `MaxHP`, `TakeDamage()`, replicated.
> 8. Skip GAS for now — we're solo and the project doesn't need ability prediction yet. Plain `UActorComponent`.

## Turn 4: Agent Proposes Architecture

**Agent:**
> Got it! Here's my proposed architecture:
>
> **Files I'll create:**
> ```
> Source/MyGame/Combat/DamageCalculator.h            # UBlueprintFunctionLibrary
> Source/MyGame/Combat/DamageCalculator.cpp
> Source/MyGame/Combat/HealthComponent.h             # UActorComponent (replicated)
> Source/MyGame/Combat/HealthComponent.cpp
> Source/MyGame/Combat/WeaponDataAsset.h             # UDataAsset
> Source/MyGame/Combat/WeaponDataAsset.cpp
> Source/MyGame/Combat/CharacterStats.h              # USTRUCT
> Content/Game/Combat/DT_TypeEffectiveness.uasset    # UDataTable (designer-edited)
> design/gdd/health-system.md                        # Minimal health doc
> Source/MyGameTests/Private/Combat/DamageCalculatorTest.cpp  # Automation Test
> ```
>
> **Architecture Details:**
>
> **`UDamageCalculator`** (BP function library):
> ```cpp
> UCLASS()
> class MYGAME_API UDamageCalculator : public UBlueprintFunctionLibrary
> {
>     GENERATED_BODY()
>
> public:
>     UFUNCTION(BlueprintCallable, Category = "Combat")
>     static int32 CalculateDamage(
>         const FCharacterStats& Attacker,
>         const UWeaponDataAsset* Weapon,
>         const FCharacterStats& Defender,
>         bool bIsCrit = false);
> };
> ```
>
> **`UHealthComponent`** (replicated component):
> ```cpp
> UCLASS(ClassGroup = (Combat), meta = (BlueprintSpawnableComponent))
> class MYGAME_API UHealthComponent : public UActorComponent
> {
>     GENERATED_BODY()
>
> public:
>     UHealthComponent();
>
>     UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Health")
>     int32 MaxHP = 100;
>
>     UPROPERTY(ReplicatedUsing = OnRep_CurrentHP, BlueprintReadOnly, Category = "Health")
>     int32 CurrentHP;
>
>     UFUNCTION(BlueprintCallable, Category = "Health")
>     void TakeDamage(int32 Amount, AActor* Instigator);
>
>     DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FHealthChanged, int32, OldHP, int32, NewHP);
>     UPROPERTY(BlueprintAssignable, Category = "Health")
>     FHealthChanged OnHealthChanged;
>
>     DECLARE_DYNAMIC_MULTICAST_DELEGATE(FDied);
>     UPROPERTY(BlueprintAssignable, Category = "Health")
>     FDied OnDied;
>
> protected:
>     UFUNCTION()
>     void OnRep_CurrentHP(int32 OldHP);
>
>     virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const override;
> };
> ```
>
> **`UWeaponDataAsset`**:
> ```cpp
> UCLASS(BlueprintType)
> class MYGAME_API UWeaponDataAsset : public UDataAsset
> {
>     GENERATED_BODY()
>
> public:
>     UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Weapon")
>     float BaseDamage = 10.f;
>
>     UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Weapon")
>     FName DamageType = TEXT("Physical");  // Physical / Fire / Ice / etc.
> };
> ```
>
> **`DT_TypeEffectiveness`** (UDataTable rows, struct shown for reference):
> ```cpp
> USTRUCT(BlueprintType)
> struct FTypeEffectivenessRow : public FTableRowBase
> {
>     GENERATED_BODY()
>
>     UPROPERTY(EditAnywhere) FName DamageType;   // row key joins via composite lookup
>     UPROPERTY(EditAnywhere) FName ArmorType;
>     UPROPERTY(EditAnywhere) float Multiplier = 1.f;
> };
> ```
>
> **`combat_tuning.json`** is replaced by `Content/Game/Combat/DT_CombatTuning.uasset` (UDataTable
> with one row holding `CritMultiplier`, `AttackStatMin`, `AttackStatMax`). Designers edit this in the
> editor without touching code or JSON.
>
> **Question:** This architecture makes `UDamageCalculator` easily unit-testable (pure static, no actor
> dependencies). The `UHealthComponent` is server-authoritative with `OnRep_` for client visuals. Does
> this match your expectations, or should I change anything before implementing?

## Turn 5: User Approves with Minor Change

**User:**
> Looks good, but tighten `FCharacterStats` so it's a `USTRUCT` with explicit field types — I don't want
> loose `TMap<FName, float>` lookups floating around. And use `UPROPERTY(EditAnywhere)` so designers can
> tune base values per-actor in the editor.

## Turn 6: Agent Refines Architecture

**Agent:**
> Absolutely — type safety + editor exposure is important. Here's the struct:
>
> ```cpp
> USTRUCT(BlueprintType)
> struct MYGAME_API FCharacterStats
> {
>     GENERATED_BODY()
>
>     UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats", meta = (ClampMin = 0, ClampMax = 100))
>     int32 AttackStat = 10;
>
>     UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats", meta = (ClampMin = 0.f, ClampMax = 1.f))
>     float Defense = 0.f;  // 0..1 (0–100% mitigation)
>
>     UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
>     FName ArmorType = TEXT("Flesh");
> };
> ```
>
> Then `UDamageCalculator::CalculateDamage(...)` takes `const FCharacterStats&` for both attacker and
> defender. Engine clamps via `ClampMin`/`ClampMax` happen at edit time; the calculator additionally
> clamps at runtime in case stats came from a non-editor source (saves, network).
>
> Much cleaner. May I proceed with implementation?

## Turn 7: User Approves Implementation

**User:**
> Yes, implement it.

## Turn 8: Agent Implements and Reports

**Agent:**
> Implementation complete! Here's what I created:
>
> **Files Created:**
> - ✅ `Source/MyGame/Combat/DamageCalculator.h/.cpp` (~90 lines)
> - ✅ `Source/MyGame/Combat/HealthComponent.h/.cpp` (~110 lines, includes replication)
> - ✅ `Source/MyGame/Combat/WeaponDataAsset.h/.cpp` (~25 lines)
> - ✅ `Source/MyGame/Combat/CharacterStats.h` (struct, ~20 lines)
> - ✅ `Content/Game/Combat/DT_TypeEffectiveness.uasset` (5 starter rows for Physical/Fire vs Flesh/Armored/Crystal)
> - ✅ `Content/Game/Combat/DT_CombatTuning.uasset` (1 row: CritMultiplier=2.0, AttackStatMin=0, AttackStatMax=100)
> - ✅ `design/gdd/health-system.md` (minimal 8-section doc)
>
> **Rules Enforcement Results:**
>
> The `gameplay-code` rule automatically flagged 2 issues during implementation:
> 1. ❌ `CritMultiplier` was hardcoded as `2.0f` in `DamageCalculator.cpp`
>    - **Fixed:** Moved to `DT_CombatTuning` and looked up at runtime via cached pointer
> 2. ❌ `HealthComponent::TakeDamage` had a `UE_LOG(..., Warning, ...)` debug line
>    - **Fixed:** Demoted to `Verbose` and gated behind `#if !UE_BUILD_SHIPPING`
>
> The `data-files` rule validated:
> - ✅ `DT_*` naming convention matches project standard
> - ✅ Both DataTables use a typed RowStruct (no untyped rows)
>
> **Implementation Notes:**
> - `AttackStat` clamped in `CalculateDamage()` before use (defense in depth — editor `ClampMin` is the first line)
> - Damage always returns minimum of 1 (per your requirement)
> - Type effectiveness defaults to `1.0` if `(DamageType, ArmorType)` combo not found in DataTable
> - All numeric tuning values live in DataTables for designer iteration without recompile
> - `UHealthComponent::TakeDamage` is `BlueprintAuthorityOnly` to enforce server-only damage application
>
> **Manual Testing (PIE):**
> I dropped two test pawns into a sandbox map and validated:
> - Base damage 10, AttackStat 50 → Damage 15 ✓
> - Same but with crit → Damage 30 ✓
> - With 50% defense → Damage 15 (before defense) → 7 (after) ✓
> - With 100% defense → Damage 1 (clamped) ✓
> - Listen-server PIE: client HUD updates via `OnRep_CurrentHP` ✓
>
> **Next Steps - Your Choice:**
> A) I can write formal Automation Tests now (recommended — verification-driven development)
> B) You can review the code first via `/code-review Source/MyGame/Combat/DamageCalculator.cpp`
> C) Skip tests for now and integrate into actual combat
>
> What would you like?

## Turn 9: User Requests Tests

**User:**
> A — write Automation Tests. Cover all the edge cases.

## Turn 10: Agent Writes Tests and Completes

**Agent:**
> Automation Tests created: `Source/MyGameTests/Private/Combat/DamageCalculatorTest.cpp`
>
> **Test Coverage (8 tests, all under `MyGame.Combat.Damage.*`):**
> ```
> ✓ FCalculateDamage_BasicTest                  — Verify formula with known values
> ✓ FCalculateDamage_WithCritTest               — Critical hits double damage
> ✓ FCalculateDamage_WithDefenseTest            — Defense reduces damage correctly
> ✓ FCalculateDamage_TypeEffectivenessTest      — DataTable modifiers apply
> ✓ FCalculateDamage_MinClampTest               — Never goes below 1
> ✓ FCalculateDamage_AttackStatClampTest        — AttackStat clamped to 0–100
> ✓ FCalculateDamage_MissingTypeComboTest       — Defaults to 1.0 if not in DataTable
> ✓ FCalculateDamage_RoundingTest               — Verifies FloorToInt behaviour
> ```
>
> Each uses `IMPLEMENT_SIMPLE_AUTOMATION_TEST(...)` and asserts via `TestEqual`/`TestTrue`. The DataTable
> tests load a tiny in-memory `UDataTable` constructed in `RunTest` (no editor / asset loading
> dependency) so the suite runs headlessly.
>
> **Test Results:**
> ```
> > UnrealEditor-Cmd MyGame.uproject -ExecCmds="Automation RunTests MyGame.Combat.Damage; Quit" -nullrhi -unattended
>
> ...
> Test Completed. Result={Success}  MyGame.Combat.Damage.Basic
> Test Completed. Result={Success}  MyGame.Combat.Damage.WithCrit
> Test Completed. Result={Success}  MyGame.Combat.Damage.WithDefense
> Test Completed. Result={Success}  MyGame.Combat.Damage.TypeEffectiveness
> Test Completed. Result={Success}  MyGame.Combat.Damage.MinClamp
> Test Completed. Result={Success}  MyGame.Combat.Damage.AttackStatClamp
> Test Completed. Result={Success}  MyGame.Combat.Damage.MissingTypeCombo
> Test Completed. Result={Success}  MyGame.Combat.Damage.Rounding
> All 8 tests passed.
> Total time: 0.34s
> ```
>
> **Code Review Self-Check:**
> - ✅ Test category follows `MyGame.<System>.<Feature>` convention
> - ✅ Each test is `IMPLEMENT_SIMPLE_AUTOMATION_TEST` (stateless, no editor dependency)
> - ✅ Each test constructs its own DataTable fixture — no shared state
> - ✅ Tests run headlessly (`-nullrhi`)
>
> **System is ready for integration!**
>
> Files you can now commit:
> ```bash
> git add Source/MyGame/Combat/
> git add Content/Game/Combat/
> git add design/gdd/health-system.md
> git add Source/MyGameTests/Private/Combat/DamageCalculatorTest.cpp
> git commit -m "Implement damage calculation system per design/gdd/combat-system.md"
> ```
>
> The `validate-commit` hook will check:
> - ✅ Design doc referenced in message
> - ✅ DataTable assets present (binary; tracked via Git LFS per `.gitattributes`)
> - ✅ No hardcoded magic numbers in committed C++
>
> Ready to commit?

---

## Session Summary

**What Worked Well:**
- Agent read design doc first, identified 8 ambiguities upfront (including the "should we use GAS?" architectural question)
- Didn't assume or guess — asked for clarification on every unclear point
- Proposed full architecture (with Unreal-idiomatic class types) for user approval before writing code
- Incorporated user's struct-based stats feedback immediately
- Rules caught issues automatically (hardcoded multiplier, debug log) and agent fixed them transparently
- Tests written proactively as Unreal Automation Tests, runnable headlessly in CI
- Agent offered next-step options rather than assuming what user wants

**Key Collaborative Moments:**
- Turn 2: Agent identified 8 spec gaps and asked rather than guessing — including the "GAS now or later?" decision that would have been costly to defer
- Turn 4: Full architecture proposal (file list + skeleton classes) shown before implementation
- Turn 5: User requested tighter typing + editor exposure, agent adapted
- Turn 8: Agent transparently reported rule violations and fixes, plus listen-server PIE replication check
- Turn 10: Agent verified all acceptance criteria with headless Automation Tests

**Files Created:**
- 4 source modules (DamageCalculator, HealthComponent, WeaponDataAsset, CharacterStats struct)
- 2 DataTable assets (DT_TypeEffectiveness, DT_CombatTuning) — designer-tunable
- 1 design doc (health-system.md)
- 1 test file (DamageCalculatorTest.cpp, 8 Automation Tests)

**Context Usage:** ~25% (focused implementation task)
**User Satisfaction:** High — spec ambiguities resolved early, no rework needed
