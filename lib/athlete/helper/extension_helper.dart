import 'package:afriendorse/athlete/utils/core_export.dart';

extension ContextInfo on BuildContext {
  ThemeData get theme => Theme.of(this);
  CustomThemeColors get customThemeColors =>
      theme.extension<CustomThemeColors>()!;
}
