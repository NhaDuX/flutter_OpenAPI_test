import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/editprofile.dart';
import '../model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
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
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.imageURL!),
                    radius: 80,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProfile(user: user),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                user.fullName!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoRow("NumberID", user.idNumber, _blueColor),
              _buildInfoRow("Fullname", user.fullName, _blueColor),
              _buildInfoRow("Phone Number", user.phoneNumber, _blueColor),
              _buildInfoRow("Gender", user.gender, _blueColor),
              _buildInfoRow("Birth Day", user.birthDay, _blueColor),
              _buildInfoRow("School Year", user.schoolYear, _blueColor),
              _buildInfoRow("School Key", user.schoolKey, _blueColor),
              _buildInfoRow("Date Created", user.dateCreated, _blueColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(
                  fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  final Color _blueColor = const Color(0xFF0000FF); // Blue color from the logo
}
