import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/menu_provider.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/services/storage_service.dart';

class MenuItemManagementScreen extends StatefulWidget {
  const MenuItemManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuItemManagementScreen> createState() =>
      _MenuItemManagementScreenState();
}

class _MenuItemManagementScreenState extends State<MenuItemManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _caloriesController = TextEditingController();

  MenuItemModel? _editingMenuItem;
  String _selectedCategory = '';
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  bool _isSpicy = false;
  bool _isAvailable = true;
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploadingImage = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Load menu items and categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuItems();
      context.read<MenuProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _showMenuItemDialog({MenuItemModel? menuItem}) {
    _editingMenuItem = menuItem;

    if (menuItem != null) {
      _nameController.text = menuItem.name;
      _descriptionController.text = menuItem.description;
      _priceController.text = menuItem.price.toString();
      _preparationTimeController.text = menuItem.preparationTimeMinutes
          .toString();
      _caloriesController.text = menuItem.calories.toString();
      _selectedCategory = menuItem.category;
      _isVegetarian = menuItem.isVegetarian;
      _isVegan = menuItem.isVegan;
      _isGlutenFree = menuItem.isGlutenFree;
      _isSpicy = menuItem.isSpicy;
      _isAvailable = menuItem.isAvailable;
      _imageUrl = menuItem.imageUrl;
      _selectedImage = null;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    menuItem != null ? Icons.edit : Icons.add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    menuItem != null ? 'Edit Menu Item' : 'Add Menu Item',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clearForm();
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Image Selection
                      _buildImageSelector(),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _preparationTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Prep Time (min)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter prep time';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter valid time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter calories';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid calories';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedCategory.isNotEmpty
                                ? _selectedCategory
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: menuProvider.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.name,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Vegetarian'),
                            selected: _isVegetarian,
                            onSelected: (selected) {
                              setState(() {
                                _isVegetarian = selected;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Vegan'),
                            selected: _isVegan,
                            onSelected: (selected) {
                              setState(() {
                                _isVegan = selected;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Gluten Free'),
                            selected: _isGlutenFree,
                            onSelected: (selected) {
                              setState(() {
                                _isGlutenFree = selected;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Spicy'),
                            selected: _isSpicy,
                            onSelected: (selected) {
                              setState(() {
                                _isSpicy = selected;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Available'),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _clearForm();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMenuItem,
                      child: Text(menuItem != null ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _preparationTimeController.clear();
    _caloriesController.clear();
    _selectedCategory = '';
    _isVegetarian = false;
    _isVegan = false;
    _isGlutenFree = false;
    _isSpicy = false;
    _isAvailable = true;
    _editingMenuItem = null;
    _selectedImage = null;
    _imageUrl = null;
    _isUploadingImage = false;
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    final menuProvider = context.read<MenuProvider>();
    final adminId = menuProvider.currentAdminId;

    if (adminId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No restaurant selected')));
      return;
    }

    // Upload image if a new one is selected
    String? finalImageUrl = _imageUrl;
    if (_selectedImage != null) {
      setState(() {
        _isUploadingImage = true;
      });

      final uploadedUrl = await _storageService.uploadMenuItemImage(
        imageFile: _selectedImage!,
        adminId: adminId,
        menuItemId:
            _editingMenuItem?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      setState(() {
        _isUploadingImage = false;
      });
    }

    final menuItem = MenuItemModel(
      id: _editingMenuItem?.id ?? '',
      adminId: adminId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      imageUrl: finalImageUrl,
      category: _selectedCategory,
      isVegetarian: _isVegetarian,
      isVegan: _isVegan,
      isGlutenFree: _isGlutenFree,
      isSpicy: _isSpicy,
      preparationTimeMinutes: int.parse(_preparationTimeController.text),
      isAvailable: _isAvailable,
      calories: int.parse(_caloriesController.text),
      createdAt: _editingMenuItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_editingMenuItem != null) {
      success = await menuProvider.updateMenuItem(menuItem);
    } else {
      success = await menuProvider.createMenuItem(menuItem);
    }

    if (success) {
      Navigator.of(context).pop();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingMenuItem != null
                ? 'Menu item updated successfully'
                : 'Menu item created successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            menuProvider.errorMessage ?? 'Failed to save menu item',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMenuItem(MenuItemModel menuItem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${menuItem.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<MenuProvider>().deleteMenuItem(
        menuItem.id,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu item deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<MenuProvider>().errorMessage ??
                  'Failed to delete menu item',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability(MenuItemModel menuItem) async {
    final success = await context
        .read<MenuProvider>()
        .toggleMenuItemAvailability(menuItem.id, !menuItem.isAvailable);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            menuItem.isAvailable
                ? 'Menu item made unavailable'
                : 'Menu item made available',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<MenuProvider>().errorMessage ??
                'Failed to update availability',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : _imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                )
              : _buildImagePlaceholder(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            if (_selectedImage != null || _imageUrl != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _imageUrl = null;
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ],
        ),
        if (_isUploadingImage)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Uploading image...'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Add Image', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _storageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrl = null; // Clear existing URL when new image is selected
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _storageService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrl = null; // Clear existing URL when new image is selected
      });
    }
  }

  Widget _buildMenuItemImage(MenuItemModel menuItem) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: menuItem.isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
      ),
      child: menuItem.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                menuItem.imageUrl!,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    color: menuItem.isAvailable ? Colors.green : Colors.red,
                    size: 28,
                  );
                },
              ),
            )
          : Icon(
              Icons.restaurant,
              color: menuItem.isAvailable ? Colors.green : Colors.red,
              size: 28,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu Items'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMenuItemDialog(),
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (menuProvider.menuItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No menu items yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first menu item to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showMenuItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Menu Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menuProvider.menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = menuProvider.menuItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _buildMenuItemImage(menuItem),
                  title: Text(menuItem.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(menuItem.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${menuItem.category}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (menuItem.isVegetarian ||
                          menuItem.isVegan ||
                          menuItem.isGlutenFree ||
                          menuItem.isSpicy)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: [
                              if (menuItem.isVegetarian)
                                Chip(
                                  label: const Text(
                                    'Veg',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                ),
                              if (menuItem.isVegan)
                                Chip(
                                  label: const Text(
                                    'Vegan',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                ),
                              if (menuItem.isGlutenFree)
                                Chip(
                                  label: const Text(
                                    'GF',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ),
                              if (menuItem.isSpicy)
                                Chip(
                                  label: const Text(
                                    'Spicy',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          menuItem.isAvailable
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: menuItem.isAvailable
                              ? Colors.orange
                              : Colors.green,
                        ),
                        onPressed: () => _toggleAvailability(menuItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showMenuItemDialog(menuItem: menuItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMenuItem(menuItem),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuItemDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
