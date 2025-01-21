import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (!await launchUrl(phoneLaunchUri)) {
      throw Exception('Could not launch $phoneLaunchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'À propos',
          textAlign: TextAlign.left,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: 'Zava-kendreny:',
                    content:
                        '•	Fitoriana Filazantsara amin’ny alalan’ny Serasera',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Sokajin\'asa misy',
                    content:
                        '•	Radio Feon\'ny Filazantsara\n'
                        '•	Fandraisam-peo (Hira, Tantara, Toriteny, Fanentanana)\n'
                        '•	Famokarana Raki-kira sy Raki-tsary toriteny mandritra ny Isatonan\'ny Toby sy Zaikabe\n'
                        '•	Dubbing (Fandikana ireo rakitsary miteny vahiny ho amin\'ny fiteny Malagasy)\n'
                        '•	Fampiofanana sy Fampianarana\n'
                        '•	Fitenim-pirenena (Anglisy, Frantsay)\n'
                        '•	Famokarana Raki-kira sy Raki-tsary (CLIP)\n'
                        '•	Mitahiry ireo vakoka Hira sy Tantara sy sangan\'asan\'ny Kristiana',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Fifandraisana',
                    content: 'Raha misy ny fiaraha-miasa tianao hatao, dia aza misalasala manatona anay :',
                  ),
                  const SizedBox(height: 8),
                  _buildContactButton(
                    context,
                    icon: Icons.email,
                    text: 'yves.razafiharison@gmail.com',
                    onTap: () => _launchEmail('yves.razafiharison@gmail.com'),
                  ),
                  _buildContactButton(
                    context,
                    icon: Icons.phone,
                    text: '+261 34 02 666 64',
                    onTap: () => _launchPhone('+261 34 02 666 64'),
                  ),
                  _buildContactButton(
                    context,
                    icon: Icons.language,
                    text: 'www.flm-rff.org',
                    onTap: () => _launchUrl('https://www.flm-rff.org'),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Araho koa ny vaovao',
                    content: 'ao amin ireo tambanjotra serasera samihafa :',
                  ),
                  const SizedBox(height: 8),
                  _buildSocialButtons(context),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                ' ${DateTime.now().year} Radio RFF. Tous droits réservés.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, {
    required IconData icon,
    required String url,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => _launchUrl(url),
        tooltip: label,
      ),
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        _buildSocialButton(
          context,
          icon: Icons.facebook,
          url: 'https://facebook.com/FLF.antsirabe',
          label: 'Facebook',
        ),
        _buildSocialButton(
          context,
          icon: Icons.telegram,
          url: 'https://t.me/radiorff',
          label: 'Telegram',
        ),
        _buildSocialButton(
          context,
          icon: Icons.web,
          url: 'https://www.flm-rff.org',
          label: 'Site web',
        ),
      ],
    );
  }
}
