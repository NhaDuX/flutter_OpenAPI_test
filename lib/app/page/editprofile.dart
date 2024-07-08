import 'package:flutter_api/app/page/detail.dart';

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
  final TextEditingController _schoolKeyController = TextEditingController();
  final TextEditingController _schoolYearController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _imageURLController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullName!;
    _numberIDController.text = widget.user.idNumber!;
    _phoneNumberController.text = widget.user.phoneNumber!;
    _schoolKeyController.text = widget.user.schoolKey!;
    _schoolYearController.text = widget.user.schoolYear!;
    _birthDayController.text = widget.user.birthDay!;
    _imageURLController.text = widget.user.imageURL ?? '';
  }

  Future<String> updateProfile() async {
    return await APIRepository().updateProfile(
      //token: widget.token as String,
      numberID: _numberIDController.text,
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      //gender: getGender(),
      birthDay: _birthDayController.text,
      schoolYear: _schoolYearController.text,
      schoolKey: _schoolKeyController.text,
      imageURL:
          _imageURLController.text.isNotEmpty ? _imageURLController.text : null,
    );
  }

  int getGender(String gender) {
    if (gender == "Male") {
      return 1;
    } else if (gender == "Female") {
      return 2;
    }
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Update Profile Info',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                updateProfileWidget(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          String response = await updateProfile();
                          if (response == "Cập nhật thành công") {
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Detail(),
                              ),
                            );
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
          setState(() {
            // Update the temp variable if needed
          });
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
