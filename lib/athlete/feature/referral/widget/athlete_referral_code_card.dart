import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/referral/controller/athlete_referral_controller.dart';

class AthleteReferralCodeCard extends StatelessWidget {
  const AthleteReferralCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AthleteReferralController>(
      init: Get.find<AthleteReferralController>(),
      builder: (controller) {
        final referralCode = controller.userReferralData?.referralCode ?? '';

        if (referralCode.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.sports_rounded,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'your_referral_code'.tr,
                                style: robotoMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'copy_and_share'.tr,
                                style: robotoRegular.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.white.withOpacity(0.5),
                        strokeWidth: 2,
                        dashPattern: const [8, 4],
                        radius: const Radius.circular(12),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                referralCode,
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: controller.copyReferralCode,
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                              ),
                              tooltip: 'copy_code'.tr,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.copyReferralText,
                        icon: const Icon(
                          Icons.content_paste_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'copy_referral_text'.tr,
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
