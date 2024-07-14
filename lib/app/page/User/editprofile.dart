import 'package:flutter_api/app/data/sharepre.dart';
import 'package:flutter_api/app/page/User/detail.dart';
import 'package:flutter_api/mainpage.dart';

import '/app/data/api.dart';
import '/app/model/user.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  final User user;

  const UpdateProfile({super.key, required this.user});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final int _gender = 0;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _numberIDController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _schoolKeyController = TextEditingController();
  final TextEditingController _schoolYearController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();
  reloadUser() async {
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiMDkyNjkyNzE2NCIsIklEIjoiMjFESDExNDM2NyIsImp0aSI6IjFkNzgxNDQxLTU2YWYtNGVhOC05YWZiLTZiMjE4OGVhYTM0NSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlN0dWRlbnQiLCJleHAiOjE3MjgzNzQzNTJ9.x77-4XJ8I-EMW4CJfMeS2r4hRNiwGzRLeAOr44Q4EVE";
    var user = await APIRepository().current(token);
    saveUser(user);
    //
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Mainpage(initialIndex: 4),
        ));
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName!;
    _numberIDController.text = widget.user.idNumber!;
    _phoneNumberController.text = widget.user.phoneNumber!;
    _genderController.text = widget.user.gender!;
    _schoolKeyController.text = widget.user.schoolKey!;
    _schoolYearController.text = widget.user.schoolYear!;
    _birthDayController.text = widget.user.birthDay!;
    _imageURLController.text = widget.user.imageURL ?? '';
  }

  Future<String> updateProfile() async {
    return await APIRepository().updateProfile(
      numberID: _numberIDController.text,
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      gender: _genderController.text,
      birthDay: _birthDayController.text,
      schoolYear: _schoolYearController.text,
      schoolKey: _schoolKeyController.text,
      imageURL:
          _imageURLController.text.isNotEmpty ? _imageURLController.text : null,
    );
  }

  getGender() {
    if (_gender == 1) {
      return "Male";
    } else if (_gender == 2) {
      return "Female";
    }
    return "Other";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text("Update Profile"),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                updateProfileWidget(),
                const SizedBox(height: 26),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            String response = await updateProfile();
                            if (response == "Cập nhật thành công") {
                              reloadUser();
                            } else {
                              print(response);
                            }
                          },
                          child: const Text('Update Profile'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: label.contains('Password'),
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            labelText: label,
            icon: Icon(icon),
            border: const OutlineInputBorder(),
            errorText: controller.text.trim().isEmpty ? 'Please enter' : null,
            focusedErrorBorder: controller.text.isEmpty
                ? const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red))
                : null,
            errorBorder: controller.text.isEmpty
                ? const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red))
                : null),
      ),
    );
  }

  Widget updateProfileWidget() {
    return Column(
      children: [
        textField(_fullNameController, "Full Name", Icons.text_fields_outlined),
        textField(_numberIDController, "NumberID", Icons.key),
        textField(_phoneNumberController, "PhoneNumber", Icons.phone),
        textField(_genderController, "Gender", Icons.sentiment_satisfied_alt),
        textField(_birthDayController, "BirthDay", Icons.date_range),
        textField(_schoolYearController, "SchoolYear", Icons.school),
        textField(_schoolKeyController, "SchoolKey", Icons.school),
        const SizedBox(height: 16),
        TextFormField(
          controller: _imageURLController,
          decoration: const InputDecoration(
            labelText: "Image URL",
            icon: Icon(Icons.image),
          ),
        ),
      ],
    );
  }
}
