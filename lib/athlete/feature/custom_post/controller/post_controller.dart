import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/provider_offer.dart';
import 'package:afriendorse/athlete/feature/custom_post/widget/notification_dialog.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class PostController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final PostRepo postRepo;
  PostController({required this.postRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _loading = false;
  bool get loading => _loading;

  List<PostData>? postList;
  List<PostData>? bidPostList;

  PostData? postDetails;

  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  List<ProviderOfferData> _providerOfferList = [];
  List<ProviderOfferData> get providerOfferList => _providerOfferList;

  final ScrollController scrollController = ScrollController();

  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController providerNoteController = TextEditingController();

  final FocusNode offerPriceNode = FocusNode();
  final FocusNode providerNoteNode = FocusNode();

  bool _showInfoWidget = false;
  bool get showInfoWidget => _showInfoWidget;

  bool _showNoteInfoWidget = false;
  bool get showNoteInfoWidget => _showNoteInfoWidget;

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(vsync: this, length: 2);

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          if (tabController!.index == 0) {
            getCustomerPostList(
              offset + 1,
              "new_request",
              reload: true,
              fromBid: false,
            );
          } else {
            getCustomerPostList(
              offset + 1,
              "placed_offer",
              reload: true,
              fromBid: true,
            );
          }
        }
      }
    });
  }

  Future<void> getCustomerPostList(
    int offset,
    String status, {
    bool reload = false,
    bool shouldUpdate = true,
    bool fromBid = false,
  }) async {
    _offset = offset;
    if (reload) {
      _isLoading = true;
    } else {
      _loading = true;
    }
    if (shouldUpdate) {
      update();
    }

    Response response = await postRepo.getCustomerPostList(offset, status);
    if (response.statusCode == 200) {
      _postModel = PostModel.fromJson(response.body);
      _pageSize = _postModel!.content!.lastPage;

      if (_postModel?.content != null) {
        if (offset == 1) {
          if (fromBid) {
            bidPostList = [];
            bidPostList!.addAll(_postModel!.content!.data!);
          } else {
            postList = [];
            postList!.addAll(_postModel!.content!.data!);
          }
        } else {
          if (fromBid) {
            bidPostList!.addAll(_postModel!.content!.data!);
          } else {
            postList!.addAll(_postModel!.content!.data!);
          }
        }
      }
    } else {
      postList = [];
      bidPostList = [];
    }

    _loading = false;
    _isLoading = false;
    update();
  }

  Future<void> bidCustomBooking({
    String? postId,
    String? offerPrice,
    String? note,
    bool? fromNotification,
    bool? fromDashboard,
  }) async {
    _isLoading = true;
    update();
    Response response = await postRepo.bidCustomPost({
      "post_id": postId!,
      "offered_price": offerPrice!,
      "provider_note": note!,
    });

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_store_200") {
      // Preload the bids data before navigating
      await getCustomerPostList(1, "placed_offer", reload: true, fromBid: true);

      // Navigate to BookingRequestScreen with index 0 (pending/bids tab)
      Get.offAll(
        () => const BottomNavScreen(
          pageIndex: 1, // 1 = BookingRequestScreen/requests tab
          formTutorial: false,
        ),
      );

      showCustomSnackBar(
        "your_request_submitted_successfully".tr,
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar("failed_to_submit_request".tr);
    }

    _isLoading = false;
    update();
  }

  Future<void> getProviderOfferList(
    int offset,
    String postId, {
    bool reload = false,
  }) async {
    _offset = offset;

    if (reload) {
      _providerOfferList = [];
      _isLoading = true;
    }
    Response response = await postRepo.getProviderOfferList(offset, postId);
    if (response.statusCode == 200) {
      _pageSize = response.body['content']['last_page'];
      List<dynamic> list = response.body['content']['data'];
      for (var element in list) {
        providerOfferList.add(ProviderOfferData.fromJson(element));
      }
    } else {}
    _isLoading = false;
    update();
  }

  Future<void> rejectCustomerPost(String postId) async {
    Response response = await postRepo.rejectCustomerPost(postId);
    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_200") {
      await getCustomerPostList(
        1,
        "new_request",
        shouldUpdate: false,
        fromBid: false,
      );
    } else {}
  }

  Future<void> withdrawBidRequest(String postId) async {
    Response response = await postRepo.withdrawBidRequest(postId);
    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_delete_200") {
      await getCustomerPostList(
        1,
        "placed_offer",
        shouldUpdate: false,
        fromBid: true,
      );
      Get.back();
      showCustomSnackBar(
        response.body['message'],
        type: ToasterMessageType.success,
      );
    } else {
      Get.back();
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getPostDetailsForNotification(String postId) async {
    Response response = await postRepo.getPostDetails(postId);
    if (response.statusCode == 200) {
      if (response.body['content'] != null) {
        postDetails = PostData.fromJson(response.body['content']);

        showGeneralDialog(
          context: Get.context!,
          barrierDismissible: true,
          transitionDuration: const Duration(milliseconds: 500),
          barrierLabel: MaterialLocalizations.of(Get.context!).dialogLabel,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          pageBuilder: (context, _, __) {
            return NotificationDialog(postData: postDetails);
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ).drive(
                    Tween<Offset>(
                      begin: const Offset(0, -1.0),
                      end: Offset.zero,
                    ),
                  ),
              child: child,
            );
          },
        );
      } else {
        postDetails = null;
      }
    } else {
      postDetails = null;
    }
    update();
  }

  void changeVisibilityInfoWidgetStatus() {
    _showInfoWidget = !_showInfoWidget;
    _showNoteInfoWidget = false;
    update();
  }

  void changeNoteWidgetStatus() {
    _showNoteInfoWidget = !_showNoteInfoWidget;
    _showInfoWidget = false;
    update();
  }

  void setTabControllerIndex({int index = 0}) {
    tabController!.index = index;
  }

  void resetInputValue() {
    offerPriceController.clear();
    providerNoteController.clear();
    _showInfoWidget = false;
  }

  void hideInfoIcon() {
    _showNoteInfoWidget = false;
    _showInfoWidget = false;
    update();
  }
}
