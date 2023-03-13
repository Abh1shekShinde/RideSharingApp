import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../global/global.dart';


class SelectNearestActiveDriversScreen extends StatefulWidget {

  DatabaseReference? referenceRideRequest;

  SelectNearestActiveDriversScreen({this.referenceRideRequest});

  @override
  _SelectNearestActiveDriversScreenState createState() => _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState extends State<SelectNearestActiveDriversScreen> {

  String fareAmount = "";
  getFareAmountAccordingToVehicleType(int index)
  {
    if(tripDirectionDetailsInfo != null){
      if(dList[index]["vehicle_details"]["vehicleType"].toString() == "Car"){
        // fareAmount =  (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 1.5).toStringAsFixed(1);

      }

      if(dList[index]["vehicle_details"]["vehicleType"].toString() == "Bike"){
        // fareAmount =  (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString()
      }

      if(dList[index]["vehicle_details"]["vehicleType"].toString() == "Scooter"){
        // fareAmount =  (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)/1.3).toStringAsFixed(1)
      }
    }
    return fareAmount;
  }

  @override
  void dispose (){
    //to dispose duplicate drivers in search nearest drivers list
    super.dispose();
    dList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F9FD),
      appBar: AppBar(
        backgroundColor: Color(0xFF7F669D),
        title: const Text(
          "Nearest Online Drivers",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
          ),
          onPressed: (){
            //Cancel the drivers info page
            //delete/remove the ride request from the database.
            Navigator.pop(context);
            widget.referenceRideRequest!.remove();
            Fluttertoast.showToast(msg: "You Have cancelled the ride request");

            //SystemNavigator.pop();
          },
        ),
      ),

      body: ListView.builder(
        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index){
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            color: Color(0xFFC6EBC5),
            elevation: 5,
            shadowColor: Colors.red,
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading:  Padding(
                padding: const EdgeInsets.all(2),
                child: Image.asset(
                  "images/" + dList[index]["vehicle_details"]["vehicleType"].toString() + ".jpg",
                  width: 70,
                ),
              ),
              // visualDensity: VisualDensity(vertical: 1, horizontal: 2),

              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Display the driver Name
                  Text(
                    dList[index]["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    )
                  ),

                  //Display the vehicle model
                  Text(
                    dList[index]["vehicle_details"]["vehicleModel"],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),

                  //Display Driver's Ratings
                  SmoothStarRating(
                    rating: 4,
                    color: Colors.amber,
                    borderColor: Colors.black,
                    allowHalfRating: true,
                    starCount: 5,
                    size: 15,
                  )
                ],
              ),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(
                    "₹ 20",
                   //"₹ " + getFareAmountAccordingToVehicleType(index),
                    // AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!).toString(),

                    style:const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2 ,),

                  Text(
                    "15 min",
                    // tripDirectionDetailsInfo !=null ? tripDirectionDetailsInfo!.duration_text! : " ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 2 ,),

                  Text(
                    "4 km",
                    // tripDirectionDetailsInfo !=null ? tripDirectionDetailsInfo!.distance_text! : " ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

            ),

          );
        },
      ),
    );
  }
}
