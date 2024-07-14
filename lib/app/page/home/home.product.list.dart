import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/home/home.product.data.dart';

class HomeProductList extends StatefulWidget {
  const HomeProductList({super.key});

  @override
  State<HomeProductList> createState() => _HomeProductListState();
}

class _HomeProductListState extends State<HomeProductList> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Center(child: HomeProductBuilder()),
    );
  }
}
