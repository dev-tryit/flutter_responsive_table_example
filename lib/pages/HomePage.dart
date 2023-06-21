import 'package:flutter/material.dart';
import 'package:responsive_table_example/widgets/CustomTable.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = CustomTableDataController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          controller.appendDataList(List.generate(
            300,
            (i) => {
              "id": i,
              "sku": "$i\000$i",
              "name": "Product $i",
              "category": "Category-$i",
              "price": i * 10.00,
              "cost": "20.00",
              "margin": "${i}0.20",
              "in_stock": "${i}0",
              "alert": "5",
              "received": [i + 20, 150]
            },
          ));
        },
      ),
      body: Card(
        elevation: 1,
        shadowColor: Colors.black,
        clipBehavior: Clip.none,
        // child: ExampleTable(),
        child: CustomTable(controller: controller),
      ),
    );
  }
}
