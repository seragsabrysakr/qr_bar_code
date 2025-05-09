import 'dart:typed_data';
import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';

/// Start and Stop symbols for Code Bar
enum BarcodeCodeBarStartStop {
  /// A or E
  A,

  /// B or N
  B,

  /// C or *
  C,

  /// D or T
  D,
}

/// Code bar Barcode
///
/// Code bar was designed to be accurately read even when printed on dot-matrix
/// printers for multi-part forms such as FedEx airbills and blood bank forms,
/// where variants are still in use as of 2007.
class BarcodeCodeBar extends Barcode1D {
  /// Create a Code bar Barcode
  const BarcodeCodeBar(
    this.start,
    this.stop,
    this.printStartStop,
    this.explicitStartStop,
  );

  /// Start symbol to use
  final BarcodeCodeBarStartStop start;

  /// Stop symbol to use
  final BarcodeCodeBarStartStop stop;

  /// Outputs the Start and Stop characters as text under the barcode
  final bool printStartStop;

  /// The caller must explicitly specify the Start and Stop characters
  /// as letters (ABCDETN*) in the data. In this case, start and stop
  /// settings are ignored
  final bool explicitStartStop;

  @override
  Iterable<int> get charSet =>
      BarcodeMaps.codabar.keys.where((int x) => x < 0x40);

  @override
  String get name => 'CODE BAR';

  @override
  Iterable<bool> convert(String data) sync* {
    final startStop = <int>[0x41, 0x42, 0x43, 0x44];

    var lStart = startStop[start.index];
    var lStop = startStop[stop.index];

    if (explicitStartStop) {
      lStart = _getStartStopByte(data.codeUnitAt(0));
      lStop = _getStartStopByte(data.codeUnitAt(data.length - 1));
      data = data.substring(1, data.length - 1);
    }

    // Start
    yield* add(BarcodeMaps.codabar[lStart]!, BarcodeMaps.codabarLen[lStart]!);

    // Space between chars
    yield false;

    for (var code in data.codeUnits) {
      if (code > 0x40 || code == 0x2a) {
        throw BarcodeException(
          'Unable to encode "${String.fromCharCode(code)}" to $name Barcode',
        );
      }

      final codeValue = BarcodeMaps.codabar[code];
      if (codeValue == null) {
        throw BarcodeException(
          'Unable to encode "${String.fromCharCode(code)}" to $name Barcode',
        );
      }
      final codeLen = BarcodeMaps.codabarLen[code]!;
      yield* add(codeValue, codeLen);

      // Space between chars
      yield false;
    }

    // Stop
    yield* add(BarcodeMaps.codabar[lStop]!, BarcodeMaps.codabarLen[lStop]!);
  }

  int _getStartStopByte(int value) {
    switch (value) {
      case 0x54:
        return 0x41;
      case 0x4e:
        return 0x42;
      case 0x2a:
        return 0x43;
      case 0x45:
        return 0x44;
    }
    return value;
  }

  @override
  void verifyBytes(Uint8List data) {
    if (explicitStartStop) {
      const validStartStop = [0x41, 0x42, 0x43, 0x44, 0x4e, 0x54, 0x2a, 0x45];

      if (data.length < 3) {
        throw BarcodeException(
          'Unable to encode $name Barcode: missing start and/or stop chars',
        );
      }

      if (!validStartStop.contains(data[0])) {
        throw BarcodeException(
          'Unable to encode $name Barcode: "${String.fromCharCode(data[0])}" is an invalid start char',
        );
      }

      if (!validStartStop.contains(data[data.length - 1])) {
        throw BarcodeException(
          'Unable to encode $name Barcode: "${String.fromCharCode(data[data.length - 1])}" is an invalid start char',
        );
      }

      data = data.sublist(1, data.length - 1);
    }

    super.verifyBytes(data);
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) {
    if (printStartStop && !explicitStartStop) {
      data =
          String.fromCharCode(start.index + 0x41) +
          data +
          String.fromCharCode(stop.index + 0x41);
    } else if (!printStartStop && explicitStartStop) {
      data = data.substring(1, data.length - 1);
    }

    return super.makeText(
      data,
      width,
      height,
      fontHeight,
      textPadding,
      lineWidth,
    );
  }
}
