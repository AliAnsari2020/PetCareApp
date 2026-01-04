import 'dart:convert';
import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final String productId;
  final bool isInWishlist;
  final VoidCallback onToggleWishlist;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.productId,
    required this.isInWishlist,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            backgroundColor: AppColor.white,
            elevation: 2,
            shadowColor: AppColor.darkText.withOpacity(0.1),
            iconTheme: const IconThemeData(color: AppColor.darkText),
            flexibleSpace: FlexibleSpaceBar(
              background: product['image'] != null
                  ? Image.memory(
                      base64Decode(product['image']),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColor.background,
                      child: Center(
                        child: Icon(Icons.image_not_supported, 
                          color: AppColor.darkText.withOpacity(0.3), 
                          size: 50),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? AppColor.accent : AppColor.darkText,
                ),
                onPressed: () {
                  onToggleWishlist();
                  // Show notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWishlist 
                          ? '❌ ${product['name']} removed from wishlist' 
                          : '❤️ ${product['name']} added to wishlist',
                      ),
                      backgroundColor: isInWishlist ? Colors.red : AppColor.primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'] ?? 'Unnamed Product',
                          style: const TextStyle(
                            color: AppColor.darkText,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'PKR ${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product['category'] ?? 'Uncategorized',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description section
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColor.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Text(
                      product['description'] ?? 'No description available',
                      style: TextStyle(
                        color: AppColor.darkText.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Add to wishlist button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        onToggleWishlist();
                        // Show notification
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWishlist 
                                ? '❌ ${product['name']} removed from wishlist' 
                                : '❤️ ${product['name']} added to wishlist',
                            ),
                            backgroundColor: isInWishlist ? Colors.red : AppColor.primary,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInWishlist ? AppColor.accent : AppColor.primary,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                        shadowColor: AppColor.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Additional product details section
                  if (product['brand'] != null || product['weight'] != null || product['ingredients'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                            color: AppColor.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            children: [
                              if (product['brand'] != null)
                                _buildDetailRow('Brand', product['brand']),
                              
                              if (product['weight'] != null)
                                _buildDetailRow('Weight', product['weight']),
                              
                              if (product['ingredients'] != null)
                                _buildDetailRow('Ingredients', product['ingredients']),
                              
                              if (product['suitable_for'] != null)
                                _buildDetailRow('Suitable For', product['suitable_for']),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColor.darkText.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColor.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}