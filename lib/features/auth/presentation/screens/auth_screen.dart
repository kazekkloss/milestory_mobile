import 'package:flutter/material.dart';
import '../../auth_export.dart';

import '../../../../core/core_export.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _recoveryAnim;
  late Animation<double> _recoveryCurved;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recoveryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _recoveryCurved = CurvedAnimation(
      parent: _recoveryAnim,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recoveryAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: FooterWidget(),
      ),
      body: GlobalErrorListener(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              AnimatedBuilder(
                animation: _recoveryCurved,
                builder: (context, _) {
                  final r = _recoveryCurved.value;
                  return Stack(
                    children: [
                      // Password Recovery — z lewej (wjeżdża gdy r: 0→1)
                      FractionalTranslation(
                        translation: Offset(r - 1, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: PasswordRecoveryTab(
                            onTap: () => _recoveryAnim.reverse(),
                          ),
                        ),
                      ),
                      // Login + Register — środek (wyjeżdża w prawo gdy r: 0→1)
                      FractionalTranslation(
                        translation: Offset(r, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'Logowanie'),
                                  Tab(text: 'Rejestracja'),
                                ],
                              ),
                              AnimatedBuilder(
                                animation: _tabController.animation!,
                                builder: (context, _) {
                                  final t = _tabController.animation!.value;
                                  return Stack(
                                    children: [
                                      FractionalTranslation(
                                        translation: Offset(-t, 0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: LoginTab(
                                            onTap: () =>
                                                _recoveryAnim.forward(),
                                          ),
                                        ),
                                      ),
                                      FractionalTranslation(
                                        translation: Offset(1.0 - t, 0),
                                        child: const SizedBox(
                                          width: double.infinity,
                                          child: RegisterTab(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/duzy.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 1),
              Colors.black.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 1],
          ),
        ),
        child: const Center(child: LogoWidget()),
      ),
    );
  }
}
