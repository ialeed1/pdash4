import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<double> retrieveOrdersDelivered() async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  final courierCollection = FirebaseFirestore.instance.collection("couriers");
  final courierDocument = courierCollection.doc(courierUID);
  final statsCollection = courierDocument.collection("stats");
  final statsDocument = statsCollection.doc("courier_stats");

  // Check if the stats document exists
  final statsSnapshot = await statsDocument.get();
  if (statsSnapshot.exists) {
    int data1 = statsSnapshot.data()?['ordersDelivered'] ?? 0;
    double a = data1.toDouble();
    return a;
  } else {
    return 0;
  }
}

Future<double> retrieveTotalAmountEarned() async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  final courierCollection = FirebaseFirestore.instance.collection("couriers");
  final courierDocument = courierCollection.doc(courierUID);
  final statsCollection = courierDocument.collection("stats");
  final statsDocument = statsCollection.doc("courier_stats");

  // Check if the stats document exists
  final statsSnapshot = await statsDocument.get();
  if (statsSnapshot.exists) {
    return statsSnapshot.data()?['amountEarned'] ?? 0.0;
  } else {
    return 0.0;
  }
}

Future<void> incrementOrdersDelivered() async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  final courierCollection = FirebaseFirestore.instance.collection("couriers");
  final courierDocument = courierCollection.doc(courierUID);
  final statsCollection = courierDocument.collection("stats");
  final statsDocument = statsCollection.doc("courier_stats");

  //Check if the stats document exists
  final statsSnapshot = await statsDocument.get();
  if (statsSnapshot.exists) {
    await statsDocument.update({
      'ordersDelivered': FieldValue.increment(1),
    });
  } else {
    await statsDocument.set({
      'ordersDelivered': 1,
    });
  }
}

Future<void> incrementAmountEarned(double amount) async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  final courierCollection = FirebaseFirestore.instance.collection("couriers");
  final courierDocument = courierCollection.doc(courierUID);
  final statsCollection = courierDocument.collection("stats");
  final statsDocument = statsCollection.doc("courier_stats");

  //Check if the stats document exists
  final statsSnapshot = await statsDocument.get();
  if (statsSnapshot.exists) {
    await statsDocument.update({
      'amountEarned': FieldValue.increment(amount),
    });
  } else {
    await statsDocument.set({
      'amountEarned': amount,
    });
  }
}
