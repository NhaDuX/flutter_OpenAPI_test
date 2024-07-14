import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/model/user.admin.dart';

class UserDetailsScreen extends StatefulWidget {
  final String accountID;

  UserDetailsScreen({required this.accountID});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<UserA> _user;

  @override
  void initState() {
    super.initState();
    _user = _fetchUser();
  }

  Future<UserA> _fetchUser() async {
    List<UserA> users = await APIRepository().fetchUsers();
    return users.firstWhere((user) => user.accountID == widget.accountID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('User Details'),
      ),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.center,
          ),
          const SizedBox(
            height: 100,
          ),
          FutureBuilder<UserA>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('User not found'));
              } else {
                UserA user = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                        Container(
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                user.imageUrl!,
                              ),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined,
                              size: 60, color: Colors.grey),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Full Name: ${user.fullName}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('Account ID: ${user.accountID}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('Birthday: ${user.birthDay}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('Gender: ${user.gender}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('Phone Number: ${user.phoneNumber}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('Date Created: ${user.dateCreated}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('School Year: ${user.schoolYear}',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text('School Key: ${user.schoolKey}',
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
