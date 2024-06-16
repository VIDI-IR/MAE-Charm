import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4131),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Manage Users'),
      ),
      body: Container(
        color: Colors.white, 
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: user['profilePhoto'] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user['profilePhoto']),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                  title: Text(
                    user['fullName'] ?? 'No Name',
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    user['role'] ?? 'No Role',
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditUserDialog(context, users[index].id, user);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _firestore.collection('Users').doc(users[index].id).delete();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showUserInfoDialog(context, user);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user['fullName'] ?? 'No Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Role: ${user['role'] ?? 'No Role'}'),
              if (user['profilePhoto'] != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user['profilePhoto']),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> user) {
    TextEditingController fullNameController = TextEditingController(text: user['fullName']);
    TextEditingController roleController = TextEditingController(text: user['role']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _firestore.collection('Users').doc(userId).update({
                  'fullName': fullNameController.text,
                  'role': roleController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: ManageUsers(),
  ));
}
