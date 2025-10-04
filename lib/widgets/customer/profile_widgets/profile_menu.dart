import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:jpmfood/data/models/profile_menu_item_model.dart';

class ProfileMenu extends StatelessWidget {
  final List<MenuSection> menuSections;

  const ProfileMenu({Key? key, required this.menuSections}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...menuSections
              .map(
                (section) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MenuGroup(items: section.items),
                    const SizedBox(height: 24),
                  ],
                ),
              )
              .toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MenuSection {
  final String title;
  final List<ProfileMenuItem> items;

  MenuSection({required this.title, required this.items});
}

class MenuGroup extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const MenuGroup({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item.textColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.textColor ?? AppColors.primary,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: item.textColor ?? Colors.black87,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: Colors.grey[200]),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
