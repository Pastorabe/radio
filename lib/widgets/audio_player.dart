import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../widgets/about_dialog.dart';

class AudioPlayerWidget extends StatefulWidget {
  final RadioStation? station;

  const AudioPlayerWidget({
    Key? key,
    this.station,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 1.0;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.station?.streamUrl != oldWidget.station?.streamUrl) {
      _handleStationChange();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _player.playbackEventStream.listen((event) {
        setState(() {
          _isPlaying = _player.playing;
          _isLoading = false;
        });
      }, onError: (Object e, StackTrace st) {
        debugPrint('Error in playback stream: $e');
        setState(() {
          _isLoading = false;
        });
      });

      if (widget.station != null) {
        await _handleStationChange();
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStationChange() async {
    try {
      if (widget.station == null) return;
      
      setState(() {
        _isLoading = true;
      });
      
      debugPrint('Loading stream URL: ${widget.station!.streamUrl}');
      await _player.stop();
      await _player.setUrl(widget.station!.streamUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Error changing station: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Misy olana ny Radio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
      _player.setVolume(value);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: AppTheme.mainGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Play button et titre
              Expanded(
                child: Row(
                  children: [
                    // Bouton play avec animation de chargement
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isLoading)
                            RotationTransition(
                              turns: _loadingController,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.station != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nom de la station
                            Text(
                              widget.station!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Description avec défilement
                            const SizedBox(height: 4),
                            if (widget.station?.description != null)
                              SizedBox(
                                height: 20,
                                child: MarqueeWidget(
                                  child: Text(
                                    widget.station!.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Contrôles
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            width: 60,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Volume',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: StatefulBuilder(
                                      builder: (context, setState) => SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: AppTheme.primaryColor,
                                          inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
                                          thumbColor: AppTheme.primaryColor,
                                          overlayColor: AppTheme.primaryColor.withOpacity(0.1),
                                          trackHeight: 4,
                                        ),
                                        child: Slider(
                                          value: _volume,
                                          onChanged: (value) {
                                            setState(() {
                                              _updateVolume(value);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AppAboutDialog(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour le défilement du texte
class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double gap;

  const MarqueeWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 20),
    this.gap = 32.0,
  }) : super(key: key);

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent > 0) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    _animationController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _animationController.value * maxScroll;
      _scrollController.jumpTo(currentScroll);
    });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          widget.child,
          SizedBox(width: widget.gap),
          widget.child,
        ],
      ),
    );
  }
}
