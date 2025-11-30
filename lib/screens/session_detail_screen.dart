import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';

class SessionDetailScreen extends StatefulWidget {
  final Session session;
  final AgendaService agendaService;

  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.agendaService,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          IconButton(
            icon: Icon(
              widget.session.isStarred ? Icons.star : Icons.star_border,
              color: widget.session.isStarred ? Colors.amber : null,
            ),
            onPressed: () async {
              await widget.agendaService.toggleStar(widget.session);
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoChip(Icons.access_time,
                '${widget.session.startTime} - ${widget.session.endTime}'),
            const SizedBox(height: 8),
            _buildInfoChip(Icons.room, widget.session.room),
            const SizedBox(height: 8),
            _buildInfoChip(Icons.language, widget.session.language),
            const SizedBox(height: 8),
            _buildInfoChip(Icons.label, widget.session.level),
            const SizedBox(height: 24),
            if (widget.session.abstract.isNotEmpty) ...[
              Text(
                'Abstract',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.session.abstract,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],
            if (widget.session.speakers.isNotEmpty) ...[
              Text(
                'Speakers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...widget.session.speakers.map((speaker) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speaker.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (speaker.bio.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            speaker.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

