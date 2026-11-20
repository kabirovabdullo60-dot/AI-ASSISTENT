import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'file_pick_service.dart';

class DeviceFilePickService implements FilePickService {
  const DeviceFilePickService();

  @override
  Future<Uint8List?> pickJson() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    return file?.xFile.readAsBytes();
  }
}
