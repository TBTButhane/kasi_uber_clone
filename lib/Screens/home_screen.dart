// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_init_to_null

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loction_taxi/Screens/register.dart';
import 'package:loction_taxi/controllers/home_controler.dart';
import 'package:loction_taxi/models/direction_model.dart';
import 'package:loction_taxi/models/user_model.dart';
import 'package:loction_taxi/util/const.dart';
import 'package:loction_taxi/widgets/animated_container.dart';
import 'package:location/location.dart' as lokshin;
import 'package:loction_taxi/widgets/pay_with_btn.dart';
import 'package:loction_taxi/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylineSet = {};
  FirebaseAuth fAuth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Set<Marker> markerSet = {};
  int? _selectedPaymentMethod;
  DirectionModel _directionModel = DirectionModel();

  late GoogleMapController googleMapController;
  double mapBottomPadding = 0;
  HomeController homeController = Get.find();

  late Position currentUserlocation;
  var currentocation = null;
  var geolocation = Geolocator();
  bool stateChange = false;
  bool? stateRequestChange;
  int? selectedRideChoice;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    final data = await fireStore
        .collection("Users")
        .doc(fAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot docSnap) {
      final userData = docSnap.data() as Map<String, dynamic>;

      userCurrentInfo = RideUserInfo.fromDocRef(userData);
    });
  }

  //Get Current User Position
  getUserLocation() async {
    Position currentposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentUserlocation = currentposition;
    currentocation = currentUserlocation;
    LatLng latLngPosition =
        LatLng(currentposition.latitude, currentposition.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String userAddress =
    //     await MapRequests.gettingUserCurrentocation(currentposition);
    String userAddress = await homeController.getLocation(currentposition);
    print("Address : $userAddress");
  }

  CameraPosition initialPosition = CameraPosition(
      // target: LatLng(252359.99, -281660.00),
      target: LatLng(-25.4132, 28.2578),
      zoom: 12);

  Future<bool> _onWillPop() {
    return currentocation ?? false;
  }

  _requestPermission() async {
    var location = lokshin.Location();
    late bool _locationEnabled;
    lokshin.PermissionStatus _permissionGranded;
    lokshin.LocationData _locationData;

    _locationEnabled = await location.serviceEnabled();
    if (!_locationEnabled) {
      _locationEnabled = await location.requestService();
      if (!_locationEnabled) {}
    }

    _permissionGranded = await location.hasPermission();
    if (_permissionGranded == lokshin.PermissionStatus.denied) {
      _permissionGranded = await location.requestPermission();
      if (_permissionGranded != lokshin.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    print("Address from location: $_locationData");
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding, top: 20),
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              myLocationEnabled: true,
              polylines: polylineSet,
              markers: markerSet,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);
                googleMapController = controller;
                await _requestPermission();
                currentocation ??
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: false,
                        builder: (context) => WillPopScope(
                              onWillPop: _onWillPop,
                              child: Dialog(
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(),
                                      Text("Getting User Location")
                                    ],
                                  ),
                                ),
                              ),
                            ));

                await getUserLocation();

                if (currentocation != null) {
                  Future.delayed(Duration(milliseconds: 3000)).whenComplete(() {
                    Navigator.pop(context);

                    setState(() {
                      mapBottomPadding = deviceHeight / 3;
                    });
                  });
                } else {
                  return;
                }
              },
              initialCameraPosition: initialPosition),

          //DfindMe
          Positioned(
              top: 80,
              right: 15,
              child: InkWell(
                onTap: () async {
                  Position currentposition =
                      await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.best);
                  homeController.getLocation(currentposition);
                  await getUserLocation();
                },
                child: Container(
                  height: 35,
                  width: 75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green),
                  child: Center(child: Text('Find Me')),
                ),
              )),

          //Search dropoff
          !stateChange
              ? Positioned(
                  top: 100,
                  right: 10,
                  child: Center(
                    child: Obx(
                      () => CustomeAnimSearchBar(
                          closeSearchOnSuffixTap: true,
                          fun: () {
                            print("Selected address Pressed, ");
                            getplaceDirection();
                          },
                          helpText: "Where to?",
                          color: Colors.green,
                          width: deviceWidth - 20,
                          textController: homeController.searchController.value,
                          rtl: true,
                          onSuffixTap: () {
                            homeController.searchController.value.clear();
                          }),
                    ),
                  ))
              : Positioned(
                  top: 135,
                  right: 10,
                  child: Center(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () async {
                          Position currentposition =
                              await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.best);
                          homeController.getLocation(currentposition);
                          await getUserLocation();
                          setState(() {
                            markerSet.clear();
                            polylineSet.clear();
                            stateChange = false;
                            stateRequestChange = null;
                            fAuth.signOut();
                          });
                          if (fAuth.currentUser == null) {
                            Get.to(() => RegisterScreen());
                          }
                        },
                        child: Container(
                            height: 50,
                            width: 65,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                            child: Icon(Icons.close, size: 30)),
                      ),
                    ),
                  )),

          // homeContainer
          Obx(() => AnimatedContainerWidget(
                dH: !stateChange ? deviceHeight / 3 : 0,
                // dH: 0,
                // state: stateChange,
                homeAddress: homeController.placeAddress.toString() != 'home'
                    ? homeController.placeAddress.string
                    : 'Home',
                workAddress: 'work',
              )),

          //Request Container
          Positioned(
            left: 8,
            right: 8,
            bottom: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              padding: EdgeInsets.only(top: 12, left: 15, right: 8),
              height: stateRequestChange == null
                  ? 0
                  : !stateRequestChange!
                      ? deviceHeight / 2.5
                      : 0,
              decoration: BoxDecoration(
                  color: Colors.black.withGreen(50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Distance: ${_directionModel.distanceText}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Row(
                    children: List<Widget>.generate(
                        3,
                        (index) => Expanded(
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedRideChoice = index;
                                      print(selectedRideChoice);
                                    });
                                  },
                                  child: Container(
                                      margin: index == 0
                                          ? EdgeInsets.only(
                                              right: 5,
                                            )
                                          : index == 1
                                              ? EdgeInsets.only(
                                                  right: 5,
                                                )
                                              : EdgeInsets.only(top: 0),
                                      padding: index == 0
                                          ? EdgeInsets.only(left: 5, right: 5)
                                          : index == 1
                                              ? EdgeInsets.only(
                                                  left: 5, right: 5)
                                              : EdgeInsets.only(
                                                  left: 5, right: 5),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: selectedRideChoice == index
                                            ? Colors.purple
                                            : Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            index == 0
                                                ? "Economy"
                                                : index == 1
                                                    ? "Premium"
                                                    : "Party Bus",
                                            style: TextStyle(
                                                color:
                                                    selectedRideChoice == index
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Expanded(
                                            child: Image(
                                                width: deviceWidth,
                                                fit: BoxFit.cover,
                                                image: AssetImage(index == 0
                                                    ? "assets/images/Economy2.png"
                                                    : index == 1
                                                        ? "assets/images/Premium4.png"
                                                        : "assets/images/PartyBus2.png")),
                                          ),
                                          Text(
                                            index == 0
                                                ? "R ${_directionModel.price}"
                                                : index == 1
                                                    ? "R ${_directionModel.price != null ? (_directionModel.price! + 10) : "5"}"
                                                    : "R ${_directionModel.price != null ? (_directionModel.price! + 17) : "5"}",
                                            style: TextStyle(
                                                color:
                                                    selectedRideChoice == index
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ))),
                            )),
                  ),

                  // ignore: prefer_const_literals_to_create_immutables
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Payment method:",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              2,
                              (index) => InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedPaymentMethod = index;
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              color: _selectedPaymentMethod ==
                                                      index
                                                  ? Colors.purple.shade50
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: PayWithbtn(
                                              btnTextColor: Colors.black,
                                              btntitle:
                                                  index == 0 ? "Cash" : "Bank",
                                            ),
                                          ),
                                        ),
                                        _selectedPaymentMethod == index
                                            ? Positioned(
                                                top: 0,
                                                bottom: 0,
                                                right: 0,
                                                left: 0,
                                                child: Center(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    padding:
                                                        const EdgeInsets.all(7),
                                                    decoration: BoxDecoration(
                                                        color: Colors.purple,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Icon(
                                                      Icons.done,
                                                      size: 25,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ))
                                            : SizedBox()
                                      ],
                                    ),
                                  )),
                        ),
                      ]),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_selectedPaymentMethod == null ||
                          selectedRideChoice == null) {
                        return;
                      }
                      if (_selectedPaymentMethod == 0) {
                        setState(() {
                          stateRequestChange = true;
                        });
                      } else {
                        setState(() {
                          stateRequestChange = true;
                        });
                      }
                    },
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text("Request Ride")),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 5,
                  )
                ],
              ),
            ),
          ),

          //Ride requested container
          Positioned(
              left: 8,
              right: 8,
              bottom: 0,
              child: Container(
                  padding: EdgeInsets.only(top: 12, left: 15, right: 8),
                  height: stateRequestChange == null
                      ? 0
                      : stateRequestChange!
                          ? deviceHeight / 2.5
                          : 0,
                  decoration: BoxDecoration(
                      color: Colors.black.withGreen(50),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Center(
                        child: Text(
                          "Ride Request Send",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        "Ride Requested by: User Name",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "From: ${_directionModel.startLocationAddress}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "To: ${_directionModel.endLocationAddress}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "paying with: " +
                            (_selectedPaymentMethod == 0 ? "Cash" : "Bank"),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10)),
                          child: PayWithbtn(
                            btntitle: "Cancel Ride Request",
                            btnTextColor: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )))
        ],
      ),
    );
  }

  Future<void> getplaceDirection() async {
    var pickUp = homeController.pickUpAddress;
    var dropff = homeController.dropOffAddress;

    LatLng pickUpLatLng = LatLng(pickUp.lat, pickUp.lng);
    LatLng dropOffatLng = LatLng(dropff.lat, dropff.lng);

    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) => Dialog(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Text("Please wait, Creating route...")
                  ],
                ),
              ),
            ));

    var directionDetails =
        await homeController.placeDirections(pickUpLatLng, dropOffatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> polylineResult =
        polylinePoints.decodePolyline(directionDetails!.polyLines.toString());

    polylineCoordinates.clear();
    if (polylineResult.isNotEmpty) {
      polylineResult.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    markerSet.clear();
    setState(() {
      stateChange = true;
      stateRequestChange = false;
      Polyline polyLine = Polyline(
          color: Colors.purple,
          polylineId: PolylineId("polyId"),
          jointType: JointType.round,
          points: polylineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      Marker originMarker = Marker(
          position: pickUpLatLng,
          markerId: MarkerId("origin"),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: directionDetails.startLocationAddress));
      Marker destinationMarker = Marker(
          position: dropOffatLng,
          markerId: MarkerId("destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(90),
          infoWindow: InfoWindow(title: directionDetails.endLocationAddress));

      polylineSet.add(polyLine);
      markerSet.addAll({originMarker, destinationMarker});
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffatLng.latitude &&
        pickUpLatLng.longitude > dropOffatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffatLng.longitude),
          northeast: LatLng(dropOffatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffatLng);
    }
    _directionModel = directionDetails;
    // LatLng southeast = LatLng(directionDetails.southWestLat!.toDouble(),
    //     directionDetails.southWestLng!.toDouble());
    // LatLng northeast = LatLng(directionDetails.northEastLat!.toDouble(),
    //     directionDetails.northEastLng!.toDouble());

    // latLngBounds = LatLngBounds(
    //   southwest: southeast,
    //   northeast: northeast,
    // );

    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 50));
  }
}
