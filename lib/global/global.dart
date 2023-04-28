import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/models/driver_data.dart';
import 'package:drivers_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/direction_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

Position? userCurrentPosition;

String statusText = "Share Ride"; //Driver is offline i.e not sharing ride / searching for ride
//Share Ride - Offline
//Sharing Ride - Online
Color buttonColor = Colors.grey;
bool isDriverActive = false;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

List dList =[]; //this is list of drivers which contains online drivers key info.

DirectionDetailsInfo? tripDirectionDetailsInfo;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

String? chosenDriverId = "";

DriverData onlineDriverData = DriverData();

String? driverVehicleType = "";

String userDropOffAddress = "";
String driverVehicleDetails = "";
String userName = "";
String userPhone = "";

String titleStarsRating = "";
double countStarRatings = 0.0;

String titleStarRating = "No rating yet";

String cloudMessagingServerToken = "key=AAAAE4qSCL8:APA91bHxwQLyMUR8LSNBc5h3hX_LEpI8IvMIuysiLUDBdzvSAxx2-i5Ro9rcqtT5fdzIt9d5f-2sKh5BnFWM2ZMQmC6QN44bqjzgCTCRKbMefRY6dW3Far9NVLjpwJwCZXbbIdSXV3nG" ;