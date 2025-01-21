import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/podcast.dart';
import '../../services/podcast_service.dart';
import '../../services/auth_service.dart';

class PodcastAdminScreen extends StatelessWidget {
  const PodcastAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final podcastService = Provider.of<PodcastService>(context);
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Accès non autorisé'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Podcasts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPodcastForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Podcast>>(
        stream: podcastService.getPodcasts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final podcasts = snapshot.data!;

          return ListView.builder(
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              final podcast = podcasts[index];
              return Dismissible(
                key: Key(podcast.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  podcastService.deletePodcast(podcast.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${podcast.title} supprimé')),
                  );
                },
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      podcast.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(podcast.title),
                  subtitle: Text(podcast.category),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showPodcastForm(context, podcast),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPodcastForm(BuildContext context, [Podcast? podcast]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PodcastForm(podcast: podcast),
    );
  }
}

class PodcastForm extends StatefulWidget {
  final Podcast? podcast;

  const PodcastForm({Key? key, this.podcast}) : super(key: key);

  @override
  State<PodcastForm> createState() => _PodcastFormState();
}

class _PodcastFormState extends State<PodcastForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _audioUrlController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  late DateTime _publishedAt;
  late int _duration;

  @override
  void initState() {
    super.initState();
    final podcast = widget.podcast;
    _titleController = TextEditingController(text: podcast?.title ?? '');
    _descriptionController = TextEditingController(text: podcast?.description ?? '');
    _audioUrlController = TextEditingController(text: podcast?.audioUrl ?? '');
    _imageUrlController = TextEditingController(text: podcast?.imageUrl ?? '');
    _categoryController = TextEditingController(text: podcast?.category ?? '');
    _publishedAt = podcast?.publishedAt ?? DateTime.now();
    _duration = podcast?.duration ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioUrlController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              widget.podcast == null ? 'Nouveau Podcast' : 'Modifier le Podcast',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _audioUrlController,
              decoration: const InputDecoration(labelText: 'URL Audio'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL Image'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              initialValue: _duration.toString(),
              decoration: const InputDecoration(labelText: 'Durée (en secondes)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Ce champ est requis';
                final duration = int.tryParse(value!);
                if (duration == null || duration <= 0) {
                  return 'Durée invalide';
                }
                return null;
              },
              onSaved: (value) => _duration = int.parse(value!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  final podcastService = context.read<PodcastService>();
                  final podcast = Podcast(
                    id: widget.podcast?.id ?? '',
                    title: _titleController.text,
                    description: _descriptionController.text,
                    audioUrl: _audioUrlController.text,
                    imageUrl: _imageUrlController.text,
                    category: _categoryController.text,
                    publishedAt: _publishedAt,
                    duration: _duration,
                  );

                  try {
                    if (widget.podcast == null) {
                      await podcastService.addPodcast(podcast);
                    } else {
                      await podcastService.updatePodcast(podcast.id, podcast);
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              child: Text(widget.podcast == null ? 'Ajouter' : 'Modifier'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
