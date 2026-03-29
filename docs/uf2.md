# Plinky UF2 Format

## Overview

Plinky uses the UF2 format for storing presets, waveforms, and samples in flash memory. UF2 blocks
are saved to Plinky memory based entirely on the **target address field** in each block. Each
block's address should be 256 bytes beyond the previous block's address.

## Memory Map

| File          | Start Address | Size    |
| ------------- | ------------- | ------- |
| CURRENT UF2   | `0x08010000`  | 896 KB  |
| WAVETABLE UF2 | `0x08077000`  | 36 KB   |
| PRESETS UF2   | `0x08080000`  | 1020 KB |
| CALIB UF2     | `0x080FF800`  | 4 KB    |
| SAMPLE0 UF2   | `0x40000000`  | 8 MB    |
| SAMPLE1 UF2   | `0x40400000`  | 8 MB    |
| SAMPLE2 UF2   | `0x40800000`  | 8 MB    |
| SAMPLE3 UF2   | `0x40C00000`  | 8 MB    |
| SAMPLE4 UF2   | `0x41000000`  | 8 MB    |
| SAMPLE5 UF2   | `0x41400000`  | 8 MB    |
| SAMPLE6 UF2   | `0x41800000`  | 8 MB    |
| SAMPLE7 UF2   | `0x41C00000`  | 8 MB    |

## Samples

Sample UF2 files contain only the raw audio data. The metadata for each sample is stored separately
in the Presets file as a `SampleInfo` structure. Without this metadata, Plinky will not recognize
the sample and it will not have a waveform. For audio not recorded on Plinky, you must generate the
`SampleInfo` data yourself and place it correctly in the Presets file.

### Audio Format

Plinky expects raw PCM with no file headers (no WAV/RIFF container):

| Property    | Value                |
| ----------- | -------------------- |
| Sample rate | 31,250 Hz            |
| Bit depth   | 16-bit               |
| Encoding    | Signed integer (s16) |
| Channels    | Mono                 |
| Endianness  | Little-endian        |

The codec (WM8758) is configured for the closest standard rate (32 kHz), but the actual rate
derived from the MCU clock dividers is 31,250 Hz.

### Flash Storage

Plinky has two external SPI flash chips (16 MB each, 32 MB total) for sample storage. Each of
the 8 sample slots holds up to 2,097,152 samples (`MAX_SAMPLE_LEN`), which is 4 MB of raw data.
The UF2 address space allocates 8 MB per slot because UF2 blocks carry 256 bytes of payload in
512-byte blocks, effectively doubling the address range.

The `0x40000000` bit in the UF2 target address flags the data as destined for the external SPI
flash rather than the MCU's internal flash.

### SampleInfo Metadata

Each sample has a `SampleInfo` struct stored in the Presets file:

```c
typedef struct SampleInfo {
    u8 waveform4_b[1024];   // 4-bit waveform display (2048 points)
    int splitpoints[8];      // absolute sample positions for 8 slices
    int samplelen;           // total sample length (splitpoints[8] reads this)
    s8 notes[8];             // root note per slice (0-96, add 12 for MIDI)
    u8 pitched;              // 0 = tape mode, 1 = pitched/multisample mode
    u8 loop;                 // bit 0: loop on/off, bit 1: slice vs all
    u8 paddy[2];
} SampleInfo;
```

**Splitpoints** are absolute sample offsets (not fractions). Adjacent points must be at least 1024
samples apart. `splitpoints[8]` is implicitly `samplelen` (placed right after the array).

**Playback modes:**

- **Tape mode** (`pitched=0`): Each of Plinky's 8 columns plays the corresponding slice directly
  (column 0 → slice 0, etc.). The Y-axis scrubs within the slice region.
- **Pitched mode** (`pitched=1`): Each slice has a root note in `notes[8]`. Plinky picks the slice
  whose root note is closest to the played pitch, with round-robin for ties.

**Note values** use Plinky's scheme (0-96) where `value + 12` gives the MIDI note number. For
example, value 48 = MIDI 60 = C4.

**Loop modes** (2-bit field):

| Value | Behaviour       |
| ----- | --------------- |
| 0     | One-shot, slice |
| 1     | Loop, slice     |
| 2     | One-shot, all   |
| 3     | Loop, all       |

## Presets

The Presets file contains presets, pattern quarters, and `SampleInfo` structures. The pages inside
the Presets file use flash wear leveling, which means they do not appear at predictable memory
locations. Each page has a `PageFooter` at the last 8 bytes containing the item ID, version, CRC,
and a wear-leveling sequence number. When multiple pages share the same item ID, the one with the
highest sequence number is the current version.

### Page Structure

Each 2048-byte flash page is laid out as:

| Offset | Size | Content                                           |
| ------ | ---- | ------------------------------------------------- |
| 0      | 2024 | Item data (Preset, PatternQuarter, or SampleInfo) |
| 2024   | 16   | SysParams                                         |
| 2040   | 8    | PageFooter                                        |

### Flash Item IDs

| Item IDs | Count | Content                                                       | Size per item |
| -------- | ----- | ------------------------------------------------------------- | ------------- |
| 0-31     | 32    | Presets                                                       | 1552 bytes    |
| 32-127   | 96    | Pattern quarters (24 patterns × 4 quarters)                   | 1792 bytes    |
| 128-135  | 8     | SampleInfo                                                    | 1072 bytes    |
| 136      | 1     | Floating preset (current working copy of preset 0)            | 1552 bytes    |
| 137-140  | 4     | Floating pattern quarters (current working copy of pattern 0) | 1792 bytes    |

### PageFooter (8 bytes)

| Offset | Size | Field   | Description                                    |
| ------ | ---- | ------- | ---------------------------------------------- |
| 0      | 1    | idx     | Flash item ID                                  |
| 1      | 1    | version | Footer version (currently 2)                   |
| 2      | 2    | crc     | CRC-16 over the first 2040 bytes of the page   |
| 3      | 4    | seq     | Wear-leveling sequence number (higher = newer) |

You must create `SampleInfo` entries with the correct properties for Plinky to retrieve them.

## Patterns

Each of the 24 patterns is stored as 4 quarters (for a maximum of 64 steps: 16 steps per quarter).
Pattern data lives inside PRESETS.UF2, **not** in a separate file. Each `PatternQuarter` is
1792 bytes.

### PatternQuarter Structure (1792 bytes)

Each quarter holds 16 steps × 8 strings of sequencer data:

| Offset | Size | Content                                                           |
| ------ | ---- | ----------------------------------------------------------------- |
| 0      | 1536 | Step data: 16 steps × 8 strings × (4 position + 8 pressure bytes) |
| 1536   | 256  | Knob data: 16 steps × 8 substeps × 2 knob bytes                   |
