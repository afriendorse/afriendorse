import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthFaPatternBackground extends StatelessWidget {
  /// [formMode] = true → uses a lighter opacity so form fields stay readable
  final bool formMode;
  const AuthFaPatternBackground({super.key, this.formMode = false});

  static const Color _kGreen = Color(0xFF045F25);
  static const double _bloomOpacity = 0.14;
  static const double _bloomRadius = 2.45;
  static const int _seed = 13;
  static const double _tile = 74;

  @override
  Widget build(BuildContext context) {
    final double patternOpacity = formMode ? 0.038 : 0.07;

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6FAF7), Color(0xFFFFFFFF)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: _bloomRadius,
                colors: [
                  _kGreen.withOpacity(_bloomOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: FaOnlyPatternPainter(
                icons: const <FaIconData>[
                  FontAwesomeIcons.futbol,
                  FontAwesomeIcons.basketball,
                  FontAwesomeIcons.volleyball,
                  FontAwesomeIcons.baseball,
                  FontAwesomeIcons.tableTennisPaddleBall,
                  FontAwesomeIcons.personRunning,
                  FontAwesomeIcons.personBiking,
                  FontAwesomeIcons.dumbbell,
                  FontAwesomeIcons.stopwatch,
                  FontAwesomeIcons.trophy,
                  FontAwesomeIcons.medal,
                  FontAwesomeIcons.football, // American football
                  FontAwesomeIcons.hockeyPuck, // Ice hockey
                  FontAwesomeIcons.golfBallTee, // Golf
                  FontAwesomeIcons.bowlingBall, // Bowling
                  FontAwesomeIcons.swimmer, // Swimming
                  FontAwesomeIcons.personSwimming, // Swimming (alt)
                  FontAwesomeIcons.personSkiing, // Skiing
                  FontAwesomeIcons.personSnowboarding, // Snowboarding
                  FontAwesomeIcons.personSkating, // Skating
                  FontAwesomeIcons.personWalking, // Walking/Hiking
                  FontAwesomeIcons.personHiking, // Hiking
                  FontAwesomeIcons.heartPulse, // Cardio/fitness
                  FontAwesomeIcons.fireFlameCurved, // Calories/burn
                  FontAwesomeIcons.bullseye, // Archery/target sports
                  FontAwesomeIcons.flagCheckered, // Racing/finish line
                  FontAwesomeIcons.bicycle, // Cycling (alt)
                  FontAwesomeIcons.motorcycle, // Motorsports
                  FontAwesomeIcons.car, // Racing
                  FontAwesomeIcons.gaugeHigh, // Speed/performance
                  FontAwesomeIcons.calendarCheck, // Scheduled events
                  FontAwesomeIcons.clipboardList, // Training plans
                  FontAwesomeIcons.chartLine, // Progress tracking
                  FontAwesomeIcons.shoePrints, // Steps/tracking
                  FontAwesomeIcons.locationDot, // Location/venues
                  FontAwesomeIcons.users, // Teams
                  FontAwesomeIcons.userGroup, // Teams (alt)
                  FontAwesomeIcons.sitemap, // League structure
                  FontAwesomeIcons.circlePlay, // Start activity
                  FontAwesomeIcons.pause, // Pause
                  FontAwesomeIcons.circleStop, // Stop
                  FontAwesomeIcons.rotateRight, // Reset/retry
                  FontAwesomeIcons.star, // Favorites
                  FontAwesomeIcons.bookmark, // Saved events
                  FontAwesomeIcons.shareNodes, // Share results
                  FontAwesomeIcons.camera, // Photos/videos
                  FontAwesomeIcons.video, // Recordings
                  FontAwesomeIcons.mountain, // Outdoor sports
                  FontAwesomeIcons.campground, // Outdoor activities
                  FontAwesomeIcons.water, // Water sports
                  FontAwesomeIcons.wind, // Wind sports
                  FontAwesomeIcons.sun, // Outdoor conditions
                  FontAwesomeIcons.cloudSun, // Weather
                  FontAwesomeIcons.temperatureHalf, // Body temp/conditions
                  FontAwesomeIcons.droplet, // Hydration
                  FontAwesomeIcons.appleWhole, // Nutrition
                  FontAwesomeIcons.burger, // Diet/cheat meals
                  FontAwesomeIcons.bed, // Rest/recovery
                  FontAwesomeIcons.moon, // Sleep tracking
                  FontAwesomeIcons.bell, // Notifications/reminders
                  FontAwesomeIcons.circleExclamation, // Alerts
                  FontAwesomeIcons.circleInfo, // Info
                  FontAwesomeIcons.gear, // Settings
                  FontAwesomeIcons.sliders, // Preferences
                  FontAwesomeIcons.magnifyingGlass, // Search
                  FontAwesomeIcons.filter, // Filter results    // Sort
                  FontAwesomeIcons.arrowRightArrowLeft,
                ],
                color: _kGreen,
                opacity: patternOpacity,
                tile: _tile,
                seed: _seed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FaOnlyPatternPainter extends CustomPainter {
  final List<FaIconData> icons;
  final Color color;
  final double opacity;
  final double tile;
  final int seed;

  const FaOnlyPatternPainter({
    required this.icons,
    required this.color,
    required this.opacity,
    required this.tile,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    const sizesMain = <double>[16, 18, 20, 22, 24, 26];
    const sizesSmall = <double>[12, 14, 16, 18];

    for (double y = -tile; y < size.height + tile; y += tile) {
      final row = (y / tile).round();
      final rowShift = row.isEven ? tile * 0.35 : 0.0;
      for (double x = -tile; x < size.width + tile; x += tile) {
        _drawFa(
          canvas: canvas,
          rnd: rnd,
          icon: icons[rnd.nextInt(icons.length)],
          origin: Offset(x + rowShift + tile / 2, y + tile / 2),
          size: sizesMain[rnd.nextInt(sizesMain.length)],
          opacityScale: 1.0,
        );
        if (rnd.nextDouble() < 0.55) {
          _drawFa(
            canvas: canvas,
            rnd: rnd,
            icon: icons[rnd.nextInt(icons.length)],
            origin: Offset(
              x + rowShift + tile * (0.25 + rnd.nextDouble() * 0.5),
              y + tile * (0.25 + rnd.nextDouble() * 0.5),
            ),
            size: sizesSmall[rnd.nextInt(sizesSmall.length)],
            opacityScale: 0.85,
          );
        }
      }
    }
  }

  void _drawFa({
    required Canvas canvas,
    required Random rnd,
    required FaIconData icon,
    required Offset origin,
    required double size,
    required double opacityScale,
  }) {
    final angle = (rnd.nextDouble() - 0.5) * 0.55;
    final jitter = Offset(
      (rnd.nextDouble() - 0.5) * 10,
      (rnd.nextDouble() - 0.5) * 10,
    );
    final alpha = (opacity * opacityScale) * (0.75 + rnd.nextDouble() * 0.5);
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          color: color.withOpacity(alpha.clamp(0.0, 1.0)),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    )..layout();
    canvas.save();
    canvas.translate(origin.dx + jitter.dx, origin.dy + jitter.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FaOnlyPatternPainter old) {
    return old.opacity != opacity ||
        old.tile != tile ||
        old.color != color ||
        old.seed != seed ||
        old.icons != icons;
  }
}
