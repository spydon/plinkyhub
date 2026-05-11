enum SampleLoopMode {
  oneShotSlice,
  loopSlice,
  oneShotAll,
  loopAll
  ;

  int get value => index;

  static SampleLoopMode fromValue(int value) =>
      SampleLoopMode.values[value.clamp(0, SampleLoopMode.values.length - 1)];
}
