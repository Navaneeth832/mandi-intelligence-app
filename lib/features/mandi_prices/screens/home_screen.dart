import 'package:flutter/material.dart';

import '../widgets/price_card.dart';
import '../../../data/models/mandi_price.dart';

final mandiData = [
  MandiPrice(
    commodity: "Tomato",
    variety: "Hybrid",
    market: "Ernakulam",
    district: "Ernakulam",
    state: "Kerala",
    minPrice: 38,
    modalPrice: 42,
    maxPrice: 45,
    arrivalDate: DateTime.now(),
  ),
];
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Markets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Revin Sight",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.account_tree,
                    size: 36,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Live Mandi Prices",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      Text("October 26, 2023")
                    ],
                  )
                ],
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "◷ Last updated: 5 mins ago",
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Chip(
                    label:
                        Text("Crop (Tomato)"),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label:
                        Text("State (Kerala)"),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.builder(
                  itemCount: mandiData.length,
                  itemBuilder:
                      (context, index) =>
                          MandiPriceCard(
                    price: mandiData[index],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}