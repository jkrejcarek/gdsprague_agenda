import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';
import '../widgets/session_card.dart';

class HomeScreen extends StatefulWidget {
  final AgendaService agendaService;

  const HomeScreen({super.key, required this.agendaService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDS Prague Agenda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'Overview'),
            Tab(icon: Icon(Icons.calendar_today), text: 'By Day'),
            Tab(icon: Icon(Icons.meeting_room), text: 'By Room'),
            Tab(icon: Icon(Icons.star), text: 'My Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildByDayTab(),
          _buildByRoomTab(),
          _buildMyScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final currentSessions = widget.agendaService.getCurrentSessions();
    final nextSessions = widget.agendaService.getNextSessions();
    final todaySessions = widget.agendaService.getTodaySessions();

    return RefreshIndicator(
      onRefresh: () async {
        await widget.agendaService.loadAgenda();
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (currentSessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Happening Now',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...currentSessions.map((session) => SessionCard(
                  session: session,
                  agendaService: widget.agendaService,
                  onStarChanged: () => setState(() {}),
                )),
            const SizedBox(height: 24),
          ],
          if (nextSessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Next Up',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...nextSessions.map((session) => SessionCard(
                  session: session,
                  agendaService: widget.agendaService,
                  onStarChanged: () => setState(() {}),
                )),
            const SizedBox(height: 24),
          ],
          if (todaySessions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Today\'s Sessions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...todaySessions.map((session) => SessionCard(
                  session: session,
                  agendaService: widget.agendaService,
                  onStarChanged: () => setState(() {}),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildByDayTab() {
    final days = widget.agendaService.getDays();

    if (days.isEmpty) {
      return const Center(child: Text('No sessions available'));
    }

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final sessions = widget.agendaService.getSessionsByDay(day);
        final date = DateTime.parse(day);
        final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

        return ExpansionTile(
          initiallyExpanded: index == 0,
          title: Text(
            formattedDate,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${sessions.length} sessions'),
          children: sessions
              .map((session) => SessionCard(
                    session: session,
                    agendaService: widget.agendaService,
                    onStarChanged: () => setState(() {}),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildByRoomTab() {
    final rooms = widget.agendaService.getRooms();

    if (rooms.isEmpty) {
      return const Center(child: Text('No rooms available'));
    }

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final sessions = widget.agendaService.getSessionsByRoom(room);

        return ExpansionTile(
          title: Text(
            room,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${sessions.length} sessions'),
          children: sessions
              .map((session) => SessionCard(
                    session: session,
                    agendaService: widget.agendaService,
                    onStarChanged: () => setState(() {}),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMyScheduleTab() {
    final starredSessions = widget.agendaService.starredSessions;

    if (starredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No starred sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Star sessions to add them to your schedule',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    // Group starred sessions by day
    final sessionsByDay = <String, List<Session>>{};
    for (var session in starredSessions) {
      if (!sessionsByDay.containsKey(session.day)) {
        sessionsByDay[session.day] = [];
      }
      sessionsByDay[session.day]!.add(session);
    }

    // Sort days
    final sortedDays = sessionsByDay.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final sessions = sessionsByDay[day]!;
        sessions.sort((a, b) {
          final aTime = a.startDateTime;
          final bTime = b.startDateTime;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        });

        final date = DateTime.parse(day);
        final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...sessions.map((session) => SessionCard(
                  session: session,
                  agendaService: widget.agendaService,
                  onStarChanged: () => setState(() {}),
                )),
          ],
        );
      },
    );
  }
}

