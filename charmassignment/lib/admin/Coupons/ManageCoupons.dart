import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCoupons extends StatefulWidget {
  const ManageCoupons({Key? key}) : super(key: key);

  @override
  _ManageCouponsState createState() => _ManageCouponsState();
}

class _ManageCouponsState extends State<ManageCoupons> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteCoupon(String couponId) async {
    await _firestore.collection('Coupons').doc(couponId).delete();
    setState(() {}); // Refresh the page
  }

  Future<void> _deleteDeal(String dealId) async {
    // Delete the deal
    await _firestore.collection('Deals').doc(dealId).delete();

    // Delete all associated coupons
    QuerySnapshot couponSnapshot = await _firestore.collection('Coupons').where('DealID', isEqualTo: dealId).get();
    for (var couponDoc in couponSnapshot.docs) {
      await _firestore.collection('Coupons').doc(couponDoc.id).delete();
    }

    setState(() {}); // Refresh the page
  }

  Future<Map<String, Map<String, dynamic>>> _fetchCouponsAndDeals() async {
    QuerySnapshot couponsSnapshot = await _firestore.collection('Coupons').get();
    QuerySnapshot dealsSnapshot = await _firestore.collection('Deals').get();

    Map<String, Map<String, dynamic>> groupedCoupons = {};

    Map<String, Map<String, dynamic>> deals = {
      for (var doc in dealsSnapshot.docs) doc.id: doc.data() as Map<String, dynamic>
    };

    for (var couponDoc in couponsSnapshot.docs) {
      var couponData = couponDoc.data() as Map<String, dynamic>;
      var dealId = couponData['DealID'] as String;
      var dealData = deals[dealId];

      if (dealData != null) {
        var restaurant = dealData['Vendor Name'] ?? 'Unknown Restaurant';
        var dealName = dealData['Coupon Name'] ?? 'Unknown Deal';

        if (!groupedCoupons.containsKey(restaurant)) {
          groupedCoupons[restaurant] = {};
        }
        if (!groupedCoupons[restaurant]!.containsKey(dealName)) {
          groupedCoupons[restaurant]![dealName] = {
            'details': dealData,
            'coupons': []
          };
        }
        couponData['CollectionID'] = couponDoc.id; // Add the document ID to the coupon data
        groupedCoupons[restaurant]![dealName]['coupons'].add(couponData);
      }
    }

    return groupedCoupons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Manage Coupons'),
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _fetchCouponsAndDeals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var groupedCoupons = snapshot.data!;
          if (groupedCoupons.isEmpty) {
            return const Center(child: Text('No coupons available.'));
          }
          return ListView(
            children: groupedCoupons.keys.map((restaurant) {
              return ExpansionTile(
                title: Text(restaurant, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                children: groupedCoupons[restaurant]!.keys.map((dealName) {
                  var dealData = groupedCoupons[restaurant]![dealName]['details'];
                  var coupons = groupedCoupons[restaurant]![dealName]['coupons'];
                  return ExpansionTile(
                    title: Text(dealName, style: const TextStyle(fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deal ID: ${dealData['DealID']}'),
                        Text('Description: ${dealData['Description']}'),
                        Image.network(dealData['Deal Image']),
                        Text('Category: ${dealData['Category']}'),
                        Text('Google Maps Link: ${dealData['Google Maps Link']}'),
                        Image.network(dealData['Merchant photo']),
                        Text('Rating: ${dealData['Rating']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDeal(dealData['DealID']),
                    ),
                    children: coupons.map<Widget>((couponData) {
                      return ListTile(
                        title: Text('Coupon Code: ${couponData['Coupon Code']}'),
                        subtitle: Text('Status: ${couponData['Status']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCoupon(couponData['CollectionID']),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
