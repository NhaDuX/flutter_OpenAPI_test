import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_api/app/page/User/editprofile.dart';
import '../../model/user.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.imageURL!),
                    radius: 40,
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProfile(user: user),
                            ),
                          );
                        },
                        child: const Text(
                          "✏️ Edit Profile",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Personal Info",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Teams",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                  Icons.person, "Username", user.fullName, _blueColor),
              _buildInfoRow(Icons.assignment_ind_rounded, "NumberID",
                  user.idNumber, _blueColor),
              _buildInfoRow(
                  Icons.phone, "Phone Number", user.phoneNumber, _blueColor),
              _buildInfoRow(Icons.person, "Gender", user.gender, _blueColor),
              _buildInfoRow(
                  Icons.calendar_today, "Birth Day", user.birthDay, _blueColor),
              _buildInfoRow(
                  Icons.school, "School Year", user.schoolYear, _blueColor),
              _buildInfoRow(
                  Icons.vpn_key, "School Key", user.schoolKey, _blueColor),
              _buildInfoRow(Icons.date_range, "Date Created", user.dateCreated,
                  _blueColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String? value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Icon(icon, color: Colors.grey),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black, // Change text color to black
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final Color _blueColor = const Color(0xFF0000FF); // Blue color from the logo
}
