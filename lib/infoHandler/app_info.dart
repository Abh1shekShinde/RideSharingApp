import 'package:drivers_app/models/trips_history_model.dart';
import 'package:flutter/cupertino.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickupLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];


  void updatePickupLocationAddress(Directions userPickUpAddress){
    userPickupLocation =  userPickUpAddress;
    notifyListeners();

  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(overAllTripsCounter){
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripKeysList){
    historyTripKeysList = tripKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }

}