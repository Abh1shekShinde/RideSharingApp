import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/models/predicted_places.dart';
import 'package:drivers_app/widgets/place_prediction_tile.dart';
import 'package:flutter/material.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async{
    if(inputText.length > 1){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IN";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error Occurred. Try Again"){
        return;
      }
      // print("This is response form API: ");
      // print(responseAutoCompleteSearch);

      if(responseAutoCompleteSearch["status"] == "OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });

      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F9FD),
      body: Column(
        children: [

          //Search Place UI
          Container(
            height: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7, 0.7
                    ),
                  )
                ]
              ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                      },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.orange,
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Search Destination",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    children: [
                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 20,
                            // bottom: 10,
                          ),
                          child: TextField(
                            onChanged: (valueTyped){
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration:const InputDecoration(
                              hintText: "Where do you want to go ?? ",
                              fillColor: Colors.black12,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 15.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          //Display Place predictions result
          (placesPredictedList.isNotEmpty)
              ? Expanded(
            child: ListView.separated(
              itemCount: placesPredictedList.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index){
                return PlacePredictionTileDesign(
                  predictedPlaces: placesPredictedList[index],
                );
              },
              separatorBuilder: (BuildContext context , int index) {
                return const Divider(
                  height: 1,
                  color: Colors.black,
                  thickness: 1,
                );
              },
          ),
          )
              : Container(),

        ],
      ),
    );
  }
}
