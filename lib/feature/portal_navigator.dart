import 'package:afriendorse/feature/athlete_module.dart';
import 'package:afriendorse/feature/brandfan_module.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import both portal widgets

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/appbar_logo.png', // Your logo
                    height: 120,
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Choose Your Portal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Select the experience that fits your needs',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Brand/Fan Portal Card
                _PortalCard(
                  title: 'Brand / Fan',
                  subtitle: 'For customers, brands, and fans',
                  icon: Icons.business,
                  color: Colors.blue,
                  onTap: () => Get.off(() => const AboutDialog()),
                ),
                const SizedBox(height: 20),

                // Athlete Portal Card
                _PortalCard(
                  title: 'Athlete Portal',
                  subtitle: 'For athletes and performers',
                  icon: Icons.sports_martial_arts,
                  color: Colors.green,
                  onTap: () => Get.off(() => const AthletePortal()),
                ),

                const SizedBox(height: 48),

                // Help text
                TextButton(
                  onPressed: () {
                    // Show help dialog
                    _showHelpDialog(context);
                  },
                  child: const Text('Need help choosing?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Which Portal?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Brand/Fan if you want to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Book services\n• Browse content\n• Connect with brands'),
            SizedBox(height: 16),
            Text(
              'Choose Athlete if you are:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• An athlete or performer\n• Managing your career\n• Offering services',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}
