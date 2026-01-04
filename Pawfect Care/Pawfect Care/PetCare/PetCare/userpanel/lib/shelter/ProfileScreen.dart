import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:userpanel/shelter/EditProfileScreen.dart';
import 'package:userpanel/auth/login.dart'; // <-- Added for logout navigation

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required String vetId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userId;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(userDoc.data() as Map);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _deleteProfile() async {
    if (userId != null) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        await _auth.currentUser?.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile Deleted Successfully'),
              backgroundColor: AppColor.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _updateProfile() async {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(userData: userData!),
        ),
      ).then((_) => fetchUserData());
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to delete your profile? This action cannot be undone.'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColor.darkText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColor.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
              color: AppColor.darkText, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColor.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColor.primary),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primary))
          : userData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64,
                          color: AppColor.darkText.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No profile data found',
                        style: TextStyle(
                            color: AppColor.darkText.withOpacity(0.6),
                            fontSize: 18),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor:
                                        AppColor.primary.withOpacity(0.1),
                                    backgroundImage: userData!['imageUrl'] !=
                                                null &&
                                            userData!['imageUrl']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(userData!['imageUrl'])
                                        : null,
                                    child: userData!['imageUrl'] == null ||
                                            userData!['imageUrl']
                                                .toString()
                                                .isEmpty
                                        ? Text(
                                            (userData!['name'] ?? 'U')[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 40,
                                              color: AppColor.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColor.white, width: 2),
                                      ),
                                      child: const Icon(Icons.person,
                                          size: 20, color: AppColor.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildInfoItem('Name', userData!['name']),
                              _buildInfoItem('Username', userData!['username']),
                              _buildInfoItem('Role', userData!['role']),
                              _buildInfoItem('Phone', userData!['phone']),
                              _buildInfoItem('Password',
                                  userData!['password'], isSensitive: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _updateProfile,
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Update Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showDeleteConfirmationDialog,
                              icon: const Icon(Icons.delete, size: 20),
                              label: const Text('Delete Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: AppColor.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'User since: ${DateTime.now().toString().substring(0, 10)}',
                        style: TextStyle(
                          color: AppColor.darkText.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value,
      {bool isSensitive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.darkText.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'Not Available',
              style: TextStyle(
                fontSize: 16,
                color: isSensitive
                    ? AppColor.primary
                    : AppColor.darkText.withOpacity(0.8),
                fontWeight:
                    isSensitive ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
