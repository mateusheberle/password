import 'package:flutter/material.dart';
import 'package:password/colors.dart';

class SwitchTile extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchTile({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(text, style: const TextStyle(color: AppColors.textLight)),
      activeColor: AppColors.switchActive,
      activeTrackColor: AppColors.switchActiveTrack,
      inactiveThumbColor: AppColors.switchInactiveThumb,
      inactiveTrackColor: AppColors.switchInactiveTrack,
    );
  }
}
