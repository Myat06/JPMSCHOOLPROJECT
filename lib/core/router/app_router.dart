import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/customer/customer_dashboard.dart';
import '../../screens/customer/cart_page.dart';
import '../../screens/customer/order_page.dart';
import '../../screens/customer/receipt_page.dart';
import '../../screens/customer/chatbot_page.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/splash_screen.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authStatus = authProvider.status;
        final currentUser = authProvider.currentUser;

        // Handle authentication redirects
        if (authStatus == AuthStatus.loading ||
            authStatus == AuthStatus.initial) {
          return null; // Stay on current route while loading
        }

        if (authStatus == AuthStatus.unauthenticated) {
          // If trying to access protected routes, redirect to login
          if (state.uri.path != '/login' &&
              state.uri.path != '/register' &&
              state.uri.path != '/') {
            return '/login';
          }
          return null;
        }

        if (authStatus == AuthStatus.authenticated && currentUser != null) {
          // Redirect to appropriate dashboard after login/register
          if (state.uri.path == '/login' ||
              state.uri.path == '/register' ||
              state.uri.path == '/' ||
              state.uri.path == '/home') {
            if (currentUser.role == UserRole.customer) {
              return '/customer/dashboard';
            } else if (currentUser.role == UserRole.admin) {
              return '/admin/dashboard';
            }
          }
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          redirect: (context, state) {
            // This route is just for redirection logic
            final currentUser = authProvider.currentUser;
            if (currentUser != null) {
              if (currentUser.role == UserRole.customer) {
                return '/customer/dashboard';
              } else if (currentUser.role == UserRole.admin) {
                return '/admin/dashboard';
              }
            }
            return '/login';
          },
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/customer/dashboard',
          name: 'customer-dashboard',
          builder: (context, state) => const CustomerDashboard(),
        ),
        GoRoute(
          path: '/customer/cart',
          name: 'customer-cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/customer/order',
          name: 'customer-order',
          builder: (context, state) => const OrderPage(),
        ),
        GoRoute(
          path: '/customer/receipt/:orderId',
          name: 'customer-receipt',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return ReceiptPage(orderId: orderId);
          },
        ),

        GoRoute(
          path: '/customer/chat',
          name: 'customer-chat',
          builder: (context, state) => const ChatBotPage(),
        ),

        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
