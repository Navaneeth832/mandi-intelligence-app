import 'package:flutter/material.dart';
import '../../../data/models/mandi_price.dart';
class MandiPriceCard extends StatelessWidget {
  final MandiPrice price;

  const MandiPriceCard({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  price.commodity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  price.market,
                  style: const TextStyle(fontSize: 10),
                ),
              )
            ],
          ),

          const SizedBox(height: 4),

          Text(
            price.variety,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                _priceColumn(
                  "High",
                  "₹${price.maxPrice}",
                  Colors.green,
                  Icons.arrow_drop_up,
                ),
                _priceColumn(
                  "Modal",
                  "₹${price.modalPrice}",
                  Colors.black,
                  null,
                ),
                _priceColumn(
                  "Low",
                  "₹${price.minPrice}",
                  Colors.red,
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _priceColumn(
    String label,
    String value,
    Color color,
    IconData? icon,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
            if (icon != null)
              Icon(icon,
                  color: color, size: 18),
          ],
        ),
      ],
    );
  }
}