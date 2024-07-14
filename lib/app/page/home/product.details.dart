import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/sqlite.dart';
import 'package:flutter_api/app/model/cart.dart';
import 'package:flutter_api/app/model/product.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DatabaseHelper _databaseService = DatabaseHelper();
  ValueNotifier<int> cartItemCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _updateCartItemCount();
  }

  Future<void> _onAddCart(ProductModel pro) async {
    final cartItems = await _databaseService.products();
    Cart? existingCartItem =
        cartItems.firstWhereOrNull((item) => item.productID == pro.id);

    if (existingCartItem != null) {
      existingCartItem.count += 1;
      await _databaseService.updateProduct(existingCartItem);
    } else {
      await _databaseService.insertProduct(
        Cart(
          productID: pro.id,
          name: pro.name,
          des: pro.description,
          price: pro.price,
          img: pro.imageUrl,
          count: 1,
        ),
      );
    }

    _updateCartItemCount();
  }

  Future<void> _updateCartItemCount() async {
    final cartItems = await _databaseService.products();
    setState(() {
      cartItemCountNotifier.value =
          cartItems.fold(0, (sum, item) => sum + item.count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${NumberFormat('#,##0').format(product.price)} VND',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 172, 172, 172),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height:
                  238, // Set the desired height for the scrollable container
              child: SingleChildScrollView(
                child: Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _onAddCart(product),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Add to Cart'),
        ),
      ),
    );
  }
}
