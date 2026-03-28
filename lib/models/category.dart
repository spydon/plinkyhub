import 'package:plinkyhub/models/plinky_params.dart';

const _randomizeGroupParameterIds = <RandomizeGroup, List<String>>{
  RandomizeGroup.synth: synthParams,
  RandomizeGroup.envelope1: envelope1Params,
  RandomizeGroup.envelope2: envelope2Params,
  RandomizeGroup.effects: effectParams,
  RandomizeGroup.arpeggiator: arpParams,
  RandomizeGroup.sequencer: seqParams,
  RandomizeGroup.sampler: samplerParams,
  RandomizeGroup.modA: modAParams,
  RandomizeGroup.modB: modBParams,
  RandomizeGroup.modX: modXParams,
  RandomizeGroup.modY: modYParams,
};

/// Groups of parameters that can be selectively randomized.
enum RandomizeGroup {
  synth('synth', 'Synth'),
  envelope1('envelope-1', 'Envelope 1'),
  envelope2('envelope-2', 'Envelope 2'),
  effects('effects', 'Effects'),
  arpeggiator('arpeggiator', 'Arpeggiator'),
  sequencer('sequencer', 'Sequencer'),
  sampler('sampler', 'Sampler'),
  modA('mod-a', 'A'),
  modB('mod-b', 'B'),
  modX('mod-x', 'X'),
  modY('mod-y', 'Y')
  ;

  const RandomizeGroup(this.id, this.displayName);
  final String id;
  final String displayName;

  List<String> get parameterIds => _randomizeGroupParameterIds[this]!;
}

/// Sound type categories assignable to a preset on the
/// Plinky device.
///
/// The order of values must match the Plinky firmware
/// category indices, since `Preset` stores the category as
/// a byte index into this enum.
enum PresetCategory {
  none(''),
  bass('Bass'),
  leads('Leads'),
  pads('Pads'),
  arps('Arps'),
  plinks('Plinks'),
  plonks('Plonks'),
  beeps('Beeps'),
  boops('Boops'),
  sfx('SFX'),
  lineIn('Line-In'),
  sampler('Sampler'),
  donk('Donk'),
  jolly('Jolly'),
  sadness('Sadness'),
  wild('Wild'),
  gnarly('Gnarly'),
  weird('Weird')
  ;

  const PresetCategory(this.label);
  final String label;
}
