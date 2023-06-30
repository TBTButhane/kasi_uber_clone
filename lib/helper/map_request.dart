import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loction_taxi/helper/http_request.dart';
import 'package:loction_taxi/util/const.dart';

class GetUserLocationCurrent extends GetxService {
  final ApiClient apiClient;

  GetUserLocationCurrent({required this.apiClient});

  Future<Response> currentClientLocation(Position? position) async {
    return await apiClient.getData(
        '/maps/api/geocode/json?latlng=${position!.latitude},${position.longitude}&key=$mkey');
  }

  Future<Response> getPredictionsRepo(String? placeName) async {
    return await apiClient.getData(
        '/maps/api/place/autocomplete/json?input=$placeName&key=$mkey&sessiontoken=1234567890&components=country:ZA');
  }

  Future<Response> getPlacesCodinates(String? placeId) async {
    return await apiClient
        .getData('/maps/api/place/details/json?place_id=$placeId&key=$mkey');
  }

  Future<Response> getDirections(LatLng pickUp, LatLng dropOff) async {
    return await apiClient.getData(
        '/maps/api/directions/json?destination=${dropOff.latitude},${dropOff.longitude}&origin=${pickUp.latitude},${pickUp.longitude}&key=$mkey');
  }
}

// class MapRequests {
//   static Future<String> gettingUserCurrentocation(Position? position) async {
//     String placeAddress = '';

//     Uri url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position!.latitude},${position.longitude}&key=$mkey');

//     var response = await HttpRequest.getRequests(url);

//     if (response != 'failed') {
//       placeAddress = response["results"][0]["formatted_address"];
//     }

//     return placeAddress;
//   }
// }
