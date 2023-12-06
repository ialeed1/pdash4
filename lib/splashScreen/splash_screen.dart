import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/authentication/auth_screen.dart';
import 'package:purdue_dash_courier_app/global/global.dart';
import 'package:purdue_dash_courier_app/home/home_screen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  startTimer()
  {
    

    Timer(const Duration(seconds: 5), () async{
      if(firebaseAuth.currentUser != null){
        //HomeScreen
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
      }
      else{
        
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
      }
      
    });
  }
  @override
  void initState(){
    super.initState();

    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
       color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Image.asset("images/splash.png"),
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                "Purdue Dash Courier",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
