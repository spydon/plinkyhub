import 'dart:math';
import 'dart:typed_data';

import 'package:plinkyhub/models/plinky_params.dart';
import 'package:plinkyhub/utils/format.dart';

class SelectOption {
  const SelectOption({required this.label, required this.value});
  final String label;
  final int value;
}

class ParameterModulations {
  ParameterModulations(this._array);
  final Int16List _array;

  int get envelope => _array[1];
  set envelope(int value) => _array[1] = value;

  int get pressure => _array[2];
  set pressure(int value) => _array[2] = value;

  int get a => _array[3];
  set a(int value) => _array[3] = value;

  int get b => _array[4];
  set b(int value) => _array[4] = value;

  int get x => _array[5];
  set x(int value) => _array[5] = value;

  int get y => _array[6];
  set y(int value) => _array[6] = value;

  int get random => _array[7];
  set random(int value) => _array[7] = value;
}

class Parameter {
  Parameter({
    required this.id,
    required Int16List array,
    this.name,
    this.description = '',
    this.minimum = 0,
    this.maximum = 127,
    this.controlChange = -1,
    this.enumNames,
  })  : _array = array,
        modulations = ParameterModulations(array);

  final String id;
  final Int16List _array;
  final String? name;
  final String description;
  final double minimum;
  final double maximum;
  final int controlChange;
  final List<String>? enumNames;
  final ParameterModulations modulations;

  int get value => _array[0];
  set value(int newValue) => _array[0] = newValue;

  String get icon => paramIconMap[id] ?? 'blank.svg';

  String get displayValue {
    final option = getActiveSelectOption();
    if (option != null) {
      return option.label;
    }
    return formatValue(value);
  }

  List<SelectOption>? getSelectOptions() {
    if (enumNames == null) {
      return null;
    }
    final length = enumNames!.length;
    return List.generate(length, (index) {
      final optionValue = (index * (1024 / length) +
              (1024 / length * 0.5))
          .floor();
      return SelectOption(
        label: enumNames![index],
        value: optionValue,
      );
    });
  }

  SelectOption? getActiveSelectOption() {
    final options = getSelectOptions();
    if (options == null) {
      return null;
    }
    final width = 1024 / options.length;
    var index = (value / width).floor();
    if (index >= options.length) {
      index = options.length - 1;
    }
    if (index < 0) {
      index = 0;
    }
    return options[index];
  }

  void randomize() {
    final range = maximum - minimum;
    final randomValue = Random().nextDouble() * range;
    final newValue = minimum + randomValue;
    value = newValue.toInt();
  }
}
