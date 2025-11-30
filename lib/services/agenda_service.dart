import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class AgendaService {
  static const String _starredKey = 'starred_sessions';
  List<Session> _sessions = [];
  Set<String> _starredSessionIds = {};

  List<Session> get sessions => _sessions;

  List<Session> get starredSessions {
    return _sessions.where((s) => s.isStarred).toList();
  }

  Future<void> loadAgenda() async {
    try {
      final jsonString = await rootBundle.loadString('agenda.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _sessions = jsonData
          .map((json) => Session.fromJson(json))
          .where((session) => !session.isEmpty)
          .toList();

      // Load starred sessions from preferences
      await _loadStarredSessions();

      // Apply starred state
      for (var session in _sessions) {
        session.isStarred = _starredSessionIds.contains(session.uniqueId);
      }
    } catch (e) {
      debugPrint('Error loading agenda: $e');
    }
  }

  Future<void> _loadStarredSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starredList = prefs.getStringList(_starredKey) ?? [];
      _starredSessionIds = Set.from(starredList);
    } catch (e) {
      debugPrint('Error loading starred sessions: $e');
    }
  }

  Future<void> toggleStar(Session session) async {
    session.isStarred = !session.isStarred;

    if (session.isStarred) {
      _starredSessionIds.add(session.uniqueId);
    } else {
      _starredSessionIds.remove(session.uniqueId);
    }

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_starredKey, _starredSessionIds.toList());
    } catch (e) {
      debugPrint('Error saving starred sessions: $e');
    }
  }

  List<String> getDays() {
    final days = _sessions
        .where((s) => s.day.isNotEmpty)
        .map((s) => s.day)
        .toSet()
        .toList();
    days.sort();
    return days;
  }

  List<String> getRooms() {
    final rooms = _sessions
        .where((s) => s.room.isNotEmpty)
        .map((s) => s.room)
        .toSet()
        .toList();
    rooms.sort();
    return rooms;
  }

  List<Session> getSessionsByDay(String day) {
    return _sessions
        .where((s) => s.day == day && !s.isEmpty)
        .toList()
      ..sort((a, b) {
        final aTime = a.startDateTime;
        final bTime = b.startDateTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
  }

  List<Session> getSessionsByRoom(String room) {
    return _sessions
        .where((s) => s.room == room && !s.isEmpty)
        .toList()
      ..sort((a, b) {
        final aTime = a.startDateTime;
        final bTime = b.startDateTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
  }

  Session? getNextSession() {
    final now = DateTime.now();
    final upcomingSessions = _sessions
        .where((s) => s.startDateTime != null && s.startDateTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDateTime!.compareTo(b.startDateTime!));

    return upcomingSessions.isEmpty ? null : upcomingSessions.first;
  }

  List<Session> getNextSessions() {
    final now = DateTime.now();
    final upcomingSessions = _sessions
        .where((s) => s.startDateTime != null && s.startDateTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDateTime!.compareTo(b.startDateTime!));

    if (upcomingSessions.isEmpty) return [];

    // Get the start time of the next session
    final nextStartTime = upcomingSessions.first.startDateTime!;

    // Return all sessions that start at the same time
    return upcomingSessions
        .where((s) => s.startDateTime!.isAtSameMomentAs(nextStartTime))
        .toList();
  }

  List<Session> getCurrentSessions() {
    return _sessions.where((s) => s.isHappeningNow()).toList();
  }

  List<Session> getTodaySessions() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getSessionsByDay(todayStr);
  }
}

