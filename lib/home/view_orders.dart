import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import '../orders.dart';
import '../widgets/order_status.dart';
import '../widgets/find_product_name_by_id.dart';
import '../widgets/retrieve_order.dart';

class ViewOrdersScreen extends StatefulWidget {
  const ViewOrdersScreen({super.key});
  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersState();
}

List<Orders> orders = [];
bool refreshEnabled = true;

/*
 * View Orders State: sets up the page
 */
class _ViewOrdersState extends State<ViewOrdersScreen> {
  Future<void> refreshOrdersList() async {
    final newOrders = await getNormalStatusOrderList();
    setState(() {
      orders = newOrders;
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
          title: const Text("View Orders"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !refreshEnabled
                  ? null
                  : () {
                      // addToOrders();
                      setState(() {
                        refreshEnabled = false;
                      });
                      refreshOrdersList();

                      Timer(const Duration(seconds: 1),
                          () => setState(() => refreshEnabled = true));
                    },
            ),
          ]),
      body: Column(
        children: [
          if (orders.isEmpty)
            const Center(
              child: Text("There are no orders currently available"),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        _showOrderDetails(context, orders[index]);
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
      ),
      drawer: const courier_drawer(),
    );
  }
} // View Orders State

//show order details when clicked on
void _showOrderDetails(BuildContext context, Orders order) {
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
                Text('Status: ${order.status}'),
                Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}')
              ],
            ),
          ),
          actions: [
            //ACCEPT ORDER CURRENTLY DOESNT DO ANYTHING IMPLEMENT
            //LATER
            ElevatedButton(
              onPressed: () {
                _showAcceptOrderConfirm(context, order.orderID);
                //if confirm button is pressed, close out of this screen
                //retrieve orderID of order
              },
              child: const Text('Accept'),
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
          ],
        );
      });
    },
  );
}

//accept order confirmation screen when Accept Order is clicked on
void _showAcceptOrderConfirm(BuildContext context2, String orderID) {
  showDialog(
      context: context2,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Confirm Accept"),
            content: const Text("Do you want to accept the order?"),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  //print("ORDER ID: $orderID");
                  await getDelivery("picking", orderID);

                  //Handle confirm here
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  //POP the details
                  Navigator.pop(context2);
                  ScaffoldMessenger.of(context2).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text("Order Accepted Successfully"),
                    ),
                  );
                  //refresh page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const ViewOrdersScreen()));
                  // TO DO: pop up a message somewhere with "confirm processed or something similar"
                },
                child: const Text("Confirm"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        });
      });
} //Show Accept Order Confirm

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
