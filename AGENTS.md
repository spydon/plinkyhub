# Agents

## Code Style

Do not use abbreviations in variable names, function names, or comments. Always use full, descriptive names (e.g. `parameter` not `p`, `configuration` not `config`, `application` not `app`).

## Flutter Widgets

Never use `_build*` helper methods to construct UI subtrees. Extract them into separate widget classes instead. This improves readability, enables the framework to optimize rebuilds, and keeps widget trees explicit.

## Code Quality

Always run `dart format .` before committing to ensure consistent formatting. Then run `dart analyze`. There must be zero issues (errors, warnings, or infos) in any code you write or modify, including in files you did not change. ALL analyze issues must be fixed, even `info`-level hints. Run `dart fix --apply` first to auto-fix what it can, then resolve any remaining issues manually.

## Routing

Use `context.go(path)` for all in-app navigation, never `context.push`.

Why: the app's top-level routes live inside a `StatefulShellRoute.indexedStack`, and all item detail routes (e.g. `/<username>/preset/<name>`) live outside the shell. When you call `context.push` from inside a shell branch, go_router pushes onto that branch's nested navigator, so the page renders but the browser URL stays on the branch's URL (e.g. `/users/highscore`). Setting `parentNavigatorKey: _rootNavigatorKey` on the target route does not fix this. `context.go` replaces the location cleanly, updates the browser URL, and records a history entry so browser-back still works.

How to apply:
- In-app back navigation: always use `context.go(parentPath)`. Do not rely on `context.canPop()` / `context.pop()`, since `go` does not leave anything to pop.
- Dialog dismissal via `Navigator.of(dialogContext).pop()` is fine and unrelated — that pops the dialog route, not the app navigation.
- The one `BackButton` in `_ItemPageShell` (in `lib/router.dart`) derives its target from `_parentRouteFor(currentPath)`. If you add a new item/detail route, extend `_parentRouteFor` so back navigation lands somewhere sensible.

## Database

**IMPORTANT:** All DDL and schema changes **must be** written as migration files under `supabase/migrations/` (named `YYYYMMDDHHMMSS_description.sql`). Never apply DDL directly via `execute_sql` or the `apply_migration` MCP tool. Always create a migration file first. Migrations are applied automatically by the CI/CD pipeline and should not be applied manually.

## Hardware Reference

The Plinky is a synthesizer. The stable firmware lives at https://github.com/plinkysynth/plinky_public (cloned at `~/repos/plinky_public`) and the docs/manual at https://plinkysynth.com/docs/manual. Consult these for anything related to how the Plinky works (synth parameters, protocols, MIDI/USB communication, hardware capabilities, etc.). https://github.com/ember-labs-io/Plinky_LPE (cloned at `~/repos/Plinky_LPE`) is an experimental/development branch, not the stable release.

For details on the UF2 format (memory map, sample encoding, presets, SampleInfo metadata), read `docs/uf2.md`.

The Plinky web player lives at https://github.com/plinkysynth/plinky-web. Reference this for the player functionality we're building in PlinkyHub.

The wavetable generator lives at https://github.com/plinkysynth/wavetable. Reference this for wavetable generation functionality.
