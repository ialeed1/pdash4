import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purdue_dash_courier_app/orders.dart';

Future<void> addToHistory(Orders order) async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  final courierCollection = FirebaseFirestore.instance.collection("couriers");

  // Use the orderID as the document ID for the "orders" collection
  final newOrderDoc =
      courierCollection.doc(courierUID).collection("orders").doc(order.orderID);

  // Convert the "Orders" object to a map
  Map<String, dynamic> orderMap = {
    'address': order.addressID,
    'courierID': order.courierID,
    'isSuccess': order.isSuccess,
    'merchant': order.merchantUID,
    'orderID': order.orderID,
    'orderTime': order.orderTime,
    'orderedBy': order.orderedBy,
    'paymentDetails': order.paymentDetails,
    'productIDs': order.productIDs,
    'status': "delivered",
    'totalPrice': order.totalPrice,
  };

  // Add the order details to the new document
  await newOrderDoc.set(orderMap);
}
