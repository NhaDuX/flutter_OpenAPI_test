import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/product/product.add.dart';
import 'package:flutter_api/app/page/product/product.data.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: const Center(child: ProductBuilder()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow.shade800,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => const ProductAdd(),
                  fullscreenDialog: true,
                ),
              )
              .then((_) => setState(() {}));
        },
        tooltip: 'Add New',
        child: const Icon(Icons.add),
      ),
    );
  }
}
