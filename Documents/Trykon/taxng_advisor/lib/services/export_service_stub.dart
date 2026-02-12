// Stub file for web platform — provides no-op File/Directory so
// conditional import compiles without dart:io on web.
// ignore_for_file: camel_case_types, non_constant_identifier_names

class File {
  final String path;
  File(this.path);

  Future<void> writeAsString(String contents) async {}
  Future<void> writeAsBytes(List<int> bytes) async {}
  int lengthSync() => 0;
}
