import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../../auth_export.dart';

class LoginTab extends StatefulWidget {
  final VoidCallback onTap;
  const LoginTab({super.key, required this.onTap});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tt = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            AppTextFormField(
              descriptionText: "Email",
              hintText: "kowalski@example.com",
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pole nie może być puste';
                }
                if (!EmailValidator.validate(value)) {
                  return 'Nieprawidłowy adres e-mail';
                }
                return null;
              },
            ),
            AppTextFormField(
              descriptionText: "Hasło",
              controller: _passwordController,
              obscureText: _obscure,
              hintText: "••••••••",
              suffixIcon: TextButton(
                child: _obscure ? const Text("pokaż") : const Text("ukryj"),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pole nie może być puste';
                }
                return null;
              },
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: SizeConfig.kTextFormFieldWidth,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: widget.onTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Zapomniałem hasła',
                    style: tt.labelMedium!.copyWith(color: c.accent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return CustomElevatedButton(
                  onPressed: () => _submit(),
                  text: "Zaloguj się",
                  isLoading: state.loading,
                );
              },
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
