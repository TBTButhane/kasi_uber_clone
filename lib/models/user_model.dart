class RideUserInfo {
  String? id, userName, userEmail;
  String? userNumber;

  RideUserInfo({this.id, this.userName, this.userEmail, this.userNumber});

  // factory RideUserInfo.fromSnapShot(Map<dynamic, dynamic> data) {
  //   return RideUserInfo(
  //   id : data['id'],
  //   userName : data['userName'],
  //   userEmail : data['userEmail'],
  //   userNumber : data['userNumber']
  //   );
  // }

  // RideUserInfo.fromSnapShot(DocumentSnapshot<Map<dynamic,dynamic>> doc) {
  //   id = doc.data()![''];
  // }

  factory RideUserInfo.fromDocRef(Map<String, dynamic> data) {
    return RideUserInfo(
        id: data['id'],
        userName: data['name'],
        userEmail: data['email'],
        userNumber: data['phoneNumber']);
  }
}
