import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/agenda_service.dart';

class LevelFilterDialog extends StatefulWidget {
  final AgendaService agendaService;

  const LevelFilterDialog({super.key, required this.agendaService});

  @override
  State<LevelFilterDialog> createState() => _LevelFilterDialogState();
}

class _LevelFilterDialogState extends State<LevelFilterDialog> {
  late Set<String> _tempSelectedLevels;

  @override
  void initState() {
    super.initState();
    _tempSelectedLevels = Set.from(widget.agendaService.selectedLevels);
  }

  Color _getLevelColor(String level) {
    // Create a temporary session to get the color
    final session = Session(
      title: '',
      room: '',
      day: '',
      startTime: '',
      endTime: '',
      language: '',
      level: level,
      abstract: '',
      speakers: [],
    );
    return session.getLevelColor();
  }

  @override
  Widget build(BuildContext context) {
    final allLevels = widget.agendaService.getAllLevels();

    return AlertDialog(
      title: const Text('Filter by Level'),
      content: SizedBox(
        width: double.maxFinite,
        child: allLevels.isEmpty
            ? const Center(child: Text('No levels available'))
            : ListView(
                shrinkWrap: true,
                children: allLevels.map((level) {
                  final isSelected = _tempSelectedLevels.contains(level);
                  final levelColor = _getLevelColor(level);

                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: levelColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(level)),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _tempSelectedLevels.add(level);
                        } else {
                          _tempSelectedLevels.remove(level);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await widget.agendaService.clearLevelFilters();
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            // Apply the selections
            await widget.agendaService.clearLevelFilters();
            for (var level in _tempSelectedLevels) {
              await widget.agendaService.toggleLevelFilter(level);
            }
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(_tempSelectedLevels.isEmpty ? 'Show All' : 'Apply'),
        ),
      ],
    );
  }
}

