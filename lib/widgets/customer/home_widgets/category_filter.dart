// lib/features/customer/home/widgets/category_filter.dart
import 'package:flutter/material.dart';
import '../../../data/config/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length + 1,
          itemBuilder: (context, i) {
            final c = i == 0 ? 'All' : categories[i - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c),
                selected: selected == c,
                onSelected: (_) => onSelect(c),
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
