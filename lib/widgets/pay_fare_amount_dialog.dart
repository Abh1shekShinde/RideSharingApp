import 'package:drivers_app/global/global.dart';
import 'package:flutter/material.dart';

import '../mainScreens/dummy_gpay_screen.dart';

class PayFareAmountDialog extends StatefulWidget {

  double? fareAmount;

  PayFareAmountDialog({
    this.fareAmount,
});

  @override
  _PayFareAmountDialogState createState() => _PayFareAmountDialogState();
}



class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: Colors.black26,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Color(0xFFFFFFE8),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.white10,
              blurRadius: 18,
              spreadRadius: 0.5,
              offset: Offset(0.6, 0.6),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Total fare of the ${driverVehicleType!} is",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 10,),

            const Divider(thickness: 2,color: Colors.grey,),

            const SizedBox(height: 16,),

            Text(
              "₹ ${widget.fareAmount.toString()}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 50,
              ),
            ),

            const SizedBox(height: 10,),


            const Padding(
              padding:  EdgeInsets.all(15.0),
              child:  Text(
                "This is the total ride share amount. Please pay to the rider. ",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 10,),
            
            Padding(
              padding: const EdgeInsets.all(18.0),

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: (){
                  Future.delayed(const Duration(milliseconds: 2000), (){
                    // SystemNavigator.pop();
                    Navigator.pop(context, "cashPayed");

                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: const [
                      Text(
                        "Pay Now",
                       style: TextStyle(
                         fontSize: 20,
                         color: Colors.white,
                         fontWeight: FontWeight.bold
                       ),
                    ),

                    Text(
                      "₹",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: (){
                  Future.delayed(const Duration(milliseconds: 2000), (){
                    // SystemNavigator.pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) =>
                            const DummyGPayScreen()));

                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: const [
                    Text(
                      "Pay with UPI",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    Icon( Icons.qr_code_outlined, ),
                  ],
                ),
              ),


            ),

            const SizedBox(height: 5),

          ],
        ),
      ),
    );
  }
}
