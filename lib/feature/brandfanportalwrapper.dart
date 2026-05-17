import 'package:get/get.dart';
import 'package:afriendorse/helper/get_di.dart' as brand_di;

class BrandFanBinding extends Bindings {
  @override
  void dependencies() async {
    // Initialize Brand/Fan dependencies
    await brand_di.init();
  }
}
