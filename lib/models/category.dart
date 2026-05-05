import 'package:plinkyhub/models/labeled_enum.dart';
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
  synth('Synth'),
  envelope1('Envelope 1'),
  envelope2('Envelope 2'),
  effects('Effects'),
  arpeggiator('Arpeggiator'),
  sequencer('Sequencer'),
  sampler('Sampler'),
  modA('A'),
  modB('B'),
  modX('X'),
  modY('Y')
  ;

  const RandomizeGroup(this.displayName);
  final String displayName;

  List<String> get parameterIds => _randomizeGroupParameterIds[this]!;
}

/// Sound type categories assignable to a preset on the
/// Plinky device.
///
/// The order of values must match the Plinky firmware
/// category indices, since `Preset` stores the category as
/// a byte index into this enum.
enum PresetCategory implements LabeledEnum {
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

  @override
  final String label;

  static PresetCategory? fromName(String name) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
