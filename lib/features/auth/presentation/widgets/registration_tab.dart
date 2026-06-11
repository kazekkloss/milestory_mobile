import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core_export.dart';
import '../../auth_export.dart';

class RegisterTab extends StatefulWidget {
  const RegisterTab({super.key});

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _consent = false;
  bool _showConsentErr = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _showConsentErr = !_consent);
    if (_formKey.currentState!.validate() && _consent) {
      context.read<AuthBloc>().add(
        RegistrationEvent(email: _emailController.text, password: _passwordController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              descriptionText: 'Hasło',
              hintText: '••••••••',
              controller: _passwordController,
              obscureText: _obscure,
              suffixIcon: TextButton(
                child: _obscure ? const Text("pokaż") : const Text("ukryj"),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Pole nie może być puste';
                }
                if (v.length < 6) return 'Hasło musi mieć min. 6 znaków';
                return null;
              },
            ),
            AppTextFormField(
              descriptionText: 'Potwierdź hasło',
              hintText: '••••••••',
              controller: _confirmController,
              obscureText: _obscure,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Pole nie może być puste';
                }
                if (v != _passwordController.text) {
                  return 'Hasła nie są zgodne';
                }
                return null;
              },
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: SizeConfig.kTextFormFieldWidth,
              ),
              child: RegulationsWidget(
                isChecked: _consent,
                isError: _showConsentErr,
                onCheckboxChanged: (v) => setState(() {
                  _consent = v ?? false;
                  if (_consent) _showConsentErr = false;
                }),
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return CustomElevatedButton(
                  onPressed: _submit,
                  text: "Zarejestruj się",
                  isLoading: state.loading,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
