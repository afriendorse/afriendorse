import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImage extends StatefulWidget {
  final String appbarTitle;
  final String imagePath;
  final String? appbarSubtitle;
  const ZoomImage({
    super.key,
    required this.appbarTitle,
    required this.imagePath,
    this.appbarSubtitle,
  });

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  bool isZoomed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isZoomed
          ? null
          : CustomAppBar(
              title: widget.appbarTitle,
              subtitle: widget.appbarSubtitle,
            ),
      body: Stack(
        children: [
          PhotoView(
            scaleStateChangedCallback: (value) {
              if (value != PhotoViewScaleState.initial) {
                isZoomed = true;
              } else {
                isZoomed = false;
              }
              setState(() {});
            },
            minScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(widget.imagePath),
          ),
        ],
      ),
    );
  }
}
