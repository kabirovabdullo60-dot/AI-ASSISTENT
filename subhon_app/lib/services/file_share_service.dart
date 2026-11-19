import 'dart:typed_data';

/// Hands a file to the phone (the share sheet: save to Files, send by
/// Telegram, e-mail…). Abstract so tests can use a fake.
abstract class FileShareService {
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });
}
