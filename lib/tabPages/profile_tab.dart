import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/info_design_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFC8F2EF),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/profileBackgroundImage.jpg"),
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.modulate,),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // name
              Text(
                userModelCurrentInfo!.name!,
                style:const TextStyle (
                  color: Color(0xFF000000),
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
                width: 300,
                child: Divider(
                  color: Color(0xFFE21818),
                  height: 3,
                  thickness: 2,
                ),
              ),

              Text(
                "You are a $titleStarRating driver",
                style:const TextStyle (
                  color: Color(0xFF000000),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 38,),

              //Phone
              InfoDesignUIWidget(
                textInfo: "+91 ${userModelCurrentInfo!.phone!}",
                iconData: Icons.phone_enabled,
              ),

              //Email
              InfoDesignUIWidget(
                textInfo: userModelCurrentInfo!.email!,
                iconData: Icons.alternate_email,
              ),


              InfoDesignUIWidget(
                textInfo: "${onlineDriverData.vehicleColor!} ${onlineDriverData.vehicleModel!}",
                iconData: Icons.directions_car_outlined,
              ),

              const SizedBox(height: 50,),

              //Logout button
              ElevatedButton(
                onPressed: (){
                  fAuth.signOut();
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
