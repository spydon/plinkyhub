# PlinkyHub

A site for sharing, creating and organizing your [Plinky](https://plinkysynth.com/) presets,
samples, wavetables and packs.

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
