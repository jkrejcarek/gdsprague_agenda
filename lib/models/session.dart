import 'speaker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Session {
  final String title;
  final String room;
  final String day;
  final String startTime;
  final String endTime;
  final String language;
  final String level;
  final String abstract;
  final List<Speaker> speakers;
  bool isStarred;

  Session({
    required this.title,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.language,
    required this.level,
    required this.abstract,
    required this.speakers,
    this.isStarred = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      title: json['title'] ?? '',
      room: json['room'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      language: json['language'] ?? '',
      level: json['level'] ?? '',
      abstract: json['abstract'] ?? '',
      speakers: (json['speakers'] as List<dynamic>?)
              ?.map((s) => Speaker.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'room': room,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'language': language,
      'level': level,
      'abstract': abstract,
      'speakers': speakers.map((s) => s.toJson()).toList(),
    };
  }

  String get uniqueId => '$day-$startTime-$room';

  bool get isEmpty => title.isEmpty;

  DateTime? get startDateTime {
    if (day.isEmpty || startTime.isEmpty) return null;
    try {
      final parts = startTime.split(':');
      final date = DateTime.parse(day);
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  DateTime? get endDateTime {
    if (day.isEmpty || endTime.isEmpty) return null;
    try {
      final parts = endTime.split(':');
      final date = DateTime.parse(day);
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  bool isHappeningNow() {
    final start = startDateTime;
    final end = endDateTime;
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  bool isUpcoming() {
    final start = startDateTime;
    if (start == null) return false;
    return start.isAfter(DateTime.now());
  }

  String getDayOfWeek() {
    if (day.isEmpty) return '';
    try {
      final date = DateTime.parse(day);
      return DateFormat('EEE').format(date); // Returns "Mon", "Tue", etc.
    } catch (e) {
      return '';
    }
  }

  Color getLevelColor() {
    switch (level) {
      case 'Industry Support':
        return const Color(0xFFC03232);
      case 'Legal Summit':
        return const Color(0xFFC66F40);
      case 'Game/Design':
        return const Color(0xFFE7AD2F);
      case 'Technical':
        return const Color(0xFF009EE2);
      case 'Art/Audio':
        return const Color(0xFF9BBA33);
      case "Business":
        return const Color(0xFFDE6E81);
      case "Sticks, Ropes and High Hopes":
        return const Color(0xFFc284fc);
      default:
        return Colors.grey;
    }
  }
}

