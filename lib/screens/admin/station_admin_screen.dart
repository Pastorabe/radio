import 'package:flutter/material.dart';
import '../../models/station.dart';
import '../../services/station_service.dart';
import 'package:provider/provider.dart';

class StationAdminScreen extends StatefulWidget {
  const StationAdminScreen({Key? key}) : super(key: key);

  @override
  State<StationAdminScreen> createState() => _StationAdminScreenState();
}

class _StationAdminScreenState extends State<StationAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streamUrlController = TextEditingController();
  final _logoController = TextEditingController();
  final _slide1Controller = TextEditingController();
  final _slide2Controller = TextEditingController();
  final _slide3Controller = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  String _generateStationId(String name) {
    return name.toLowerCase().replaceAll(' ', '-');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streamUrlController.dispose();
    _logoController.dispose();
    _slide1Controller.dispose();
    _slide2Controller.dispose();
    _slide3Controller.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _streamUrlController.clear();
    _logoController.clear();
    _slide1Controller.clear();
    _slide2Controller.clear();
    _slide3Controller.clear();
    _descriptionController.clear();
    _categoryController.clear();
  }

  Future<void> _addStation() async {
    if (_formKey.currentState?.validate() ?? false) {
      final station = RadioStation(
        id: _generateStationId(_nameController.text),
        name: _nameController.text,
        streamUrl: _streamUrlController.text,
        logo: _logoController.text,
        slide1: _slide1Controller.text,
        slide2: _slide2Controller.text,
        slide3: _slide3Controller.text,
        description: _descriptionController.text,
        category: _categoryController.text,
      );

      try {
        await context.read<StationService>().addStation(station);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Station ajoutée avec succès')),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les stations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la station',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streamUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL du flux',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer une URL';
                  }
                  if (!Uri.parse(value!).isAbsolute) {
                    return 'Veuillez entrer une URL valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(
                  labelText: 'URL du logo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    if (!Uri.parse(value!).isAbsolute) {
                      return 'Veuillez entrer une URL valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slide1Controller,
                decoration: const InputDecoration(
                  labelText: 'URL Slide 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slide2Controller,
                decoration: const InputDecoration(
                  labelText: 'URL Slide 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slide3Controller,
                decoration: const InputDecoration(
                  labelText: 'URL Slide 3',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addStation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ajouter la station'),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<RadioStation>>(
                stream: context.read<StationService>().getAllStations(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stations = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Stations existantes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...stations.map((station) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(station.name),
                              subtitle: Text(station.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<StationService>()
                                        .deleteStation(station.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Station supprimée avec succès'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erreur: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
