import 'package:afriendorse/athlete/feature/dashboard/view/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/advertisement_section.dart';

class AthleteAdSection extends StatelessWidget {
  const AthleteAdSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AthleteSectionTitle(
          title: 'Spotlight',
          subtitle: 'Featured promotions and platform updates',
        ),
        AdvertisementSection(),
      ],
    );
  }
}
