import 'package:afriendorse/athlete/utils/core_export.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.controlAffinity,
  }) : assert(!initiallyExpanded),
       assert(!maintainState),
       assert(
         expandedCrossAxisAlignment != CrossAxisAlignment.baseline,
         'CrossAxisAlignment.baseline is not supported since the expanded children '
         'are aligned in a column, not a row. Try to use another constant.',
       );

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool maintainState;
  final EdgeInsetsGeometry? tilePadding;
  final Alignment? expandedAlignment;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final EdgeInsetsGeometry? childrenPadding;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final Color? textColor;
  final Color? collapsedTextColor;
  final ListTileControlAffinity? controlAffinity;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween = CurveTween(
    curve: Curves.easeOut,
  );
  static final Animatable<double> _easeInTween = CurveTween(
    curve: Curves.easeIn,
  );

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;

  late Animation<double> _heightFactor;

  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor = _controller.drive(
      _backgroundColorTween.chain(_easeOutTween),
    );

    _isExpanded =
        PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final ExpansionTileThemeData expansionTileTheme = ExpansionTileTheme.of(
      context,
    );

    return Container(
      decoration: BoxDecoration(
        color:
            _backgroundColor.value ??
            expansionTileTheme.backgroundColor ??
            Colors.transparent,
        border: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value ?? expansionTileTheme.iconColor,
            textColor: _headerColor.value,
            child: ListTile(
              //tileColor: Colors.blue,
              onTap: _handleTap,
              contentPadding:
                  widget.tilePadding ?? expansionTileTheme.tilePadding,
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(Dimensions.radiusDefault),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded == true
                          ? Icons.remove_circle
                          : Icons.add_circle_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: widget.title),
                  ],
                ),
              ),
              //title: widget.title,
              subtitle: widget.subtitle,
            ),
          ),
          ClipRect(
            child: Align(
              alignment:
                  widget.expandedAlignment ??
                  expansionTileTheme.expandedAlignment ??
                  Alignment.center,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    final ExpansionTileThemeData expansionTileTheme = ExpansionTileTheme.of(
      context,
    );
    final ColorScheme colorScheme = theme.colorScheme;
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin =
          widget.collapsedTextColor ??
          expansionTileTheme.collapsedTextColor ??
          theme.textTheme.titleMedium!.color
      ..end =
          widget.textColor ??
          expansionTileTheme.textColor ??
          colorScheme.primary;
    _iconColorTween
      ..begin =
          widget.collapsedIconColor ??
          expansionTileTheme.collapsedIconColor ??
          theme.unselectedWidgetColor
      ..end =
          widget.iconColor ??
          expansionTileTheme.iconColor ??
          colorScheme.primary;
    _backgroundColorTween
      ..begin =
          widget.collapsedBackgroundColor ??
          expansionTileTheme.collapsedBackgroundColor
      ..end = widget.backgroundColor ?? expansionTileTheme.backgroundColor;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ExpansionTileThemeData expansionTileTheme = ExpansionTileTheme.of(
      context,
    );
    final bool closed = !_isExpanded && _controller.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
          padding:
              widget.childrenPadding ??
              expansionTileTheme.childrenPadding ??
              EdgeInsets.zero,
          child: Column(
            crossAxisAlignment:
                widget.expandedCrossAxisAlignment ?? CrossAxisAlignment.center,
            children: widget.children,
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }
}
