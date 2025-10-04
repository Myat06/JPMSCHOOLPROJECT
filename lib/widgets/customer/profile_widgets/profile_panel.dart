import 'package:flutter/material.dart';
import 'package:jpmfood/data/models/profile_menu_item_model.dart';
import 'package:jpmfood/providers/customer_provider.dart';
import 'package:jpmfood/widgets/customer/profile_widgets/profile_dialogs.dart';
import 'package:jpmfood/widgets/customer/profile_widgets/profile_header.dart';
import 'package:jpmfood/widgets/customer/profile_widgets/profile_menu.dart';
import 'package:jpmfood/widgets/customer/profile_widgets/profile_starts.dart';
import 'package:provider/provider.dart';
import 'package:jpmfood/providers/auth_provider.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({Key? key}) : super(key: key);

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load user profile data here if needed
      // context.read<CustomerProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer2<CustomerProvider, AuthProvider>(
        builder: (context, customerProvider, authProvider, child) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with Profile Info
                ProfileHeader(
                  userName: user?.name ?? 'User Name',
                  userEmail: user?.email ?? 'user@email.com',
                  loyaltyPoints:
                      '0', // Replace with actual data or fetch from Firestore if available
                  profileImageUrl: user?.profileImageUrl,
                  onEditPressed: () =>
                      ProfileDialogs.showEditProfileDialog(context),
                ),

                // Stats Cards
                ProfileStats(
                  totalOrders: '0', // Replace with actual data
                  joinDate: user?.createdAt,
                ),

                // Menu Options
                ProfileMenu(menuSections: _buildMenuSections()),
              ],
            ),
          );
        },
      ),
    );
  }

  List<MenuSection> _buildMenuSections() {
    return [
      MenuSection(
        title: 'Account Settings',
        items: [
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your personal details',
            onTap: () => ProfileDialogs.showPersonalInfoDialog(context),
          ),
          ProfileMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Delivery Addresses',
            subtitle: 'Manage your delivery locations',
            onTap: () => ProfileDialogs.showComingSoonSnackBar(
              context,
              'Address management',
            ),
          ),
          ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage cards and payment options',
            onTap: () => ProfileDialogs.showComingSoonSnackBar(
              context,
              'Payment methods',
            ),
          ),
        ],
      ),
      MenuSection(
        title: 'Order History',
        items: [
          ProfileMenuItem(
            icon: Icons.history,
            title: 'Order History',
            subtitle: 'View your past orders',
            onTap: () =>
                ProfileDialogs.showComingSoonSnackBar(context, 'Order history'),
          ),
          ProfileMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorite Items',
            subtitle: 'Your liked restaurants and food',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check your Favorites tab!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      MenuSection(
        title: 'Support & Settings',
        items: [
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () => ProfileDialogs.showComingSoonSnackBar(
              context,
              'Notification settings',
            ),
          ),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            onTap: () => ProfileDialogs.showHelpDialog(context),
          ),
          ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => ProfileDialogs.showAboutDialog(context),
          ),
        ],
      ),
      MenuSection(
        title: 'Account Actions',
        items: [
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => ProfileDialogs.showSignOutDialog(context),
            textColor: Colors.red,
          ),
        ],
      ),
    ];
  }
}
