import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  _CarInfoScreenState createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController vehicleModelTextEditingController =
      TextEditingController();
  TextEditingController vehicleNumberTextEditingController =
      TextEditingController();
  TextEditingController vehicleColorTextEditingController =
      TextEditingController();

  List<String> vehicleTypeList = <String>["Car", "Bike", "Scooter"];
  String? selectedVehicleType;

  saveCarInfo() {
    Map userVehicleInfoMap = {
      "vehicleType": selectedVehicleType,
      "vehicleModel": vehicleModelTextEditingController.text.trim(),
      "vehicleNumber": vehicleNumberTextEditingController.text.trim(),
      "vehicleColor": vehicleColorTextEditingController.text.trim(),
    };

    DatabaseReference userReference =
        FirebaseDatabase.instance.ref().child("users");
    userReference
        .child(currentFirebaseUser!.uid)
        .child("vehicle_details")
        .set(userVehicleInfoMap);
    
    Fluttertoast.showToast(msg: "Vehicle Details Saved Successfully");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  validateVehicleInfo() {
    if (vehicleModelTextEditingController.text.isNotEmpty &&
        vehicleNumberTextEditingController.text.isNotEmpty &&
        vehicleColorTextEditingController.text.isNotEmpty &&
        selectedVehicleType != null) {
      saveCarInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCCCFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("images/vehicleDetails.jpg"),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Register you Vehicle",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                height: 30,
                alignment: Alignment.topLeft,
                child: DropdownButton(
                  iconSize: 30,
                  dropdownColor: const Color(0xFFF5F5DC),
                  hint: const Text(
                    "Choose Vehicle Type",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  value: selectedVehicleType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedVehicleType = newValue.toString();
                    });
                  },
                  items: vehicleTypeList.map((vehicle) {
                    return DropdownMenuItem(
                      value: vehicle,
                      child: Text(
                        vehicle,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: vehicleModelTextEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  icon: Icon(Icons.directions_car_rounded),
                  labelText: "Vehicle Model",
                  hintText: "Enter Model of your Vehicle",
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
                    fontSize: 16,
                  ),
                ),
              ),
              TextField(
                controller: vehicleNumberTextEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  icon: Icon(Icons.numbers),
                  labelText: "Vehicle Number",
                  hintText: "Enter your Vehicle Number",
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
                    fontSize: 16,
                  ),
                ),
              ),
              TextField(
                controller: vehicleColorTextEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  icon: Icon(Icons.format_color_fill),
                  labelText: "Vehicle Color",
                  hintText: "Enter your Vehicle Color",
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
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  validateVehicleInfo();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBF00),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                ),
                child: const Text(
                  "Save details",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
