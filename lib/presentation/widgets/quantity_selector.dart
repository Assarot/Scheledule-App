import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 60,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.hint.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: onPressed != null ? AppColors.primary : AppColors.hint.withOpacity(0.3),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
