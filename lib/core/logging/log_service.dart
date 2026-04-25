import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class LogService {
  late Logger _logger;
  late File _logFile;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${directory.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _logFile = File('${logsDir.path}/app_log_$dateStr.log');

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        _FileLogOutput(_logFile),
      ]),
    );

    _initialized = true;
    _logger.i('LogService Initialized. Logging to: ${_logFile.path}');
  }

  void d(String message) => _logger.d(message);
  void i(String message) => _logger.i(message);
  void w(String message) => _logger.w(message);
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

class _FileLogOutput extends LogOutput {
  final File file;
  _FileLogOutput(this.file);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()}: $line\n',
        mode: FileMode.append,
      );
    }
  }
}
