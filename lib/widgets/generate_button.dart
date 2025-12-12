import 'package:flutter/material.dart';
import 'package:password/colors.dart';

class GenerateButton extends StatefulWidget {
  final VoidCallback onTap;

  const GenerateButton({super.key, required this.onTap});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.switchActive,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: const Center(
          child: Text(
            'GERAR SENHA',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
