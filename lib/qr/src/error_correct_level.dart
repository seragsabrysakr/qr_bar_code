class QRErrorCorrectLevel {
  static const int L = 1;
  static const int M = 0;
  static const int Q = 3;
  static const int H = 2;

  // these *are* in order of lowest to highest quality...I think
  // all I know for sure: you can create longer messages w/ item N than N+1
  // I assume this corresponds to more error correction for N+1
  static const List<int> levels = [L, M, Q, H];

  static String getName(int level) => switch (level) {
    L => 'Low',
    M => 'Medium',
    Q => 'Quartile',
    H => 'High',
    _ => throw ArgumentError('level $level not supported'),
  };
}
