import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Users/ManageUsers.dart';
import 'Report/ViewReports.dart';
import 'Coupons/ManageCoupons.dart';
import 'package:charmassignment/Login.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _username = "Loading...";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['fullName'] ?? 'No Name';
          });
        } else {
          setState(() {
            _username = 'No user data found';
          });
        }
      }
    } catch (e) {
      setState(() {
        _username = 'Error loading user data';
      });
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
  }

  void _navigateToManageUsers() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageUsers()));
  }

  void _navigateToViewReports() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ViewReports()));
  }

  void _navigateToManageCoupons() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCoupons()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFF4131),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF000000)),
          bodyMedium: TextStyle(color: Color(0xFF000000)),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFFF4131),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF4131),
          title: const Text('Admin Dashboard', style: TextStyle(color: Color(0xFF000000))),
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 4,
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, $_username',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                    icon: Icons.group,
                    label: 'Manage Users',
                    onPressed: _navigateToManageUsers,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    icon: Icons.bar_chart,
                    label: 'View Reports',
                    onPressed: _navigateToViewReports,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    icon: Icons.card_giftcard,
                    label: 'Manage Coupons',
                    onPressed: _navigateToManageCoupons,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFFFFFFFF)),
        label: Text(label, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4131),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
