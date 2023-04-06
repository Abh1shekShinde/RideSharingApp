import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/info_design_ui.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFC8F2EF),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/profileBackgroundImage.jpg"),
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
                  color: Color(0xFF4D4D4D),
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
                  width: 300,
                child: Divider(
                  color: const Color(0xFFD989B5),
                  height: 3,
                  thickness: 2,
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

              const SizedBox(height: 50,),

              //Close button
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
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
                  "Close",
                  style: TextStyle(
                    color: Colors.white
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
