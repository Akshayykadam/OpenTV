/// Player Screen
/// Fullscreen video player with advanced gesture controls and UX features
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:floating/floating.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/channel.dart';
import '../../data/repositories/favorites_repository.dart';

/// Player screen - fullscreen video playback with advanced controls
class PlayerScreen extends ConsumerStatefulWidget {
  final Channel channel;
  final List<Channel>? channelList; // Optional list for channel switching
  final int? currentIndex; // Current index in the list

  const PlayerScreen({
    super.key, 
    required this.channel,
    this.channelList,
    this.currentIndex,
  });

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
  bool _isFitToScreen = true;
  double _baseScale = 1.0;
  double _currentScale = 1.0;
  
  // Brightness/Volume gesture state
  double _brightness = 0.5;
  double _startBrightness = 0.5;
  double _startVolume = 1.0;
  bool _isDraggingBrightness = false;
  bool _isDraggingVolume = false;
  Offset? _dragStartPoint;
  bool _isPinching = false;
  double _horizontalDragDelta = 0;
  
  // Channel switching state
  late Channel _currentChannel;
  late int _currentIndex;
  bool _isSwitchingChannel = false;
  
  // Auto-retry state
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;
  int _retryCountdown = 5;
  bool _isAutoRetrying = false;
  
  // PiP state
  final Floating _floating = Floating();
  bool _isPipAvailable = false;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _currentIndex = widget.currentIndex ?? 0;
    
    _initializePlayer();
    _startTime = DateTime.now();
    
    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Keep screen on while watching
    WakelockPlus.enable();

    _initVolume();
    _initBrightness();
    _checkPipAvailability();
  }

  Future<void> _checkPipAvailability() async {
    try {
      final available = await _floating.isPipAvailable;
      if (mounted) {
        setState(() => _isPipAvailable = available);
      }
    } catch (e) {
      debugPrint('PiP not available: $e');
    }
  }

  Future<void> _initBrightness() async {
    try {
      final brightness = await ScreenBrightness().system;
      if (mounted) {
        setState(() => _brightness = brightness);
      }
    } catch (e) {
      debugPrint('Error getting brightness: $e');
    }
  }

  Future<void> _initVolume() async {
    try {
      final initVol = await FlutterVolumeController.getVolume();
      if (mounted && initVol != null) {
        setState(() => _volume = initVol);
      }
      
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
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(_currentChannel.streamUrl),
        httpHeaders: {
          if (_currentChannel.referrer != null) 
            'Referer': _currentChannel.referrer!,
          if (_currentChannel.userAgent != null) 
            'User-Agent': _currentChannel.userAgent!,
        },
      );

      await _controller!.initialize();
      await _controller!.play();
      
      // Reset retry count on successful connection
      _retryCount = 0;
      _isAutoRetrying = false;
      _retryTimer?.cancel();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
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
        _startAutoRetry();
      }
    }
  }

  void _startAutoRetry() {
    if (_retryCount >= _maxRetries) {
      setState(() => _isAutoRetrying = false);
      return;
    }
    
    setState(() {
      _isAutoRetrying = true;
      _retryCountdown = 5;
    });
    
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _retryCountdown--;
      });
      
      if (_retryCountdown <= 0) {
        timer.cancel();
        _retryCount++;
        setState(() {
          _hasError = false;
          _isInitialized = false;
          _isAutoRetrying = false;
        });
        _initializePlayer();
      }
    });
  }

  void _cancelAutoRetry() {
    _retryTimer?.cancel();
    setState(() {
      _isAutoRetrying = false;
      _retryCount = _maxRetries; // Prevent further auto-retries
    });
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
    HapticFeedback.selectionClick();
    setState(() {
      _volume = value.clamp(0.0, 1.0);
    });
    FlutterVolumeController.setVolume(_volume);
    _startHideTimer();
  }

  Future<void> _setBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    setState(() => _brightness = clamped);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(clamped);
    } catch (e) {
      debugPrint('Error setting brightness: $e');
    }
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
    HapticFeedback.mediumImpact();
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    setState(() {});
  }

  void _switchChannel(int direction) {
    if (widget.channelList == null || widget.channelList!.isEmpty) return;
    
    final newIndex = _currentIndex + direction;
    if (newIndex < 0 || newIndex >= widget.channelList!.length) return;
    
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isSwitchingChannel = true;
      _currentIndex = newIndex;
      _currentChannel = widget.channelList![newIndex];
      _isInitialized = false;
      _hasError = false;
      _retryCount = 0;
    });
    
    _initializePlayer().then((_) {
      if (mounted) {
        setState(() => _isSwitchingChannel = false);
      }
    });
  }

  Future<void> _enablePip() async {
    HapticFeedback.mediumImpact();
    try {
      final status = await _floating.enable(ImmediatePiP(
        aspectRatio: const Rational.landscape(),
      ));
      debugPrint('PiP enabled: $status');
    } catch (e) {
      debugPrint('Error enabling PiP: $e');
    }
  }

  // Unified gesture handling using onScale (handles both pinch and drag)
  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
    _dragStartPoint = details.focalPoint;
    _startBrightness = _brightness;
    _startVolume = _volume;
    _isPinching = details.pointerCount >= 2;
    _horizontalDragDelta = 0;
    
    // Determine if brightness or volume based on start position
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.focalPoint.dx < screenWidth / 2) {
      _isDraggingBrightness = true;
      _isDraggingVolume = false;
    } else {
      _isDraggingVolume = true;
      _isDraggingBrightness = false;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_dragStartPoint == null) return;
    
    // Handle pinch zoom
    if (_isPinching || details.scale != 1.0) {
      _isPinching = true;
      _currentScale = _baseScale * details.scale;
      return;
    }
    
    // Calculate drag deltas
    final deltaY = _dragStartPoint!.dy - details.focalPoint.dy;
    final deltaX = details.focalPoint.dx - _dragStartPoint!.dx;
    _horizontalDragDelta = deltaX;
    
    // Determine if this is more horizontal or vertical
    if (deltaY.abs() > deltaX.abs() && deltaY.abs() > 10) {
      // Vertical drag - brightness/volume
      final screenHeight = MediaQuery.of(context).size.height;
      final verticalDelta = deltaY / (screenHeight * 0.5);
      
      if (_isDraggingBrightness) {
        _setBrightness(_startBrightness + verticalDelta);
      } else if (_isDraggingVolume) {
        _setVolume(_startVolume + verticalDelta);
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Handle pinch zoom completion
    if (_isPinching) {
      if (_currentScale > _baseScale * 1.2) {
        if (_isFitToScreen) {
          HapticFeedback.lightImpact();
          setState(() => _isFitToScreen = false);
        }
      } else if (_currentScale < _baseScale * 0.8) {
        if (!_isFitToScreen) {
          HapticFeedback.lightImpact();
          setState(() => _isFitToScreen = true);
        }
      }
    }
    
    // Handle horizontal swipe for channel switching
    if (!_isPinching && widget.channelList != null) {
      final velocity = details.velocity.pixelsPerSecond.dx;
      if (_horizontalDragDelta.abs() > 100 || velocity.abs() > 500) {
        if (_horizontalDragDelta > 0 || velocity > 500) {
          // Swipe right - previous channel
          _switchChannel(-1);
        } else if (_horizontalDragDelta < 0 || velocity < -500) {
          // Swipe left - next channel
          _switchChannel(1);
        }
      }
    }
    
    // Reset state
    _currentScale = 1.0;
    _baseScale = 1.0;
    _isDraggingBrightness = false;
    _isDraggingVolume = false;
    _dragStartPoint = null;
    _isPinching = false;
    _horizontalDragDelta = 0;
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    _controller?.pause();
    _hideTimer?.cancel();
    _retryTimer?.cancel();
    
    // Reset brightness
    ScreenBrightness().resetApplicationScreenBrightness();
    
    // Disable wakelock when leaving
    WakelockPlus.disable();
    
    // Record watch duration
    if (_startTime != null) {
      final duration = DateTime.now().difference(_startTime!);
      ref.read(favoritesRepositoryProvider).addWatchHistory(
        _currentChannel.id, 
        duration,
      );
      ref.read(favoritesRepositoryProvider).setLastChannel(_currentChannel.id);
    }
    
    _controller?.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    super.dispose();
  }

  bool _canPop = false;

  Future<void> _onExit() async {
    await _controller?.pause();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future.delayed(const Duration(milliseconds: 100));
    
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
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player
              if (_isInitialized && _controller != null)
                Center(
                  child: _isFitToScreen
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                      : SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),
                ),
              
              // Loading state
              if (!_isInitialized && !_hasError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _isSwitchingChannel 
                            ? 'Switching to ${_currentChannel.name}...'
                            : 'Loading stream...',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              
              // Error state with auto-retry
              if (_hasError)
                _buildErrorOverlay(),
              
              // Brightness indicator (left side)
              if (_isDraggingBrightness)
                _buildVerticalIndicator(
                  icon: Icons.brightness_6_rounded,
                  value: _brightness,
                  isLeft: true,
                ),
              
              // Volume indicator (right side)
              if (_isDraggingVolume)
                _buildVerticalIndicator(
                  icon: _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  value: _volume,
                  isLeft: false,
                ),
              
              // Channel switch indicator
              if (_isSwitchingChannel)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _currentChannel.name,
                          style: AppTypography.titleMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Controls overlay
              if (_showControls && _isInitialized)
                _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalIndicator({
    required IconData icon,
    required double value,
    required bool isLeft,
  }) {
    return Positioned(
      left: isLeft ? 40 : null,
      right: isLeft ? null : 40,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 50,
          height: 180,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${(value * 100).round()}%',
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
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
              
              // Auto-retry countdown
              if (_isAutoRetrying) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Retrying in $_retryCountdown seconds...',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Attempt ${_retryCount + 1} of $_maxRetries',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _cancelAutoRetry,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
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
                        HapticFeedback.mediumImpact();
                        _retryCount = 0;
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
            // Top Bar
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentChannel.name,
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
                          if (widget.channelList != null)
                            Text(
                              '${_currentIndex + 1} of ${widget.channelList!.length}',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                        ],
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
                              HapticFeedback.selectionClick();
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
                    // PiP button (if available)
                    if (_isPipAvailable)
                      _buildCircleButton(
                        icon: Icons.picture_in_picture_alt_rounded,
                        onPressed: _enablePip,
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildFavoriteButton(),
                  ],
                ),
              ),
            ),

            // Center play/pause button
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous channel button
                  if (widget.channelList != null && _currentIndex > 0)
                    _buildCircleButton(
                      icon: Icons.skip_previous_rounded,
                      onPressed: () => _switchChannel(-1),
                      size: 56,
                      iconSize: 32,
                    ),
                  const SizedBox(width: AppSpacing.xl),
                  _buildCircleButton(
                    icon: _controller?.value.isPlaying ?? false
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onPressed: _togglePlayPause,
                    size: 72,
                    iconSize: 48,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  // Next channel button
                  if (widget.channelList != null && 
                      _currentIndex < widget.channelList!.length - 1)
                    _buildCircleButton(
                      icon: Icons.skip_next_rounded,
                      onPressed: () => _switchChannel(1),
                      size: 56,
                      iconSize: 32,
                    ),
                ],
              ),
            ),
            
            // Bottom controls
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
                      
                      // Gesture hint
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Swipe ↕ for brightness/volume',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Quality indicator
                      if (_currentChannel.quality != StreamQuality.unknown)
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
                            _getQualityLabel(_currentChannel.quality),
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
    final isFavorite = ref.watch(favoriteIdsProvider).contains(_currentChannel.id);
    
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
          HapticFeedback.mediumImpact();
          ref.read(favoriteIdsProvider.notifier).toggle(_currentChannel.id);
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
