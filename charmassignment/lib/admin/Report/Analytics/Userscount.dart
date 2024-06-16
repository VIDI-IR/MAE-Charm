import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCount extends StatefulWidget {
  const UsersCount({Key? key}) : super(key: key);

  @override
  _UsersCountState createState() => _UsersCountState();
}

class _UsersCountState extends State<UsersCount> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _totalUsers = 0;
  Map<String, int> _userRolesCount = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      int totalUsers = await getTotalUsers();
      Map<String, int> userRolesCount = await getUserRolesCount();

      setState(() {
        _totalUsers = totalUsers;
        _userRolesCount = userRolesCount;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<int> getTotalUsers() async {
    QuerySnapshot snapshot = await _db.collection('Users').get();
    return snapshot.size;
  }

  Future<Map<String, int>> getUserRolesCount() async {
    QuerySnapshot snapshot = await _db.collection('Users').get();
    Map<String, int> rolesCount = {};
    for (var doc in snapshot.docs) {
      String role = doc['role'];
      if (rolesCount.containsKey(role)) {
        rolesCount[role] = rolesCount[role]! + 1;
      } else {
        rolesCount[role] = 1;
      }
    }
    return rolesCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4131),
        title: const Text('User Count'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Total Users: $_totalUsers',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              ..._userRolesCount.entries.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
