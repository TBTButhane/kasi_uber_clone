import 'package:get/get.dart';
import 'package:loction_taxi/controllers/home_controler.dart';
import 'package:loction_taxi/helper/http_request.dart';
import 'package:loction_taxi/helper/map_request.dart';

Future<void> init() async {
  Get.lazyPut(() => ApiClient(baseUri: 'https://maps.googleapis.com'));

  Get.lazyPut(() => GetUserLocationCurrent(apiClient: Get.find()));

  Get.lazyPut(() => HomeController(getUserLocationCurrent: Get.find()));
}
