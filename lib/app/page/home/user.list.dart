import 'package:flutter/material.dart';
import 'package:flutter_api/app/data/api.dart';
import 'package:flutter_api/app/model/user.admin.dart';
import 'package:flutter_api/app/page/home/detail.user.admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserA> users = [];
  APIRepository apiRepository = APIRepository();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers([String? query]) async {
    try {
      List<UserA> fetchedUsers;
      if (query != null && query.isNotEmpty) {
        fetchedUsers = await apiRepository.findByNumberID(query);
      } else {
        fetchedUsers = await apiRepository.fetchUsers();
      }
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching users: $e');
    }
  }

  Future<bool> _removeUser(String accountID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    return await apiRepository.removeUser(accountID, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by accountID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    fetchUsers(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: users.length,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      UserA user = users[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Card.outlined(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(user.fullName),
                            subtitle: Text(user.accountID),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool success =
                                    await _removeUser(user.accountID);
                                if (success) {
                                  fetchUsers();
                                } else {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Failed to delete user')),
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsScreen(
                                    accountID: user.accountID,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
