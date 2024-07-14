// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/data/sqlite.dart';
import 'package:flutter_api/app/model/cart.dart';
import 'package:flutter_api/app/model/product.dart';
import 'package:flutter_api/app/page/product/product.add.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProductBuilder extends StatefulWidget {
  const ProductBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductBuilder> createState() => _ProductBuilderState();
}

class _ProductBuilderState extends State<ProductBuilder> {
  final DatabaseHelper _databaseService = DatabaseHelper();
  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getProduct(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());
  }

  Future<void> _onAddCart(ProductModel pro) async {
    _databaseService.insertProduct(Cart(
        productID: pro.id,
        name: pro.name,
        des: pro.description,
        price: pro.price,
        img: pro.imageUrl,
        count: 1));
    setState(() {});
  }

  Future<void> _deleteProduct(ProductModel pro) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool success = await APIRepository().removeProduct(
        pro.id,
        pref.getString('accountID').toString(),
        pref.getString('token').toString());
    if (success) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final itemProduct = snapshot.data![index];
              return _buildProduct(itemProduct, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildProduct(ProductModel pro, BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(pro.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
              alignment: Alignment.center,
              // child: Image(
              //     width: 128,
              //     height: 128,
              //     fit: BoxFit.cover,
              //     image: FileImage(File(pro.imageUrl))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pro.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    NumberFormat('#,##0').format(pro.price),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.red,
                    ),
                  ),
                  // const SizedBox(height: 4.0),
                  // Text('Category: ${pro.catId}'),
                  const SizedBox(height: 4.0),
                  //Text('Description: ' + pro.description),
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductAdd(
                                      isUpdate: true,
                                      productModel: pro,
                                    ),
                                    fullscreenDialog: true,
                                  ),
                                )
                                .then((_) => setState(() {}));
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.yellow.shade800,
                        )),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        bool confirm = await _showConfirmationDialog(context);
                        if (confirm) {
                          await _deleteProduct(pro);
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Bạn có muốn xoá sản phẩm không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Không'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Có'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
