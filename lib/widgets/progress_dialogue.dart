import 'package:flutter/material.dart';

class ProgressDialogue extends StatelessWidget {

  String? message;
  ProgressDialogue({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const SizedBox(width: 10,),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green)
            ),
            const SizedBox(width: 20,),

            Text(
              message!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),

            )
          ],

        ),
      ),
      ),
    );
  }
}
