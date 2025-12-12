import 'package:flutter/material.dart';
import 'package:password/colors.dart';

class PasswordLengthSelector extends StatelessWidget {
  final int length;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const PasswordLengthSelector({
    super.key,
    required this.length,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final int passwordLength = length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Tamanho da senha: $passwordLength'),
        Slider(
          value: passwordLength.toDouble(),
          min: 4,
          max: 64,
          divisions: 60,
          label: passwordLength.toString(),
          activeColor: AppColors.switchActive,
          inactiveColor: AppColors.switchInactiveTrack,
          thumbColor: AppColors.switchActive,
          onChanged: (value) {
            if (value < passwordLength) {
              onDecrement();
            } else if (value > passwordLength) {
              onIncrement();
            }
          },
        ),
      ],
    );
  }
}
