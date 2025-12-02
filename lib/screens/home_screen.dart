import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';
import '../widgets/session_card.dart';
import '../widgets/level_filter_dialog.dart';
import '../widgets/timeline_view.dart';

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
    _tabController = TabController(length: 5, vsync: this);
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter by Level',
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => LevelFilterDialog(
                      agendaService: widget.agendaService,
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              ),
              if (widget.agendaService.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${widget.agendaService.selectedLevels.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'Overview'),
            Tab(icon: Icon(Icons.calendar_today), text: 'By Day'),
            Tab(icon: Icon(Icons.meeting_room), text: 'By Room'),
            Tab(icon: Icon(Icons.grid_on), text: 'Timeline'),
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
          TimelineView(agendaService: widget.agendaService),
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
          if (widget.agendaService.hasActiveFilters)
            _buildFilterBanner(),
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
            ..._buildSessionBlocks(todaySessions),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBanner() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtering by: ${widget.agendaService.selectedLevels.join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Clear filters',
            onPressed: () async {
              await widget.agendaService.clearLevelFilters();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildByDayTab() {
    final days = widget.agendaService.getDays();

    if (days.isEmpty) {
      return const Center(child: Text('No sessions available'));
    }

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    return ListView(
      children: [
        if (widget.agendaService.hasActiveFilters)
          _buildFilterBanner(),
        ...days.map((day) {
          final sessions = widget.agendaService.getSessionsByDay(day);
          final date = DateTime.parse(day);
          final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

          // Collapse days that are in the past (before today)
          final dateOnly = DateTime(date.year, date.month, date.day);
          final isPastDay = dateOnly.isBefore(todayDateOnly);

          return ExpansionTile(
            initiallyExpanded: !isPastDay,
            title: Text(
              formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${sessions.length} sessions'),
            children: _buildSessionBlocks(sessions),
          );
        }),
      ],
    );
  }

  List<Widget> _buildSessionBlocks(List<Session> sessions) {
    if (sessions.isEmpty) return [];

    // Group sessions by start time
    final Map<String, List<Session>> sessionBlocks = {};
    for (var session in sessions) {
      final startTime = session.startTime;
      if (!sessionBlocks.containsKey(startTime)) {
        sessionBlocks[startTime] = [];
      }
      sessionBlocks[startTime]!.add(session);
    }

    // Sort by start time
    final sortedStartTimes = sessionBlocks.keys.toList()..sort();

    // Build widgets with visual separation between blocks
    final List<Widget> widgets = [];
    for (int i = 0; i < sortedStartTimes.length; i++) {
      final startTime = sortedStartTimes[i];
      final blockSessions = sessionBlocks[startTime]!;

      // Add time block header
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.only(top: i == 0 ? 0 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                startTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${blockSessions.length} session${blockSessions.length > 1 ? 's' : ''})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      );

      // Add sessions in this block
      for (var session in blockSessions) {
        widgets.add(
          SessionCard(
            session: session,
            agendaService: widget.agendaService,
            onStarChanged: () => setState(() {}),
          ),
        );
      }

      // Add spacing after each block (except the last one)
      if (i < sortedStartTimes.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildByRoomTab() {
    final rooms = widget.agendaService.getRooms();

    if (rooms.isEmpty) {
      return const Center(child: Text('No rooms available'));
    }

    return ListView(
      children: [
        if (widget.agendaService.hasActiveFilters)
          _buildFilterBanner(),
        ...rooms.map((room) {
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
        }),
      ],
    );
  }

  Widget _buildMyScheduleTab() {
    final starredSessions = widget.agendaService.starredSessions;

    if (starredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No starred sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Star sessions to add them to your schedule',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return ListView(
      children: [
        if (widget.agendaService.hasActiveFilters)
          _buildFilterBanner(),
        ...sortedDays.map((day) {
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
              ..._buildSessionBlocks(sessions),
            ],
          );
        }),
      ],
    );
  }
}

