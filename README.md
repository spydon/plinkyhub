<p align="center">
  <img src="web/icons/Icon-512.png" width="128" alt="PlinkyHub logo">
</p>

# PlinkyHub

A site for sharing, creating and organizing your [Plinky](https://plinkysynth.com/) presets,
samples, wavetables and packs.

Use it at [plinkyhub.com](https://plinkyhub.com).

## Features

### Presets

Browse and share presets with the community. Edit preset parameters in a visual editor, organize
presets with categories, and star your favourites.

### Samples

Upload WAV files or import samples directly from your Plinky's UF2 files. Configure slice points,
base note, fine tune, and pitched/tape mode with a visual slice editor. Share samples with the
community.

### Wavetables

Create custom wavetables from 15 single-cycle WAV files (c0 through c14). The app generates a
wavetab.uf2 using the same algorithm as the
[plinkysynth/wavetable](https://github.com/plinkysynth/wavetable) tool, with built-in saw and sine
waves added automatically. Upload wavetables directly to your Plinky via the Tunnel of Lights mode.

### Packs

Bundle presets, samples and a wavetable together into a pack. Save a complete pack to your Plinky
in one go, or load a pack from your Plinky to back it up and share it with others.

### Save to Plinky

Write presets, samples, wavetables and full packs directly to your Plinky when it is mounted as a
USB drive in Tunnel of Lights mode.

## Issues and support

If you run into any problems or have feature requests, you can:

- [Open an issue](https://github.com/spydon/plinkyhub/issues) on GitHub
- Reach out to **spydon** on the [Plinky Discord](https://discord.gg/pHzcVnBt3A)

## Tech stack

- **Flutter Web** (Flutter SDK 3.41.4 or newer) compiled to **WebAssembly**
  (`--wasm`) for near-native performance in the browser.
- **Riverpod** for state management and **go_router** for routing.
- **Supabase** (Postgres, Auth, Storage, Row-Level Security) as the backend,
  accessed via `supabase_flutter`.
- **WebUSB** for direct communication with Plinky in Tunnel of Lights mode.
- **flutter_soloud** for audio playback and **MediaPipe Hands** for the
  webcam-based play tab.
- **freezed** + **json_serializable** for immutable models, generated via
  `build_runner`.

## Running locally

### Prerequisites

- Flutter SDK 3.41.4 or newer
- A Chromium-based browser (WebUSB and WebAssembly are required)
- [Supabase CLI](https://supabase.com/docs/guides/local-development) if you
  want to run the backend locally

### Configure environment

Copy `.env.template` to `.env` and fill in the Supabase credentials you want
to use:

```bash
cp .env.template .env
```

### Install dependencies and generate code

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run against a remote Supabase project

Point `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env` at your hosted project,
then launch the app in Chrome with WebAssembly enabled:

```bash
flutter run -d chrome --wasm
```

### Run against local Supabase

#### Start Supabase

Start the local Supabase stack (Postgres, Auth, Studio, etc.) from the repo
root:

```bash
supabase start
```

The CLI prints a local `API -> Project URL` and `Authentication Keys -> Publishable`. Put those into `.env`:

```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<anon key printed by supabase start>
```

*Note: if you are using podman on Linux, you will likely have to run `sudo supabase start` if you have an issue with `RLIMIT_NOFILE`.*

#### Add Supabase user

- Visit [http://127.0.0.1:54321/project/default/auth/users](http://127.0.0.1:54321/project/default/auth/users)
- Add a user with the email and password you specified in `.env` as `DEV_EMAIL` and `DEV_PASSWORD`
  - You will get a random uuid for your username (you can see this when you log in, or in the `profiles` table in the database).

#### Run plinkyhub

Migrations under `supabase/migrations/` are applied automatically on
`supabase start`. Then run the app the same way:

```bash
flutter run -d chrome --wasm 
```

#### Stopping Supabase

Stop the stack with `supabase stop` when you are done (or `sudo supabase stop` if you started it with `sudo`).

### Building for production

```bash
flutter build web --wasm --release
```

The output in `build/web/` is a static site that can be served from any
static host.

## WebUSB on Linux

If you get a `SecurityError: Failed to execute 'open' on 'USBDevice': Access denied`
error when trying to connect to Plinky, you need to grant your user permission to
access the USB device.

1. **Verify Plinky is connected** by running `lsusb`. You should see something like:
   ```
   Bus 001 Device 026: ID cafe:4018 Plinky PlinkySynth MIDI
   ```

2. **Add your user to the `plugdev` group:**
   ```bash
   sudo usermod -a -G plugdev $USER
   ```
   Log out and back in for the change to take effect. Verify with the `groups` command.

3. **Create a udev rule:**
   ```bash
   echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="cafe", MODE="0660", GROUP="plugdev"' | \
   sudo tee /etc/udev/rules.d/99-plinky.rules
   ```

4. **Reload udev rules:**
   ```bash
   sudo udevadm control --reload-rules
   ```

5. **Reconnect Plinky** by unplugging and replugging the USB cable.
