import 'package:flutter/material.dart';
import 'package:cool_sudoku/theme/nord_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? NordColors.nord6 : NordColors.nord0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Cool Sudoku™',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'A modern, user-friendly Sudoku game with a beautiful Nord theme.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem('Multiple difficulty levels'),
          _buildFeatureItem('Note-taking functionality'),
          _buildFeatureItem('Undo/Redo support'),
          _buildFeatureItem('Dark mode support'),
          _buildFeatureItem('Cross-platform support'),
          const SizedBox(height: 24),
          const Text(
            'Credits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildCreditItem('Created by', 'taytay'),
          _buildCreditItem('Theme', 'Nord Theme'),
          _buildCreditItem('Icons', 'Material Icons'),
          const SizedBox(height: 24),
          const Text(
            'Legal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 taytay. All rights reserved.\n'
            'Cool Sudoku™ is a trademark of taytay.\n\n'
            'This software is licensed under the MIT License.',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://github.com/tmw-it/cool_sudoku');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: Text(
              'View on GitHub',
              style: TextStyle(
                color: NordColors.nord10,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildCreditItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
} 