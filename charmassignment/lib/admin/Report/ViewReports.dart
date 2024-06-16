import 'package:flutter/material.dart';
import 'Analytics/UsersCount.dart';
import 'Analytics/CouponsCount.dart';
import 'Analytics/LoginRate/LoginRateSelection.dart'; // Import the new LoginRate page

class ViewReports extends StatelessWidget {
  const ViewReports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4131),
        title: const Text('View Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsersCount()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4131),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'View User Count',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CouponsCount()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4131),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'View Coupons Count',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginRateSelection()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4131),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'View Login Rate',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
