import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DummyQRCodeScreen extends StatefulWidget {
  const DummyQRCodeScreen({Key? key}) : super(key: key);

  @override
  _DummyQRCodeScreenState createState() => _DummyQRCodeScreenState();
}

class _DummyQRCodeScreenState extends State<DummyQRCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8F2EF),
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Scan QR Code to pay",
                style:  TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                "images/riderQRCode.png",
                width: 350,
                height: 400,
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      Navigator.pop(context);
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
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
