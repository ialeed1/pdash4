import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/global/global.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'change_availablity.dart';

bool isAvailable = true;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ToggleStatus extends StatefulWidget {
  const ToggleStatus({super.key});
  @override
  State<ToggleStatus> createState() => _ToggleStatusState();
}

class _ToggleStatusState extends State<ToggleStatus> {
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          thumbIcon: thumbIcon,
          value: isAvailable,
          onChanged: (bool value) {
            setState(() {
              isAvailable = value;
            });
          },
        ),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    getAvailabilityFireStore();
  }

//grab if availible to set the availability status
  Future<void> getAvailabilityFireStore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final couriersGroup = FirebaseFirestore.instance.collection('couriers');
      final doc = await couriersGroup.doc(user!.uid).get();
      final availabilityStatus = doc.data()?['availablityStatus'];

      setState(() {
        isAvailable = availabilityStatus ?? false;
      });
    } catch (e) {
      print('Error unable to fetch status: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            sharedPreferences!.getString("name")!,
          ),
          backgroundColor: Colors.amber,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openDrawer,
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Image.asset(
                'images/splash.png',
                width: 400,
                height: 400,
              ),
              const Text("Change Availability Status"),
              Switch(
                value: true,
                activeColor: Colors.green,
                inactiveTrackColor: Colors.red,
                onChanged: (bool val) {
                  setState(() {
                    isAvailable = val;
                  });
                  updateCourierAvailability(val);
                },
              )
            ],
          ),
        ),
        drawer: courier_drawer());
  }
}
