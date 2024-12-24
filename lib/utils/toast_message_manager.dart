
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage{
  static void success({required String? message, String nullMessage = "Something went wrong",Toast toastLength = Toast.LENGTH_LONG}){
    Fluttertoast.showToast(
        msg: message ?? nullMessage,
        toastLength: toastLength,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  static void error({required String? message, String nullMessage = "Something went wrong",Toast toastLength = Toast.LENGTH_LONG}){
    Fluttertoast.showToast(
        msg: message ?? nullMessage,
        toastLength: toastLength,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  static void warning({required String? message, String nullMessage = "Something went wrong",Toast toastLength = Toast.LENGTH_LONG}){
    Fluttertoast.showToast(
        msg: message ?? nullMessage,
        toastLength: toastLength,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.yellow.withOpacity(0.7),
        textColor: Colors.black,
        fontSize: 16.0);
  }
  static void info({required String? message, String nullMessage = "Something went wrong",Toast toastLength = Toast.LENGTH_LONG}){
    Fluttertoast.showToast(
        msg: message ?? nullMessage,
        toastLength: toastLength,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showSnackBar({required BuildContext context,required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
