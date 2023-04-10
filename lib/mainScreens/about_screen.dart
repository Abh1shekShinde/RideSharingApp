import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPageScreen extends StatefulWidget {


  @override
  _AboutPageScreenState createState() => _AboutPageScreenState();
}

class _AboutPageScreenState extends State<AboutPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("About Us",
          style: TextStyle(
            color: Colors.white,
          ),),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("Rideshare",
              style: GoogleFonts.poppins(
                fontSize: 30.0,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8,),
            //IMAGE
            const Text("RideShare is a gated community for hassle-free ridesharing experience built with an aim of improving quality of life through Technology and Innovation.",
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16,),
            Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission Statement:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each one of us wants to do good for our society but this desire gets fizzled in midst of our daily chores to achieve our personal priorities in life. We understand this practicality and started looking for opportunities for people who want to do good for society. ‘RideShare’ is one such opportunity.',
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Values:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: Icon(Icons.directions_bus,color: Colors.deepOrange,),
                      title: Text('Reduce Traffic Congestion'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.air,color: Colors.deepOrange,),
                      title: Text('Improve Air Quality'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.pin_drop,color: Colors.deepOrange,),
                      title: Text('Safe Inter & Intra City Travel'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.wallet,color: Colors.deepOrange,),
                      title: Text('Save on Travel Cost'),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
