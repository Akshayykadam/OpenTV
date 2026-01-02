/// Player Screen
/// Fullscreen video player with minimal, invisible controls
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/channel.dart';
import '../../data/repositories/favorites_repository.dart';

/// Player screen - fullscreen video playback
class PlayerScreen extends ConsumerStatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideTimer;
  DateTime? _startTime;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startTime = DateTime.now();
    
    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initVolume();
  }

  Future<void> _initVolume() async {
    try {
      // Get current system volume
      final initVol = await FlutterVolumeController.getVolume();
      if (mounted && initVol != null) {
        setState(() => _volume = initVol);
      }
      
      // Listen for system volume changes (buttons)
      FlutterVolumeController.addListener((volume) {
        if (mounted) {
          setState(() => _volume = volume);
        }
      });
    } catch (e) {
      debugPrint('Error initializing volume controller: $e');
    }
  }



  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
        httpHeaders: {
          if (widget.channel.referrer != null) 
            'Referer': widget.channel.referrer!,
          if (widget.channel.userAgent != null) 
            'User-Agent': widget.channel.userAgent!,
        },
      );

      await _controller!.initialize();
      // await _controller!.setVolume(_volume); // Use system volume instead
      await _controller!.play();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startHideTimer();
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _getHumanReadableError(e);
        });
      }
    }
  }

  String _getHumanReadableError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'This channel is not available in your region';
    }
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Channel stream not found';
    }
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Connection timed out. Please check your internet.';
    }
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    return 'Unable to play this channel. Please try again later.';
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
    });
    // Control system volume
    FlutterVolumeController.setVolume(value);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isInitialized) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideTimer();
      }
    });
  }

  void _togglePlayPause() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    setState(() {});
  }

  @override
  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    _controller?.pause();
    _hideTimer?.cancel();
    
    // Record watch duration
    if (_startTime != null) {
      final duration = DateTime.now().difference(_startTime!);
      ref.read(favoritesRepositoryProvider).addWatchHistory(
        widget.channel.id, 
        duration,
      );
      ref.read(favoritesRepositoryProvider).setLastChannel(widget.channel.id);
    }
    
    _controller?.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    super.dispose();
  }

  bool _canPop = false;

  Future<void> _onExit() async {
    // Stop playback immediately
    await _controller?.pause();
    
    // Reset orientation and UI mode before popping
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (mounted) {
      setState(() => _canPop = true);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onExit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player
              if (_isInitialized && _controller != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              
              // Loading state
              if (!_isInitialized && !_hasError)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Loading stream...',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              
              // Error state
              if (_hasError)
                _buildErrorOverlay(),
              
              // Controls overlay
              if (_showControls && _isInitialized)
                _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_off_rounded,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Stream Unavailable',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage ?? 'Unable to play this channel',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isInitialized = false;
                      });
                      _initializePlayer();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: AppMotion.fast,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Top Bar (Back button, Title, Favorite)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.channel.name,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 4,
                              color: Colors.black54,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Volume Control
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              _setVolume(_volume == 0 ? 1.0 : 0.0);
                            },
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          SizedBox(
                            width: 150,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                trackHeight: 2,
                              ),
                              child: Slider(
                                value: _volume,
                                onChanged: _setVolume,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildFavoriteButton(),
                  ],
                ),
              ),
            ),

            // Center play/pause button
            Center(
              child: _buildCircleButton(
                icon: _controller?.value.isPlaying ?? false
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onPressed: _togglePlayPause,
                size: 72,
                iconSize: 48,
              ),
            ),
            
            // Bottom controls (Live indicator, Quality)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Live indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'LIVE',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      
                      // Quality indicator
                      if (widget.channel.quality != StreamQuality.unknown)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: AppRadius.pillRadius,
                          ),
                          child: Text(
                            _getQualityLabel(widget.channel.quality),
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
    double? iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFavoriteButton() {
    final isFavorite = ref.watch(favoriteIdsProvider).contains(widget.channel.id);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.error : Colors.white,
        ),
        onPressed: () {
          ref.read(favoriteIdsProvider.notifier).toggle(widget.channel.id);
        },
      ),
    );
  }

  String _getQualityLabel(StreamQuality quality) {
    switch (quality) {
      case StreamQuality.uhd4k:
        return '4K';
      case StreamQuality.hd1080:
        return '1080p';
      case StreamQuality.hd720:
        return '720p';
      case StreamQuality.sd480:
        return '480p';
      case StreamQuality.low360:
        return '360p';
      case StreamQuality.unknown:
        return 'Auto';
    }
  }
}
