import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'file_share_service.dart';

/// [FileShareService] with the phone's share sheet: the file is written to
/// the app's temporary folder and shared from there.
class DeviceFileShareService implements FileShareService {
  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
    );
  }
}
