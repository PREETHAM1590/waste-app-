import 'package:flutter/material.dart';

/// Material 3 Motion System
/// Based on Material Design 3 motion specifications
/// https://m3.material.io/styles/motion/overview
class Material3Motion {
  Material3Motion._();

  // ============================================================================
  // MATERIAL 3 MOTION DURATIONS
  // ============================================================================
  
  /// Duration for quick, simple transitions (e.g., icon state changes)
  static const Duration durationShort1 = Duration(milliseconds: 50);
  static const Duration durationShort2 = Duration(milliseconds: 100);
  static const Duration durationShort3 = Duration(milliseconds: 150);
  static const Duration durationShort4 = Duration(milliseconds: 200);
  
  /// Duration for standard transitions (e.g., button press, card expand)
  static const Duration durationMedium1 = Duration(milliseconds: 250);
  static const Duration durationMedium2 = Duration(milliseconds: 300);
  static const Duration durationMedium3 = Duration(milliseconds: 350);
  static const Duration durationMedium4 = Duration(milliseconds: 400);
  
  /// Duration for longer, more complex transitions
  static const Duration durationLong1 = Duration(milliseconds: 450);
  static const Duration durationLong2 = Duration(milliseconds: 500);
  static const Duration durationLong3 = Duration(milliseconds: 550);
  static const Duration durationLong4 = Duration(milliseconds: 600);
  
  /// Duration for very long transitions (e.g., screen transitions)
  static const Duration durationExtraLong1 = Duration(milliseconds: 700);
  static const Duration durationExtraLong2 = Duration(milliseconds: 800);
  static const Duration durationExtraLong3 = Duration(milliseconds: 900);
  static const Duration durationExtraLong4 = Duration(milliseconds: 1000);

  // ============================================================================
  // MATERIAL 3 EASING CURVES
  // ============================================================================
  
  /// Standard easing - Most common, balanced entrance and exit
  /// Use for: Simple animations, fades, color changes
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  
  /// Emphasized easing - More expressive, for important transitions
  /// Use for: Hero animations, large surface movements
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  
  /// Standard easing curves
  static const Curve standard = Curves.easeInOut;
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  
  /// Legacy easing (for backward compatibility)
  static const Curve legacy = Curves.fastOutSlowIn;
  static const Curve legacyAccelerate = Curves.easeIn;
  static const Curve legacyDecelerate = Curves.easeOut;

  // ============================================================================
  // MATERIAL 3 TRANSITION PATTERNS
  // ============================================================================
  
  /// Container transform - For transitions between UI elements
  static Duration get containerTransformDuration => durationMedium2;
  static Curve get containerTransformCurve => emphasized;
  
  /// Shared axis - For transitions between pages with spatial relationship
  static Duration get sharedAxisDuration => durationMedium4;
  static Curve get sharedAxisCurve => emphasized;
  
  /// Fade through - For transitions with no spatial relationship
  static Duration get fadeThroughDuration => durationMedium1;
  static Curve get fadeThroughCurve => standard;
  
  /// Fade - Simple opacity transition
  static Duration get fadeDuration => durationShort4;
  static Curve get fadeCurve => standard;

  // ============================================================================
  // PAGE TRANSITIONS
  // ============================================================================
  
  /// Material 3 page transition (fade through pattern)
  static PageTransitionsBuilder get pageTransitionBuilder {
    return const ZoomPageTransitionsBuilder();
  }
  
  /// Custom Material 3 page route with shared axis transition
  static PageRoute<T> sharedAxisPageRoute<T>({
    required Widget page,
    required SharedAxisTransitionType transitionType,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: sharedAxisDuration,
      reverseTransitionDuration: sharedAxisDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }
  
  /// Fade through page route
  static PageRoute<T> fadeThroughPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: fadeThroughDuration,
      reverseTransitionDuration: fadeThroughDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

/// Shared axis transition type
enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Shared axis transition widget
class SharedAxisTransition extends StatelessWidget {
  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Material3Motion.emphasized,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Material3Motion.emphasized,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Material3Motion.emphasized,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// Fade through transition widget
class FadeThroughTransition extends StatelessWidget {
  const FadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }
}

/// Material 3 animated icon button with state transitions
class Material3IconButton extends StatefulWidget {
  const Material3IconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.selectedIcon,
    this.selected = false,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback? onPressed;
  final bool selected;
  final String? tooltip;
  final Color? color;

  @override
  State<Material3IconButton> createState() => _Material3IconButtonState();
}

class _Material3IconButtonState extends State<Material3IconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Material3Motion.durationShort3,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Material3Motion.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIcon = widget.selected && widget.selectedIcon != null
        ? widget.selectedIcon!
        : widget.icon;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            icon: Icon(effectiveIcon),
            onPressed: widget.onPressed,
            color: widget.color ?? colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Material 3 animated container with smooth transitions
class Material3AnimatedContainer extends StatelessWidget {
  const Material3AnimatedContainer({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.duration,
    this.curve,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Decoration? decoration;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? Material3Motion.durationMedium2,
      curve: curve ?? Material3Motion.emphasized,
      color: color,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      decoration: decoration,
      child: child,
    );
  }
}

/// Extension for adding Material 3 motion to widgets
extension Material3MotionExtension on Widget {
  /// Wrap widget with fade transition
  Widget withFadeTransition({
    required Animation<double> animation,
    Curve? curve,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve ?? Material3Motion.fadeCurve,
      ),
      child: this,
    );
  }

  /// Wrap widget with slide transition
  Widget withSlideTransition({
    required Animation<double> animation,
    Offset begin = const Offset(0, 0.3),
    Curve? curve,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve ?? Material3Motion.emphasized,
      )),
      child: this,
    );
  }

  /// Wrap widget with scale transition
  Widget withScaleTransition({
    required Animation<double> animation,
    double begin = 0.8,
    Curve? curve,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve ?? Material3Motion.emphasized,
      )),
      child: this,
    );
  }
}
