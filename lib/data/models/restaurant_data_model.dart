import 'category_model.dart';
import 'menu_item_model.dart';

// Data class to hold restaurant information with menu
class RestaurantData {
  final String adminId;
  final String adminName;
  final String adminEmail;
  final List<CategoryModel> categories;
  final List<MenuItemModel> menuItems;

  RestaurantData({
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.categories,
    required this.menuItems,
  });

  // Get menu items grouped by category
  Map<String, List<MenuItemModel>> get menuItemsByCategory {
    Map<String, List<MenuItemModel>> grouped = {};
    for (var item in menuItems) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    return grouped;
  }
}
