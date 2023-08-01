import 'package:flutter/material.dart';
import 'database_helper.dart';

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: itemPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Item Price'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    DatabaseServices databaseServices = DatabaseServices();
                    databaseServices.clearDatabase().then((_) {
                      print("Database cleared successfully");
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    String itemName = itemNameController.text;
                    double itemPrice =
                        double.tryParse(itemPriceController.text) ?? 0.0;

                    if (itemName.isNotEmpty && itemPrice > 0.0) {
                      DatabaseServices databaseServices = DatabaseServices();

                      databaseServices.insertAuditAttachment(
                          itemName, itemPrice);
                      print("Item inserted successfully");
                    } else {
                      print("Please enter a valid item name and price.");
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
