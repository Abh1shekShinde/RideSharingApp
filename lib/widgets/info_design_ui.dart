import 'package:flutter/material.dart';

class InfoDesignUIWidget extends StatefulWidget {
String? textInfo;
IconData? iconData;

InfoDesignUIWidget({
  this.textInfo,
  this.iconData,
});
  @override
  _InfoDesignUIWidgetState createState() => _InfoDesignUIWidgetState();
}

class _InfoDesignUIWidgetState extends State<InfoDesignUIWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFB84C),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: ListTile(
        leading: Icon(
          widget.iconData,
          color: Colors.black,
        ),
        title: Text(
          widget.textInfo!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
