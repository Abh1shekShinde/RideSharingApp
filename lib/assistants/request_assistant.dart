import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant{
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      //It means successful response (code 200)
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body; //json response

        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;

      }
      else {
        return "Error Occurred. Try Again";
      }
    }catch(exp){
      return "Error Occurred. Try Again";
    }

  }
}