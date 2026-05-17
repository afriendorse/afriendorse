import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class DescriptionExpansionTile extends StatefulWidget {
  final String title;
  final String? subTitle;
  final List<AdditionInstructions>? additionalInstruction;

  const DescriptionExpansionTile({
    super.key,
    required this.title,
    this.subTitle,
    this.additionalInstruction,
  });

  @override
  State<DescriptionExpansionTile> createState() =>
      _DescriptionExpansionTileState();
}

class _DescriptionExpansionTileState extends State<DescriptionExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
              if (expanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.additionalInstruction != null
                  ? Icons.info_outline_rounded
                  : Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          trailing: RotationTransition(
            turns: _iconTurns,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.title.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).hoverColor.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.additionalInstruction != null)
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.additionalInstruction![index].details ??
                                    "",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: widget.additionalInstruction!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  if (widget.subTitle != null)
                    Text(
                      widget.subTitle!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
