import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponsCount extends StatefulWidget {
  const CouponsCount({Key? key}) : super(key: key);

  @override
  _CouponsCountState createState() => _CouponsCountState();
}

class _CouponsCountState extends State<CouponsCount> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _totalCoupons = 0;
  Map<String, int> _couponsByRestaurant = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      int totalCoupons = await getTotalCoupons();
      Map<String, int> couponsByRestaurant = await getCouponsByRestaurant();

      setState(() {
        _totalCoupons = totalCoupons;
        _couponsByRestaurant = couponsByRestaurant;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<int> getTotalCoupons() async {
    QuerySnapshot snapshot = await _db.collection('Coupons').get();
    return snapshot.size;
  }

  Future<Map<String, int>> getCouponsByRestaurant() async {
    QuerySnapshot snapshot = await _db.collection('Coupons').get();
    Map<String, int> restaurantCount = {};

    for (var doc in snapshot.docs) {
      String dealID = doc['DealID'];
      DocumentSnapshot dealDoc = await _db.collection('Deals').doc(dealID).get();
      String restaurantName = dealDoc['Vendor Name'];

      if (restaurantCount.containsKey(restaurantName)) {
        restaurantCount[restaurantName] = restaurantCount[restaurantName]! + 1;
      } else {
        restaurantCount[restaurantName] = 1;
      }
    }
    return restaurantCount;
  }

  Future<void> showCouponsByRestaurant(String restaurantName) async {
    QuerySnapshot snapshot = await _db.collection('Coupons').get();
    Map<String, int> dealCount = {};

    for (var doc in snapshot.docs) {
      String dealID = doc['DealID'];
      DocumentSnapshot dealDoc = await _db.collection('Deals').doc(dealID).get();
      String currentRestaurantName = dealDoc['Vendor Name'];

      if (currentRestaurantName == restaurantName) {
        String couponName = dealDoc['Coupon Name'];
        if (dealCount.containsKey(couponName)) {
          dealCount[couponName] = dealCount[couponName]! + 1;
        } else {
          dealCount[couponName] = 1;
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Coupons for $restaurantName'),
          content: SingleChildScrollView(
            child: ListBody(
              children: dealCount.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4131),
        title: const Text('Coupons Count'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Total Coupons: $_totalCoupons',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              ..._couponsByRestaurant.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showCouponsByRestaurant(entry.key),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: Text('${entry.key}: ${entry.value} coupons',style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
