import 'package:afriendorse/athlete/utils/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  final Widget? errorWidget;
  const CustomImage({
    super.key,
    @required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = Images.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image!,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) =>
          Image.asset(placeholder!, height: height, width: width, fit: fit),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Image.asset(placeholder!, height: height, width: width, fit: fit),
    );
  }
}
