import 'package:flutter/material.dart';

/// A simple country code picker widget.
/// This is a minimal implementation to satisfy the import.
class CountryCodePicker extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool showFlag;

  const CountryCodePicker({
    super.key,
    this.onChanged,
    this.showFlag = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // For now, just call onChanged with default country code
        onChanged?.call('+1');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) const Text('🇺🇸 ', style: TextStyle(fontSize: 20)),
            const Text('+1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
