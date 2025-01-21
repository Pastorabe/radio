import 'package:flutter/material.dart';

class AnimatedPlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const AnimatedPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  State<AnimatedPlayPauseButton> createState() => _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * 2 * 3.14159,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isPlaying ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(widget.isPlaying),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedVolumeControl extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const AnimatedVolumeControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AnimatedVolumeControl> createState() => _AnimatedVolumeControlState();
}

class _AnimatedVolumeControlState extends State<AnimatedVolumeControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) {
        if (!_isDragging) {
          _controller.reverse();
        }
      },
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.value == 0 ? Icons.volume_off : Icons.volume_up,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (widget.value > 0) {
                widget.onChanged(0);
              } else {
                widget.onChanged(1);
              }
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4 + (_controller.value * 2),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6 + (_controller.value * 4),
                      pressedElevation: 8,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 12 + (_controller.value * 8),
                    ),
                  ),
                  child: Slider(
                    value: widget.value,
                    onChanged: widget.onChanged,
                    onChangeStart: (_) => setState(() => _isDragging = true),
                    onChangeEnd: (_) {
                      setState(() => _isDragging = false);
                      if (!_isDragging) {
                        _controller.reverse();
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
