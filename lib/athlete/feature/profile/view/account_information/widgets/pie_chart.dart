import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionPieChart extends StatefulWidget {
  const TransactionPieChart({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;
  var totalBookingRequest = 0;
  var percentOfCancelRequest = 0;
  var percentOfCompletedRequest = 0;
  var percentOfOngoingRequest = 0;
  var percentOfAcceptedRequest = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        totalBookingRequest =
            (userProfileController.totalOngoingRequest +
            userProfileController.totalCompletedRequest +
            userProfileController.totalCanceledRequest +
            userProfileController.totalAcceptedRequest);

        if (userProfileController.totalCanceledRequest != 0) {
          percentOfCancelRequest =
              ((userProfileController.totalCanceledRequest * 100.00) /
                      totalBookingRequest)
                  .ceil();
        }
        if (userProfileController.totalCompletedRequest != 0) {
          percentOfCompletedRequest =
              ((userProfileController.totalCompletedRequest * 100.00) /
                      totalBookingRequest)
                  .ceil();
        }
        if (userProfileController.totalOngoingRequest != 0) {
          percentOfOngoingRequest =
              ((userProfileController.totalOngoingRequest * 100.00) /
                      totalBookingRequest)
                  .floor();
        }
        if (userProfileController.totalAcceptedRequest != 0) {
          percentOfAcceptedRequest =
              ((userProfileController.totalAcceptedRequest * 100.00) /
                      totalBookingRequest)
                  .floor();
        }

        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: showingSections(userProfileController),
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFF433aff),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${'accepted'.tr} (${userProfileController.totalAcceptedRequest})",
                          style: robotoRegular.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.deepPurpleAccent,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${'ongoing'.tr} (${userProfileController.totalOngoingRequest})",
                          style: robotoRegular.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 15),
                        const SizedBox(width: 5),
                        Text(
                          "${'completed'.tr} (${userProfileController.totalCompletedRequest})",
                          style: robotoRegular.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, color: Colors.lightBlue, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      "${'canceled'.tr} (${userProfileController.totalCanceledRequest})",
                      style: robotoRegular.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text(
                "$totalBookingRequest\n${'booking'.tr}",
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
    UserProfileController userProfileController,
  ) {
    return totalBookingRequest > 0
        ? List.generate(4, (i) {
            final isTouched = i == touchedIndex;
            final radius = isTouched ? 35.0 : 35.0;
            switch (i) {
              case 0:
                return PieChartSectionData(
                  color: Colors.lightBlueAccent,
                  value: double.tryParse(percentOfCancelRequest.toString()),
                  title: "$percentOfCancelRequest%",
                  radius: radius,
                  titleStyle: robotoMedium.copyWith(color: Colors.white),
                );
              case 1:
                return PieChartSectionData(
                  color: Colors.deepPurpleAccent,
                  value: double.tryParse(percentOfOngoingRequest.toString()),
                  title: "$percentOfOngoingRequest%",
                  radius: radius,
                  titleStyle: robotoMedium.copyWith(color: Colors.white),
                );
              case 2:
                return PieChartSectionData(
                  color: const Color(0xFF433aff),
                  value: double.tryParse(percentOfAcceptedRequest.toString()),
                  title: "$percentOfAcceptedRequest%",
                  radius: radius,
                  titleStyle: robotoMedium.copyWith(color: Colors.white),
                );
              case 3:
                return PieChartSectionData(
                  color: Colors.green.shade400,
                  value: double.tryParse(percentOfCompletedRequest.toString()),
                  title: "$percentOfCompletedRequest%",
                  radius: radius,
                  titleStyle: robotoMedium.copyWith(color: Colors.white),
                );
              default:
                throw Error();
            }
          })
        : List.generate(1, (i) {
            final isTouched = i == touchedIndex;
            final fontSize = isTouched ? 25.0 : 16.0;
            final radius = isTouched ? 50.0 : 40.0;
            switch (i) {
              case 0:
                return PieChartSectionData(
                  color: const Color(0xffabe59e),
                  value: 1.0,
                  title: "",
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                  ),
                );
              default:
                throw Error();
            }
          });
  }
}
