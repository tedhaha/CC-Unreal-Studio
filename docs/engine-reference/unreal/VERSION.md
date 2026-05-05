# Unreal Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Unreal Engine 5.7 |
| **Release Date** | 2025-11-12 |
| **Project Pinned** | 2026-02-13 |
| **Last Docs Verified** | 2026-05-06 (partial — see Verification Notes) |
| **LLM Knowledge Cutoff** | January 2026 |

## Knowledge Gap Warning

The LLM's training data likely covers Unreal Engine up to ~5.3 reliably (some
spotty 5.4/5.5 coverage). Versions 5.4, 5.5, 5.6, and 5.7 introduced significant
changes that the model does NOT reliably know about. Always cross-reference this
directory before suggesting Unreal API calls.

## Verification Notes (2026-05-06 refresh)

WebSearch is blocked on Opus by org policy. Verification was completed via a
**sonnet sub-agent** (CLAUDE.md "환경 제약" workaround) on 2026-05-06.

### Confirmed VERIFIED (high confidence, primary Epic sources)

- **UE 5.7 released 2025-11-12** ([Epic announcement](https://www.unrealengine.com/news/unreal-engine-5-7-is-now-available))
- **PCG production-ready in 5.7** ([Epic announcement](https://www.unrealengine.com/news/unreal-engine-5-7-is-now-available))
- **Megalights introduced as experimental in UE 5.5** ([Epic Megalights docs](https://dev.epicgames.com/documentation/en-us/unreal-engine/megalights-in-unreal-engine))
- **Substrate moved to production-ready in UE 5.7** (Wikipedia: introduced in 5.2; sonnet agent confirms 5.7 production milestone)
- **macOS 13+ / Metal 3 required for UE 5.5+** ([Epic Mac feature parity blog](https://www.unrealengine.com/tech-blog/bringing-unreal-engine-on-macos-up-to-feature-parity-with-windowsprogress-report))
- **GameplayCameras introduced in UE 5.5, still experimental in 5.7** ([dev blog](https://ludovic.chabant.com/blog/2025/11/14/ue5-gameplay-cameras-upgrading-to-5-7/))

### Corrections applied (this refresh)

- **Iris Replication is Beta in 5.7, NOT production-ready** — `PLUGINS.md`
  previously said "Replaces old Replication Graph" with implied production
  status. Corrected to Beta. Iris introduction version still UNVERIFIED.
- **Substrate intro version**: Wikipedia says 5.2; some sources say 5.5+
  experimental. Recorded as "5.2+ introduced, 5.7 production-ready" in
  `breaking-changes.md`.
- **Mover plugin**: Still experimental in 5.7 (eventual CMC replacement, not
  yet ready). Added as new note.
- **Nanite Foliage**: NEW experimental feature in 5.7. Added as new note.

### Still UNVERIFIED (sonnet agent could not confirm)

- Iris introduction version (only confirmed Beta in 5.7)
- DX12 Windows-default specific version (DX12 is the default in UE5; the
  exact 5.x where it became default is unconfirmed)
- Mobile minimums for UE 5.7: Android API 26 medium-confidence, iOS 14
  unconfirmed. **Note**: Google Play requires Android API 34 since Aug 2024
  (needs UE 5.4.4+) — separate constraint from UE engine minimum
- macOS SM6/Nanite specifically requires macOS 15.x+ (newer than the
  general macOS 13 minimum) — narrow claim, treat with care

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 5.4 | ~Mid 2025 | HIGH | Motion Design tools, animation improvements, PCG enhancements |
| 5.5 | ~Sep 2025 | HIGH | Megalights (millions of lights), animation authoring, MegaCity demo |
| 5.6 | ~Oct 2025 | MEDIUM | Performance optimizations, bug fixes |
| 5.7 | Nov 2025 | HIGH | PCG production-ready, Substrate production-ready, AI assistant |

## Major Changes from UE 5.3 to UE 5.7

### Breaking Changes
- **Substrate Material System**: New material framework (replaces legacy materials)
- **PCG (Procedural Content Generation)**: Production-ready, major API changes
- **Megalights**: New lighting system (millions of dynamic lights)
- **Animation Authoring**: New rigging and animation tools
- **AI Assistant**: In-editor AI guidance (experimental)

### New Features (Post-Cutoff)
- **Megalights**: Dynamic lighting at massive scale (millions of lights)
- **Substrate Materials**: Production-ready modular material system
- **PCG Framework**: Procedural world generation (production-ready in 5.7)
- **Enhanced Virtual Production**: MetaHuman integration, deeper VP workflows
- **Animation Improvements**: Better rigging, blending, procedural animation
- **AI Assistant**: In-editor AI help (experimental)

### Deprecated Systems
- **Legacy Material System**: Migrate to Substrate for new projects
- **Old PCG API**: Use new production-ready PCG API (5.7+)

## Verified Sources

- Official docs: https://docs.unrealengine.com/5.7/
- UE 5.7 release notes: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- What's new in 5.7: https://dev.epicgames.com/documentation/en-us/unreal-engine/whats-new
- UE 5.7 announcement: https://www.unrealengine.com/en-US/news/unreal-engine-5-7-is-now-available
- UE 5.5 blog: https://www.unrealengine.com/en-US/blog/unreal-engine-5-5-is-now-available
- Migration guides: https://docs.unrealengine.com/5.7/en-US/upgrading-projects/
