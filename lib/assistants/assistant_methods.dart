import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/direction_details_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:drivers_app/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async{
   String humanReadableAddress = "";

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Error Occurred. Try Again"){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLongitude = position.latitude;
      userPickupAddress.locationLongitude= position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickupLocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }


  static void readCurrentOnlineUserInfo() async{
    currentFirebaseUser  = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);

  userRef.once().then((snap){
    if(snap.snapshot.value != null) {
      userModelCurrentInfo =  UserModel.fromSnapshot(snap.snapshot);
    }
    });
  }
  

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{

    //String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?destination=${destinationPosition.latitude},${destinationPosition.longitude}&origin=${originPosition.latitude},${originPosition.longitude}&key=$mapKey";

    //https://maps.googleapis.com/maps/api/directions/json
    //   ?destination=${destinationPosition.latitude},${destinationPosition.longitude}
    //   &origin=${originPosition.latitude},${originPosition.longitude}
    //   &key=$mapKey

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred. Try Again"){
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    //directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.e_points = responseDirectionApi['routes'][0]['steps'][0]['polyline']['points'];

    directionDetailsInfo.distance_text = responseDirectionApi['routes'][0]['legs'][0]['distance']['text'];
    directionDetailsInfo.distance_value = responseDirectionApi['routes'][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }


}