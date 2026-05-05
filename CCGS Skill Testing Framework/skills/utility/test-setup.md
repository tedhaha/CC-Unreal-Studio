# Skill Test Spec: /test-setup

## Skill Summary

`/test-setup` (Unreal-only fork) scaffolds the Unreal Automation Testing
framework + CI/CD pipeline for the project. It creates the `tests/` directory
structure (unit/, integration/, smoke/, evidence/), generates a UE test
module under `Source/<ProjectName>Tests/`, writes a working example
Automation Test, and produces a GitHub Actions workflow for headless test runs.

Each file or directory is gated behind a "May I write" ask. The skill never
overwrites existing test files — it only creates files that are missing. If
everything is already in place, it reports the configuration as verified.
No director gates apply. The verdict is COMPLETE when the scaffold is in
place (or already complete).

---

## Static Assertions (Structural)

Verified automatically by `/skill-test static` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains "May I write" / "May I create" collaborative protocol language
- [ ] Has a next-step handoff (e.g., `/test-helpers` for assertion library, `/qa-plan` for sprint test planning)

---

## Director Gate Checks

None. `/test-setup` is a scaffolding utility. No director gates apply.

---

## Test Cases

### Case 1: Happy Path — Fresh project, scaffolds full UE Automation test setup

**Fixture:**
- `technical-preferences.md` confirms engine is Unreal Engine 5.x
- No `tests/`, no `Source/<ProjectName>Tests/`, no `.github/workflows/tests.yml`

**Input:** `/test-setup`

**Expected behavior:**
1. Skill verifies the engine is Unreal (sanity check — fork is UE-only)
2. Skill drafts the plan: `tests/{unit,integration,smoke,evidence}/`,
   `Source/<ProjectName>Tests/` module + Build.cs + example test, and
   `.github/workflows/tests.yml`
3. Skill asks "May I create these files? I will not overwrite anything that already exists."
4. After approval, all files are written
5. Output includes the headless run command:
   `UnrealEditor-Cmd <ProjectPath>.uproject -ExecCmds="Automation RunTests MyGame.; Quit" -nullrhi -unattended -nopause -log`
6. Output reminds the user to add the new test module to `<ProjectName>.uproject` and the Editor target
7. Verdict is COMPLETE

**Assertions:**
- [ ] All 4 `tests/` subdirectories (unit/, integration/, smoke/, evidence/) are created
- [ ] `Source/<ProjectName>Tests/<ProjectName>Tests.Build.cs` is created
- [ ] At least one example Automation Test (`IMPLEMENT_SIMPLE_AUTOMATION_TEST(...)`) is created
- [ ] `.github/workflows/tests.yml` is created and uses the headless `-nullrhi` runner
- [ ] "May I create" is asked before writing any files
- [ ] Verdict is COMPLETE

---

### Case 2: Existing partial scaffold — only fills the gaps

**Fixture:**
- `tests/unit/` exists; `tests/smoke/` and `tests/evidence/` are missing
- `Source/<ProjectName>Tests/` exists with a Build.cs but no example test
- `.github/workflows/tests.yml` is missing

**Input:** `/test-setup`

**Expected behavior:**
1. Skill detects the existing pieces and lists what is missing
2. Skill drafts a plan that ONLY creates the missing files
3. Skill asks "May I create these missing files?"
4. After approval, only the gap files are written — existing files are untouched
5. Verdict is COMPLETE

**Assertions:**
- [ ] Skill does NOT overwrite the existing Build.cs or `tests/unit/` contents
- [ ] Only the missing files are created
- [ ] Verdict is COMPLETE

---

### Case 3: Already complete — verifies and reports no-op

**Fixture:**
- `tests/{unit,integration,smoke,evidence}/` all present
- `Source/<ProjectName>Tests/` module compiles with at least one example test
- `.github/workflows/tests.yml` exists

**Input:** `/test-setup`

**Expected behavior:**
1. Skill detects everything in place
2. Skill reports: "Test infrastructure already in place. Re-run with `/test-setup force` to regenerate any missing pieces."
3. No files are created or modified
4. Verdict is COMPLETE

**Assertions:**
- [ ] No file is written
- [ ] Skill explicitly mentions the `force` argument as the override
- [ ] Verdict is COMPLETE

---

### Case 4: Force argument — creates missing pieces even if structure exists

**Fixture:**
- `tests/unit/` exists, but `Source/<ProjectName>Tests/` is missing entirely

**Input:** `/test-setup force`

**Expected behavior:**
1. Skill skips the "already exists" early-exit
2. Skill creates the missing `Source/<ProjectName>Tests/` module + example test
3. Skill does NOT overwrite the existing `tests/unit/` contents
4. Verdict is COMPLETE

**Assertions:**
- [ ] `force` skips the early-exit but does NOT overwrite existing files
- [ ] Missing pieces are created
- [ ] Verdict is COMPLETE

---

### Case 5: Director gate check — No gate; test-setup is a scaffolding utility

**Fixture:**
- Any fixture

**Input:** `/test-setup`

**Expected behavior:**
1. Skill scaffolds and writes all test framework files (or reports verified)
2. No director agents are spawned
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is COMPLETE without any gate check

---

## Protocol Compliance

- [ ] Confirms engine is Unreal before scaffolding (sanity check, not selection)
- [ ] Generates the UE-native test setup (Automation Test module, headless CI invocation)
- [ ] Asks "May I create" before writing files
- [ ] Never overwrites existing test files — always additive
- [ ] `force` flag skips the "already exists" early-exit but never overwrites
- [ ] Surfaces the manual `<ProjectName>.uproject` / `*.Target.cs` edits required (does not attempt to auto-edit those)
- [ ] Verdict is COMPLETE when scaffold is in place or verified

---

## Coverage Notes

- The exact contents of the example Automation Test (assertion choice, category
  string) are not assertion-tested here — only that one exists and uses the
  `IMPLEMENT_SIMPLE_AUTOMATION_TEST` macro.
- CI runner choice (self-hosted vs hosted with Unreal container) is documented
  in the generated workflow but not exercised here.
- `UE_EDITOR_PATH` configuration is documented in the post-setup summary but
  the user must set it on the runner manually.
