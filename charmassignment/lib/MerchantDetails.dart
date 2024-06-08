import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Coupons.dart';

class MerchantDetails extends StatefulWidget {
  final String dealId;
  final String username;  // Add this line

  const MerchantDetails({Key? key, required this.dealId, required this.username}) : super(key: key);

  @override
  _MerchantDetailsState createState() => _MerchantDetailsState();
}

class _MerchantDetailsState extends State<MerchantDetails> {
  bool isLoading = true;
  Map<String, dynamic>? dealData;

  @override
  void initState() {
    super.initState();
    fetchDealData();
  }

  Future<void> fetchDealData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Deals')
          .doc(widget.dealId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        dealData = snapshot.data() as Map<String, dynamic>;
        setState(() => isLoading = false);
      } else {
        throw Exception('Deal not found');
      }
    } catch (e) {
      print('Error fetching deal: $e');
      Navigator.pop(context);
    }
  }

  Future<void> _getCoupon() async {
    if (dealData != null && dealData!['Coupon Number'] > 0) {
      String updatedCouponNumber = (dealData!['Coupon Number'] - 1).toString();
      String couponCode = dealData!['Coupon Code'];

      await FirebaseFirestore.instance.collection('Deals').doc(widget.dealId).update({
        'Coupon Number': int.parse(updatedCouponNumber)
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Coupons(
            collectionId: widget.dealId,
            username: widget.username,  // Pass username to Coupons page
            category: dealData!['Category'],
            restaurant: dealData!['Vendor Name'],
            date: DateTime.now().toString(),
            couponCode: couponCode,
          )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No coupons available for this deal."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(dealData?['Vendor Name'] ?? 'Vendor Details',
                  style: const TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            body: CustomScrollView(
              slivers: [
                _buildImageSection(dealData?['Deal Image'] ?? ''),
                _buildDetailsSection(dealData?['Category'] ?? 'N/A', dealData?['Rating'].toString() ?? 'N/A'),
                _buildCouponDetails(dealData?['Description'] ?? ''),
                _buildReviewSection(),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context),
          );
  }

  Widget _buildImageSection(String imageUrl) => SliverToBoxAdapter(
        child: Image.network(
          imageUrl,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Image.asset('assets/images/default.png', fit: BoxFit.cover),
        ),
      );

  Widget _buildDetailsSection(String category, String rating) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(category, style: const TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  Text(' $rating', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildCouponDetails(String description) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coupon Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );

  Widget _buildReviewSection() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Leave Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Implement review submission logic
                },
                child: const Text('Submit Review', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      );

  Widget _buildBottomBar(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _getCoupon,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer, color: Colors.white),
              Text(' Get Coupon', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      );
}
