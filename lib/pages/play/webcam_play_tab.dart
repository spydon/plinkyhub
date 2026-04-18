import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/play/providers/midi_play_notifier.dart';
import 'package:plinkyhub/services/mediapipe_hands_service.dart';
import 'package:plinkyhub/utils/pitch.dart';
import 'package:web/web.dart' as web;

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

String _midiNoteName(int midi) {
  final octave = (midi ~/ 12) - 1;
  return '${_noteNames[midi % 12]}$octave';
}

/// Webcam-based MIDI controller. Renders a live camera feed with a
/// semi-transparent 8×8 note grid overlay. MediaPipe Hands detects
/// fingertips and triggers MIDI notes when they enter a cell.
class WebcamPlayTab extends ConsumerStatefulWidget {
  const WebcamPlayTab({
    required this.scale,
    required this.octaveOffset,
    required this.enabled,
    required this.latch,
    required this.active,
    super.key,
  });

  final PlinkyScale scale;
  final int octaveOffset;
  final bool enabled;
  final bool latch;

  /// Whether this tab is currently visible. When false the camera
  /// stream is stopped and all held notes are released.
  final bool active;

  @override
  ConsumerState<WebcamPlayTab> createState() => _WebcamPlayTabState();
}

class _WebcamPlayTabState extends ConsumerState<WebcamPlayTab> {
  final _mediaPipe = MediaPipeHandsService();
  web.HTMLVideoElement? _videoElement;
  web.MediaStream? _stream;
  String? _viewType;
  String? _errorMessage;
  bool _initializing = true;

  /// Horizontal crop offset in normalised coordinates (0..1) caused
  /// by `objectFit: cover` squashing a non-square camera feed into
  /// the square display. Landmarks within [_cropX, 1 - _cropX] are
  /// visible; those outside are off-screen.
  double _cropX = 0;
  double _cropY = 0;

  /// Maps each hand index to the grid pad it is currently pinching.
  final Map<int, int> _fingertipToPad = {};

  /// Tracks which hands had an active middle-finger pinch on the
  /// previous frame, so we only toggle latch on the rising edge.
  final Map<int, bool> _middlePinchWasActive = {};

  /// Latest hand landmarks for rendering the skeleton overlay.
  List<List<HandLandmark>> _latestHands = const [];

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _initializeCamera();
    } else {
      _initializing = false;
    }
  }

  @override
  void didUpdateWidget(WebcamPlayTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _initializeCamera();
    } else if (!widget.active && oldWidget.active) {
      _deactivate();
    }
  }

  @override
  void dispose() {
    _mediaPipe.dispose();
    _stopCamera();
    super.dispose();
  }

  /// Stops the camera stream, MediaPipe processing, and releases all
  /// held notes. Called when the user navigates away from this tab.
  void _deactivate() {
    _mediaPipe.dispose();
    _stopCamera();
    _fingertipToPad.clear();
    _middlePinchWasActive.clear();
    _latestHands = const [];
    ref.read(midiPlayProvider.notifier).releaseAll();
    setState(() {});
  }

  Future<void> _initializeCamera() async {
    try {
      // Reuse the existing video element when reactivating so we
      // don't re-register the platform view.
      var video = _videoElement;
      if (video == null) {
        video = web.document.createElement('video') as web.HTMLVideoElement;
        video.autoplay = true;
        video.setAttribute('playsinline', '');
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'cover';
        video.style.transform = 'scaleX(-1)';
        _videoElement = video;
      }

      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(
            web.MediaStreamConstraints(video: true.toJS),
          )
          .toDart;
      _stream = stream;
      video.srcObject = stream;

      // Wait for the video to have valid dimensions so we can
      // compute the objectFit: cover crop offset.
      await video.onLoadedMetadata.first;
      _updateCropOffsets();

      if (_viewType == null) {
        final viewType = 'webcam-play-${identityHashCode(this)}';
        ui_web.platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) => video!,
        );
        _viewType = viewType;
      }

      _mediaPipe.onResults = _onHandResults;

      if (!mounted) {
        return;
      }
      setState(() {
        _initializing = false;
      });

      await _mediaPipe.initialize(video);
    } on Object catch (error) {
      debugPrint('Webcam initialization error: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _initializing = false;
      });
    }
  }

  /// Computes how much `objectFit: cover` crops on each axis when
  /// fitting the camera's native resolution into a 1:1 square.
  void _updateCropOffsets() {
    final video = _videoElement;
    if (video == null) {
      return;
    }
    final videoWidth = video.videoWidth.toDouble();
    final videoHeight = video.videoHeight.toDouble();
    if (videoWidth <= 0 || videoHeight <= 0) {
      return;
    }
    if (videoWidth > videoHeight) {
      // Landscape camera → horizontal crop.
      _cropX = (videoWidth - videoHeight) / (2 * videoWidth);
      _cropY = 0;
    } else if (videoHeight > videoWidth) {
      // Portrait camera → vertical crop.
      _cropX = 0;
      _cropY = (videoHeight - videoWidth) / (2 * videoHeight);
    }
  }

  /// Maps a MediaPipe normalised coordinate (relative to the full
  /// video frame) to a display-space coordinate (relative to the
  /// visible, cropped square), accounting for the mirror flip.
  double _remapX(double normalizedX) {
    final visibleWidth = 1.0 - 2 * _cropX;
    if (visibleWidth <= 0) {
      return 0.5;
    }
    // Mirror, then shift into the visible range.
    return (1.0 - normalizedX - _cropX) / visibleWidth;
  }

  double _remapY(double normalizedY) {
    final visibleHeight = 1.0 - 2 * _cropY;
    if (visibleHeight <= 0) {
      return 0.5;
    }
    return (normalizedY - _cropY) / visibleHeight;
  }

  void _stopCamera() {
    final tracks = _stream?.getTracks().toDart;
    if (tracks != null) {
      for (final track in tracks) {
        track.stop();
      }
    }
  }

  void _onHandResults(
    List<List<HandLandmark>> hands,
    List<Handedness> handedness,
  ) {
    if (!mounted) {
      return;
    }

    // Always update the visual even when MIDI output is disabled.
    setState(() => _latestHands = hands);

    if (!widget.enabled) {
      return;
    }

    final newFingertips = <int, ({int padIndex, double pressure})>{};
    final notifier = ref.read(midiPlayProvider.notifier);

    for (var handIndex = 0; handIndex < hands.length; handIndex++) {
      final hand = hands[handIndex];
      final h = handIndex < handedness.length
          ? handedness[handIndex]
          : Handedness.right;

      // Only detect gestures when the palm is facing the camera.
      if (!isPalmFacingCamera(hand, h)) {
        // Reset middle-pinch edge state so a stale pinch does not
        // carry over when the palm becomes visible again.
        _middlePinchWasActive[handIndex] = false;
        continue;
      }

      // --- Index-finger pinch: play notes (existing behaviour) ---
      final pinch = detectPinch(hand);
      if (pinch != null && pinch.isPinching) {
        final mappedX = _remapX(pinch.x);
        final mappedY = _remapY(pinch.y);
        final column = (mappedX * 8).floor().clamp(0, 7);
        final row = (mappedY * 8).floor().clamp(0, 7);
        final padIndex = row * 8 + column;
        newFingertips[handIndex] = (
          padIndex: padIndex,
          pressure: pinch.closeness,
        );
      }

      // --- Middle-finger pinch: toggle latch on rising edge ---
      final middlePinch = detectPinch(
        hand,
        fingertipIndex: middleTipIndex,
      );
      final wasActive = _middlePinchWasActive[handIndex] ?? false;
      final isActive = middlePinch != null && middlePinch.isPinching;
      _middlePinchWasActive[handIndex] = isActive;

      if (isActive && !wasActive) {
        // Rising edge: latch the pad under the middle finger pinch
        // point. Use index pinch to unlatch.
        final mappedX = _remapX(middlePinch.x);
        final mappedY = _remapY(middlePinch.y);
        final column = (mappedX * 8).floor().clamp(0, 7);
        final row = (mappedY * 8).floor().clamp(0, 7);
        final padIndex = row * 8 + column;
        final pressureMap = ref.read(midiPlayProvider).pressureByPad;
        if (!pressureMap.containsKey(padIndex)) {
          notifier.pressPad(
            row: row,
            column: column,
            scale: widget.scale,
            octaveOffset: widget.octaveOffset,
            pressure: middlePinch.closeness,
          );
        }
      }
    }

    // Clean up middle-pinch state for hands that disappeared.
    _middlePinchWasActive.removeWhere(
      (handIndex, _) => handIndex >= hands.length,
    );

    _reconcileFingertips(newFingertips);
  }

  void _reconcileFingertips(
    Map<int, ({int padIndex, double pressure})> newFingertips,
  ) {
    final notifier = ref.read(midiPlayProvider.notifier);

    // Release pads whose fingertip disappeared or moved away.
    for (final entry in _fingertipToPad.entries) {
      final fingertipId = entry.key;
      final oldPad = entry.value;
      final newEntry = newFingertips[fingertipId];
      if (newEntry == null || newEntry.padIndex != oldPad) {
        if (!widget.latch) {
          notifier.releasePad(oldPad ~/ 8, oldPad % 8);
        }
      }
    }

    // Press or update pads.
    for (final entry in newFingertips.entries) {
      final fingertipId = entry.key;
      final newPad = entry.value.padIndex;
      final pressure = entry.value.pressure;
      final oldPad = _fingertipToPad[fingertipId];

      if (newPad == oldPad) {
        // Same cell, just update pressure (sends aftertouch).
        notifier.updatePadPressure(
          row: newPad ~/ 8,
          column: newPad % 8,
          pressure: pressure,
        );
        continue;
      }

      final row = newPad ~/ 8;
      final column = newPad % 8;
      if (widget.latch) {
        final pressureMap = ref.read(midiPlayProvider).pressureByPad;
        if (pressureMap.containsKey(newPad)) {
          notifier.releasePad(row, column);
        } else {
          notifier.pressPad(
            row: row,
            column: column,
            scale: widget.scale,
            octaveOffset: widget.octaveOffset,
            pressure: pressure,
          );
        }
      } else {
        notifier.pressPad(
          row: row,
          column: column,
          scale: widget.scale,
          octaveOffset: widget.octaveOffset,
          pressure: pressure,
        );
      }
    }

    _fingertipToPad.clear();
    for (final entry in newFingertips.entries) {
      _fingertipToPad[entry.key] = entry.value.padIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pressureByPad = ref.watch(
      midiPlayProvider.select((state) => state.pressureByPad),
    );

    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not start webcam',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HintRow(
                  icon: Icons.pinch_outlined,
                  text: 'Thumb + index pinch to play',
                  style: hintStyle,
                ),
                const SizedBox(height: 8),
                _HintRow(
                  icon: Icons.push_pin_outlined,
                  text: 'Thumb + middle pinch to latch',
                  style: hintStyle,
                ),
                const SizedBox(height: 8),
                _HintRow(
                  icon: Icons.lock_open_outlined,
                  text: 'Index pinch a latched note to unlatch',
                  style: hintStyle,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_viewType != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: HtmlElementView(viewType: _viewType!),
                    ),
                  _HandSkeletonOverlay(
                    hands: _latestHands,
                    cropX: _cropX,
                    cropY: _cropY,
                  ),
                  _WebcamGridOverlay(
                    scale: widget.scale,
                    octaveOffset: widget.octaveOffset,
                    pressureByPad: pressureByPad,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 180),
      ],
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: style?.color),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}

/// Draws the MediaPipe hand skeleton (landmarks + connections) over
/// the webcam feed so the user can see what the tracker detects.
class _HandSkeletonOverlay extends StatelessWidget {
  const _HandSkeletonOverlay({
    required this.hands,
    required this.cropX,
    required this.cropY,
  });

  final List<List<HandLandmark>> hands;
  final double cropX;
  final double cropY;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HandSkeletonPainter(
          hands: hands,
          cropX: cropX,
          cropY: cropY,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _HandSkeletonPainter extends CustomPainter {
  _HandSkeletonPainter({
    required this.hands,
    required this.cropX,
    required this.cropY,
    required this.primaryColor,
  });

  final List<List<HandLandmark>> hands;
  final double cropX;
  final double cropY;
  final Color primaryColor;

  /// MediaPipe hand connections (pairs of landmark indices).
  static const _connections = [
    // Thumb
    [0, 1], [1, 2], [2, 3], [3, 4],
    // Index
    [0, 5], [5, 6], [6, 7], [7, 8],
    // Middle
    [9, 10], [10, 11], [11, 12],
    // Ring
    [13, 14], [14, 15], [15, 16],
    // Pinky
    [17, 18], [18, 19], [19, 20],
    // Palm
    [0, 17], [5, 9], [9, 13], [13, 17],
  ];

  Offset _toCanvas(HandLandmark landmark, Size size) {
    // Remap from full-frame normalised coords to the visible
    // cropped square, and mirror x to match the flipped video.
    final visibleWidth = 1.0 - 2 * cropX;
    final visibleHeight = 1.0 - 2 * cropY;
    final remappedX = visibleWidth > 0
        ? (1.0 - landmark.x - cropX) / visibleWidth
        : 0.5;
    final remappedY = visibleHeight > 0
        ? (landmark.y - cropY) / visibleHeight
        : 0.5;
    return Offset(
      remappedX * size.width,
      remappedY * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final hand in hands) {
      if (hand.length < 21) {
        continue;
      }

      // Draw connections as lines.
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (final connection in _connections) {
        final start = _toCanvas(hand[connection[0]], size);
        final end = _toCanvas(hand[connection[1]], size);
        canvas.drawLine(start, end, linePaint);
      }

      // Draw landmarks as dots.
      final dotPaint = Paint()..style = PaintingStyle.fill;
      final indexPinch = detectPinch(hand);
      final middlePinch = detectPinch(
        hand,
        fingertipIndex: middleTipIndex,
      );
      for (var i = 0; i < hand.length; i++) {
        final position = _toCanvas(hand[i], size);
        final isIndexFinger = i == thumbTipIndex || i == indexTipIndex;
        final isMiddleFinger = i == middleTipIndex;
        final isIndexPinching =
            isIndexFinger && indexPinch != null && indexPinch.isPinching;
        final isMiddlePinching =
            isMiddleFinger && middlePinch != null && middlePinch.isPinching;

        if (isIndexPinching || isMiddlePinching) {
          dotPaint.color = primaryColor;
          canvas.drawCircle(position, 7, dotPaint);
        } else if (isIndexFinger || isMiddleFinger) {
          dotPaint.color = Colors.white.withValues(alpha: 0.9);
          canvas.drawCircle(position, 6, dotPaint);
        } else {
          dotPaint.color = Colors.white.withValues(alpha: 0.5);
          canvas.drawCircle(position, 3, dotPaint);
        }
      }

      // Draw a line between thumb and index to visualise the pinch.
      if (indexPinch != null) {
        final thumbPosition = _toCanvas(hand[thumbTipIndex], size);
        final indexPosition = _toCanvas(hand[indexTipIndex], size);
        final pinchLinePaint = Paint()
          ..color = indexPinch.isPinching
              ? primaryColor.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = indexPinch.isPinching ? 3 : 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(thumbPosition, indexPosition, pinchLinePaint);
      }

      // Draw a line between thumb and middle finger for latch pinch.
      if (middlePinch != null) {
        final thumbPosition = _toCanvas(hand[thumbTipIndex], size);
        final middlePosition = _toCanvas(hand[middleTipIndex], size);
        final latchLinePaint = Paint()
          ..color = middlePinch.isPinching
              ? primaryColor.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = middlePinch.isPinching ? 3 : 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(thumbPosition, middlePosition, latchLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_HandSkeletonPainter oldDelegate) =>
      !identical(hands, oldDelegate.hands);
}

/// Semitransparent 8×8 note grid drawn on top of the webcam feed.
class _WebcamGridOverlay extends StatelessWidget {
  const _WebcamGridOverlay({
    required this.scale,
    required this.octaveOffset,
    required this.pressureByPad,
  });

  final PlinkyScale scale;
  final int octaveOffset;
  final Map<int, double> pressureByPad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IgnorePointer(
      child: Column(
        children: [
          for (var row = 0; row < 8; row++)
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < 8; column++)
                    Expanded(
                      child: _OverlayCell(
                        note: midiNoteForPad(
                          row: row,
                          column: column,
                          scale: scale,
                          octaveOffset: octaveOffset,
                        ),
                        pressure: pressureByPad[row * 8 + column] ?? 0,
                        isActive: pressureByPad.containsKey(row * 8 + column),
                        primaryColor: colorScheme.primary,
                        onPrimaryColor: colorScheme.onPrimary,
                        textStyle: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayCell extends StatelessWidget {
  const _OverlayCell({
    required this.note,
    required this.pressure,
    required this.isActive,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.textStyle,
  });

  final int note;
  final double pressure;
  final bool isActive;
  final Color primaryColor;
  final Color onPrimaryColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // Brightness follows pressure, same approach as the pad grid:
    // full pressure = saturated primary, zero = mostly transparent.
    final fillColor = isActive
        ? Color.lerp(
            Colors.black.withValues(alpha: 0.15),
            primaryColor.withValues(alpha: 0.7),
            pressure,
          )!
        : Colors.black.withValues(alpha: 0.15);
    final textColor = isActive && pressure > 0.5
        ? onPrimaryColor
        : Colors.white.withValues(alpha: 0.8);

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive
              ? primaryColor.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _midiNoteName(note),
        style: textStyle?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
