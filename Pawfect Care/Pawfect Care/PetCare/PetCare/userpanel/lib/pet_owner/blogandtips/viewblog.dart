import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:userpanel/pet_owner/blogandtips/addblog.dart';
import 'package:userpanel/pet_owner/blogandtips/blogdetail.dart';

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  bool _isLoading = true;
  Set<String> _savedBlogs = {};

  @override
  void initState() {
    super.initState();
    _loadSavedBlogs();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _loadSavedBlogs() {
    setState(() {
      _savedBlogs = {};
    });
  }

  void _toggleSaveBlog(String blogId, String blogTitle, BuildContext context) {
    setState(() {
      if (_savedBlogs.contains(blogId)) {
        _savedBlogs.remove(blogId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $blogTitle removed from saved'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        _savedBlogs.add(blogId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💾 $blogTitle saved for later'),
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
        title: const Text('Blogs', 
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
            icon: Icon(Icons.bookmark, color: AppColor.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedBlogsPage(savedBlogs: _savedBlogs)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColor.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBlogPage()),
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
                  hintText: 'Search blogs...',
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
          
          Expanded(
            child: _isLoading
                ? _buildShimmerLoader()
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('blogs').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerLoader();
                      }
                      
                      final blogs = snapshot.data!.docs;
                      
                      final filteredBlogs = blogs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final searchMatch = searchQuery.isEmpty || 
                                          data['title'].toString().toLowerCase().contains(searchQuery) ||
                                          data['content'].toString().toLowerCase().contains(searchQuery) ||
                                          (data['tags'] != null && data['tags'].toString().toLowerCase().contains(searchQuery));
                        return searchMatch;
                      }).toList();
                      
                      if (filteredBlogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppColor.darkText.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'No blogs found',
                                style: TextStyle(
                                  color: AppColor.darkText.withOpacity(0.6),
                                  fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  color: AppColor.darkText.withOpacity(0.4),
                                  fontSize: 14
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddBlogPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  foregroundColor: AppColor.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Create First Blog', style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBlogs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredBlogs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogDetailPage(
                                    blog: data,
                                    blogId: doc.id,
                                    isSaved: _savedBlogs.contains(doc.id),
                                    onToggleSave: () => _toggleSaveBlog(doc.id, data['title'] ?? 'Blog', context),
                                  ),
                                ),
                              );
                            },
                            child: _buildBlogCard(data, doc.id, context),
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

  // Blogs display mein image ko decode karna hoga
  Widget _buildBlogCard(Map<String, dynamic> blog, String blogId, BuildContext context) {
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          if (hasImage && imageBytes != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  // Gradient overlay for better text readability
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog['title'] ?? 'Untitled Blog',
                  style: const TextStyle(
                    color: AppColor.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  blog['content'] != null 
                    ? (blog['content'].length > 120 
                        ? '${blog['content'].substring(0, 120)}...' 
                        : blog['content'])
                    : 'No content',
                  style: TextStyle(
                    color: AppColor.darkText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                if (blog['tags'] != null && blog['tags'] is List && blog['tags'].isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (blog['tags'] as List).take(3).map<Widget>((tag) {
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
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog['createdAt'] != null 
                        ? _formatDate(blog['createdAt'].toDate())
                        : 'Unknown date',
                      style: TextStyle(
                        color: AppColor.darkText.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _savedBlogs.contains(blogId) 
                            ? Icons.bookmark 
                            : Icons.bookmark_border,
                        color: _savedBlogs.contains(blogId) 
                            ? AppColor.accent 
                            : AppColor.darkText.withOpacity(0.4),
                      ),
                      onPressed: () => _toggleSaveBlog(blogId, blog['title'] ?? 'Blog', context),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColor.white,
          highlightColor: AppColor.background,
          child: Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 20),
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

class SavedBlogsPage extends StatelessWidget {
  final Set<String> savedBlogs;

  const SavedBlogsPage({super.key, required this.savedBlogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('Saved Blogs', 
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
      body: savedBlogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: AppColor.darkText.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved blogs',
                    style: TextStyle(color: AppColor.darkText.withOpacity(0.6), fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Save blogs to read them later',
                    style: TextStyle(color: AppColor.darkText.withOpacity(0.4)),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColor.primary));
                }
                
                final blogs = snapshot.data!.docs;
                final savedBlogsList = blogs.where((doc) => savedBlogs.contains(doc.id)).toList();
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedBlogsList.length,
                  itemBuilder: (context, index) {
                    final doc = savedBlogsList[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final imageData = data['image'];
                    final hasImage = imageData != null && imageData is String && imageData.isNotEmpty;
                    
                    Uint8List? imageBytes;
                    if (hasImage) {
                      try {
                        imageBytes = base64Decode(imageData);
                      } catch (e) {
                        print('Error decoding image: $e');
                      }
                    }
                    
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
                        leading: hasImage && imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imageBytes,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColor.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.article, 
                                  color: AppColor.primary.withOpacity(0.5)),
                              ),
                        title: Text(
                          data['title'] ?? 'Untitled Blog',
                          style: const TextStyle(
                            color: AppColor.darkText,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        subtitle: Text(
                          data['createdAt'] != null 
                            ? _formatDate(data['createdAt'].toDate())
                            : 'Unknown date',
                          style: TextStyle(
                            color: AppColor.darkText.withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(Icons.bookmark, color: AppColor.accent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlogDetailPage(
                                blog: data,
                                blogId: doc.id,
                                isSaved: true,
                                onToggleSave: () {},
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}