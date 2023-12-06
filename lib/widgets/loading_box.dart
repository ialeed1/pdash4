import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/progress_bar.dart';


class LoadingBox extends StatelessWidget {
  final String? message;
  LoadingBox({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(), 
          const SizedBox(height: 10,),
          Text("${message!}, wait..."), 
        ],
      ),
    );
  }
}
