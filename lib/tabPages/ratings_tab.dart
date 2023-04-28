import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({Key? key})  : super(key: key);

  @override
  _RatingsTabPageState createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {

  double ratingsNumber = 0;


  @override
  void initState(){
    super.initState();

    getRatingsNumber();

  }

  getRatingsNumber(){
    setState(() {
      ratingsNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });
    setUpRatingsTitle();
  }

  setUpRatingsTitle(){
    if(ratingsNumber == 1)
    {
      setState(() {
        titleStarRating = "Very Bad";
      });
    }
    if(ratingsNumber == 2)
    {
      setState(() {
        titleStarRating = "Bad";
      });
    }
    if(ratingsNumber == 3)
    {
      setState(() {
        titleStarRating = "Good";
      });
    }
    if(ratingsNumber == 4)
    {
      setState(() {
        titleStarRating = "Very Good";
      });
    }
    if(ratingsNumber == 5)
    {
      setState(() {
        titleStarRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.black26,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const SizedBox(height: 22.0,),

              const Text(
                "Your Average Rating",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 22.0,),

              const Divider(height: 4.0, thickness: 4.0,),

              const SizedBox(height: 22.0,),

              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.green,
                borderColor: Colors.green,
                size: 40,
              ),

              const SizedBox(height: 12.0,),

              Text(
                titleStarRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              // TextField(
              //
              //   maxLines: 8, //or null
              //   decoration: InputDecoration.collapsed(hintText: "Enter your text here"),
              // ),

              const SizedBox(height: 18.0,),

            ],

          ),

        ),
      ),

    );
  }
}
