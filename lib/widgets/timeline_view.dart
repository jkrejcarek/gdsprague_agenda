import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';
import '../screens/session_detail_screen.dart';

class TimelineView extends StatefulWidget {
  final AgendaService agendaService;

  const TimelineView({super.key, required this.agendaService});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _timeScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();

  bool _isSyncingScroll = false;

  String? _selectedDay;


  @override
  void initState() {
    super.initState();
    _selectedDay = widget.agendaService.getDays().firstOrNull;

    // Sync vertical scrolling between time column and content area
    _timeScrollController.addListener(() {
      if (_isSyncingScroll) return;
      if (!_contentScrollController.hasClients) return;
      _isSyncingScroll = true;
      final offset = _timeScrollController.position.pixels;
      final max = _contentScrollController.position.maxScrollExtent;
      _contentScrollController.jumpTo(offset.clamp(0.0, max));
      _isSyncingScroll = false;
    });

    _contentScrollController.addListener(() {
      if (_isSyncingScroll) return;
      if (!_timeScrollController.hasClients) return;
      _isSyncingScroll = true;
      final offset = _contentScrollController.position.pixels;
      final max = _timeScrollController.position.maxScrollExtent;
      _timeScrollController.jumpTo(offset.clamp(0.0, max));
      _isSyncingScroll = false;
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _timeScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.agendaService.getDays();

    if (days.isEmpty) {
      return const Center(child: Text('No sessions available'));
    }

    _selectedDay ??= days.first;

    final sessions = widget.agendaService.getSessionsByDay(_selectedDay!);

    return Column(
      children: [
        // Day selector
        Container(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<String>(
            segments: days.map((day) {
              final date = DateTime.parse(day);
              final formattedDate = DateFormat('EEE, MMM d').format(date);
              return ButtonSegment<String>(
                value: day,
                label: Text(formattedDate),
              );
            }).toList(),
            selected: {_selectedDay!},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedDay = newSelection.first;
              });
            },
          ),
        ),
        // Timeline grid
        Expanded(
          child: _buildTimelineGrid(sessions),
        ),
      ],
    );
  }

  Widget _buildTimelineGrid(List<Session> sessions) {
    // Get all unique hour slots (rounded to hour)
    final hourSlots = _getHourSlots(sessions);

    if (hourSlots.isEmpty) {
      return const Center(child: Text('No sessions for this day'));
    }


    const double hourHeight = 120.0; // Height for one hour
    const double timeColumnWidth = 50.0;
    const double roomCellWidth = 200.0;

    return Row(
      children: [
        // Fixed column for room names
        Column(
          children: [
            // Header corner
            Container(
              width: timeColumnWidth,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Center(
                child: Text(
                  'Time',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            // Time slots
            Expanded(
              child: SingleChildScrollView(
                controller: _timeScrollController,
                child: Column(
                  children: hourSlots.map((hour) {
                    return Container(
                      width: timeColumnWidth,
                      height: hourHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border(
                          right: BorderSide(color: Theme.of(context).dividerColor),
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '$hour:00',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        // Scrollable room columns
        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Room headers
                Row(
                  children: AgendaService.roomOrder.map((room) {
                    return Container(
                      width: roomCellWidth,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border(
                          right: BorderSide(color: Theme.of(context).dividerColor),
                          bottom: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          room,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Session grid
                Expanded(
                  child: SingleChildScrollView(
                    controller: _contentScrollController,
                    child: SizedBox(
                      height: hourSlots.length * hourHeight,
                      child: Stack(
                        children: [
                          // Background grid cells
                          Column(
                            children: hourSlots.map((hour) {
                              return Row(
                                children: AgendaService.roomOrder.map((room) {
                                  return _buildEmptyHourCell(
                                    width: roomCellWidth,
                                    height: hourHeight,
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                          // Sessions positioned absolutely
                          ...sessions.map((session) {
                            return _buildAbsoluteSessionCard(
                              session: session,
                              hourSlots: hourSlots,
                              hourHeight: hourHeight,
                              roomCellWidth: roomCellWidth,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<int> _getHourSlots(List<Session> sessions) {
    final Set<int> hours = {};
    for (var session in sessions) {
      final startTime = session.startDateTime;
      if (startTime != null) {
        hours.add(startTime.hour);
      }
    }
    final list = hours.toList()..sort();
    return list;
  }


  Widget _buildEmptyHourCell({
    required double width,
    required double height,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildAbsoluteSessionCard({
    required Session session,
    required List<int> hourSlots,
    required double hourHeight,
    required double roomCellWidth,
  }) {
    final startTime = session.startDateTime;
    final endTime = session.endDateTime;

    if (startTime == null || endTime == null) {
      return const SizedBox.shrink();
    }

    // Find the room index
    final roomIndex = AgendaService.roomOrder.indexOf(session.room);
    if (roomIndex == -1) return const SizedBox.shrink();

    // Calculate absolute top position
    final firstHour = hourSlots.first;
    final sessionStartHour = startTime.hour;
    final sessionStartMinute = startTime.minute;

    // Hours from the first hour slot
    final hourOffset = sessionStartHour - firstHour;
    // Position within the starting hour
    final minuteOffset = sessionStartMinute / 60.0;

    final topPosition = (hourOffset + minuteOffset) * hourHeight;

    // Calculate height based on duration
    final durationMinutes = endTime.difference(startTime).inMinutes;
    final cardHeight = (durationMinutes / 60.0) * hourHeight;

    // Calculate left position based on room
    final leftPosition = roomIndex * roomCellWidth;

    return Positioned(
      top: topPosition,
      left: leftPosition,
      width: roomCellWidth,
      height: cardHeight,
      child: _buildSessionCard(session, durationMinutes),
    );
  }

  Widget _buildSessionCard(Session session, int durationMinutes) {
    final theme = Theme.of(context);
    final levelColor = session.getLevelColor();
    final isStarred = session.isStarred;


    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailScreen(
              session: session,
              agendaService: widget.agendaService,
            ),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: levelColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: levelColor,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with star and duration
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$durationMinutes min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isStarred ? Icons.star : Icons.star_border,
                  size: 16,
                  color: isStarred ? Colors.amber : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Title
            Expanded(
              child: Text(
                session.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Speaker (only show for sessions longer than 25 minutes)
            // if (durationMinutes > 25 && session.speakers.isNotEmpty) ...[
            //   const SizedBox(height: 4),
            //   Text(
            //     session.speakers.map((s) => s.name).join(', '),
            //     style: theme.textTheme.bodySmall?.copyWith(
            //       color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}

