import 'package:flutter/material.dart';
import 'package:password/colors.dart';

class PasswordDisplay extends StatefulWidget {
  final String password;
  final VoidCallback onCopy;
  final VoidCallback onError;

  const PasswordDisplay({
    super.key,
    required this.password,
    required this.onCopy,
    required this.onError,
  });

  @override
  State<PasswordDisplay> createState() => _PasswordDisplayState();
}

class _PasswordDisplayState extends State<PasswordDisplay> {
  bool _copied = false;
  bool _error = false;

  Future<void> _copyToClipboard() async {
    setState(() {
      if (widget.password.isEmpty) {
        _error = true;
        widget.onError();
      } else {
        _copied = true;
        widget.onCopy();
      }
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _copied = false;
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.password.isEmpty
                  ? 'Sua senha aparecerá aqui.'
                  : widget.password,
              style: const TextStyle(fontSize: 20, color: AppColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _error
                  ? Icons.close
                  : _copied
                      ? Icons.check
                      : Icons.copy,
              color: _error ? Colors.red : AppColors.switchActive,
            ),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}
