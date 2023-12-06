/*
 *Order class dummy value creator with NEW updated 
 *information from order 10/26/23
 */

class Orders {
  //All fields from firestore
  String addressID;
  String courierID;
  bool isSuccess;
  String merchantUID;
  String orderID;
  String orderTime;
  String orderedBy;
  String paymentDetails;
  List<dynamic> productIDs;
  String status;
  // ignore: prefer_typing_uninitialized_variables
  final totalPrice;
//initializes everything to make order
  Orders(
    this.addressID,
    this.courierID,
    this.isSuccess,
    this.merchantUID,
    this.orderID,
    this.orderTime,
    this.orderedBy,
    this.paymentDetails,
    this.productIDs,
    this.status,
    this.totalPrice,
  );
}
