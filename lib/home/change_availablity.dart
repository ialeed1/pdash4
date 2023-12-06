import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateCourierAvailability(bool isAvailable) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final profileCollection = FirebaseFirestore.instance.collection('couriers');

    final dataToUpdate = <String, dynamic>{};

    dataToUpdate['availabilityStatus'] = isAvailable;

    try {
      await profileCollection.doc(user.uid).update(dataToUpdate);
    } catch (error) {
      print("Error updating user profile: $error");
    }
  }
}
