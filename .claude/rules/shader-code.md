---
paths:
  - "assets/shaders/**"
  - "**/*.usf"
  - "**/*.ush"
---

# Unreal Shader & Material Code Standards

All Unreal shader/material files (`.usf`, `.ush`, custom HLSL nodes, and
shipped Material/MaterialInstance assets) must follow these standards to
maintain visual quality, performance, and platform compatibility.

## Naming Conventions
- Materials: `M_<Domain>_<Name>` — e.g. `M_Env_Water`, `M_Char_Skin`
- Material Instances: `MI_<ParentName>_<Variant>` — e.g. `MI_Env_Water_River`
- Material Functions: `MF_<Purpose>` — e.g. `MF_TriplanarSampling`
- Custom HLSL include files: `Common<Topic>.ush`, `<Feature>.usf`
- Use descriptive names that indicate the material purpose
- Group related materials in `Content/.../Materials/` subfolders by domain (Env, Char, FX, UI)

## Code Quality
- All material parameters must have descriptive names and `Group` / `SortPriority` set
- Comment non-obvious calculations in custom HLSL (especially math-heavy sections)
- No magic numbers — use named scalar parameters or documented constants
- Include authorship and purpose comment at the top of each `.usf` / `.ush` file
- Prefer Material Functions over copy-pasted node graphs

## Performance Requirements
- Document the target platform and instruction-count budget for each material
- Watch the material editor's stats panel: instruction count, sampler count, texture lookups
- Avoid dynamic branching where possible — prefer `step()`, `lerp()`, `smoothstep()`
- No texture samples inside loops
- Use `Static Switch` parameters to compile out unused features per Material Instance
- Use Substrate when targeting UE 5.7+ for layered materials (better perf than legacy layered)

## Render Pipeline / Platform
- Test materials on minimum spec target hardware
- Provide simplified Material Instances for lower scalability tiers (Low/Medium/High/Epic)
- Document which feature level / shader model is required (SM5, SM6, Mobile, etc.)
- Mark mobile-incompatible nodes explicitly when shipping for mobile

## Variant Management
- Minimize Static Switch permutations — each combination is a separate compiled shader
- Document all `Static Switch Parameter` and `Static Component Mask` keywords and their purpose
- Monitor PSO (Pipeline State Object) cache size and shader compile times per material
