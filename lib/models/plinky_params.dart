/// Ordered list of param IDs matching the Plinky firmware binary layout.
const eParams = [
  'P_PWM', 'P_DRIVE', 'P_PITCH', 'P_OCT', 'P_GLIDE', 'P_INTERVAL',
  'P_NOISE', 'P_MIXRESO', 'P_ROTATE', 'P_SCALE', 'P_MICROTUNE', 'P_STRIDE',
  'P_SENS', 'P_A', 'P_D', 'P_S', 'P_R', 'P_ENV1_UNUSED', 'P_ENV_LEVEL1',
  'P_A2', 'P_D2', 'P_S2', 'P_R2', 'P_ENV2_UNUSED', 'P_DLSEND', 'P_DLTIME',
  'P_DLRATIO', 'P_DLWOB', 'P_DLFB', 'P_TEMPO', 'P_RVSEND', 'P_RVTIME',
  'P_RVSHIM', 'P_RVWOB', 'P_RVUNUSED', 'P_SWING', 'P_ARPONOFF', 'P_ARPMODE',
  'P_ARPDIV', 'P_ARPPROB', 'P_ARPLEN', 'P_ARPOCT', 'P_LATCHONOFF',
  'P_SEQMODE', 'P_SEQDIV', 'P_SEQPROB', 'P_SEQLEN', 'P_GATE_LENGTH',
  'P_SMP_POS', 'P_SMP_GRAINSIZE', 'P_SMP_RATE', 'P_SMP_TIME', 'P_SAMPLE',
  'P_SEQPAT', 'P_JIT_POS', 'P_JIT_GRAINSIZE', 'P_JIT_RATE', 'P_JIT_PULSE',
  'P_JIT_UNUSED', 'P_SEQSTEP', 'P_ASCALE', 'P_AOFFSET', 'P_ADEPTH',
  'P_AFREQ', 'P_ASHAPE', 'P_AWARP', 'P_BSCALE', 'P_BOFFSET', 'P_BDEPTH',
  'P_BFREQ', 'P_BSHAPE', 'P_BWARP', 'P_XSCALE', 'P_XOFFSET', 'P_XDEPTH',
  'P_XFREQ', 'P_XSHAPE', 'P_XWARP', 'P_YSCALE', 'P_YOFFSET', 'P_YDEPTH',
  'P_YFREQ', 'P_YSHAPE', 'P_YWARP', 'P_MIXSYNTH', 'P_MIXWETDRY', 'P_MIXHPF',
  'P_MIX_UNUSED', 'P_CV_QUANT', 'P_HEADPHONE', 'P_MIXINPUT', 'P_MIXINWETDRY',
  'P_SYS_UNUSED1', 'P_SYS_UNUSED2', 'P_SYS_UNUSED3', 'P_ACCEL_SENS',
];

// Randomization category groups
const synthParams = [
  'P_PWM', 'P_DRIVE', 'P_PITCH', 'P_OCT', 'P_GLIDE', 'P_INTERVAL',
  'P_NOISE', 'P_MIXRESO', 'P_ROTATE', 'P_SCALE', 'P_MICROTUNE', 'P_STRIDE',
  'P_SENS',
];

const envelope1Params = ['P_A', 'P_D', 'P_S', 'P_R', 'P_ENV_LEVEL1'];

const envelope2Params = ['P_A2', 'P_D2', 'P_S2', 'P_R2', 'P_ENV_LEVEL'];

const effectParams = [
  'P_DLSEND', 'P_DLTIME', 'P_DLRATIO', 'P_DLWOB', 'P_DLFB', 'P_TEMPO',
  'P_RVSEND', 'P_RVTIME', 'P_RVSHIM', 'P_RVWOB',
];

const arpParams = [
  'P_ARPMODE', 'P_ARPDIV', 'P_ARPPROB', 'P_ARPLEN', 'P_ARPOCT',
];

const seqParams = [
  'P_SEQMODE', 'P_SEQDIV', 'P_SEQPROB', 'P_SEQLEN', 'P_GATE_LENGTH',
];

const samplerParams = [
  'P_SMP_POS', 'P_SMP_GRAINSIZE', 'P_SMP_RATE', 'P_SMP_TIME',
  'P_JIT_POS', 'P_JIT_GRAINSIZE', 'P_JIT_RATE', 'P_JIT_PULSE',
];

const modAParams = [
  'P_ASCALE', 'P_AOFFSET', 'P_ADEPTH', 'P_AFREQ', 'P_ASHAPE', 'P_AWARP',
];

const modBParams = [
  'P_BSCALE', 'P_BOFFSET', 'P_BDEPTH', 'P_BFREQ', 'P_BSHAPE', 'P_BWARP',
];

const modXParams = [
  'P_XSCALE', 'P_XOFFSET', 'P_XDEPTH', 'P_XFREQ', 'P_XSHAPE', 'P_XWARP',
];

const modYParams = [
  'P_YSCALE', 'P_YOFFSET', 'P_YDEPTH', 'P_YFREQ', 'P_YSHAPE', 'P_YWARP',
];

class PlinkyParamDef {
  const PlinkyParamDef({
    required this.id,
    required this.min,
    required this.max,
    this.cc = -1,
    this.name,
    this.description = '',
    this.enumName,
  });

  final String id;
  final double min;
  final double max;
  final int cc;
  final String? name;
  final String description;
  final List<String>? enumName;
}

const plinkyParams = <PlinkyParamDef>[
  PlinkyParamDef(
    id: 'P_PWM',
    min: -100,
    max: 100,
    cc: 13,
    name: 'Shape',
    description: 'Controls the shape of the oscillators in '
        'Plinky. When exactly 0%, you get 4 sawtooths per '
        'voice. When positive, you blend smoothly through '
        '16 ROM wavetable shapes. When negative, you get '
        'PWM control of pulse/square shapes.',
  ),
  PlinkyParamDef(
    id: 'P_DRIVE',
    min: -1024,
    max: 1024,
    cc: 4,
    name: 'Distortion',
    description: 'Drive/Saturation. When turned up high, '
        'the saturation unit will create guitar-like tones, '
        'especially when playing polyphonically.',
  ),
  PlinkyParamDef(
    id: 'P_PITCH',
    min: -1024,
    max: 1024,
    cc: 9,
    name: 'Pitch',
    description: 'Use this to (fine) tune plinky. Range is '
        '1 octave up or down, unquantized.',
  ),
  PlinkyParamDef(
    id: 'P_OCT',
    min: -1024,
    max: 1024,
    name: 'Octave',
    description: 'Use this to quickly change pitch, '
        'quantized to octaves.',
  ),
  PlinkyParamDef(
    id: 'P_GLIDE',
    min: 0,
    max: 127,
    cc: 5,
    name: 'Glide',
    description: 'Controls the speed of the portamento '
        'between notes in a single voice. Higher = slower',
  ),
  PlinkyParamDef(
    id: 'P_INTERVAL',
    min: 0,
    max: 127,
    cc: 14,
    name: 'Interval',
    description: 'Each voice has several oscillators, and '
        'this sets a fixed interval between them, from +1 '
        'to -1 octaves.',
  ),
  PlinkyParamDef(
    id: 'P_NOISE',
    min: -127,
    max: 127,
    cc: 2,
    name: 'Noise',
    description: 'Each voice can add a variable amount of '
        'white noise to the oscillator, before the '
        'low-pass gate.',
  ),
  PlinkyParamDef(
    id: 'P_MIXRESO',
    min: 0,
    max: 127,
    cc: 71,
    name: 'Resonance',
    description: 'Each voice has a 2-pole lowpass gate. '
        'This parameter adds resonance to the filter.',
  ),
  PlinkyParamDef(
    id: 'P_ROTATE',
    min: 0,
    max: 127,
    name: 'Degree',
    description: 'A quantized pitch control that transposes '
        'plinky while staying in the same scale.',
  ),
  PlinkyParamDef(
    id: 'P_SCALE',
    min: 0,
    max: 26,
    name: 'Scale',
    description:
        'Selects which scale of notes plinky uses',
    enumName: [
      'Major',
      'Minor',
      'Harmonic Min',
      'Penta Maj',
      'Penta Min',
      'Hirajoshi',
      'Insen',
      'Iwato',
      'Minyo',
      'Fifths',
      'Triad Maj',
      'Triad Min',
      'Dorian',
      'Phrygian',
      'Lydian',
      'Mixolydian',
      'Aeolian',
      'Locrian',
      'Blues Min',
      'Blues Maj',
      'Romanian',
      'Wholetone',
      'Harmonics',
      'Hexany',
      'Just',
      'Chromatic',
    ],
  ),
  PlinkyParamDef(
    id: 'P_MICROTUNE',
    min: 0,
    max: 127,
    name: 'Microtune',
    description: 'Controls how much vertical movement of '
        'your finger detunes the note.',
  ),
  PlinkyParamDef(
    id: 'P_STRIDE',
    min: 0,
    max: 127,
    name: 'Stride',
    description: 'Controls the interval, in semitones, '
        'between each column of plinky.',
  ),
  PlinkyParamDef(
    id: 'P_SENS',
    min: 0,
    max: 1,
    cc: 3,
    name: 'Sensitivity',
    description: 'Master sensitivity, controlling the '
        'mapping of finger pressure to the '
        "opening/closing of each voice's low-pass gate.",
  ),
  PlinkyParamDef(
    id: 'P_A',
    min: 0,
    max: 127,
    cc: 73,
    name: 'Attack',
    description: 'Attack time for the main envelope that '
        'controls the lowpass gate.',
  ),
  PlinkyParamDef(
    id: 'P_D',
    min: 0,
    max: 127,
    cc: 75,
    name: 'Decay',
    description: 'Decay time for the main envelope that '
        'controls the lowpass gate.',
  ),
  PlinkyParamDef(
    id: 'P_S',
    min: 0,
    max: 127,
    cc: 74,
    name: 'Sustain',
    description: 'Sustain level for the main envelope that '
        'controls the lowpass gate.',
  ),
  PlinkyParamDef(
    id: 'P_R',
    min: 0,
    max: 127,
    cc: 72,
    name: 'Release',
    description: 'Release time for the main envelope that '
        'controls the lowpass gate.',
  ),
  PlinkyParamDef(
    id: 'P_ENV1_UNUSED',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_ENV_LEVEL1',
    min: 0,
    max: 127,
    name: 'Envelope 1 level',
    description: 'Envelope 1 level',
  ),
  PlinkyParamDef(
    id: 'P_A2',
    min: 0,
    max: 127,
    cc: 20,
    name: 'Attack 2',
    description: 'Attack time of the second envelope.',
  ),
  PlinkyParamDef(
    id: 'P_D2',
    min: 0,
    max: 127,
    cc: 21,
    name: 'Decay 2',
    description: 'Decay time of the second envelope.',
  ),
  PlinkyParamDef(
    id: 'P_S2',
    min: 0,
    max: 127,
    cc: 22,
    name: 'Sustain 2',
    description: 'Sustain level of the second envelope.',
  ),
  PlinkyParamDef(
    id: 'P_R2',
    min: 0,
    max: 127,
    cc: 23,
    name: 'Release 2',
    description: 'Release time of the second envelope.',
  ),
  PlinkyParamDef(
    id: 'P_ENV2_UNUSED',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_DLSEND',
    min: 0,
    max: 1,
    cc: 94,
    name: 'Delay Send',
    description:
        'Amount of the dry sound sent to the delay unit.',
  ),
  PlinkyParamDef(
    id: 'P_DLTIME',
    min: -1,
    max: 1,
    cc: 12,
    name: 'Delay Time',
    description: 'The time between each echo.',
  ),
  PlinkyParamDef(
    id: 'P_DLRATIO',
    min: 0,
    max: 1,
    name: 'Delay Ratio',
    description: 'Moves the right tap to an earlier time, '
        'causing ping-pong poly-rhythmic repeats.',
  ),
  PlinkyParamDef(
    id: 'P_DLWOB',
    min: 0,
    max: 1,
    name: 'Delay Wobble',
    description: 'Amount of simulated tape speed wobble '
        'in the delay.',
  ),
  PlinkyParamDef(
    id: 'P_DLFB',
    min: 0,
    max: 1,
    cc: 95,
    name: 'Delay Feedback',
    description: 'Amount of feedback - the volume of each '
        'echo reduces by this amount.',
  ),
  PlinkyParamDef(
    id: 'P_TEMPO',
    min: -1,
    max: 1,
    name: 'BPM',
    description: 'Tempo in BPM. You can also tap this '
        'parameter pad rhythmically to set the tempo.',
  ),
  PlinkyParamDef(
    id: 'P_RVSEND',
    min: 0,
    max: 1,
    cc: 91,
    name: 'Reverb Send',
    description:
        'Amount of the dry sound sent to the reverb unit.',
  ),
  PlinkyParamDef(
    id: 'P_RVTIME',
    min: 0,
    max: 1,
    cc: 92,
    name: 'Reverb Time',
    description:
        'Controls the length of the decay of the reverb.',
  ),
  PlinkyParamDef(
    id: 'P_RVSHIM',
    min: 0,
    max: 1,
    cc: 93,
    name: 'Shimmer',
    description: 'Amount of octave-up signal fed into the '
        'reverb, causing a shimmer effect.',
  ),
  PlinkyParamDef(
    id: 'P_RVWOB',
    min: 0,
    max: 1,
    name: 'Reverb Wobble',
    description: 'Amount of simulated tape speed wobble '
        'in the reverb.',
  ),
  PlinkyParamDef(
    id: 'P_RVUNUSED',
    min: 0,
    max: 1,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_SWING',
    min: 0,
    max: 1,
    name: 'Swing',
    description: 'This parameter will be used to add swing '
        'in a future firmware update.',
  ),
  PlinkyParamDef(
    id: 'P_ARPONOFF',
    min: 0,
    max: 1,
    cc: 102,
    name: 'Arp on/off',
    description:
        'Switches the arpeggiator on and off.',
  ),
  PlinkyParamDef(
    id: 'P_ARPMODE',
    min: 0,
    max: 15,
    cc: 103,
    name: 'Arpeggiator Mode',
    description: 'Arpeggiator mode.',
    enumName: [
      'Up',
      'Down',
      'Up then Down',
      'Up then Down (repeat end notes)',
      'Up with lowest note pedal',
      'Down with lowest note pedal',
      'Up then down with lowest note pedal',
      'Random',
      'Random playing 2 notes at a time',
      'Repeat all notes (polyphonic)',
      'Up (all 8 columns)',
      'Down (all 8 columns)',
      'Up then Down (all 8 columns)',
      'Random (all 8 columns)',
      'Random, 2 notes at a time (all 8 columns)',
    ],
  ),
  PlinkyParamDef(
    id: 'P_ARPDIV',
    min: -1,
    max: 22,
    name: 'Arp Clock Divide',
    description:
        'Sets the speed of the arpeggiator.',
    enumName: [
      '1/32', '2/32', '3/32', '4/32', '5/32',
      '6/32', '8/32', '10/32', '12/32', '16/32',
      '20/32', '24/32', '32/32', '40/32', '48/32',
      '64/32', '80/32', '96/32', '128/32', '160/32',
      '192/32', '256/32',
    ],
  ),
  PlinkyParamDef(
    id: 'P_ARPPROB',
    min: 0,
    max: 1,
    name: 'Arp Probability / Density',
    description: 'Sets the probability of the arpeggiator '
        'progressing on each tick of its clock.',
  ),
  PlinkyParamDef(
    id: 'P_ARPLEN',
    min: -17,
    max: 17,
    name: 'Arp Pattern Length',
    description: 'Sets the length of the euclidean pattern '
        'used by the arp.',
  ),
  PlinkyParamDef(
    id: 'P_ARPOCT',
    min: 0,
    max: 4,
    name: 'Arp Octaves',
    description: 'Sets how many octaves the arpeggiator '
        'ranges over.',
  ),
  PlinkyParamDef(
    id: 'P_LATCHONOFF',
    min: 0,
    max: 1,
    name: 'Latch on/off',
    description: 'Switches the latch on/off. When on, '
        'played notes will sustain even when you take your '
        'fingers off plinky.',
  ),
  PlinkyParamDef(
    id: 'P_SEQMODE',
    min: 0,
    max: 6,
    name: 'Sequencer Mode',
    description: 'Sets the order that notes are played '
        'by the sequencer.',
    enumName: [
      'Pause',
      'Forwards',
      'Backwards',
      'Pingpong',
      'Pingpong (repeat end notes)',
      'Random',
    ],
  ),
  PlinkyParamDef(
    id: 'P_SEQDIV',
    min: 0,
    max: 22,
    name: 'Seq Clock Divide',
    description: 'Sets the speed of the sequencer.',
    enumName: [
      '1/32', '2/32', '3/32', '4/32', '5/32',
      '6/32', '8/32', '10/32', '12/32', '16/32',
      '20/32', '24/32', '32/32', '40/32', '48/32',
      '64/32', '80/32', '96/32', '128/32', '160/32',
      '192/32', '256/32',
    ],
  ),
  PlinkyParamDef(
    id: 'P_SEQPROB',
    min: 0,
    max: 1,
    name: 'Seq Probability / Density',
    description: 'Sets the probability of the sequencer '
        'progressing on each tick of its clock.',
  ),
  PlinkyParamDef(
    id: 'P_SEQLEN',
    min: -17,
    max: 17,
    name: 'Seq Pattern Length',
    description: 'Sets the length of the euclidean pattern '
        'used by the sequencer.',
  ),
  PlinkyParamDef(
    id: 'P_GATE_LENGTH',
    min: 0,
    max: 127,
    cc: 11,
    name: 'Gate length',
    description:
        'Sets the length of the gate of each step.',
  ),
  PlinkyParamDef(
    id: 'P_SMP_POS',
    min: 0,
    max: 127,
    cc: 15,
    name: 'Sample position',
    description: 'Controls the starting point of the '
        'sample playback.',
  ),
  PlinkyParamDef(
    id: 'P_SMP_GRAINSIZE',
    min: 0,
    max: 127,
    cc: 16,
    name: 'Grain size',
    description: 'Sets the size of the grains.',
  ),
  PlinkyParamDef(
    id: 'P_SMP_RATE',
    min: 0,
    max: 127,
    cc: 17,
    name: 'Sample playback rate',
    description: 'Determines at what relative speed the '
        'sample is played back.',
  ),
  PlinkyParamDef(
    id: 'P_SMP_TIME',
    min: 0,
    max: 127,
    cc: 18,
    name: 'Sample playback time',
    description: 'Determines at what relative speed the '
        'sample is played back, without changing the pitch.',
  ),
  PlinkyParamDef(
    id: 'P_SAMPLE',
    min: 0,
    max: 127,
    cc: 82,
    name: 'Sample #',
    description: 'Controls which sample is being played.',
  ),
  PlinkyParamDef(
    id: 'P_SEQPAT',
    min: 0,
    max: 127,
    cc: 83,
    name: 'Sequencer pattern #',
    description: 'Controls which sequencer pattern is '
        'being played back.',
    enumName: [
      '1', '2', '3', '4', '5', '6', '7', '8',
      '9', '10', '11', '12', '13', '14', '15', '16',
      '17', '18', '19', '20', '21', '22', '23', '24',
    ],
  ),
  PlinkyParamDef(
    id: 'P_JIT_POS',
    min: 0,
    max: 127,
    name: 'Sample position jitter',
    description: 'Adds randomness to the sample '
        'playback position.',
  ),
  PlinkyParamDef(
    id: 'P_JIT_GRAINSIZE',
    min: 0,
    max: 127,
    name: 'Grain size jitter',
    description: 'Adds randomness to the sample '
        'grain size.',
  ),
  PlinkyParamDef(
    id: 'P_JIT_RATE',
    min: 0,
    max: 127,
    name: 'Sample speed jitter',
    description: 'Adds randomness to the sample '
        'playback speed.',
  ),
  PlinkyParamDef(
    id: 'P_JIT_PULSE',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_JIT_UNUSED',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_SEQSTEP',
    min: 0,
    max: 127,
    cc: 85,
    name: 'Pattern offset',
    description: 'Offsets the starting point of the '
        'sequencer pattern.',
  ),
  PlinkyParamDef(
    id: 'P_ASCALE',
    min: 0,
    max: 127,
    name: 'A scale',
    description: 'An attenuator for the signal coming '
        'from the corresponding CV input jacks.',
  ),
  PlinkyParamDef(
    id: 'P_AOFFSET',
    min: 0,
    max: 127,
    cc: 24,
    name: 'A offset',
    description: 'Offsets the CV and/or LFO.',
  ),
  PlinkyParamDef(
    id: 'P_ADEPTH',
    min: 0,
    max: 127,
    cc: 25,
    name: 'A depth',
    description: 'Attenuator for the internal LFOs. '
        'Turn this up for LFOs.',
  ),
  PlinkyParamDef(
    id: 'P_AFREQ',
    min: 0,
    max: 127,
    cc: 26,
    name: 'A rate',
    description:
        'Controls the rate of the internal LFO.',
  ),
  PlinkyParamDef(
    id: 'P_ASHAPE',
    min: 0,
    max: 127,
    name: 'A shape',
    description: 'Sets the shape of the LFO.',
  ),
  PlinkyParamDef(
    id: 'P_AWARP',
    min: 0,
    max: 127,
    name: 'A warp',
    description: 'Sets the slope of the LFO shape.',
  ),
  PlinkyParamDef(
    id: 'P_BSCALE',
    min: 0,
    max: 127,
    name: 'B scale',
    description: 'An attenuator for the signal coming '
        'from the corresponding CV input jacks.',
  ),
  PlinkyParamDef(
    id: 'P_BOFFSET',
    min: 0,
    max: 127,
    cc: 27,
    name: 'B offset',
    description: 'Offsets the CV and/or LFO.',
  ),
  PlinkyParamDef(
    id: 'P_BDEPTH',
    min: 0,
    max: 127,
    cc: 28,
    name: 'B depth',
    description: 'Attenuator for the internal LFOs. '
        'Turn this up for LFOs.',
  ),
  PlinkyParamDef(
    id: 'P_BFREQ',
    min: 0,
    max: 127,
    cc: 29,
    name: 'B rate',
    description:
        'Controls the rate of the internal LFO.',
  ),
  PlinkyParamDef(
    id: 'P_BSHAPE',
    min: 0,
    max: 127,
    name: 'B shape',
    description: 'Sets the shape of the LFO.',
  ),
  PlinkyParamDef(
    id: 'P_BWARP',
    min: 0,
    max: 127,
    name: 'B warp',
    description: 'Sets the slope of the LFO shape.',
  ),
  PlinkyParamDef(
    id: 'P_XSCALE',
    min: 0,
    max: 127,
    name: 'X scale',
    description: 'An attenuator for the signal coming '
        'from the corresponding CV input jacks.',
  ),
  PlinkyParamDef(
    id: 'P_XOFFSET',
    min: 0,
    max: 127,
    cc: 78,
    name: 'X offset',
    description: 'Offsets the CV and/or LFO.',
  ),
  PlinkyParamDef(
    id: 'P_XDEPTH',
    min: 0,
    max: 127,
    cc: 77,
    name: 'X depth',
    description: 'Attenuator for the internal LFOs. '
        'Turn this up for LFOs.',
  ),
  PlinkyParamDef(
    id: 'P_XFREQ',
    min: 0,
    max: 127,
    cc: 76,
    name: 'X rate',
    description:
        'Controls the rate of the internal LFO.',
  ),
  PlinkyParamDef(
    id: 'P_XSHAPE',
    min: 0,
    max: 127,
    name: 'X shape',
    description: 'Sets the shape of the LFO.',
  ),
  PlinkyParamDef(
    id: 'P_XWARP',
    min: 0,
    max: 127,
    name: 'X warp',
    description: 'Sets the slope of the LFO shape.',
  ),
  PlinkyParamDef(
    id: 'P_YSCALE',
    min: 0,
    max: 127,
    name: 'Y scale',
    description: 'An attenuator for the signal coming '
        'from the corresponding CV input jacks.',
  ),
  PlinkyParamDef(
    id: 'P_YOFFSET',
    min: 0,
    max: 127,
    cc: 81,
    name: 'Y offset',
    description: 'Offsets the CV and/or LFO.',
  ),
  PlinkyParamDef(
    id: 'P_YDEPTH',
    min: 0,
    max: 127,
    cc: 80,
    name: 'Y depth',
    description: 'Attenuator for the internal LFOs. '
        'Turn this up for LFOs.',
  ),
  PlinkyParamDef(
    id: 'P_YFREQ',
    min: 0,
    max: 127,
    cc: 79,
    name: 'Y rate',
    description:
        'Controls the rate of the internal LFO.',
  ),
  PlinkyParamDef(
    id: 'P_YSHAPE',
    min: 0,
    max: 127,
    name: 'Y shape',
    description: 'Sets the shape of the LFO.',
  ),
  PlinkyParamDef(
    id: 'P_YWARP',
    min: 0,
    max: 127,
    name: 'Y warp',
    description: 'Sets the slope of the LFO shape.',
  ),
  PlinkyParamDef(
    id: 'P_MIXSYNTH',
    min: 0,
    max: 127,
    cc: 7,
    name: 'Synth level',
    description: "Sets the gain level of Plinky's "
        'synth / sampler.',
  ),
  PlinkyParamDef(
    id: 'P_MIXWETDRY',
    min: 0,
    max: 127,
    cc: 8,
    name: 'Synth wet/dry',
    description: 'Sets the balance between the dry signal '
        'and the wet signal of the Reverb and Delay units.',
  ),
  PlinkyParamDef(
    id: 'P_MIXHPF',
    min: 0,
    max: 127,
    cc: 21,
    name: 'HPF',
    description: 'High Pass Filter cutoff frequency.',
  ),
  PlinkyParamDef(
    id: 'P_MIX_UNUSED',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_CV_QUANT',
    min: 0,
    max: 127,
    name: 'Pitch quantization',
    description: 'Choose if pitch CV transposition is '
        'unquantized, quantized to semitones, or '
        'transposed in-scale.',
  ),
  PlinkyParamDef(
    id: 'P_HEADPHONE',
    min: 0,
    max: 127,
    name: 'Headphone level',
    description: 'Sets the level of the final output '
        'stage for the headphone out.',
  ),
  PlinkyParamDef(
    id: 'P_MIXINPUT',
    min: 0,
    max: 127,
    cc: 89,
    name: 'Input level',
    description:
        "Sets the gain level of Plinky's inputs.",
  ),
  PlinkyParamDef(
    id: 'P_MIXINWETDRY',
    min: 0,
    max: 127,
    cc: 90,
    name: 'Input wet/dry',
    description: 'Sets the balance between the dry signal '
        'of the audio inputs and the wet signal.',
  ),
  PlinkyParamDef(
    id: 'P_SYS_UNUSED1',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_SYS_UNUSED2',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_SYS_UNUSED3',
    min: 0,
    max: 127,
    description: 'unused parameter slot',
  ),
  PlinkyParamDef(
    id: 'P_ACCEL_SENS',
    min: 0,
    max: 127,
    name: 'Accelerometer sensitivity',
    description:
        'Sets the sensitivity of the accelerometer.',
  ),
];

PlinkyParamDef? getParamDef(String id) {
  for (final p in plinkyParams) {
    if (p.id == id) {
      return p;
    }
  }
  return null;
}

const paramIconMap = <String, String>{
  'P_PWM': 'shape.svg',
  'P_DRIVE': 'distortion--resonance.svg',
  'P_PITCH': 'pitch.svg',
  'P_OCT': 'octave--scale.svg',
  'P_GLIDE': 'glide--microtone.svg',
  'P_INTERVAL': 'osc-interval--column.svg',
  'P_NOISE': 'noise.svg',
  'P_MIXRESO': 'distortion--resonance.svg',
  'P_ROTATE': 'degree.svg',
  'P_SCALE': 'octave--scale.svg',
  'P_MICROTUNE': 'glide--microtone.svg',
  'P_STRIDE': 'osc-interval--column.svg',
  'P_SENS': 'sensitivity--env-2-level.svg',
  'P_A': 'attack.svg',
  'P_D': 'decay.svg',
  'P_S': 'sustain.svg',
  'P_R': 'release.svg',
  'P_ENV1_UNUSED': 'blank.svg',
  'P_ENV_LEVEL1': 'sensitivity--env-2-level.svg',
  'P_A2': 'attack.svg',
  'P_D2': 'decay.svg',
  'P_S2': 'sustain.svg',
  'P_R2': 'release.svg',
  'P_ENV2_UNUSED': 'blank.svg',
  'P_DLSEND': 'delay--reverb.svg',
  'P_DLTIME': 'time.svg',
  'P_DLRATIO': 'pingpong--shimmer.svg',
  'P_DLWOB': 'wobble.svg',
  'P_DLFB': 'feedback.svg',
  'P_TEMPO': 'tempo--swing.svg',
  'P_RVSEND': 'delay--reverb.svg',
  'P_RVTIME': 'time.svg',
  'P_RVSHIM': 'pingpong--shimmer.svg',
  'P_RVWOB': 'wobble.svg',
  'P_RVUNUSED': 'feedback.svg',
  'P_SWING': 'tempo--swing.svg',
  'P_ARPONOFF': 'arp--latch.svg',
  'P_ARPMODE': 'order.svg',
  'P_ARPDIV': 'clock-div.svg',
  'P_ARPPROB': 'chance.svg',
  'P_ARPLEN': 'euclid-len.svg',
  'P_ARPOCT': 'arp-octaves.svg',
  'P_LATCHONOFF': 'arp--latch.svg',
  'P_SEQMODE': 'order.svg',
  'P_SEQDIV': 'clock-div.svg',
  'P_SEQPROB': 'chance.svg',
  'P_SEQLEN': 'euclid-len.svg',
  'P_GATE_LENGTH': 'gate-len.svg',
  'P_SMP_POS': 'scrub--jitter.svg',
  'P_SMP_GRAINSIZE': 'grain-size--jitter.svg',
  'P_SMP_RATE': 'play-speed--jitter.svg',
  'P_SMP_TIME': 'time.svg',
  'P_SAMPLE': 'sample.svg',
  'P_SEQPAT': 'pattern--step-offset.svg',
  'P_JIT_POS': 'scrub--jitter.svg',
  'P_JIT_GRAINSIZE': 'grain-size--jitter.svg',
  'P_JIT_RATE': 'play-speed--jitter.svg',
  'P_JIT_PULSE': 'time.svg',
  'P_JIT_UNUSED': 'blank.svg',
  'P_SEQSTEP': 'pattern--step-offset.svg',
  'P_ASCALE': 'a-b-cv-level.svg',
  'P_AOFFSET': 'offset.svg',
  'P_ADEPTH': 'lfo--depth.svg',
  'P_AFREQ': 'lfo--rate.svg',
  'P_ASHAPE': 'lfo--shape.svg',
  'P_AWARP': 'lfo--symmetry.svg',
  'P_BSCALE': 'a-b-cv-level.svg',
  'P_BOFFSET': 'offset.svg',
  'P_BDEPTH': 'lfo--depth.svg',
  'P_BFREQ': 'lfo--rate.svg',
  'P_BSHAPE': 'lfo--shape.svg',
  'P_BWARP': 'lfo--symmetry.svg',
  'P_XSCALE': 'x-y-cv-level.svg',
  'P_XOFFSET': 'offset.svg',
  'P_XDEPTH': 'lfo--depth.svg',
  'P_XFREQ': 'lfo--rate.svg',
  'P_XSHAPE': 'lfo--shape.svg',
  'P_XWARP': 'lfo--symmetry.svg',
  'P_YSCALE': 'x-y-cv-level.svg',
  'P_YOFFSET': 'offset.svg',
  'P_YDEPTH': 'lfo--depth.svg',
  'P_YFREQ': 'lfo--rate.svg',
  'P_YSHAPE': 'lfo--shape.svg',
  'P_YWARP': 'lfo--symmetry.svg',
  'P_MIXSYNTH': 'synth.svg',
  'P_MIXWETDRY': 'wet-dry.svg',
  'P_MIXHPF': 'hpf.svg',
  'P_MIX_UNUSED': 'blank.svg',
  'P_CV_QUANT': 'cv-quantize.svg',
  'P_HEADPHONE': 'volume.svg',
  'P_MIXINPUT': 'input.svg',
  'P_MIXINWETDRY': 'wet-dry.svg',
  'P_SYS_UNUSED1': 'blank.svg',
  'P_SYS_UNUSED2': 'blank.svg',
  'P_SYS_UNUSED3': 'blank.svg',
  'P_ACCEL_SENS': 'cv-quantize.svg',
};
