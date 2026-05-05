---
paths:
  - "tests/**"
  - "Source/**/*Tests/**"
---

# Test Standards (Unreal Automation Tests)

- Test class naming: `F<System><Feature>Test` (e.g. `FHealthTakeDamageTest`)
- Test category naming: `MyGame.<System>.<Feature>` (e.g. `MyGame.Health.TakeDamage`)
- Every test must have a clear Arrange / Act / Assert structure
- Unit tests must not depend on external state (filesystem, network, editor assets)
- Functional tests must clean up after themselves (destroy spawned actors, remove worlds via `World->DestroyWorld(false)`)
- Performance tests must specify acceptable thresholds and fail if exceeded
- Test data must be defined in the test (in-memory) or in dedicated fixture
  classes — never shared mutable state across tests
- Mock external dependencies — tests should be fast and deterministic
- Every bug fix must have a regression test that would have caught the original bug

## Examples

**Correct** (proper naming + Arrange / Act / Assert):

```cpp
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FHealthTakeDamageReducesHealthTest,
    "MyGame.Health.TakeDamageReducesHealth",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FHealthTakeDamageReducesHealthTest::RunTest(const FString& Parameters)
{
    // Arrange
    UHealthComponent* Health = NewObject<UHealthComponent>();
    Health->MaxHP = 100;
    Health->CurrentHP = 100;

    // Act
    Health->TakeDamage(25, /*Instigator=*/nullptr);

    // Assert
    TestEqual(TEXT("CurrentHP after 25 damage"), Health->CurrentHP, 75);
    return true;
}
```

**Incorrect**:

```cpp
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FTest1, "MyGame.X", EAutomationTestFlags::GameFilter)
bool FTest1::RunTest(const FString& Parameters)               // VIOLATION: no descriptive name / category
{
    UHealthComponent* H = NewObject<UHealthComponent>();
    H->TakeDamage(25, nullptr);                                // VIOLATION: no arrange step, no clear assert
    return TestTrue(TEXT("hp"), H->CurrentHP < 100);           // VIOLATION: imprecise assertion (passes even if HP is -50)
}
```
