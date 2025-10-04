import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final String totalOrders;
  final DateTime? joinDate;

  const ProfileStats({Key? key, required this.totalOrders, this.joinDate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.shopping_bag,
              title: 'Total Orders',
              value: totalOrders,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              icon: Icons.calendar_today,
              title: 'Member Since',
              value: _formatMemberSince(),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince() {
    final memberSinceDate =
        joinDate ?? DateTime.now().subtract(const Duration(days: 180));
    final now = DateTime.now();
    final difference = now.difference(memberSinceDate).inDays;

    if (difference < 30) {
      return '${difference} days';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '${months} month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference / 365).floor();
      return '${years} year${years > 1 ? 's' : ''}';
    }
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
