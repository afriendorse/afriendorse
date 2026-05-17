import 'package:afriendorse/common/models/api_response_model.dart';
import 'package:afriendorse/common/repo/data_sync_repo.dart';
import 'package:afriendorse/util/core_export.dart';

class CampaignRepo extends DataSyncRepo {
  CampaignRepo({
    required super.apiClient,
    required SharedPreferences super.sharedPreferences,
  });

  Future<ApiResponseModel<T>> getCampaignList<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.campaignUri, source);
  }
}
