double normalize(int x) => x / 1024 * 100;

double denormalize(double x) => x / 100 * 1024;

double _round(double num) =>
    ((num * 10 + double.minPositive) * 10).roundToDouble() / 10;

String formatValue(int v) => _round(normalize(v)).toStringAsFixed(1);
