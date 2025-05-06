import 'package:flutter/material.dart';
import 'package:cool_sudoku/theme/nord_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      alignment: Alignment.center,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Text(
        'created by taytay',
        style: TextStyle(
          color: NordColors.nord6,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 