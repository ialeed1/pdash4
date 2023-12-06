import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/order_status.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/widgets/find_product_name_by_id.dart';
import '../widgets/retrieve_order.dart';

//remove later when backend for orders fully implemented
import '../orders.dart';

class DeliveryProgressScreen extends StatefulWidget {
  const DeliveryProgressScreen({super.key});

  @override
  State<DeliveryProgressScreen> createState() => _DeliveryProgressScreenState();
}

bool refreshEnabled = true;
List<Orders> orders = [];

class _DeliveryProgressScreenState extends State<DeliveryProgressScreen> {
  int progressValue = 1;
  Future<void> refreshOrdersList() async {
    final newOrders = await getDeliveringStatusOrderList();
    setState(() {
      orders = newOrders;
    });
  }

  Future<void> getNewProgressVal(Orders order) async {
    int newProgressVal = await retrieveOrderStatus(order.orderID);
    setState(() {
      progressValue =
          newProgressVal; // Update progressValue with the status value
    });
  }

  @override
  void initState() {
    super.initState();
    refreshOrdersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text("Deliveries In Progress"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                //retrieveOrderData();
                setState(() {
                  refreshEnabled = false;
                });
                refreshOrdersList();

                Timer(const Duration(seconds: 1),
                    () => setState(() => refreshEnabled = true));
              },
            ),
          ],
        ),
        drawer: const courier_drawer(),
        body: Column(
          children: [
            if (orders.isEmpty)
              const Center(
                child: Text("There are no orders currently"),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: GestureDetector(
                        onTap: () async {
                          await getNewProgressVal(orders[index]);
                          if (!context.mounted) {
                            return;
                          }
                          _showOrderDetails(
                              context, orders[index], progressValue);
                        },
                        child: ListTile(
                          title: Text('Order ${orders[index].orderID}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Status: ${orders[index].status}"),
                                ],
                              ),
                              Text(
                                'Total Price: \$${orders[index].totalPrice.toStringAsFixed(2)}',
                              ),
                              Text(
                                  "Number of Items: ${orders[index].productIDs.length - 1}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ));
  }
}

//show order details when clicked on
void _showOrderDetails(BuildContext context, Orders order, int progVal) {
  int progressValue = progVal;
  String updateButtonText = (progressValue == 2) ? 'Deliver' : 'Update';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(8),
          title: const Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address: ${order.addressID}'),
                //replace: merchant with restaurant
                Text('Merchant: ${order.merchantUID}'),
                Text('Order Id: ${order.orderID}'),
                Text('Order Time: ${order.orderTime}'),
                //replace ordered by with actual username
                Text('Ordered By: ${order.orderedBy}'),
                Text('Number of Items: ${order.productIDs.length - 1}'),
                Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
                Text('Status: ${order.status}'),

                LinearProgressIndicator(
                  value: progressValue / 3.0,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.grey,
                  minHeight: 6,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _showUpdateConfirmation(context, order, progressValue);
              },
              child: Text(updateButtonText),
            ),
            ElevatedButton(
              onPressed: () {
                _showItemsScreen(context, order);
              },
              child: const Text('Items'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                if (progressValue <= 1) {
                  _showCancelConfirmation(context, order, progressValue);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text("Order currently cannot be canceled!"),
                    ),
                  );
                }
              },
              child: const Text('Cancel Order'),
            ),
          ],
        );
      });
    },
  );
}

void _showCancelConfirmation(BuildContext context2, Orders order, int progVal) {
  showDialog(
      context: context2,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("Confirm Cancel"),
            content: const Text("Do you want to cancel the order?"),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await updateOrderStatus("normal", order.orderID);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  Navigator.pop(context2);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const DeliveryProgressScreen()));
                  ScaffoldMessenger.of(context2).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text("successfully canceled!"),
                    ),
                  );
                },
                child: const Text("Confirm"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
                child: const Text("Cancel"),
              ),
            ]);
      });
}

void _showUpdateConfirmation(BuildContext context2, Orders order, int progVal) {
  String updateButtonText =
      (progVal == 2) ? 'Order has been delivered' : 'Order has been picked up';

  showDialog(
    context: context2,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Do you want to update the order?"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await updateOrderStatusBySteps(order);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              Navigator.pop(context2);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const DeliveryProgressScreen()));
              ScaffoldMessenger.of(context2).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text(updateButtonText),
                ),
              );
            },
            child: const Text("Confirm"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the confirmation dialog
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

void _showItemsScreen(BuildContext context, Orders order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: ((context, setState) {
        return AlertDialog(
            insetPadding: const EdgeInsets.all(8),
            title: const Text("Item Details"),
            content: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i < order.productIDs.length; i++)
                  FutureBuilder(
                      future: getProductString(order.productIDs.elementAt(i)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Text("${snapshot.data}");
                          } else if (snapshot.hasData) {
                            return const Text("Could not be loaded");
                          }
                        }
                        return const Text("Loading...");
                      }),
                //process the productID into product name, and display the correct amount
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"))
              ],
            )));
      }));
    },
  );
}
