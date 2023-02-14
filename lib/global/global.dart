import 'dart:async';

import 'package:drivers_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/direction_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

StreamSubscription<Position>? streamSubscriptionPosition;

List dList =[]; //this is list of drivers which contains online drivers key info.

DirectionDetailsInfo? tripDirectionDetailsInfo;