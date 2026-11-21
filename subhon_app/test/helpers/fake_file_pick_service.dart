import 'dart:typed_data';

import 'package:subhon_app/services/file_pick_service.dart';

/// "Picks" [file] (`null`: the person cancels).
class FakeFilePickService implements FilePickService {
  Uint8List? file;

  @override
  Future<Uint8List?> pickJson() async => file;
}
