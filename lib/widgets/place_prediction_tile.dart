import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/predicted_places.dart';
import 'package:drivers_app/widgets/progress_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/directions.dart';

class PlacePredictionTileDesign extends StatelessWidget {

  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({
    this.predictedPlaces
});

  //This will return the details of the location selected by the user as a destination
  getPlaceDirectionDetails(String? placeId, context) async{
    showDialog(
        context: context,
        builder: (BuildContext context)=> ProgressDialogue(message: "Setting up your destination \n Hang on ......",)
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseApi == "Error Occurred. Try Again"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName =  responseApi["result"]["name"];
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];
      directions.locationId = placeId;

      Provider.of<AppInfo>(context, listen:false).updateDropOffLocationAddress(directions);
      //This will close the screen once the destination is received.
      Navigator.pop(context, "obtainedDropOff");

    }

  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        getPlaceDirectionDetails(predictedPlaces!.place_id, context);

      },

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2DEBA)
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location_outlined,
              color: Colors.blue,
            ),
            const SizedBox(width: 14,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2,),

                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8,),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
