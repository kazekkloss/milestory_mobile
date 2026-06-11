import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../../auth_export.dart';

class PasswordRecoveryTab extends StatelessWidget {
  final VoidCallback onTap;

  PasswordRecoveryTab({super.key, required this.onTap});
  final TextEditingController _emailController = TextEditingController();
  final _recoveryFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tt = Theme.of(context).textTheme;

    return Form(
      key: _recoveryFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kTextTabBarHeight,
            child: Center(
              child: Text(
                'Podaj adres e-mail przypisany do konta',
                style: tt.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                AppTextFormField(
                  descriptionText: 'Email',
                  hintText: 'kowalski@example.com',
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: SizeConfig.kTextFormFieldWidth,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Wróć do logowania',
                        style: tt.labelMedium!.copyWith(color: c.accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      onPressed: () {
                        if (_recoveryFormKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(SendPasswordRecoveryLinkEvent(email: _emailController.text));
                        }
                      },
                      text: 'Wyślij link',
                      isLoading: state.loading,
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
