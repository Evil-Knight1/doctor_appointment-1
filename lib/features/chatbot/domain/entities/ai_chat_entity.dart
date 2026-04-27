import 'package:equatable/equatable.dart';

class AIChatMessage extends Equatable {
  final int? id;
  final String sessionId;
  final String userMessage;
  final String aiMessage;
  final DateTime createdAt;

  const AIChatMessage({
    this.id,
    required this.sessionId,
    required this.userMessage,
    required this.aiMessage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sessionId, userMessage, aiMessage, createdAt];
}

class AIChatResponse extends Equatable {
  final String sessionId;
  final String userMessage;
  final String aiMessage;
  final String? riskLevel;
  final List<String>? followUpQuestions;
  final Map<String, dynamic>? structured;
  final DateTime createdAt;

  const AIChatResponse({
    required this.sessionId,
    required this.userMessage,
    required this.aiMessage,
    this.riskLevel,
    this.followUpQuestions,
    this.structured,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        sessionId,
        userMessage,
        aiMessage,
        riskLevel,
        followUpQuestions,
        structured,
        createdAt,
      ];
}
