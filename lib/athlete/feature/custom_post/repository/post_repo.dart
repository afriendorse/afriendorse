import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class PostRepo {
  final ApiClient apiClient;
  PostRepo({required this.apiClient});

  Future<Response> getCustomerPostList(int offset, String status) async {
    return await apiClient.getData(
      "${AppConstants.getCustomerPostList}?status=$status&offset=$offset&limit=${Get.find<SplashController>().configModel.content!.paginationLimit}",
    );
  }

  Future<Response> bidCustomPost(Map<String, String> body) async {
    return await apiClient.postData(AppConstants.bidCustomerPost, body);
  }

  Future<Response> rejectCustomerPost(String postId) async {
    return await apiClient.postData(AppConstants.declineCustomerPost, {
      "post_id": postId,
    });
  }

  Future<Response> withdrawBidRequest(String postId) async {
    return await apiClient.postData(AppConstants.withdrawBidRequest, {
      "post_id": postId,
    });
  }

  Future<Response> getProviderOfferList(int offset, String postId) async {
    return await apiClient.getData(
      "${AppConstants.getProviderOfferList}?post_id=$postId&limit=30&offset=$offset",
    );
  }

  Future<Response> getPostDetails(String postId) async {
    return await apiClient.getData("${AppConstants.getPostDetails}/$postId");
  }
}
