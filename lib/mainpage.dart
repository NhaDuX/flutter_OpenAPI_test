import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/cart/cart.dart';
import 'package:flutter_api/app/page/category/categorylist.screen.dart';
import 'package:flutter_api/app/page/history/history_screen.dart';
import 'package:flutter_api/app/page/home/home.product.list.dart';
import 'package:flutter_api/app/page/user.admin/user.list.dart';
import 'package:flutter_api/app/page/product/product.list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '/app/model/user.dart';
import 'app/page/user/detail.dart';
import 'app/data/sharepre.dart';
import 'package:flutter_api/app/data/sqlite.dart';

ValueNotifier<int> cartItemCountNotifier = ValueNotifier<int>(0);

class Mainpage extends StatefulWidget {
  final int initialIndex;
  const Mainpage({super.key, this.initialIndex = 0});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  late int _selectedIndex;
  User user = User.userEmpty();
  int _cartItemCount = 0;

  Future<void> getDataUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? strUser = pref.getString('user');
    if (strUser != null) {
      user = User.fromJson(jsonDecode(strUser));
      setState(() {});
    }
  }

  Future<void> _updateCartItemCount() async {
    final cartItems = await DatabaseHelper().products();
    _cartItemCount = cartItems.fold(0, (sum, item) => sum + item.count);
    cartItemCountNotifier.value = _cartItemCount;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    getDataUser();
    _updateCartItemCount();
    cartItemCountNotifier.addListener(() {
      setState(() {
        _cartItemCount = cartItemCountNotifier.value;
      });
    });
    if (kDebugMode) {
      print(user.imageURL);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _loadWidget(int index) {
    switch (index) {
      case 0:
        return const HomeProductList();
      case 1:
        return const CategoryList();
      case 2:
        return const HistoryScreen();
      case 3:
        return const ProductList();
      case 4:
        return const Detail();
      default:
        return const HomeProductList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text("HL Mobile"),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: cartItemCountNotifier,
            builder: (context, count, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      ).then((_) => _updateCartItemCount());
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F6FA),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 218, 218, 218),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.imageURL!.length >= 5)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.imageURL!),
                    ),
                  const SizedBox(height: 8),
                  Text(user.fullName!),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_rounded),
              title: const Text('Category'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text('User List'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
            const Divider(color: Color.fromARGB(255, 156, 156, 157)),
            user.accountId == ''
                ? const SizedBox()
                : ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Logout'),
                    onTap: () {
                      logOut(context);
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 70.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.category_rounded, size: 30),
          Icon(Icons.history, size: 30),
          Icon(Icons.shop, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: _onItemTapped,
      ),
      body: _loadWidget(_selectedIndex),
    );
  }
}
