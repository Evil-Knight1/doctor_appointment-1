import 'dart:async';

import 'package:doctor_appointment/core/config/app_config.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:signalr_core/signalr_core.dart';

abstract class ChatSignalRService {
  Future<bool> connect();
  Future<void> disconnect();
  Future<void> sendMessage(int receiverId, String message);
  Stream<ChatMessageModel> get messageStream;
  Stream<String> get errorStream;
  Stream<int> get readStream;
  Stream<bool> get connectionStream;
  HubConnectionState get state;
}

class ChatSignalRServiceImpl implements ChatSignalRService {
  final AppConfig _config;
  final AuthLocalDataSource _authLocalDataSource;

  HubConnection? _connection;
  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _readController = StreamController<int>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  ChatSignalRServiceImpl(this._config, this._authLocalDataSource);

  @override
  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<int> get readStream => _readController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  HubConnectionState get state =>
      _connection?.state ?? HubConnectionState.disconnected;

  @override
  Future<bool> connect() async {
    if (_connection?.state == HubConnectionState.connected) {
      _connectionController.add(true);
      return true;
    }

    final session = await _authLocalDataSource.getCachedSession();
    if (session == null) {
      _errorController.add('Authentication required');
      _connectionController.add(false);
      return false;
    }

    final hubUrl = '${_config.apiUrl}/chathub';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            accessTokenFactory: () async => session.token,
            logging: (level, message) =>
                getIt<LogService>().d('SignalR [$level]: $message'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.onclose((error) {
      getIt<LogService>().w('SignalR: Connection closed ${error ?? ''}');
      _connectionController.add(false);
    });

    _connection!.onreconnecting((error) {
      getIt<LogService>().w('SignalR: Reconnecting ${error ?? ''}');
      _connectionController.add(false);
    });

    _connection!.onreconnected((connectionId) {
      getIt<LogService>().i('SignalR: Reconnected ($connectionId)');
      _connectionController.add(true);
    });

    _connection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageDto = ChatMessageModel.fromJson(
          arguments[0] as Map<String, dynamic>,
        );
        _messageController.add(messageDto);
      }
    });

    _connection!.on('MessageSent', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageDto = ChatMessageModel.fromJson(
          arguments[0] as Map<String, dynamic>,
        );
        _messageController.add(messageDto);
      }
    });

    _connection!.on('MessagesRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _pushReadEvent(arguments[0]);
      }
    });

    _connection!.on('MessageRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _pushReadEvent(arguments[0]);
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
      _connectionController.add(true);
      return true;
    } catch (e) {
      getIt<LogService>().e('SignalR: Connection error', e);
      _errorController.add('Failed to connect to chat server');
      _connectionController.add(false);
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
    _connectionController.add(false);
  }

  @override
  Future<void> sendMessage(int receiverId, String message) async {
    if (_connection?.state != HubConnectionState.connected) {
      _errorController.add('Not connected to chat server');
      return;
    }

    try {
      await _connection!.invoke('SendMessage', args: [receiverId, message]);
    } catch (e) {
      getIt<LogService>().e('SignalR: Error sending message', e);
      _errorController.add('Failed to send message');
    }
  }

  void _pushReadEvent(dynamic readerId) {
    if (readerId is int) {
      _readController.add(readerId);
      return;
    }

    if (readerId is Map<String, dynamic>) {
      final id =
          readerId['readerId'] ?? readerId['userId'] ?? readerId['senderId'];
      if (id != null) {
        _readController.add(int.parse(id.toString()));
      }
      return;
    }

    final id = int.tryParse(readerId.toString());
    if (id != null) {
      _readController.add(id);
    }
  }
}
