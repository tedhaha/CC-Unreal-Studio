---
paths:
  - "src/core/**"
---

# Engine Code Rules

- ZERO allocations in hot paths (update loops, rendering, physics) — pre-allocate, pool, reuse
- All engine APIs must be thread-safe OR explicitly documented as single-thread-only
- Profile before AND after every optimization — document the measured numbers
- Engine code must NEVER depend on gameplay code (strict dependency direction: engine <- gameplay)
- Every public API must have usage examples in its doc comment
- Changes to public interfaces require a deprecation period and migration guide
- Use RAII / deterministic cleanup for all resources
- All engine systems must support graceful degradation
- Before writing engine API code, consult `docs/engine-reference/` for the current engine version and verify APIs against the reference docs

## Examples

**Correct** (zero-alloc hot path):

```cpp
// Pre-allocated buffer reused each frame; cleared, not reallocated.
TArray<AActor*, TInlineAllocator<32>> NearbyCache;

void AMyActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    NearbyCache.Reset();                               // Reuse storage
    SpatialGrid->QueryRadius(GetActorLocation(), Radius, /*Out*/ NearbyCache);
}
```

**Incorrect** (allocating in hot path):

```cpp
void AMyActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    TArray<AActor*> Nearby;                            // VIOLATION: heap-allocates every frame
    UGameplayStatics::GetAllActorsOfClass(GetWorld(),  // VIOLATION: O(n) global iteration every frame
                                          AEnemy::StaticClass(), Nearby);
}
```
