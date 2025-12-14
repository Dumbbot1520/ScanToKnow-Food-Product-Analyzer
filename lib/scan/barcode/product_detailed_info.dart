import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String image;
  final String health;
  final String price;
  final int novaScore;
  final String nutriScore;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.image,
    required this.health,
    required this.price,
    required this.novaScore,
    required this.nutriScore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Product Image
            Center(
              child: Image.asset(
                image,
                height: MediaQuery.of(context).size.height / 3,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Product Name & Price
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹$price",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            // Health Information
            Text(
              "Health Rating: $health",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
