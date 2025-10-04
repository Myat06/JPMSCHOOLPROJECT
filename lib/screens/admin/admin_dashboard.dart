import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import 'category_management_screen.dart';
import 'menu_item_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OrdersManagementTab(),
    const MenuManagementTab(),
    const AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        // Initialize menu provider with admin ID when dashboard loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final authProvider = context.read<AuthProvider>();

          if (authProvider.currentUser != null &&
              menuProvider.currentAdminId == null) {
            menuProvider.setAdminId(authProvider.currentUser!.uid);
          }
        });

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Text(
              'Admin Dashboard - ${authProvider.currentUser?.name ?? 'Admin'}',
            );
          },
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    '247',
                    Icons.shopping_bag,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Revenue',
                    '\$1,240',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Orders',
                    '12',
                    Icons.timer,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Menu Items',
                    '45',
                    Icons.restaurant_menu,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to orders tab or detailed view
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOrderCard(
              '#ORD001',
              'John Doe',
              '\$24.99',
              'Preparing',
              AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildOrderCard(
              '#ORD002',
              'Jane Smith',
              '\$18.50',
              'Ready',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildOrderCard(
              '#ORD003',
              'Mike Johnson',
              '\$32.75',
              'Delivered',
              Colors.blue,
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Add Menu Item',
                    Icons.add_circle,
                    Colors.green,
                    () {
                      // TODO: Navigate to add menu item
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'View Analytics',
                    Icons.analytics,
                    Colors.blue,
                    () {
                      // TODO: Navigate to analytics
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    String orderId,
    String customer,
    String amount,
    String status,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.receipt_long, color: color),
        ),
        title: Text(orderId),
        subtitle: Text(customer),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(status, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Orders Management Tab ----------------
class OrdersManagementTab extends StatelessWidget {
  const OrdersManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Orders"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("Order #ORD001"),
              subtitle: const Text("John Doe - Preparing"),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  // TODO: Mark order as completed
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Order #ORD002"),
              subtitle: const Text("Jane Smith - Ready"),
              trailing: IconButton(
                icon: const Icon(Icons.delivery_dining, color: Colors.blue),
                onPressed: () {
                  // TODO: Update status to delivered
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Menu Management Tab ----------------
class MenuManagementTab extends StatelessWidget {
  const MenuManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Menu"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Categories',
                        '${menuProvider.categories.length}',
                        Icons.category,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Menu Items',
                        '${menuProvider.menuItems.length}',
                        Icons.restaurant_menu,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Management Options
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildManagementCard(
                        'Categories',
                        'Manage food categories',
                        Icons.category,
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategoryManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _buildManagementCard(
                        'Menu Items',
                        'Manage menu items',
                        Icons.restaurant_menu,
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MenuItemManagementScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Recent Menu Items
                if (menuProvider.menuItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Menu Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...menuProvider.menuItems
                      .take(3)
                      .map(
                        (item) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isAvailable
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                Icons.restaurant,
                                color: item.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              '\$${item.price.toStringAsFixed(2)} • ${item.category}',
                            ),
                            trailing: Text(
                              item.isAvailable ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                color: item.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Admin Profile Tab ----------------
class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(authProvider.currentUser?.name ?? "Admin"),
              subtitle: Text(
                authProvider.currentUser?.email ?? "admin@example.com",
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go("/login");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
