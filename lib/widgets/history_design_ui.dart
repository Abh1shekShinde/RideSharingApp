import 'package:drivers_app/models/trips_history_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDesignUIWidget extends StatefulWidget {

  TripsHistoryModel? tripsHistoryModel;

  HistoryDesignUIWidget({
    this.tripsHistoryModel,
});

  @override
  _HistoryDesignUIWidgetState createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {

  String formatDateAndTime(String dateTimeFromDB){
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

              //Dec 10                            //2022                                      1:12 pm
    String formattedDateTime = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDateTime;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x59D28491),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Driver name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 "Shared by : ${widget.tripsHistoryModel!.driverName!}",
                 style: const TextStyle(
                   color: Color(0xFFb6494d),
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),

               const SizedBox(width: 12,),

               Text(
                 "₹ ${widget.tripsHistoryModel!.fareAmount!}",
                 style: const TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ],
            ),

            const SizedBox(height: 4,),

            //Driver vehicle details
            Row(
              children: [
                Image.asset(
                  "images/carHistoryIcon.png",
                  height: 24,
                  width: 24,
                ),

                const SizedBox(width: 12,),

                Text(
                  widget.tripsHistoryModel!.vehicle_details!,
                  style: const TextStyle(
                    color: Color(0xFF8491D2),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),

            const SizedBox(height: 12,),

            //Pick UP address and icon
            Row(
              children: [
                Image.asset(
                  "images/origin.png",
                  height: 24,
                  width: 24,
                ),

                const SizedBox(width: 12,),

                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.originAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10,),

            //Drop Off address and icon
            Row(
              children: [
                Image.asset(
                  "images/destination.png",
                  height: 24,
                  width: 24,
                ),

                const SizedBox(width: 12,),

                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.destinationAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 18,),

            //date and time
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatDateAndTime(widget.tripsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),

                ),
              ],
            ),
            const SizedBox(height: 2,),



          ],
        ),
      ),
    );
  }
}
