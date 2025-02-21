import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/program_service.dart';
import '../models/program.dart';
import 'package:intl/intl.dart';

class ProgramGrid extends StatelessWidget {
  const ProgramGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return StreamBuilder<List<RadioProgram>>(
      stream: programService.getTodayPrograms(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final programs = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: programs.length,
          itemBuilder: (context, index) {
            final program = programs[index];
            final isNow = now.isAfter(program.startTime) &&
                now.isBefore(program.endTime);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  // TODO: Afficher les détails du programme
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heure
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isNow
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('HH:mm').format(program.startTime),
                              style: TextStyle(
                                fontWeight:
                                    isNow ? FontWeight.bold : FontWeight.normal,
                                color: isNow
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                            const Text('à'),
                            Text(
                              DateFormat('HH:mm').format(program.endTime),
                              style: TextStyle(
                                fontWeight:
                                    isNow ? FontWeight.bold : FontWeight.normal,
                                color: isNow
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    program.title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                  ),
                                ),
                                if (program.isPodcast)
                                  const Icon(
                                    Icons.podcasts,
                                    size: 16,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              program.host,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              program.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Indicateurs
                      if (isNow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'EN DIRECT',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
