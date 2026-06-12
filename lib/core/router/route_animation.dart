import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAnimationPage<T> extends CustomTransitionPage<T> {
  CustomAnimationPage({
    super.key,
    required super.child,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final slideAnimation =
               Tween<Offset>(
                 begin: const Offset(0, 1),
                 end: Offset.zero,
               ).animate(
                 CurvedAnimation(parent: animation, curve: Curves.easeInOut),
               );

           final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(parent: animation, curve: Curves.easeInOut),
           );

           return SlideTransition(
             position: slideAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );
}

class CustomShellAnimationPage extends Page {
  final Widget child;
  final int currentIndex;
  final int previousIndex;
  final Widget? previousScreen;

  const CustomShellAnimationPage({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.previousIndex,
    this.previousScreen,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final isForward = currentIndex > previousIndex;
        final enterBegin = isForward
            ? const Offset(1.0, 0.0)
            : const Offset(-1.0, 0.0);
        final enterTween = Tween(begin: enterBegin, end: Offset.zero);
        final enterAnimation = animation.drive(
          enterTween.chain(CurveTween(curve: Curves.easeInOut)),
        );

        const exitBegin = Offset.zero;
        final exitEnd = isForward
            ? const Offset(-1.0, 0.0)
            : const Offset(1.0, 0.0);
        final exitTween = Tween(begin: exitBegin, end: exitEnd);
        final exitAnimation = animation.drive(
          exitTween.chain(CurveTween(curve: Curves.easeInOut)),
        );

        return Stack(
          children: [
            if (previousScreen != null)
              SlideTransition(position: exitAnimation, child: previousScreen),
            SlideTransition(position: enterAnimation, child: child),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
