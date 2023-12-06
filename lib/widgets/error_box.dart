import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String? message;
  ErrorBox({this.message});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          child: const Center(
            child: Text("Ok"),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
