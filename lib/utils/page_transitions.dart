import 'package:flutter/material.dart';

/// Custom page transition animations for smooth navigation
class PageTransitions {
  /// Slide transition from right to left
  static PageRouteBuilder<T> slideFromRight<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curve)),
        );
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Slide transition from bottom to top
  static PageRouteBuilder<T> slideFromBottom<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curve)),
        );
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition
  static PageRouteBuilder<T> fadeTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  /// Scale transition with fade
  static PageRouteBuilder<T> scaleTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double initialScale = 0.8,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = animation.drive(
          Tween(begin: initialScale, end: 1.0).chain(
            CurveTween(curve: curve),
          ),
        );
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Rotation transition
  static PageRouteBuilder<T> rotationTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (Material Design)
  static PageRouteBuilder<T> sharedAxisTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

class _SharedAxisTransition extends StatelessWidget {
  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    required this.transitionType,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final SharedAxisTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
            )),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
              )),
              child: child,
            ),
          ),
        );
        
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
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
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// Extension methods for easy navigation with animations
extension AnimatedNavigation on BuildContext {
  /// Navigate with slide from right animation
  Future<T?> pushSlideFromRight<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.slideFromRight<T>(page: page),
    );
  }

  /// Navigate with slide from bottom animation
  Future<T?> pushSlideFromBottom<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.slideFromBottom<T>(page: page),
    );
  }

  /// Navigate with fade animation
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.fadeTransition<T>(page: page),
    );
  }

  /// Navigate with scale animation
  Future<T?> pushScale<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.scaleTransition<T>(page: page),
    );
  }

  /// Replace current page with slide animation
  Future<T?> pushReplacementSlide<T extends Object?, TO extends Object?>(
    Widget page,
  ) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransitions.slideFromRight<T>(page: page),
    );
  }
}

/// Staggered animation utility for list items
class StaggeredAnimationHelper {
  static List<Widget> buildStaggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration delayBetweenItems = const Duration(milliseconds: 100),
    Duration itemAnimationDuration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      final delay = delayBetweenItems.inMilliseconds * index / 1000.0;
      final animationStart = delay / controller.duration!.inMilliseconds * 1000.0;
      final animationEnd = (delay + itemAnimationDuration.inMilliseconds) / 
          controller.duration!.inMilliseconds * 1000.0;
      
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final animationValue = Interval(
            animationStart.clamp(0.0, 1.0),
            animationEnd.clamp(0.0, 1.0),
            curve: curve,
          ).transform(controller.value);
          
          return Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: Opacity(
              opacity: animationValue,
              child: child,
            ),
          );
        },
        child: child,
      );
    }).toList();
  }
}
