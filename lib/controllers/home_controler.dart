// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loction_taxi/helper/map_request.dart';

import 'package:google_maps_webservice/src/places.dart';
import 'package:loction_taxi/models/address_model.dart';
import 'package:loction_taxi/models/direction_model.dart';
import 'package:loction_taxi/models/dropoff_address_model.dart';
import 'package:loction_taxi/models/user_model.dart';
import 'package:loction_taxi/util/const.dart';

class HomeController extends GetxController {
  final GetUserLocationCurrent getUserLocationCurrent;
  final PickUpAddress _pickUpAddress = PickUpAddress();
  final DropOffAddress _dropOffAddress = DropOffAddress();
  get pickUpAddress => _pickUpAddress;
  get dropOffAddress => _dropOffAddress;

  var searchController = TextEditingController().obs;
  HomeController({required this.getUserLocationCurrent});
  final Placemark _placeMark = Placemark();
  Placemark get pickPlaceMark => _placeMark;
  List<Prediction> _predictionList = [];
  DirectionModel directionModel = DirectionModel();

  var placeAddress = 'home'.obs;

  late String? st1, st2, st3, st4;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<String> getLocation(Position? position) async {
    Response response =
        await getUserLocationCurrent.currentClientLocation(position);

    if (response.statusCode == 200) {
      var jsonData = response.bodyString;
      var decodedJson = await jsonDecode(jsonData.toString());
      // placeAddress.value = decodedJson["results"][0]["formatted_address"];
      st1 = decodedJson["results"][0]["address_components"][1]['short_name'];
      st2 = decodedJson["results"][0]["address_components"][2]['short_name'];

      st3 = decodedJson["results"][0]["address_components"][3]['short_name'];

      // st4 = decodedJson["results"][0]["address_components"][6]['long_name'];
      placeAddress.value = " $st1, $st2, $st3";

      // print('This is our response: $lat & $lng  address');

      _pickUpAddress.placeName = placeAddress.value;
      _pickUpAddress.placeId = decodedJson["results"][0]["place_id"];
      _pickUpAddress.lat =
          decodedJson["results"][0]["geometry"]["location"]["lat"];
      _pickUpAddress.lng =
          decodedJson["results"][0]["geometry"]["location"]["lng"];
      print("""
          Address name :${pickUpAddress.placeName}
          Address place id :${pickUpAddress.placeId}
          Address lat :${pickUpAddress.lat}
          Address lng :${pickUpAddress.lng}
        """);
    }
    return placeAddress.toString();
  }

  Future<List<Prediction>> searchLocation(
      BuildContext context, String text) async {
    if (text != null && text.isNotEmpty) {
      Response response = await getUserLocationCurrent.getPredictionsRepo(text);
      var jsonData = response.bodyString;
      var data = await jsonDecode(jsonData.toString());
      print("my status is " + data["status"]);
      if (data['status'] == 'OK') {
        _predictionList = [];
        data['predictions'].forEach((prediction) =>
            _predictionList.add(Prediction.fromJson(prediction)));
      } else {}
    }
    return _predictionList;
  }

  Future<DropOffAddress> placeCodinates(String placeId) async {
    Response response =
        await getUserLocationCurrent.getPlacesCodinates(placeId);
    if (response.statusCode == 200) {
      var data = response.bodyString;
      var jsonData = await jsonDecode(data.toString());

      _dropOffAddress.placeName = jsonData["result"]["name"];
      _dropOffAddress.placeId = jsonData["result"]["place_id"];
      _dropOffAddress.lat = jsonData["result"]["geometry"]["location"]["lat"];
      _dropOffAddress.lng = jsonData["result"]["geometry"]["location"]["lng"];
      print("""
          Address dropoff name :${dropOffAddress.placeName}
          Address dropoff place id :${dropOffAddress.placeId}
          Address dropoff lat :${dropOffAddress.lat}
          Address dropoff lng :${dropOffAddress.lng}
        """);
    }

    return _dropOffAddress;
  }

  Future<DirectionModel?> placeDirections(LatLng pickUp, LatLng dropOff) async {
    Response response =
        await getUserLocationCurrent.getDirections(pickUp, dropOff);

    if (response.statusCode == 200) {
      var data = response.bodyString;
      var jsonData = await jsonDecode(data.toString());

      print("Direction api response : $jsonData");

      directionModel.polyLines =
          jsonData["routes"][0]["overview_polyline"]["points"];
      directionModel.northEastLat =
          jsonData["routes"][0]["bounds"]["northeast"]["lat"];
      directionModel.northEastLng =
          jsonData["routes"][0]["bounds"]["northeast"]["lng"];
      directionModel.southWestLat =
          jsonData["routes"][0]["bounds"]["southwest"]["lat"];
      directionModel.southWestLng =
          jsonData["routes"][0]["bounds"]["southwest"]["lng"];
      directionModel.distanceText =
          jsonData["routes"][0]["legs"][0]["distance"]["text"];
      directionModel.distanceValue =
          jsonData["routes"][0]["legs"][0]["distance"]["value"];
      directionModel.durationText =
          jsonData["routes"][0]["legs"][0]["duration"]["text"];
      directionModel.durationValue =
          jsonData["routes"][0]["legs"][0]["duration"]["value"];
      directionModel.startLocationAddress =
          jsonData["routes"][0]["legs"][0]["start_address"];
      directionModel.endLocationAddress =
          jsonData["routes"][0]["legs"][0]["end_address"];
      directionModel.distanceText =
          jsonData["routes"][0]["legs"][0]["distance"]["text"];
      directionModel.distanceValue =
          jsonData["routes"][0]["legs"][0]["distance"]["value"];
      directionModel.durationText =
          jsonData["routes"][0]["legs"][0]["duration"]["text"];
      directionModel.durationValue =
          jsonData["routes"][0]["legs"][0]["duration"]["value"];
      double rideFare = calcuateRideFare(directionModel);
      directionModel.price = rideFare;

      print("my polly: ${directionModel.polyLines}");
      return directionModel;
    } else {
      return null;
    }
  }

  static double calcuateRideFare(DirectionModel directionModel) {
    double timeTraveledFare = (directionModel.durationValue! / 60) * 0.30;
    double distanceTraveledFare = (directionModel.distanceValue! / 1000) * 0.30;

    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    //convert to rands
    double convertedAmount = totalFareAmount * 17.69;

    return convertedAmount.truncateToDouble();
  }

  void getCurrentUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    String userId = currentUser!.uid;
    // DatabaseReference reference =
    //     FirebaseDatabase.instance.ref().child("User Request").child(userId);

    // reference.once().then((DatabaseEvent databaseEvent) {
    //   if (databaseEvent.snapshot.value != null) {
    //     final data = databaseEvent.snapshot as Map<String, dynamic>;
    //     userCurrentInfo = RideUserInfo.fromSnapShot(data);
    //   }
    // });

    DocumentReference docRef =
        FirebaseFirestore.instance.collection("User Request").doc(userId);

    docRef.get().then((DocumentSnapshot ref) {
      if (ref.data() != null) {
        final data = ref.data() as Map<String, dynamic>;
        userCurrentInfo = RideUserInfo.fromDocRef(data);
      }
    });
  }
}
