import 'package:drivers_app/mainScreens/trip_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({Key? key}) : super(key: key);


  @override
  _EarningsTabPageState createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
   @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [

          //here we display the total earnings.
          Container(
            color: const Color(0x80FFEB3B),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              children: [
                const Text(
                  "Total Money Earned",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 20,),

                 Text(
                  "₹ ${Provider.of<AppInfo>(context, listen: false).driverTotalEarnings}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),


              ],
            ),
          ),

          //button to display total trips
          ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));

              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent
            ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                        "images/movingCarIcon.png",
                      width: 70,
                    ),

                    const SizedBox(width: 20,),

                    const Text(
                      "Total Rides Shared",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),

                    Expanded(
                      child: Container(
                        child: Text(
                          Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }
}
