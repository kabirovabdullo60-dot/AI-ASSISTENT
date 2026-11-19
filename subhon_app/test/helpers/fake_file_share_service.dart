import 'dart:typed_data';

import 'package:subhon_app/services/file_share_service.dart';

/// Keeps the shared files instead of opening the share sheet.
class FakeFileShareService implements FileShareService {
  final List<(String, Uint8List)> shared = [];

  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async => shared.add((fileName, bytes));
}
