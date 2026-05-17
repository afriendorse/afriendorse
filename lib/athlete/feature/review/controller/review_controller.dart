import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ReviewController extends GetxController implements GetxService {
  final ReviewRepo reviewRepo;
  ReviewController({required this.reviewRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Review>? _providerReviewList;
  List<Review>? get providerReviewList => _providerReviewList;

  Rating? _providerRating;
  Rating? get providerRating => _providerRating;

  List<Review>? _serviceReviewList = [];
  List<Review>? get serviceReviewList => _serviceReviewList!;

  Rating? _serviceRating;
  Rating? get serviceRating => _serviceRating;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          getProviderReview(offset + 1, isLoading: true);
        }
      }
    });
  }

  Future<void> getProviderReview(int offset, {bool isLoading = false}) async {
    _offset = offset;
    if (isLoading) {
      _isLoading = true;
      update();
    }
    Response response = await reviewRepo.getProviderReviewList(offset);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _pageSize = response.body['content']['reviews']['last_page'];
      if (offset == 1) {
        _providerReviewList = [];
        _providerRating == null;
      }
      response.body['content']['reviews']['data'].forEach((review) {
        _providerReviewList!.add(Review.fromJson(review));
      });
      _providerRating = Rating.fromJson(response.body['content']['rating']);
    } else {
      _providerReviewList = [];
      _providerRating = null;
    }
    _isLoading = false;
    update();
  }

  Future<void> getServiceReview(String serviceID) async {
    _serviceReviewList = [];
    _serviceRating = null;
    Response response = await reviewRepo.getServiceReviewList(serviceID, 1);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      try {
        response.body['content']['reviews']['data'].forEach((review) {
          _serviceReviewList!.add(Review.fromJson(review));
        });
      } catch (error) {
        if (kDebugMode) {
          print('error : $error');
        }
      }
      try {
        _serviceRating = Rating.fromJson(response.body['content']['rating']);
      } catch (error) {
        if (kDebugMode) {
          print('rating get error : $error');
        }
      }
    } else {
      //ApiChecker.checkApi(response);
    }
  }

  Future<ResponseModel> replyReview({
    required String reviewId,
    required String reviewContent,
    String? fromPage,
    String? serviceId,
  }) async {
    _isLoading = true;
    update();
    Response response = await reviewRepo.replyReview(
      reviewId: reviewId,
      reviewContent: reviewContent,
    );
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (fromPage == "service" && serviceId != null) {
        await getServiceReview(serviceId);
      } else {
        await getProviderReview(1);
      }
      responseModel = ResponseModel(true, "success");
    } else {
      responseModel = ResponseModel(
        false,
        response.body['message'] ?? "failed",
      );
    }
    _isLoading = false;
    update();

    return responseModel;
  }
}
