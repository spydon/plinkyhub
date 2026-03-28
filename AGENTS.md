# Agents

## Code Style

Do not use abbreviations in variable names, function names, or comments. Always use full, descriptive names (e.g. `parameter` not `p`, `configuration` not `config`, `application` not `app`).

## Database

All DDL and schema changes must be written as migration files under `supabase/migrations/` (named `YYYYMMDDHHMMSS_description.sql`). Never apply DDL directly via `execute_sql` or the `apply_migration` MCP tool — always create a migration file first. Migrations are applied automatically by the CI/CD pipeline and should not be applied manually.

## Hardware Reference

The Plinky is a synthesizer. The firmware lives at https://github.com/ember-labs-io/Plinky_LPE and the docs/manual at https://plinkysynth.com/docs/manual — consult these for anything related to how the Plinky works (synth parameters, protocols, MIDI/USB communication, hardware capabilities, etc.).

The Plinky web player lives at https://github.com/plinkysynth/plinky-web — reference this for the player functionality we're building in PlinkyHub.

The wavetable generator lives at https://github.com/plinkysynth/wavetable — reference this for wavetable generation functionality.
