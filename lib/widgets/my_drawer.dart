import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/about_screen.dart';
import 'package:drivers_app/mainScreens/profle_screen.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../mainScreens/trip_history_screen.dart';


class MyDrawer extends StatefulWidget {
  // const MyDrawer({Key? key}) : super(key: key);
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: const Color(0xFFFF5D5D),
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
              child: Row(
                children: [
                  const Icon(
                      Icons.person,
                    size: 40,
                    color: Color(0xFF243763),
                  ),
                  const SizedBox(width: 16,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hi, ${widget.name.toString()}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF243763),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF243763),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox( height: 10,),

          //History
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.history, color: const Color(0xFF243763),),
              title: Text(
                "History",
                style: TextStyle(
                  color: Color(0xFF243763),
                  fontSize: 16,
                ),
              ),

            ),
          ),

          //Visit Profile
          // GestureDetector(
          //   onTap: (){
          //     Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen()));
          //   },
          //   child: const ListTile(
          //     leading: Icon(Icons.person, color: Color(0xFF243763),),
          //     title: Text(
          //       "Visit Profile",
          //       style: TextStyle(
          //         color: Color(0xFF243763),
          //         fontSize: 16,
          //       ),
          //     ),
          //
          //   ),
          // ),

          //About Page

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => AboutPageScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.info, color: Color(0xFF243763),),
              title: Text(
                "About Page",
                style: TextStyle(
                  color: Color(0xFF243763),
                  fontSize: 16,
                ),
              ),

            ),
          ),

          //Sign out
          GestureDetector(
            onTap: (){
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen())) ;
            },
            child: const ListTile(
              leading: Icon(Icons.logout, color:Color(0xFF243763),),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color: Color(0xFF243763),
                  fontSize: 16,
                ),
              ),

            ),
          ),

          //drawer body
        ],
      ),
    );
  }
}
