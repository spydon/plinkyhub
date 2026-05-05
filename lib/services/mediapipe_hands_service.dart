import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

// ---------------------------------------------------------------------------
// JS interop for @mediapipe/tasks-vision (HandLandmarker)
// ---------------------------------------------------------------------------

@JS('FilesetResolver')
extension type _FilesetResolver._(JSObject _) implements JSObject {
  external static JSPromise<JSObject> forVisionTasks(JSString wasmPath);
}

@JS('HandLandmarker')
extension type _HandLandmarker._(JSObject _) implements JSObject {
  external static JSPromise<_HandLandmarker> createFromOptions(
    JSObject vision,
    JSObject options,
  );
  external JSObject detectForVideo(
    JSObject image,
    JSNumber timestampMilliseconds,
  );
}

/// A normalized 2D landmark from MediaPipe (values in 0..1).
class HandLandmark {
  const HandLandmark({required this.x, required this.y});

  final double x;
  final double y;
}

/// Thumb tip and fingertip landmark indices.
const thumbTipIndex = 4;
const indexTipIndex = 8;
const middleTipIndex = 12;

/// MCP (knuckle) indices used for palm-orientation detection.
const _wristIndex = 0;
const _indexMcpIndex = 5;
const _pinkyMcpIndex = 17;

/// Which hand MediaPipe detected (from the image's perspective).
enum Handedness { left, right }

/// Normalized distance threshold below which the thumb and index
/// finger are considered to be pinching. Tuned for typical webcam
/// hand sizes, roughly 6 % of the frame width.
const pinchThreshold = 0.06;

/// Result of a pinch-gesture check for one hand.
class PinchResult {
  const PinchResult({
    required this.isPinching,
    required this.x,
    required this.y,
    required this.closeness,
  });

  /// Whether the thumb and index tips are close enough to count as a
  /// pinch (distance < [pinchThreshold]).
  final bool isPinching;

  /// Normalised contact point (midpoint of thumb tip and index tip),
  /// in the same 0..1 coordinate space as the raw landmarks.
  final double x;
  final double y;

  /// How tightly the pinch is closed, in [0, 1]. 1 = tips touching,
  /// 0 = at or beyond the threshold. Maps naturally to MIDI velocity
  /// / pressure.
  final double closeness;
}

/// Detects whether a hand is making a pinch gesture (thumb tip close
/// to the given fingertip). Much more reliable across hand angles than
/// per-finger extension checks because it only measures the distance
/// between two well-tracked landmarks.
///
/// By default checks the index finger ([indexTipIndex]). Pass
/// [fingertipIndex] to check a different finger (e.g.
/// [middleTipIndex] for a latch gesture).
PinchResult? detectPinch(
  List<HandLandmark> hand, {
  int fingertipIndex = indexTipIndex,
}) {
  if (hand.length <= fingertipIndex) {
    return null;
  }
  final thumb = hand[thumbTipIndex];
  final finger = hand[fingertipIndex];
  final dx = thumb.x - finger.x;
  final dy = thumb.y - finger.y;
  final distance = sqrt(dx * dx + dy * dy);
  final isPinching = distance < pinchThreshold;
  final closeness = isPinching
      ? (1.0 - distance / pinchThreshold).clamp(0.0, 1.0)
      : 0.0;
  return PinchResult(
    isPinching: isPinching,
    x: (thumb.x + finger.x) / 2,
    y: (thumb.y + finger.y) / 2,
    closeness: closeness,
  );
}

/// Returns true when the palm side of [hand] faces the camera.
///
/// Uses the 2D cross product of the wrist → index-MCP and
/// wrist → pinky-MCP vectors. The sign of the cross product
/// flips when the hand turns over; combined with [handedness]
/// this reliably distinguishes palm from back-of-hand.
bool isPalmFacingCamera(List<HandLandmark> hand, Handedness handedness) {
  if (hand.length <= _pinkyMcpIndex) {
    return false;
  }
  final wrist = hand[_wristIndex];
  final indexMcp = hand[_indexMcpIndex];
  final pinkyMcp = hand[_pinkyMcpIndex];

  final v1x = indexMcp.x - wrist.x;
  final v1y = indexMcp.y - wrist.y;
  final v2x = pinkyMcp.x - wrist.x;
  final v2y = pinkyMcp.y - wrist.y;
  final cross = v1x * v2y - v1y * v2x;

  // MediaPipe labels hands from the image perspective, so "Left" in
  // the image is the person's right hand. Flip the sign accordingly.
  return handedness == Handedness.left ? cross > 0 : cross < 0;
}

typedef HandResultsCallback =
    void Function(
      List<List<HandLandmark>> hands,
      List<Handedness> handedness,
    );

/// Wraps the MediaPipe Tasks Vision HandLandmarker (loaded from CDN
/// in `web/index.html`). Uses CPU delegate to avoid WebGL context
/// conflicts with Flutter's CanvasKit renderer.
class MediaPipeHandsService {
  _HandLandmarker? _handLandmarker;
  int? _animationFrameId;
  HandResultsCallback? onResults;
  bool _running = false;

  Future<void> initialize(web.HTMLVideoElement videoElement) async {
    // The ES module script in index.html loads asynchronously; wait
    // for the globals to appear on window before proceeding.
    await _waitForGlobal('FilesetResolver');

    final vision = await _FilesetResolver.forVisionTasks(
      'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision/wasm'.toJS,
    ).toDart;

    _handLandmarker = await _HandLandmarker.createFromOptions(
      vision,
      _makeJsObject({
        'baseOptions': _makeJsObject({
          'modelAssetPath':
              'https://storage.googleapis.com/mediapipe-models/'
                      'hand_landmarker/hand_landmarker/float16/1/'
                      'hand_landmarker.task'
                  .toJS,
          'delegate': 'CPU'.toJS,
        }),
        'runningMode': 'VIDEO'.toJS,
        'numHands': 2.toJS,
      }),
    ).toDart;

    _running = true;
    _detectLoop(videoElement);
  }

  void _detectLoop(web.HTMLVideoElement videoElement) {
    if (!_running || _handLandmarker == null) {
      return;
    }

    void onFrame(JSNumber timestamp) {
      if (!_running || _handLandmarker == null) {
        return;
      }

      try {
        if (videoElement.readyState >= 2) {
          final results = _handLandmarker!.detectForVideo(
            videoElement as JSObject,
            timestamp,
          );
          _processResults(results);
        }
      } on Object catch (error) {
        debugPrint('MediaPipe detect error: $error');
      }

      _animationFrameId = web.window.requestAnimationFrame(onFrame.toJS);
    }

    _animationFrameId = web.window.requestAnimationFrame(onFrame.toJS);
  }

  void _processResults(JSObject results) {
    final callback = onResults;
    if (callback == null) {
      return;
    }

    final landmarksRaw = results['landmarks'];
    if (landmarksRaw == null || landmarksRaw.isUndefinedOrNull) {
      callback([], []);
      return;
    }

    final handsArray = landmarksRaw as JSArray;

    // Extract handedness classifications that sit alongside landmarks.
    final handednessRaw = results['handedness'];
    final handednessArray =
        handednessRaw != null && !handednessRaw.isUndefinedOrNull
        ? handednessRaw as JSArray
        : null;

    final hands = <List<HandLandmark>>[];
    final handedness = <Handedness>[];

    for (var handIndex = 0; handIndex < handsArray.length; handIndex++) {
      final handRaw = handsArray[handIndex];
      if (handRaw == null) {
        continue;
      }
      final landmarks = handRaw as JSArray;
      final points = <HandLandmark>[];
      for (var i = 0; i < landmarks.length; i++) {
        final point = landmarks[i];
        if (point == null) {
          continue;
        }
        final pointObject = point as JSObject;
        final x = pointObject['x'];
        final y = pointObject['y'];
        if (x == null || y == null) {
          continue;
        }
        points.add(
          HandLandmark(
            x: (x as JSNumber).toDartDouble,
            y: (y as JSNumber).toDartDouble,
          ),
        );
      }
      hands.add(points);

      // Determine handedness for this hand.
      var h = Handedness.right;
      if (handednessArray != null && handIndex < handednessArray.length) {
        final classifications = handednessArray[handIndex] as JSArray?;
        if (classifications != null && classifications.length > 0) {
          final first = classifications[0] as JSObject?;
          final label = first?['categoryName'];
          if (label != null) {
            h = (label as JSString).toDart == 'Left'
                ? Handedness.left
                : Handedness.right;
          }
        }
      }
      handedness.add(h);
    }
    callback(hands, handedness);
  }

  void dispose() {
    _running = false;
    final frameId = _animationFrameId;
    if (frameId != null) {
      web.window.cancelAnimationFrame(frameId);
    }
    _handLandmarker = null;
    _animationFrameId = null;
  }
}

/// Polls until [name] appears on the JS global context, with a
/// timeout so we don't spin forever if the script failed to load.
Future<void> _waitForGlobal(String name) async {
  const pollInterval = Duration(milliseconds: 100);
  const timeout = Duration(seconds: 15);
  final deadline = DateTime.now().add(timeout);
  while (!globalContext.has(name)) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError(
        'MediaPipe script did not load within '
        '${timeout.inSeconds} seconds ($name not found)',
      );
    }
    await Future<void>.delayed(pollInterval);
  }
}

/// Helper to create a plain JS object from a Dart map.
JSObject _makeJsObject(Map<String, JSAny?> properties) {
  final object = JSObject();
  for (final entry in properties.entries) {
    object[entry.key] = entry.value;
  }
  return object;
}
