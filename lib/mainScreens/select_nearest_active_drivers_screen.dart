import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../global/global.dart';


class SelectNearestActiveDriversScreen extends StatefulWidget {
  const SelectNearestActiveDriversScreen({Key? key}) : super(key: key);

  @override
  _SelectNearestActiveDriversScreenState createState() => _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState extends State<SelectNearestActiveDriversScreen> {
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
                    "20",
                    // AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!).toString(),
                    style:const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2 ,),

                  Text(
                    "15 km",
                    // tripDirectionDetailsInfo !=null ? tripDirectionDetailsInfo!.duration_text! : " ",
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
