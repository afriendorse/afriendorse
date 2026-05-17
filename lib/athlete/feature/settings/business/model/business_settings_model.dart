import 'package:just_the_tooltip/just_the_tooltip.dart';

class BusinessSettings{
  String? settingTitle;
  int? settingsValue;
  String? toolTipText;
  String? keyValue;
  JustTheController ? toolTipController;

  BusinessSettings({required this.settingTitle, required this.settingsValue, required this.toolTipText, required this.toolTipController, required this.keyValue});
}