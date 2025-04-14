import 'package:flutter/material.dart';

class SubscriptionStatus extends StatelessWidget {
  final String planName;
  final bool isActive;

  const SubscriptionStatus({
    super.key,
    required this.planName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.deepPurple, size: 28),
                const SizedBox(width: 10),
                Text(
                  planName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? "✅ Active" : "❌ Inactive",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isActive
                  ? "🎉 Your subscription is active. Enjoy all features included in the $planName plan."
                  : "⚠️ Your subscription is inactive. Please renew or upgrade to continue using premium features.",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
