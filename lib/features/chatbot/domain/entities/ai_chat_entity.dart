import 'package:equatable/equatable.dart';

class UiComponent extends Equatable {
  final String type; // text, radio, checkbox
  final List<String> options;
  final bool allowOther;

  const UiComponent({
    required this.type,
    this.options = const [],
    this.allowOther = true,
  });

  @override
  List<Object?> get props => [type, options, allowOther];
}

class DoctorSearchParams extends Equatable {
  final String? specialization;
  final String? location;
  final double? minRating;

  const DoctorSearchParams({
    this.specialization,
    this.location,
    this.minRating,
  });

  @override
  List<Object?> get props => [specialization, location, minRating];
}

class NewChatResponse extends Equatable {
  final String sessionId;
  final String welcomeMessageEn;
  final String welcomeMessageAr;

  const NewChatResponse({
    required this.sessionId,
    required this.welcomeMessageEn,
    required this.welcomeMessageAr,
  });

  @override
  List<Object?> get props => [sessionId, welcomeMessageEn, welcomeMessageAr];
}

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
  final String? type; // chat, get_doctors
  final UiComponent? ui;
  final DoctorSearchParams? searchParams;
  final DateTime createdAt;

  const AIChatResponse({
    required this.sessionId,
    required this.userMessage,
    required this.aiMessage,
    this.riskLevel,
    this.followUpQuestions,
    this.structured,
    this.type,
    this.ui,
    this.searchParams,
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
        type,
        ui,
        searchParams,
        createdAt,
      ];
}
