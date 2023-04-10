import 'package:drivers_app/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RateDriverScreen extends StatefulWidget {

String? assignedDriverId;
RateDriverScreen({
  this.assignedDriverId,
});


  @override
  _RateDriverScreenState createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {

  TextEditingController driverReviewsTextEditingController = TextEditingController();


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
                "Rate Trip Experience",
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
                rating: countStarRatings,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.green,
                borderColor: Colors.green,
                size: 40,
                onRatingChanged: (valueOfStarsChosen)
                {
                  countStarRatings = valueOfStarsChosen;

                  if(countStarRatings == 1)
                  {
                    setState(() {
                      titleStarsRating = "Very Bad";
                    });
                  }
                  if(countStarRatings == 2)
                  {
                    setState(() {
                      titleStarsRating = "Bad";
                    });
                  }
                  if(countStarRatings == 3)
                  {
                    setState(() {
                      titleStarsRating = "Good";
                    });
                  }
                  if(countStarRatings == 4)
                  {
                    setState(() {
                      titleStarsRating = "Very Good";
                    });
                  }
                  if(countStarRatings == 5)
                  {
                    setState(() {
                      titleStarsRating = "Excellent";
                    });
                  }
                },
              ),

              const SizedBox(height: 12.0,),

              Text(
                titleStarsRating,
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

              TextField(
                controller: driverReviewsTextEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  icon: Icon(Icons.reviews),
                  labelText: "Reviews",
                  hintText: "Enter your reviews here",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 18.0,),

              ElevatedButton(
                  onPressed: ()
                  {
                    DatabaseReference rateDriverRef = FirebaseDatabase.instance.ref()
                        .child("users")
                        .child(widget.assignedDriverId!)
                        .child("ratings");

                    rateDriverRef.once().then((snap)
                    {
                      if(snap.snapshot.value == null)
                      {
                        rateDriverRef.set(countStarRatings.toString());
                        Navigator.pop(context);
                      }
                      else
                      {
                        double pastRatings = double.parse(snap.snapshot.value.toString());
                        double newAverageRatings = (pastRatings + countStarRatings) / 2;
                        rateDriverRef.set(newAverageRatings.toString());

                        Navigator.pop(context);
                      }

                      Fluttertoast.showToast(msg: "Please Restart the App");
                    });

                    DatabaseReference driverTextReviews = FirebaseDatabase.instance.ref()
                        .child("users")
                        .child(widget.assignedDriverId!)
                        .child("reviews");

                    driverTextReviews.once().then((snap)
                    {
                      if(snap.snapshot.value == null)
                      {
                        driverTextReviews.set(driverReviewsTextEditingController);
                        Navigator.pop(context);
                      }
                      else
                      {
                        String pastReviews = snap.snapshot.value.toString();
                        String newReviews = pastReviews + driverReviewsTextEditingController.toString() ;
                        driverTextReviews.set(newReviews.toString());
                        Navigator.pop(context);
                      }

                      Fluttertoast.showToast(msg: "Please Restart the App");
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
              ),

              const SizedBox(height: 10.0,),

            ],

          ),

        ),
      ),

    );
  }
}
