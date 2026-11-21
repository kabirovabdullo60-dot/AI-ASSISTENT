import 'dart:typed_data';

/// Picks a file on the phone (Files, iCloud, Downloads…). Abstract so tests
/// can use a fake.
abstract class FilePickService {
  /// The bytes of a picked `.json` file; `null` when nothing was picked.
  Future<Uint8List?> pickJson();
}
