import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'podcast_screen.dart';
import 'radio_screen.dart';
import '../widgets/unified_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pages = [
    const RadioScreen(),
    const PodcastScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/foibe.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'FOIBE LOTERANA\nMOMBA NY FIFANDRAISANA',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            height: 1.2,
          ),
        ),
        centerTitle: false,
        toolbarHeight: 70,
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: UnifiedPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'Radio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts),
            label: 'Podcasts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'À propos',
          ),
        ],
      ),
    );
  }
}
