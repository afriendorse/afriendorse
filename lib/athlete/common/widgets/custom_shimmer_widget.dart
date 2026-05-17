import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomShimmerWidget extends StatelessWidget {
  final Widget child;
  final bool isSliver;
  final double? separator;
  final Axis scrollDirection;

  const CustomShimmerWidget({
    super.key,
    required this.child,
    this.isSliver = false,
    this.separator,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? Skeletonizer.sliver(
            child: ListView.separated(
              scrollDirection: scrollDirection,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: 10,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, index) {
                return child;
              },
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: separator ?? Dimensions.paddingSizeSmall),
            ),
          )
        : Skeletonizer(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: scrollDirection,
              shrinkWrap: true,
              itemCount: 10,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, index) {
                return child;
              },
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: Dimensions.paddingSizeSmall),
            ),
          );
  }
}
