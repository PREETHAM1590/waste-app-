import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Micro-interactions for enhanced user experience
class MicroInteractions {
  /// Button press animation with haptic feedback
  static Widget pressableButton({
    required Widget child,
    required VoidCallback? onPressed,
    Duration animationDuration = const Duration(milliseconds: 150),
    double pressedScale = 0.95,
    bool enableHaptics = true,
    HapticFeedbackType hapticType = HapticFeedbackType.light,
  }) {
    return _PressableButton(
      onPressed: onPressed,
      animationDuration: animationDuration,
      pressedScale: pressedScale,
      enableHaptics: enableHaptics,
      hapticType: hapticType,
      child: child,
    );
  }

  /// Shimmer loading animation
  static Widget shimmer({
    required Widget child,
    bool enabled = true,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerAnimation(
      enabled: enabled,
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      child: child,
    );
  }

  /// Bounce animation
  static Widget bounce({
    required Widget child,
    required AnimationController controller,
    double bounceFactor = 0.1,
    Curve curve = Curves.elasticOut,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scaleValue = 1.0 + (bounceFactor * curve.transform(controller.value));
        return Transform.scale(
          scale: scaleValue,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Parallax scroll effect
  static Widget parallax({
    required Widget child,
    required double scrollOffset,
    double parallaxFactor = 0.5,
    Axis direction = Axis.vertical,
  }) {
    final offset = direction == Axis.vertical
        ? Offset(0, scrollOffset * parallaxFactor)
        : Offset(scrollOffset * parallaxFactor, 0);
    
    return Transform.translate(
      offset: offset,
      child: child,
    );
  }

  /// Staggered reveal animation
  static Widget staggeredReveal({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Axis direction = Axis.vertical,
    double slideDistance = 20.0,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        final delay = staggerDelay.inMilliseconds * index;
        final startTime = delay / controller.duration!.inMilliseconds;
        final endTime = (delay + 300) / controller.duration!.inMilliseconds;
        
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final progress = Interval(
              startTime.clamp(0.0, 1.0),
              endTime.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ).transform(controller.value);
            
            final slideOffset = direction == Axis.vertical
                ? Offset(0, slideDistance * (1 - progress))
                : Offset(slideDistance * (1 - progress), 0);
            
            return Transform.translate(
              offset: slideOffset,
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  /// Floating action button with reveal animation
  static Widget revealFAB({
    required Widget child,
    required AnimationController controller,
    Alignment alignment = Alignment.bottomRight,
    double initialScale = 0.0,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: initialScale,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: child,
        );
      },
      child: child,
    );
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.child,
    required this.onPressed,
    required this.animationDuration,
    required this.pressedScale,
    required this.enableHaptics,
    required this.hapticType,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Duration animationDuration;
  final double pressedScale;
  final bool enableHaptics;
  final HapticFeedbackType hapticType;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  void _onTap() {
    if (widget.onPressed != null) {
      if (widget.enableHaptics) {
        _triggerHapticFeedback(widget.hapticType);
      }
      widget.onPressed!();
    }
  }

  void _triggerHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation({
    required this.child,
    required this.enabled,
    required this.baseColor,
    required this.highlightColor,
    required this.period,
  });

  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_ShimmerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _controller.repeat();
    } else if (!widget.enabled && oldWidget.enabled) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceContainerHighest;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Animated counter widget with smooth transitions
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix$animatedValue$suffix',
          style: style,
        );
      },
    );
  }
}

/// Loading dots animation
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.color,
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.duration,
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _animations.asMap().entries.map((entry) {
        final animation = entry.value;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: animation.value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
