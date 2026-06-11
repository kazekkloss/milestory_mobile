import 'package:flutter/material.dart';

import '../../../../core/core_export.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalErrorListener(
      child: Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(),
              Column(
                children: [
                  LogoWidget(),
                  SizedBox(height: 40),
                  CircularProgressIndicator(),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
