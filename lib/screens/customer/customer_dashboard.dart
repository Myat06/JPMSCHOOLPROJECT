import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:jpmfood/widgets/customer/shop_panel.dart';
import 'package:jpmfood/widgets/customer/favorite_panel.dart';
import 'package:jpmfood/widgets/customer/home_widgets/home_panel.dart';
import 'package:jpmfood/widgets/customer/profile_widgets/profile_panel.dart';

// Pulsing FAB Widget Class with Option 5 Design
class _PulsingFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PulsingFAB({required this.onPressed, required this.child});

  @override
  __PulsingFABState createState() => __PulsingFABState();
}

class __PulsingFABState extends State<_PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.9,
        end: 1.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          backgroundColor: Colors.white, // Changed from orange to white
          foregroundColor: Colors.blue, // Changed to blue for better contrast
          shape: const CircleBorder(),
          onPressed: widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade200], // Blue gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3), // Blue shadow
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy, size: 28), // AI/chatbot icon
          ),
        ),
      ),
    );
  }
}

// Main CustomerDashboard Class
class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  // List of panels for each tab
  final List<Widget> _panels = [
    const HomePanel(),
    const ShopPanel(),
    const FavoritesPanel(),
    const ProfilePanel(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> wrappedPanels = List.generate(
      _panels.length,
      (index) =>
          HeroMode(enabled: _selectedIndex == index, child: _panels[index]),
    );

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: wrappedPanels),
      floatingActionButton: _PulsingFAB(
        onPressed: () {
          context.push('/customer/chat');
        },
        child: const Icon(
          Icons.smart_toy,
        ), // Using smart_toy icon for AI chatbot
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 1 ? Icons.store : Icons.store_outlined,
                  size: 24,
                ),
              ),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 2 ? Icons.favorite : Icons.favorite_outline,
                  size: 24,
                ),
              ),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
