import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? leadingIcon;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.leadingIcon,
    this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: leadingIcon != null ? Icon(leadingIcon, color: AppColors.hint) : null,
            suffixIcon: trailing,
            hintText: hint,
          ),
        ),
      ],
    );
  }
}


