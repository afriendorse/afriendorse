import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CreateAdvertisementLogoView extends StatelessWidget {
  const CreateAdvertisementLogoView({super.key});

  @override
  Widget build(BuildContext context) {
    AdvertisementController advertisementController = Get.find();
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              advertisementController.networkProfileImage == null &&
                  advertisementController.pickedProfileImage != null
              ? Image.file(
                  File(advertisementController.pickedProfileImage!.path),
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                )
              : advertisementController.networkProfileImage != null &&
                    advertisementController.pickedProfileImage == null
              ? CustomImage(
                  height: 100,
                  width: 100,
                  image: "${advertisementController.networkProfileImage}",
                )
              : const SizedBox(),
        ),

        Positioned(
          top: -10,
          right: -10,
          child: IconButton(
            onPressed: () => advertisementController.pickProfileImage(true),
            icon: const Icon(
              Icons.highlight_remove_rounded,
              color: Colors.red,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}
