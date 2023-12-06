import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/authentication/register.dart';
import 'login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Color(0xFF555960), // Steel color from Purdue's palette
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFF000000), // Black color from Purdue's palette
            title: const Text("Purdue Dash", style: TextStyle(
              fontSize: 50,
              color: Color(0xFFCFB991), // Boilermaker Gold
              fontFamily: "Gabarito",
            ),
            ),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.lock, color: Colors.white,),
                  text: "Login",
                ),
                Tab(
                  icon: Icon(Icons.person, color: Colors.white,),
                  text: "Register",
                ),
              ],
              indicatorColor: Color(0xFFDAAA00), // Rush color for the indicator
              indicatorWeight: 6,
            ),
          ),
          body: Container(
              color: Color(0xFF6F727B), // Cool Gray color for the body background
              child: const TabBarView(
                children: [
                  LoginScreen(),
                  RegisterScreen(),
                ],
              )
          ),
        )
    );
  }
}
