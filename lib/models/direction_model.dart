class DirectionModel {
  int? distanceValue;
  int? durationValue;
  double? price;
  double? northEastLat, northEastLng;
  double? southWestLat, southWestLng;
  String? distanceText, durationText, startLocationAddress, endLocationAddress;

  String? polyLines;
  DirectionModel({
    this.distanceValue,
    this.durationValue,
    this.price,
    this.northEastLat,
    this.northEastLng,
    this.southWestLat,
    this.southWestLng,
    this.distanceText,
    this.durationText,
    this.startLocationAddress,
    this.endLocationAddress,
    this.polyLines,
  });
}
