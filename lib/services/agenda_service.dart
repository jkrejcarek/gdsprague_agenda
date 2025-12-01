import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class AgendaService {
  static const String _starredKey = 'starred_sessions';
  static const String _levelFilterKey = 'level_filters';
  List<Session> _sessions = [];
  Set<String> _starredSessionIds = {};
  Set<String> _selectedLevels = {};

  List<Session> get sessions => _applyFilters(_sessions);

  List<Session> get starredSessions {
    return _applyFilters(_sessions.where((s) => s.isStarred).toList());
  }

  Set<String> get selectedLevels => _selectedLevels;

  bool get hasActiveFilters => _selectedLevels.isNotEmpty;

  List<Session> _applyFilters(List<Session> sessions) {
    if (_selectedLevels.isEmpty) return sessions;
    return sessions.where((s) => _selectedLevels.contains(s.level)).toList();
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

      // Load level filters from preferences
      await _loadLevelFilters();

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

  Future<void> _loadLevelFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelList = prefs.getStringList(_levelFilterKey) ?? [];
      _selectedLevels = Set.from(levelList);
    } catch (e) {
      debugPrint('Error loading level filters: $e');
    }
  }

  Future<void> _saveLevelFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_levelFilterKey, _selectedLevels.toList());
    } catch (e) {
      debugPrint('Error saving level filters: $e');
    }
  }

  Future<void> toggleLevelFilter(String level) async {
    if (_selectedLevels.contains(level)) {
      _selectedLevels.remove(level);
    } else {
      _selectedLevels.add(level);
    }
    await _saveLevelFilters();
  }

  Future<void> clearLevelFilters() async {
    _selectedLevels.clear();
    await _saveLevelFilters();
  }

  List<String> getAllLevels() {
    final levels = _sessions
        .where((s) => s.level.isNotEmpty)
        .map((s) => s.level)
        .toSet()
        .toList();
    levels.sort();
    return levels;
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
    return _applyFilters(
      _sessions
          .where((s) => s.day == day && !s.isEmpty)
          .toList()
        ..sort((a, b) {
          final aTime = a.startDateTime;
          final bTime = b.startDateTime;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        }),
    );
  }

  List<Session> getSessionsByRoom(String room) {
    return _applyFilters(
      _sessions
          .where((s) => s.room == room && !s.isEmpty)
          .toList()
        ..sort((a, b) {
          final aTime = a.startDateTime;
          final bTime = b.startDateTime;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        }),
    );
  }

  Session? getNextSession() {
    final now = DateTime.now();
    final upcomingSessions = _applyFilters(_sessions)
        .where((s) => s.startDateTime != null && s.startDateTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDateTime!.compareTo(b.startDateTime!));

    return upcomingSessions.isEmpty ? null : upcomingSessions.first;
  }

  List<Session> getNextSessions() {
    final now = DateTime.now();
    final upcomingSessions = _applyFilters(_sessions)
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
    return _applyFilters(_sessions.where((s) => s.isHappeningNow()).toList());
  }

  List<Session> getTodaySessions() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getSessionsByDay(todayStr);
  }
}

