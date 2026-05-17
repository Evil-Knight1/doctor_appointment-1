import 'package:signalr_core/signalr_core.dart';
import 'package:doctor_appointment/core/config/app_config.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'dart:async';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';

abstract class ChatSignalRService {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> sendMessage(int receiverId, String message);
  Stream<ChatMessageModel> get messageStream;
  Stream<String> get errorStream;
  Stream<int> get readStream;
  HubConnectionState get state;
}

class ChatSignalRServiceImpl implements ChatSignalRService {
  final AppConfig _config;
  final AuthLocalDataSource _authLocalDataSource;
  HubConnection? _connection;
  
  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _readController = StreamController<int>.broadcast();

  ChatSignalRServiceImpl(this._config, this._authLocalDataSource);

  @override
  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<int> get readStream => _readController.stream;

  @override
  HubConnectionState get state => _connection?.state ?? HubConnectionState.disconnected;

  @override
  Future<void> connect() async {
    if (_connection?.state == HubConnectionState.connected) return;

    final session = await _authLocalDataSource.getCachedSession();
    if (session == null) {
      _errorController.add("Authentication required");
      return;
    }

    final hubUrl = "${_config.apiUrl}/chathub";

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            accessTokenFactory: () async => session.token,
            logging: (level, message) => getIt<LogService>().d('SignalR [$level]: $message'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageDto = ChatMessageModel.fromJson(arguments[0] as Map<String, dynamic>);
        _messageController.add(messageDto);
      }
    });

    _connection!.on('MessageSent', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageDto = ChatMessageModel.fromJson(arguments[0] as Map<String, dynamic>);
        _messageController.add(messageDto);
      }
    });

    _connection!.on('MessagesRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final readerId = arguments[0];
        if (readerId is int) {
          _readController.add(readerId);
        } else if (readerId is Map<String, dynamic>) {
          final id = readerId['readerId'] ?? readerId['userId'] ?? readerId['senderId'];
          if (id != null) {
            _readController.add(int.parse(id.toString()));
          }
        } else {
          final id = int.tryParse(readerId.toString());
          if (id != null) {
            _readController.add(id);
          }
        }
      }
    });

    _connection!.on('MessageRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final readerId = arguments[0];
        if (readerId is int) {
          _readController.add(readerId);
        } else if (readerId is Map<String, dynamic>) {
          final id = readerId['readerId'] ?? readerId['userId'] ?? readerId['senderId'];
          if (id != null) {
            _readController.add(int.parse(id.toString()));
          }
        } else {
          final id = int.tryParse(readerId.toString());
          if (id != null) {
            _readController.add(id);
          }
        }
      }
    });

    _connection!.on('Error', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _errorController.add(arguments[0].toString());
      }
    });

    try {
      await _connection!.start();
      getIt<LogService>().i('SignalR: Connected to chat hub');
    } catch (e) {
      getIt<LogService>().e('SignalR: Connection error', e);
      _errorController.add("Failed to connect to chat server");
    }
  }

  @override
  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }

  @override
  Future<void> sendMessage(int receiverId, String message) async {
    if (_connection?.state != HubConnectionState.connected) {
      _errorController.add("Not connected to chat server");
      return;
    }

    try {
      await _connection!.invoke('SendMessage', args: [receiverId, message]);
    } catch (e) {
      getIt<LogService>().e('SignalR: Error sending message', e);
      _errorController.add("Failed to send message");
    }
  }
}
