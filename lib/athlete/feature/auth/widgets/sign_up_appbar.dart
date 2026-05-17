import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpAppbar extends StatefulWidget implements PreferredSizeWidget {
  const SignUpAppbar({super.key});
  @override
  State<SignUpAppbar> createState() => _SignUpAppbarState();
  @override
  Size get preferredSize =>
      const Size(double.maxFinite, Dimensions.signUpAppbarHeight);
}

class _SignUpAppbarState extends State<SignUpAppbar> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      builder: (signUpController) {
        int totalStep = SignUpPageStep.values.length - 1;
        int currentStep = signUpController.currentStep == SignUpPageStep.step5
            ? totalStep - 1
            : SignUpPageStep.values.indexOf(signUpController.currentStep);

        String title = currentStep == 0
            ? "basic_information"
            : currentStep == 1
            ? "business_information"
            : currentStep == 2
            ? "account_information"
            : currentStep == 3
            ? "choose_business_plan"
            : "choose_business_plan";

        return AppBar(
          elevation: 5,
          titleSpacing: 0,
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          shadowColor: Get.isDarkMode
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          centerTitle: false,
          toolbarHeight: Dimensions.signUpAppbarHeight,
          title: Text(
            title.tr.replaceFirst(" ", "\n"),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              if (signUpController.currentStep == SignUpPageStep.step1) {
                Get.back();
              } else {
                signUpController.updateRegistrationStep(
                  signUpController.currentStep == SignUpPageStep.step5
                      ? SignUpPageStep.step4
                      : signUpController.currentStep == SignUpPageStep.step4
                      ? SignUpPageStep.step3
                      : signUpController.currentStep == SignUpPageStep.step3
                      ? SignUpPageStep.step2
                      : signUpController.currentStep == SignUpPageStep.step2
                      ? SignUpPageStep.step1
                      : SignUpPageStep.step1,
                );
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColorLight,
              size: 20,
            ),
          ),
          actions: [
            const SizedBox(width: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(
                begin: currentStep / totalStep,
                end: currentStep / totalStep + (1 / totalStep),
              ),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: Dimensions.signUpAppbarHeight * 0.62,
                      width: Dimensions.signUpAppbarHeight * 0.62,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: Dimensions.signUpAppbarHeight * 0.06,
                        backgroundColor: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.signUpAppbarHeight * 0.4,
                      width: Dimensions.signUpAppbarHeight * 0.4,
                      child: FittedBox(
                        child: Text(
                          "${currentStep + 1} ${'of'.tr} $totalStep",
                          style: robotoBold.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 20),
          ],
        );
      },
    );
  }
}
