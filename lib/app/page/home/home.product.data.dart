import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/data/sqlite.dart';
import 'package:flutter_api/app/model/cart.dart';
import 'package:flutter_api/app/model/product.dart';
import 'package:flutter_api/app/page/home/product.details.dart';

import 'package:flutter_api/mainpage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class HomeProductBuilder extends StatefulWidget {
  const HomeProductBuilder({super.key});

  @override
  State<HomeProductBuilder> createState() => _HomeProductBuilderState();
}

class _HomeProductBuilderState extends State<HomeProductBuilder> {
  final DatabaseHelper _databaseService = DatabaseHelper();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _updateCartItemCount();
    _productsFuture = _getProducts();
  }

  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getProduct(
      prefs.getString('accountID') ?? '',
      prefs.getString('token') ?? '',
    );
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
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final itemProduct = snapshot.data![index];
                return _buildProduct(itemProduct, context);
              },
            ),
          );
        } else {
          return const Center(
            child: Text('No products available.'),
          );
        }
      },
    );
  }

  Widget _buildProduct(ProductModel pro, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: pro),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    image: DecorationImage(
                      image: NetworkImage(pro.imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                pro.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                NumberFormat('#,##0').format(pro.price),
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  await _onAddCart(pro);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
