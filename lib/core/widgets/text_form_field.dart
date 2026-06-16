import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final String descriptionText;
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? obscureText;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;

  const AppTextFormField({
    super.key,
    required this.descriptionText,
    this.validator,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(descriptionText, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          focusNode: focusNode,
          style: Theme.of(context).textTheme.bodySmall,
          controller: controller,
          validator: validator,
          obscureText: obscureText!,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hintText,
            helperText: ' ',
            counterText: maxLength != null ? '' : null,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
