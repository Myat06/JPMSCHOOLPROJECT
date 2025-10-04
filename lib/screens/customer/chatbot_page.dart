import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:jpmfood/data/services/ai_service.dart';
import 'package:jpmfood/widgets/customer/chat_widgets/message_input.dart';
import 'package:jpmfood/widgets/customer/chat_widgets/typing_indicator.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/restaurant_data_model.dart';
import '../../data/models/menu_item_model.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/customer/chat_widgets/shop_bubbles.dart';
import '../../widgets/customer/chat_widgets/menu_preview.dart';
import '../../widgets/customer/chat_widgets/chat_bubble.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final AIService _aiService = AIService();

  RestaurantData? _selectedShop;
  bool _showShopBubbles = true;
  bool _isTyping = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final cartProvider = context.read<CartProvider>();
        cartProvider.loadCartItems(authProvider.currentUser!.uid);
      }

      await _addBotMessage(
        'Hello! Welcome to our food delivery service!',
        delay: 500,
      );

      final customer = context.read<CustomerProvider>();
      if (customer.restaurants.isEmpty && !customer.isLoading) {
        await customer.loadRestaurants();
      }

      await _addBotMessage(
        'I can help you explore our partner restaurants. You can select a shop below or ask me anything!',
        delay: 1000,
      );

      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addBotMessage(String text, {int delay = 0}) async {
    if (delay > 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isBot: true));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isBot: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    final message = text.trim();
    _textController.clear();
    _addUserMessage(message);

    setState(() {
      _isTyping = true;
    });

    // Check if message mentions a specific restaurant
    final customer = context.read<CustomerProvider>();
    RestaurantData? mentionedShop;

    for (var shop in customer.restaurants) {
      if (message.toLowerCase().contains(shop.adminName.toLowerCase())) {
        mentionedShop = shop;
        break;
      }
    }

    if (mentionedShop != null) {
      await _onShopSelected(mentionedShop);
    } else {
      // Get AI response
      final aiResponse = await _aiService.sendMessage(
        message,
        customer.restaurants,
      );

      setState(() {
        _isTyping = false;
      });

      await _addBotMessage(aiResponse);
    }

    setState(() {
      _isTyping = false;
    });
  }

  Future<void> _onShopSelected(RestaurantData shop) async {
    if (!_messages.any(
      (msg) => !msg.isBot && msg.text.contains('Show me ${shop.adminName}'),
    )) {
      _addUserMessage('Show me ${shop.adminName}');
    }

    setState(() {
      _selectedShop = shop;
      _showShopBubbles = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (shop.menuItems.isEmpty) {
      await _addBotMessage(
        'Oops! ${shop.adminName} doesn\'t have any menu items available right now. Please try another restaurant!',
      );
      return;
    }

    final itemCount = shop.menuItems.length;
    final topItems = shop.menuItems.take(6).toList();
    final itemNames = topItems.map((e) => e.name).join(', ');

    await _addBotMessage(
      'Great choice! ${shop.adminName} has ${itemCount} delicious items on their menu.',
    );

    await Future.delayed(const Duration(milliseconds: 500));
    await _addBotMessage('Here are some popular items: $itemNames');

    await Future.delayed(const Duration(milliseconds: 500));
    await _addBotMessage(
      'You can scroll through their menu below, or tap items to add them to your cart!',
    );
  }

  void _resetChat() {
    setState(() {
      _selectedShop = null;
      _showShopBubbles = true;
      _messages.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _addBotMessage(
        'Welcome back! Which restaurant would you like to explore?',
        delay: 300,
      );
    });
  }

  void _navigateToCart() {
    context.push('/customer/cart');
  }

  void _navigateToOrder() {
    context.push('/customer/order');
  }

  Future<void> _onAddToCart(MenuItemModel item) async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    if (authProvider.currentUser != null) {
      final isInCart = cartProvider.isItemInCart(item.id);

      if (isInCart) {
        final cartItem = cartProvider.getCartItemByMenuId(item.id);
        if (cartItem != null) {
          final currentQty = cartProvider.getItemQuantity(item.id);
          await cartProvider.updateItemQuantity(
            userId: authProvider.currentUser!.uid,
            cartItemId: cartItem.id,
            quantity: currentQty + 1,
          );
        }
      } else {
        await cartProvider.addToCart(
          item,
          userId: authProvider.currentUser!.uid,
        );
      }

      await _addBotMessage(
        '${item.name} has been added to your cart! You can continue shopping or proceed to checkout.',
      );
    } else {
      await _addBotMessage('Please log in to add items to your cart.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 2,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _navigateToCart,
                  ),
                  if (cartProvider.cartItemsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.cartItemsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (_selectedShop != null)
            IconButton(
              onPressed: _resetChat,
              icon: const Icon(Icons.refresh),
              tooltip: 'Start Over',
            ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customer, _) {
          if (customer.isLoading && customer.restaurants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading restaurants...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final shops = customer.restaurants;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _messages.length +
                      (_showShopBubbles ? 1 : 0) +
                      (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping &&
                        index ==
                            _messages.length + (_showShopBubbles ? 1 : 0)) {
                      return const TypingIndicator();
                    }

                    if (_showShopBubbles && index == _messages.length) {
                      return FadeTransition(
                        opacity: _fadeController,
                        child: ShopBubbles(
                          shops: shops,
                          onSelected: _onShopSelected,
                        ),
                      );
                    }

                    final msg = _messages[index];
                    return ChatBubble(message: msg);
                  },
                ),
              ),
              if (_selectedShop != null)
                MenuPreview(
                  shop: _selectedShop!,
                  onResetChat: _resetChat,
                  onAddToCart: _onAddToCart,
                ),
              MessageInput(
                controller: _textController,
                onSubmit: _handleSubmit,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _selectedShop == null
          ? null
          : Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final hasCartItems = cartProvider.cartItemsCount > 0;

                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.go('/customer/dashboard');
                            },
                            icon: const Icon(Icons.storefront),
                            label: const Text('Visit Shop'),
                              style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: hasCartItems
                                ? _navigateToOrder
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Add some items to cart first!',
                                        ),
                                        backgroundColor: AppColors.primary,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              hasCartItems
                                  ? Icons.payment
                                  : Icons.shopping_cart,
                            ),
                            label: Text(
                              hasCartItems ? 'Process Payment' : 'Cart Empty',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasCartItems
                                  ? AppColors.success
                                  : Colors.grey,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
