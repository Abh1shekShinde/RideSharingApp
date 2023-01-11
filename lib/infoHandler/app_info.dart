import 'package:flutter/cupertino.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickupLocation, userDropOffLocation;

  void updatePickupLocationAddress(Directions userPickUpAddress){
    userPickupLocation =  userPickUpAddress;
    notifyListeners();

  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();

  }

}