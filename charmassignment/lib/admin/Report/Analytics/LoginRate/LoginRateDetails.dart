import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class LoginRateDetails extends StatelessWidget {
  final String period;
  final String? day;
  final String? month;
  final String year;

  const LoginRateDetails({
    required this.period,
    this.day,
    this.month,
    required this.year,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4131),
        title: Text('$period Login Count', style: const TextStyle(color: Color(0xFF000000))),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _calculateLoginCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available', style: TextStyle(color: Color(0x0000000))));
          }

          final loginCounts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: loginCounts.entries.map((entry) {
              return ListTile(
                title: Text(entry.key, style: const TextStyle(color: Colors.black)),
                trailing: Text('${entry.value}', style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<Map<String, int>> _calculateLoginCount() async {
    final userCollection = FirebaseFirestore.instance.collection('Users');
    final loginInfoCollection = FirebaseFirestore.instance.collection('LoginInfo');

    final userDocs = await userCollection.get();
    final loginInfoDocs = await loginInfoCollection.get();

    final roleLoginCount = <String, int>{};

    DateTime startTime, endTime;
    if (period == 'daily') {
      startTime = DateTime(int.parse(year), int.parse(month!), int.parse(day!)).add(Duration(hours: -8));
      endTime = startTime.add(Duration(days: 1)).subtract(Duration(seconds: 1));
    } else if (period == 'monthly') {
      startTime = DateTime(int.parse(year), int.parse(month!)).add(Duration(hours: -8));
      endTime = DateTime(int.parse(year), int.parse(month!) + 1).subtract(Duration(seconds: 1)).add(Duration(hours: 0));
    } else {
      startTime = DateTime(int.parse(year)).add(Duration(hours: 8));
      endTime = DateTime(int.parse(year) + 1).subtract(Duration(seconds: 1)).add(Duration(hours: -8));
    }

    print('Start time: $startTime'); // Debugging log
    print('End time: $endTime'); // Debugging log

    for (var loginDoc in loginInfoDocs.docs) {
      final loginTime = (loginDoc.data()['loginTime'] as Timestamp).toDate();
      print('Login time: $loginTime'); // Debugging log
      if (loginTime.isAfter(startTime) && loginTime.isBefore(endTime)) {
        final uid = loginDoc.data()['uid'] as String;
        final userDoc = userDocs.docs.firstWhereOrNull((doc) => doc.id == uid);

        if (userDoc != null) {
          final role = userDoc.data()['role'] as String;
          roleLoginCount[role] = (roleLoginCount[role] ?? 0) + 1;
        }
      }
    }

    print('Role login count: $roleLoginCount'); // Debugging log

    return roleLoginCount;
  }
}
