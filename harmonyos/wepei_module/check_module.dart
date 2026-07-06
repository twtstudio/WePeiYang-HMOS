import 'dart:io';

void main() {
  final dir = Directory('.android/Flutter');
  print('cwd: ${Directory.current.path}');
  print('flutterModule exists: ${dir.existsSync()}');
  print('flutterModule isDir: ${dir.isDirectory}');
  try {
    print('flutterModule list: ${dir.listSync().map((e) => '${e.path} [${e.statSync().type}]').toList()}');
  } catch (e) {
    print('list error: $e');
  }
}
