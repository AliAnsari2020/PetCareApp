import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class BlogDetailPage extends StatelessWidget {
  final Map<String, dynamic> blog;
  final String blogId;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const BlogDetailPage({
    super.key,
    required this.blog,
    required this.blogId,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final imageData = blog['image'];
    final hasImage = imageData != null && imageData is String && imageData.isNotEmpty;
    
    Uint8List? imageBytes;
    if (hasImage) {
      try {
        imageBytes = base64Decode(imageData);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }

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
            flexibleSpace: hasImage && imageBytes != null
                ? FlexibleSpaceBar(
                    background: Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    ),
                  )
                : FlexibleSpaceBar(
                    background: Container(
                      color: AppColor.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(Icons.article, 
                          color: AppColor.primary.withOpacity(0.5), 
                          size: 50),
                      ),
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColor.accent : AppColor.darkText,
                ),
                onPressed: () {
                  onToggleSave();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved 
                          ? '❌ ${blog['title']} removed from saved' 
                          : '💾 ${blog['title']} saved for later',
                      ),
                      backgroundColor: isSaved ? Colors.red : AppColor.primary,
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
                  // Blog Title
                  Text(
                    blog['title'] ?? 'Untitled Blog',
                    style: const TextStyle(
                      color: AppColor.darkText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Meta Information Container
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
                        // Date and Reading Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetaItem(
                              Icons.calendar_today, 
                              blog['createdAt'] != null 
                                ? _formatDate(blog['createdAt'].toDate())
                                : 'Unknown date'
                            ),
                            _buildMetaItem(
                              Icons.timer, 
                              _calculateReadingTime(blog['content'] ?? '')
                            ),
                            _buildMetaItem(
                              Icons.visibility, 
                              '${_calculateViewCount()} views'
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Tags
                        if (blog['tags'] != null && blog['tags'] is List && (blog['tags'] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'Tags:',
                                style: TextStyle(
                                  color: AppColor.darkText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (blog['tags'] as List).map<Widget>((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      tag.toString(),
                                      style: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Content
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      blog['content'] ?? 'No content available',
                      style: TextStyle(
                        color: AppColor.darkText.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Save Button
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              onToggleSave();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSaved 
                                      ? '❌ ${blog['title']} removed from saved' 
                                      : '💾 ${blog['title']} saved for later',
                                  ),
                                  backgroundColor: isSaved ? Colors.red : AppColor.primary,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSaved ? AppColor.accent : AppColor.primary,
                              foregroundColor: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isSaved ? 'Saved' : 'Save',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Share Button
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () {
                            _shareBlog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColor.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(Icons.share, color: AppColor.primary),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Author Info (if available)
                  if (blog['author'] != null)
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColor.primary.withOpacity(0.2),
                            child: Icon(Icons.person, color: AppColor.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Written by',
                                  style: TextStyle(
                                    color: AppColor.darkText.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  blog['author'],
                                  style: const TextStyle(
                                    color: AppColor.darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColor.primary),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: AppColor.darkText.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _calculateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final readingTime = (wordCount / 200).ceil(); // Assuming 200 words per minute
    return '${readingTime} min read';
  }

int _calculateViewCount() {
  final title = blog['title'] as String?;
  final titleLength = title?.length ?? 0;
  return 150 + (titleLength * 3);
}

  void _shareBlog(BuildContext context) {
    // In a real app, you would implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing functionality would be implemented here'),
        backgroundColor: AppColor.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }
}