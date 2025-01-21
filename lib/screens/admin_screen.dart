import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/station_list.dart';
import '../widgets/station_dialog.dart';
import '../services/station_service.dart';
import '../services/program_service.dart';
import '../services/admin_service.dart';
import '../services/audio_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer les services existants
    final stationService = Provider.of<StationService>(context, listen: false);
    final programService = Provider.of<ProgramService>(context, listen: false);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final audioService = Provider.of<AudioService>(context, listen: false);

    // Réutiliser les mêmes instances de services
    return MultiProvider(
      providers: [
        Provider<StationService>.value(value: stationService),
        Provider<ProgramService>.value(value: programService),
        Provider<AdminService>.value(value: adminService),
        Provider<AudioService>.value(value: audioService),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Administration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.radio),
                  text: 'Stations',
                ),
                Tab(
                  icon: Icon(Icons.schedule),
                  text: 'Programmes',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              StationList(),
              Center(child: Text('Programmes à venir')),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) {
              final tabController = DefaultTabController.of(context);
              return FloatingActionButton(
                onPressed: () {
                  if (tabController.index == 0) {
                    showDialog(
                      context: context,
                      builder: (context) => const StationDialog(),
                    );
                  } else {
                    // TODO: Ajouter le dialogue pour les programmes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('À venir : Ajout de programmes'),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add),
              );
            },
          ),
        ),
      ),
    );
  }
}
