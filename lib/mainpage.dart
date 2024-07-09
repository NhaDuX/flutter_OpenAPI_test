import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/category/categorylist.screen.dart';
import 'package:flutter_api/app/page/home/user.list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '/app/model/category.dart';
import '/app/model/user.dart';
import 'app/page/User/detail.dart';
import '/app/route/page1.dart';
import '/app/route/page2.dart';
import '/app/route/page3.dart';
import 'app/page/defaultwidget.dart';
import 'app/data/sharepre.dart';
// Import DisplayCategories

class Mainpage extends StatefulWidget {
  final int initialIndex;
  const Mainpage({super.key, this.initialIndex = 0});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  late int _selectedIndex;
  User user = User.userEmpty();

  getDataUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String strUser = pref.getString('user')!;

    user = User.fromJson(jsonDecode(strUser));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    getDataUser();
    if (kDebugMode) {
      print(user.imageURL);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _loadWidget(int index) {
    switch (index) {
      case 0:
        return UserListScreen();
      case 1:
        return const CategoryList();
      case 2:
        return const DefaultWidget(title: "Shop");
      case 3:
        return const Detail();
      default:
        return const DefaultWidget(title: "None");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text("HL Mobile"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 243, 152, 33),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  user.imageURL!.length < 5
                      ? const SizedBox()
                      : CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            user.imageURL!,
                          )),
                  const SizedBox(
                    height: 8,
                  ),
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
              leading: const Icon(Icons.shop),
              title: const Text('Shop'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Page1()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Page2()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text(''),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Page3()));
              },
            ),
            const Divider(
              color: Colors.black,
            ),
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
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.category_rounded, size: 30),
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
