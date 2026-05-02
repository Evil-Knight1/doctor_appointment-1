import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('app_theme.dart') || file.path.contains('app_colors.dart')) {
      continue;
    }

    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('AppColors.bg')) {
      content = content.replaceAll('AppColors.bg', 'Theme.of(context).scaffoldBackgroundColor');
      modified = true;
    }

    if (content.contains('Colors.white')) {
      // Replace Colors.white with theme.scaffoldBackgroundColor or similar, but wait, some white is for text.
      // We will only do this for specific known background files if needed, or leave Colors.white for now 
      // because we already fixed AppStyles.
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Modified ${file.path}');
    }
  }
}
