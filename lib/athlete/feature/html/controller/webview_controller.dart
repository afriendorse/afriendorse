import 'package:afriendorse/athlete/api/api_checker.dart';
import 'package:afriendorse/athlete/feature/html/model/pages_details_model.dart';
import 'package:afriendorse/athlete/feature/html/repository/html_repo.dart';
import 'package:get/get.dart';

class HtmlViewController extends GetxController implements GetxService {
  final HtmlRepository htmlRepository;
  HtmlViewController({required this.htmlRepository});

  PageDetailsModel? _pageDetailsModel;
  PageDetailsModel? get pageDetailsModel => _pageDetailsModel;

  Future<void> getPagesContent(String pageKey) async {
    _pageDetailsModel = null;
    Response response = await htmlRepository.getPagesContent(pageKey);
    if (response.statusCode == 200) {
      _pageDetailsModel = PageDetailsModel.fromJson(response.body['content']);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
