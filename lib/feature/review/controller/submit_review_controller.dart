import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/review/repo/submit_review_repo.dart';

class SubmitReviewController extends GetxController {
  final SubmitReviewRepo submitReviewRepo;
  SubmitReviewController({required this.submitReviewRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _loading = false;
  bool get loading => _loading;

  List<Service>? _serviceReviewList;
  List<Service>? get serviceReviewList => _serviceReviewList;

  Map<String, Map<String, dynamic>> listOfReview = {};

  TextEditingController reviewController = TextEditingController();
  Map<String, TextEditingController> textControllers = {};
  Map<String, int> selectedRating = {};
  Map<String, bool> isEditable = {};
  Map<String, String> reviewComments = {};

  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;

  void selectReview(int rating, serviceId) {
    selectedRating[serviceId] = rating;
    update();
  }

  void setIndex(int index) {
    _selectedIndex = index;
    update();
  }

  Future<void> submitReview(
    ReviewBody reviewBody,
    String serviceId,
    String review,
    int index,
  ) async {
    _isLoading = true;
    update();
    Response response = await submitReviewRepo.submitReview(
      reviewBody: reviewBody,
    );
    if (response.statusCode == 200) {
      isEditable[serviceId] = false;
      reviewComments[serviceId] = review;
      customSnackBar(
        'review_submitted_successfully'.tr,
        type: ToasterMessageType.success,
      );
    }
    _isLoading = false;
    update();
  }

  Future<void> getReviewList(String bookingId) async {
    _loading = true; // You forgot to set this to true at start!
    update();

    Response response = await submitReviewRepo.getReviewList(
      bookingId: bookingId,
    );

    if (response.statusCode == 200) {
      if (response.body['content'] != null &&
          response.body['content'].isNotEmpty) {
        List<dynamic> list = response.body['content'];
        _serviceReviewList = [];

        // Clear old controllers to prevent memory leaks
        for (var controller in textControllers.values) {
          controller.dispose();
        }
        textControllers.clear();
        selectedRating.clear();
        isEditable.clear();
        reviewComments.clear();

        for (var element in list) {
          _serviceReviewList!.add(Service.fromJson(element));
        }

        _serviceReviewList?.forEach((element) {
          // SAFETY CHECK: Skip if id is null
          if (element.id == null) return;

          String serviceId = element.id!;
          textControllers[serviceId] = TextEditingController();

          if (element.review != null && element.review!.isNotEmpty) {
            selectedRating[serviceId] = element.review!.first.reviewRating ?? 5;
            isEditable[serviceId] = false; // Has review = not editable
            reviewComments[serviceId] =
                element.review!.first.reviewComment ?? "";
            textControllers[serviceId]!.text =
                element.review!.first.reviewComment ?? "";
          } else {
            selectedRating[serviceId] = 5;
            isEditable[serviceId] = true; // No review = editable
            reviewComments[serviceId] = "";
            textControllers[serviceId]!.text = "";
          }
        });
      } else {
        _serviceReviewList = [];
      }
    }

    _loading = false;
    update();
  }

  void updateEditableValue(
    String serviceId,
    bool value, {
    bool isUpdate = false,
  }) {
    isEditable[serviceId] = value;
    if (isUpdate) {
      update();
    }
  }
}
