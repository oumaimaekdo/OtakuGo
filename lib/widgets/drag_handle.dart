import 'package:flutter/material.dart';

const double handleExtent = 40;

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: handleExtent,
      child: Center(
        child: Container(
          width: 68,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.28),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
