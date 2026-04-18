import 'package:flutter/material.dart';
import 'package:plinkyhub/pages/wavetables/utils/waveform_effects.dart';

/// Panel displaying labeled sliders for all waveform effects.
class WaveformEffectsPanel extends StatelessWidget {
  const WaveformEffectsPanel({
    required this.effects,
    required this.onEffectsChanged,
    required this.onApply,
    this.enabled = true,
    super.key,
  });

  final WaveformEffects effects;
  final VoidCallback onEffectsChanged;
  final VoidCallback onApply;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waveshaper', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _EffectSlider(
          label: 'Pre Gain',
          value: effects.preGain,
          onChanged: enabled
              ? (value) {
                  effects.preGain = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Harmonic Shift',
          value: effects.harmonicShift,
          onChanged: enabled
              ? (value) {
                  effects.harmonicShift = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Comb',
          value: effects.comb,
          onChanged: enabled
              ? (value) {
                  effects.comb = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Ring Mod',
          value: effects.ringModulation,
          onChanged: enabled
              ? (value) {
                  effects.ringModulation = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Chebyshev',
          value: effects.chebyshev,
          onChanged: enabled
              ? (value) {
                  effects.chebyshev = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Sample & Hold',
          value: effects.sampleAndHold,
          onChanged: enabled
              ? (value) {
                  effects.sampleAndHold = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Quantization',
          value: effects.quantization,
          onChanged: enabled
              ? (value) {
                  effects.quantization = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Slew Limiter',
          value: effects.slewLimiter,
          onChanged: enabled
              ? (value) {
                  effects.slewLimiter = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Lowpass',
          value: effects.lowpass,
          onChanged: enabled
              ? (value) {
                  effects.lowpass = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Highpass',
          value: effects.highpass,
          onChanged: enabled
              ? (value) {
                  effects.highpass = value;
                  onEffectsChanged();
                }
              : null,
        ),
        _EffectSlider(
          label: 'Post Gain',
          value: effects.postGain,
          onChanged: enabled
              ? (value) {
                  effects.postGain = value;
                  onEffectsChanged();
                }
              : null,
        ),
        const SizedBox(height: 4),
        _EffectToggleRow(
          effects: effects,
          enabled: enabled,
          onEffectsChanged: onEffectsChanged,
        ),
        const SizedBox(height: 8),
        _ApplyResetRow(
          effects: effects,
          enabled: enabled,
          onApply: onApply,
          onReset: () {
            effects.reset();
            onEffectsChanged();
          },
        ),
      ],
    );
  }
}

class _EffectSlider extends StatelessWidget {
  const _EffectSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12,
                ),
                activeTrackColor: theme.colorScheme.tertiary,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                thumbColor: theme.colorScheme.tertiary,
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(2),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectToggleRow extends StatelessWidget {
  const _EffectToggleRow({
    required this.effects,
    required this.enabled,
    required this.onEffectsChanged,
  });

  final WaveformEffects effects;
  final bool enabled;
  final VoidCallback onEffectsChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleChip(
          label: 'Normalize',
          value: effects.normalize,
          onChanged: enabled
              ? (value) {
                  effects.normalize = value;
                  onEffectsChanged();
                }
              : null,
        ),
        const SizedBox(width: 8),
        _ToggleChip(
          label: 'Cycle',
          value: effects.cycle,
          onChanged: enabled
              ? (value) {
                  effects.cycle = value;
                  onEffectsChanged();
                }
              : null,
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }
}

class _ApplyResetRow extends StatelessWidget {
  const _ApplyResetRow({
    required this.effects,
    required this.enabled,
    required this.onApply,
    required this.onReset,
  });

  final WaveformEffects effects;
  final bool enabled;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final hasEffects = effects.hasAnyEffect;
    return Row(
      children: [
        ActionChip(
          label: const Text('Apply'),
          avatar: const Icon(Icons.check, size: 16),
          onPressed: enabled && hasEffects ? onApply : null,
        ),
        const SizedBox(width: 8),
        ActionChip(
          label: const Text('Reset'),
          avatar: const Icon(Icons.refresh, size: 16),
          onPressed: enabled && hasEffects ? onReset : null,
        ),
      ],
    );
  }
}
