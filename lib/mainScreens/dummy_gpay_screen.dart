import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class DummyGPayScreen extends StatefulWidget {
  const DummyGPayScreen({Key? key}) : super(key: key);

  @override
  _DummyGPayScreenState createState() => _DummyGPayScreenState();
}

class _DummyGPayScreenState extends State<DummyGPayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Pay'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Payment amount:',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter payment amount',
                suffixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 20.0),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Payment method:',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image.asset('images/googlePayLogo.png',
                        width: 30.0, height: 30.0),
                    const SizedBox(width: 10.0),
                    const Expanded(
                      child: Text(
                        'Google Pay',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () {
              },
              child: Text('Make Payment',
                style: TextStyle(
                  fontSize: 20,
                ),),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 20,
                ),),
            ),
          ),
        ],
      ),
    );
  }
}
