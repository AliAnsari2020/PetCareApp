import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:userpanel/pet_owner/pet_store/productdetail.dart';

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class PetProductsPage extends StatefulWidget {
  const PetProductsPage({super.key});

  @override
  State<PetProductsPage> createState() => _PetProductsPageState();
}

class _PetProductsPageState extends State<PetProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = ['All', 'Food', 'Grooming', 'Toys', 'Health'];
  String selectedCategory = 'All';
  String searchQuery = '';
  bool _isLoading = true;
  Set<String> _wishlistItems = {};

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _loadWishlist() {
    setState(() {
      _wishlistItems = {};
    });
  }

  void _toggleWishlist(String productId, String productName, BuildContext context) {
    setState(() {
      if (_wishlistItems.contains(productId)) {
        _wishlistItems.remove(productId);
        // Show remove notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $productName removed from wishlist'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        _wishlistItems.add(productId);
        // Show add notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❤️ $productName added to wishlist'),
            backgroundColor: AppColor.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('Pet Products', 
          style: TextStyle(
            color: AppColor.darkText, 
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
        centerTitle: true,
        backgroundColor: AppColor.white,
        elevation: 2,
        shadowColor: AppColor.darkText.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppColor.darkText),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: AppColor.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistPage(wishlistItems: _wishlistItems)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColor.white,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: AppColor.darkText),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppColor.darkText.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: AppColor.darkText.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColor.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
          ),
          
          // Category Chips
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColor.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category,
                      style: TextStyle(
                        color: selectedCategory == category ? AppColor.white : AppColor.darkText,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? category : 'All';
                      });
                    },
                    selectedColor: AppColor.primary,
                    backgroundColor: AppColor.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _isLoading
                ? _buildShimmerLoader()
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('pet_products').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerLoader();
                      }
                      
                      final products = snapshot.data!.docs;
                      
                      final filteredProducts = products.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final categoryMatch = selectedCategory == 'All' || 
                                            data['category'] == selectedCategory;
                        final searchMatch = searchQuery.isEmpty || 
                                          data['name'].toString().toLowerCase().contains(searchQuery) ||
                                          data['description'].toString().toLowerCase().contains(searchQuery);
                        return categoryMatch && searchMatch;
                      }).toList();
                      
                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppColor.darkText.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  color: AppColor.darkText.withOpacity(0.5),
                                  fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search or category',
                                style: TextStyle(
                                  color: AppColor.darkText.withOpacity(0.4),
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final doc = filteredProducts[index];
                          final data = doc.data() as Map<String, dynamic>;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(
                                    product: data,
                                    productId: doc.id,
                                    isInWishlist: _wishlistItems.contains(doc.id),
                                    onToggleWishlist: () => _toggleWishlist(doc.id, data['name'] ?? 'Product', context),
                                  ),
                                ),
                              );
                            },
                            child: _buildProductCard(data, doc.id, context),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, String productId, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  product['image'] != null
                      ? Image.memory(
                          base64Decode(product['image']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Container(
                          color: AppColor.background,
                          child: Icon(Icons.image_not_supported, 
                            color: AppColor.darkText.withOpacity(0.3),
                            size: 40,
                          ),
                        ),
                  
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product['category'] ?? 'General',
                        style: const TextStyle(
                          color: AppColor.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unnamed Product',
                  style: const TextStyle(
                    color: AppColor.darkText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _wishlistItems.contains(productId) 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        color: _wishlistItems.contains(productId) 
                            ? AppColor.accent 
                            : AppColor.darkText.withOpacity(0.4),
                      ),
                      onPressed: () => _toggleWishlist(productId, product['name'] ?? 'Product', context),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColor.white,
          highlightColor: AppColor.background,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class WishlistPage extends StatelessWidget {
  final Set<String> wishlistItems;

  const WishlistPage({super.key, required this.wishlistItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('My Wishlist', 
          style: TextStyle(
            color: AppColor.darkText, 
            fontWeight: FontWeight.w600
          )
        ),
        centerTitle: true,
        backgroundColor: AppColor.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColor.darkText),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColor.darkText.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(color: AppColor.darkText.withOpacity(0.6), fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add products to your wishlist',
                    style: TextStyle(color: AppColor.darkText.withOpacity(0.4)),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pet_products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColor.primary));
                }
                
                final products = snapshot.data!.docs;
                final wishlistProducts = products.where((doc) => wishlistItems.contains(doc.id)).toList();
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final doc = wishlistProducts[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: AppColor.background,
                            child: data['image'] != null
                                ? Image.memory(
                                    base64Decode(data['image']),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.image_not_supported, 
                                    color: AppColor.darkText.withOpacity(0.3)),
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Unnamed Product',
                          style: const TextStyle(
                            color: AppColor.darkText,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        subtitle: Text(
                          'PKR ${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        trailing: Icon(Icons.favorite, color: AppColor.accent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: data,
                                productId: doc.id,
                                isInWishlist: true,
                                onToggleWishlist: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Removed from wishlist'),
                                      backgroundColor: AppColor.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}