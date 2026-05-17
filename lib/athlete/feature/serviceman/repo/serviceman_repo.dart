import 'package:get/get.dart';
import '../../../utils/core_export.dart';

class ServicemanRepo{
  final ApiClient apiClient;

  ServicemanRepo({required this.apiClient});

  Future<Response> getAllServicemanData(int offset,String status) async {
    return await apiClient.getData("${AppConstants.servicemanListUri}?limit=10&offset=$offset&status=$status");
  }

  Future<Response> getServicemanDetails(String id) async {
    return await apiClient.getData("${AppConstants.servicemanDetailsUri}/$id");
  }
  Future<Response> assignServiceman({String? bookingId, String? subBookingId ,String? servicemanId}) async {

    if (kDebugMode) {
      print("Booking Type : ${subBookingId!=null ? "Sub-Booking": "Regular-Booking"}");
    }
    return await apiClient.postData("${AppConstants.servicemanAssignUri}/${bookingId ?? subBookingId}",
        {
          "booking_type": subBookingId != null ? "repeat" : "regular",
          'serviceman_id': servicemanId,
          '_method':'put',
        },
    );
  }

  Future<Response> changeServicemanStatus(String servicemanId) async {
    return await apiClient.putData("${AppConstants.servicemanUpdateStatus}?serviceman_id[]=$servicemanId",{});
  }


  Future<Response> getSingleServicemanData(String id) async {
    return await apiClient.getData("${AppConstants.servicemanListUri}/$id");
  }

  Future<Response> deleteServiceman(String id) async {
    return await apiClient.deleteData("${AppConstants.servicemanDeleteUri}?serviceman_id[]=$id");
  }

  Future<Response?> addNewServiceman(ServicemanBody servicemanBody,XFile? profileImage, List<MultipartBody> identityImage) async {
    Map<String, String> body = {};
    body.addAll(<String, String>{
      'first_name': servicemanBody.firstName!,
      'last_name': servicemanBody.lastName!,
      'email': servicemanBody.email!,
      'phone': servicemanBody.phone!,
      'password': servicemanBody.password!,
      'confirm_password': servicemanBody.confirmedPassword!,
      'identity_type': servicemanBody.identityType!,
      'identity_number': servicemanBody.identityNumber!,


    });

    ///add multipart image here
    return await apiClient.postMultipartData(AppConstants.addNewServicemanUri, body,
     identityImage, profileImage!=null?MultipartBody('profile_image',profileImage):null,);
  }


  Future<Response?> editServicemanInfoWithPassword(ServicemanBody servicemanBody,XFile? profileImage, XFile? identityImage,String servicemanId) async {
    Map<String, String> body = {};
    body.addAll(<String, String>{
      'first_name': servicemanBody.firstName!,
      'last_name': servicemanBody.lastName!,
      'email': servicemanBody.email!,
      'phone': servicemanBody.phone!,
      'password': servicemanBody.password!,
      'confirm_password': servicemanBody.confirmedPassword!,
      'identity_type': servicemanBody.identityType!,
      'identity_number': servicemanBody.identityNumber!,
      "_method":"put"
    });
    return await apiClient.postMultipartData("${AppConstants.addNewServicemanUri}/$servicemanId", body,
      identityImage!=null?[MultipartBody('identity_image[]',identityImage)]:null, profileImage!=null?MultipartBody('profile_image',profileImage):null,);
  }
  Future<Response?> editServicemanInfoWithoutPassword(ServicemanBody servicemanBody,XFile? profileImage, List<MultipartBody> identityImage,String servicemanId) async {
    Map<String, String> body = {};
    body.addAll(<String, String>{
      'first_name': servicemanBody.firstName!,
      'last_name': servicemanBody.lastName!,
      'email': servicemanBody.email!,
      'phone': servicemanBody.phone!,
      'identity_type': servicemanBody.identityType!,
      'identity_number': servicemanBody.identityNumber!,
      "_method":"put"
    });
    return await apiClient.postMultipartData("${AppConstants.addNewServicemanUri}/$servicemanId", body,
      identityImage, profileImage!=null?MultipartBody('profile_image',profileImage):null,);
  }



}