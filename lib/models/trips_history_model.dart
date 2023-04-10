import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? vehicle_details;
  String? driverName;
  String? userName;
  String? userPhone;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.vehicle_details,
    this.driverName,
    this.userName,
    this.userPhone,
});

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot){
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    vehicle_details = (dataSnapshot.value as Map)["vehicle_details"];
    driverName = (dataSnapshot.value as Map)["driverName"];
    userName = (dataSnapshot.value as Map)["userName"];
    userPhone = (dataSnapshot.value as Map)["userPhone"];
  }


}