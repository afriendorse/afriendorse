import 'package:afriendorse/api/local/cache_response.dart';
import 'package:afriendorse/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/home/model/campaign_model.dart';

class CampaignController extends GetxController implements GetxService {
  final CampaignRepo campaignRepo;
  CampaignController({required this.campaignRepo});

  List<CampaignData>? _campaignList;
  List<Service>? _itemCampaignList;
  int? _currentIndex = 0;
  bool? _isLoading = false;

  List<CampaignData>? get campaignList => _campaignList;
  List<Service>? get itemCampaignList => _itemCampaignList;
  int? get currentIndex => _currentIndex;
  bool? get isLoading => _isLoading;

  Future<void> getCampaignList(bool reload) async {
    if (_campaignList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => campaignRepo.getCampaignList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            campaignRepo.getCampaignList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          // 🔴 FIX: Added type checking to prevent 'String is not a subtype of int'
          if (data != null && data is Map<String, dynamic>) {
            if (data.containsKey('content') &&
                data['content'] != null &&
                data['content']['data'] is List) {
              _campaignList = [];
              data['content']['data'].forEach((campaign) {
                _campaignList!.add(CampaignData.fromJson(campaign));
              });
              update();
            }
          } else {
            printLog("====> Invalid campaign data format received: $data");
          }
        },
      );
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> navigateFromCampaign(
    String campaignID,
    String discountType,
  ) async {
    printLog("discountType:$discountType");
    _isLoading = true;
    update();
    if (discountType == 'category') {
      Get.find<CategoryController>().getCampaignBasedCategoryList(
        campaignID,
        false,
      );
    } else if (discountType == 'mixed') {
      Get.find<ServiceController>().getMixedCampaignList(campaignID, false);
    } else {
      Get.find<ServiceController>().getCampaignBasedServiceList(
        campaignID,
        true,
      );
    }
    _isLoading = false;
    update();
  }
}
