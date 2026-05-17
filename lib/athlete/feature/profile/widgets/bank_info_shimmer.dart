import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BankInfoShimmer extends StatelessWidget {
  const BankInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(
        seconds: 5,
      ), //Default value: Duration(seconds: 0)
      color: Colors.white, //Default value
      colorOpacity: 0, //Default value
      enabled: true, //Default value
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        height: context.height,
        width: context.width,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    height: 90,
                    width: context.width,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          height: 50,
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
