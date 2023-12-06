import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/widgets/custom_text_field.dart';

/*
 * todo: 
 * 1.overhaul profile.
 * 2. TBA, needs redesign
 * 
 */

//initialize for profile information defaults
bool available = false;
String address = '';
String email = '';
String name = '';
String UID = '';
String contact = '';
double earnings = -1;

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactDetailsController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    grabCourierInfo(); // Call the method when the page is initially loaded
  }

  Future<void> refreshData() async {
    grabCourierInfo();
  }

  //get all information about user
  Future<void> grabCourierInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final couriersGroup = FirebaseFirestore.instance.collection('couriers');
      final doc = await couriersGroup.doc(user!.uid).get();
      final isAvailable = doc.data()?['availabilityStatus'];
      final address1 = doc.data()?['courierAddress'];
      final email1 = doc.data()?['courierEmail'];
      final name1 = doc.data()?['courierName'];
      final uid1 = doc.data()?['courierUID'];
      final contact1 = doc.data()?['couriertContact'];
      final earnings1 = doc.data()?['earnings'];

      setState(() {
        available = isAvailable;
        address = address1;
        email = email1;
        name = name1;
        UID = uid1;
        contact = contact1;
        earnings = earnings1;
      });
    } catch (e) {
      print('Error unable to fetch information: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("View Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refreshData(); // Call the method when the refresh button is pressed
            },
          ),
        ],
      ),
      drawer: courier_drawer(),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Availability Status: ${available ? "Available" : "Not Available"}'),
            Text('Address: $address'),
            Text('Email: $email'),
            Text('Name: $name'),
            Text('UID: $UID'),
            Text('Contact: $contact'),
            Text('Earnings: ${earnings != -1 ? earnings.toString() : "N/A"}'),
            // Name
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.person,
                controller: nameController,
                hintText:
                    nameController.text.isEmpty ? "Name" : nameController.text,
                isObscure: false,
              ),
            ),
            // Email
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.email,
                controller: emailController,
                hintText: emailController.text.isEmpty
                    ? "Email"
                    : emailController.text,
                isObscure: false,
              ),
            ),
            // Contact Details
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.contact_page,
                controller: contactDetailsController,
                hintText: contactDetailsController.text.isEmpty
                    ? "Contact Details"
                    : contactDetailsController.text,
                isObscure: false,
              ),
            ),
            // Address
            const SizedBox(height: 6),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.map,
                controller: addressController,
                hintText: addressController.text.isEmpty
                    ? "Address"
                    : addressController.text,
                isObscure: false,
              ),
            ),
/*
            if (isEditing) ...[
              ElevatedButton(
                onPressed: () {
                },
                child: Text('Upload Image'),
              ),
            ],
            */

            const SizedBox(height: 20),

            // Save button

            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String email = emailController.text;
                String contactDetails = contactDetailsController.text;
                String address = addressController.text;

                updateUserProfile(name, email, contactDetails, address);

                setState(() {
                  isEditing = false;
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> updateUserProfile(
  String name,
  String email,
  String contactDetails,
  String address,
) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final profileCollection = FirebaseFirestore.instance.collection('couriers');

    final dataToUpdate = <String, dynamic>{};

    if (name.isNotEmpty) {
      dataToUpdate['courierName'] = name;
    }

    if (email.isNotEmpty) {
      dataToUpdate['courierEmail'] = email;
    }

    if (contactDetails.isNotEmpty) {
      dataToUpdate['couriertContact'] = contactDetails;
    }

    if (address.isNotEmpty) {
      dataToUpdate['courierAddress'] = address;
    }

    try {
      await profileCollection.doc(user.uid).update(dataToUpdate);

      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
    } catch (error) {
      // print("Error updating user profile: $error");
    }
  }
}
