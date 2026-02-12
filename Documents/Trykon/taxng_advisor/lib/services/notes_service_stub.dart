// Stub file for web platform — provides no-op File/Directory so
// conditional import compiles without dart:io on web.
// ignore_for_file: camel_case_types, non_constant_identifier_names

class File {
  final String path;
  File(this.path);

  Future<bool> exists() async => false;
  Future<void> delete() async {}
  Future<File> copy(String newPath) async => File(newPath);
  Future<int> length() async => 0;
}

class Directory {
  final String path;
  Directory(this.path);

  Future<bool> exists() async => false;
  Future<Directory> create({bool recursive = false}) async => this;
}
