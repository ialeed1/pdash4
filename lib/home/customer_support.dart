import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/widgets/retrieve_user_details.dart';

class CourierSupportScreen extends StatefulWidget {
  const CourierSupportScreen({super.key});

  @override
  State<CourierSupportScreen> createState() => _CourierSupportScreenState();
}

class FormSubmitScreen extends StatefulWidget {
  const FormSubmitScreen({super.key});

  @override
  State<FormSubmitScreen> createState() => _SubmitFormState();
}

class _CourierSupportScreenState extends State<CourierSupportScreen> {
  String selectedOption = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Customer Support"),
      ),
      drawer: const courier_drawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "How can we help?",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Welcome to Purdue Dash support. How can we assist you?",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Delivery Issues"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeliveredItemsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text("Customer Issues"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Earnings Issues"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
            /*
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Unable to Access Orders"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
            */
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Something Else"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveredItemsScreen extends StatelessWidget {
  const DeliveredItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Delivery Issues"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Please select the option which best describes your situation.",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text("Unable to View Orders"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text("Unable to Process Delivery"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.broken_image),
              title: const Text("Other Delivery Issues"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormSubmitScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitFormState extends State<FormSubmitScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  @override
  void initState() {
    super.initState();
    String name = getName();
    String email = getEmail();

    // Set the initial values for name and email fields
    nameController.text = name;
    emailController.text = email;
  }

  @override
  void dispose() {
    //cleanup all controllers
    nameController.dispose();
    emailController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Fill Form"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Please provide the following information:",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            // Name Form
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: InputBorder.none,
                ),
              ),
            ),
            // Email Form
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: InputBorder.none,
                ),
              ),
            ),
            // Details Form
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: detailsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Details",
                  border: InputBorder.none,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    detailsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill out all fields"),
                    ),
                  );
                } else {
                  // Handle form submission

                  // Clear text fields
                  detailsController.clear();

                  // Return to the first screen
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Successfully Submitted!"),
                    ),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
