import 'package:flutter/material.dart';
import 'package:based_sudoku/theme/nord_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      alignment: Alignment.center,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Image.asset(
              'assets/images/rock_on_64.png',
              width: 58,
              height: 58,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
        'created by taytay',
        style: TextStyle(
          color: NordColors.nord6,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
          ),
        ],
      ),
    );
  }
} 