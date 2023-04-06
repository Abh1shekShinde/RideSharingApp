import 'package:drivers_app/widgets/history_design_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class TripsHistoryScreen extends StatefulWidget {


  @override
  _TripsHistoryScreenState createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF84D2C5),
        title: const Text(
          "Trips History",
        ),

        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView.separated(
          separatorBuilder: (context, i) => const Divider(
            thickness: 10,
            color: Colors.white,
            height: 10,
          ),
            itemBuilder: (context, i){
              return Card(
                child: HistoryDesignUIWidget(
                  tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
                ),
              );
            },
          itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
        ),
      
    );
  }
}
