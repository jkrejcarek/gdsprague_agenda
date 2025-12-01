import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';
import '../screens/session_detail_screen.dart';

class SessionCard extends StatefulWidget {
  final Session session;
  final AgendaService agendaService;
  final VoidCallback? onStarChanged;

  const SessionCard({
    super.key,
    required this.session,
    required this.agendaService,
    this.onStarChanged,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  @override
  Widget build(BuildContext context) {
    final isNow = widget.session.isHappeningNow();
    final levelColor = widget.session.getLevelColor();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isNow ? 4 : 1,
      color: isNow
          ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50)
          : null,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailScreen(
                session: widget.session,
                agendaService: widget.agendaService,
              ),
            ),
          );
          if (widget.onStarChanged != null) {
            widget.onStarChanged!();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.session.isStarred ? Icons.star : Icons.star_border,
                      color: widget.session.isStarred ? Colors.amber : null,
                    ),
                    onPressed: () async {
                      await widget.agendaService.toggleStar(widget.session);
                      setState(() {});
                      if (widget.onStarChanged != null) {
                        widget.onStarChanged!();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    widget.session.getDayOfWeek().isNotEmpty
                        ? '${widget.session.getDayOfWeek()} ${widget.session.startTime} - ${widget.session.endTime}'
                        : '${widget.session.startTime} - ${widget.session.endTime}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.room, size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.session.room,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.session.level.isNotEmpty) ...[
                    Chip(
                      label: Text(
                        widget.session.level,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: levelColor,
                      padding: const EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.session.language.isNotEmpty)
                    Chip(
                      label: Text(
                        widget.session.language,
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: const EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              if (widget.session.speakers.isNotEmpty &&
                  widget.session.speakers.first.name.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.session.speakers
                            .map((s) => s.name)
                            .where((name) => name.isNotEmpty)
                            .join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (isNow) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HAPPENING NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

