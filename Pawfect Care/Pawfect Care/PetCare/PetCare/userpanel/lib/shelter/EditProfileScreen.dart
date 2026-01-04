import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;

  File? _imageFile;
  XFile? _webPickedFile; // For web image storage
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['name']);
    usernameController = TextEditingController(
      text: widget.userData['username'],
    );
    emailController = TextEditingController(text: widget.userData['email']);
    passwordController = TextEditingController(
      text: widget.userData['password'] ?? "",
    );
    phoneController = TextEditingController(text: widget.userData['phone']);
  }

  // 📸 Pick Image
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() => _webPickedFile = pickedFile); // store XFile on web
      } else {
        setState(
          () => _imageFile = File(pickedFile.path),
        ); // store File on mobile
      }
    }
  }

  // ☁️ Upload to Cloudinary
  Future<String?> uploadImage() async {
    const cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/dlbnwaj7c/image/upload";
    const uploadPreset = "PawfectCare"; // unsigned upload preset

    try {
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb && _webPickedFile != null) {
        // Web → use bytes
        final bytes = await _webPickedFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: "upload.jpg"),
        );
      } else if (_imageFile != null) {
        // Mobile → use path
        request.files.add(
          await http.MultipartFile.fromPath('file', _imageFile!.path),
        );
      }

      var response = await request.send();
      final resString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resString);
        return data['secure_url'];
      } else {
        debugPrint("Cloudinary Upload Failed: $resString");
        return null;
      }
    } catch (e) {
      debugPrint("Upload Exception: $e");
      return null;
    }
  }

  // 💾 Save Profile
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl = widget.userData['imageUrl'];
    if (_imageFile != null || _webPickedFile != null) {
      imageUrl = await uploadImage();
    }

    User? user = _auth.currentUser;

    try {
      if (user == null) throw Exception("No user found");

      // ✅ Re-authenticate user before sensitive updates
      final cred = EmailAuthProvider.credential(
        email: widget.userData['email'], // old email from Firestore
        password: widget.userData['password'], // old password from Firestore
      );
      await user.reauthenticateWithCredential(cred);

      // 🔄 Update Email in Firebase Auth
      if (emailController.text.trim().isNotEmpty &&
          user.email != emailController.text.trim()) {
        await user.updateEmail(emailController.text.trim());
      }

      // 🔄 Update Password in Firebase Auth
      if (passwordController.text.trim().isNotEmpty &&
          passwordController.text.trim() != widget.userData['password']) {
        await user.updatePassword(passwordController.text.trim());
      }

      // 🔄 Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'phone': phoneController.text.trim(),
        'imageUrl': imageUrl ?? "",
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColor.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : _webPickedFile != null
            ? NetworkImage(_webPickedFile!.path)
            : (widget.userData['imageUrl'] != null &&
                    widget.userData['imageUrl'].toString().isNotEmpty
                ? NetworkImage(widget.userData['imageUrl'])
                : null);

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 👤 Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColor.primary.withOpacity(0.1),
                      backgroundImage: imageProvider as ImageProvider?,
                      child: imageProvider == null
                          ? Icon(Icons.person, 
                              size: 60, 
                              color: AppColor.primary.withOpacity(0.5))
                          : null,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.white, width: 2),
                    ),
                    child: IconButton(
                      onPressed: pickImage,
                      icon: const Icon(Icons.camera_alt, 
                        color: AppColor.white, 
                        size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 📝 Fields
              _buildTextField(nameController, 'Name', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(usernameController, 'Username', Icons.badge),
              const SizedBox(height: 16),
              _buildTextField(emailController, 'Email', Icons.email, isEmail: true),
              const SizedBox(height: 16),
              _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Phone', Icons.phone, isPhone: true),
              const SizedBox(height: 30),

              // 💾 Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColor.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 Custom TextField Widget
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return '$label cannot be empty';
        if (isEmail && !value.contains('@')) return 'Enter a valid email';
        if (isPhone && value.length < 10) return 'Enter a valid phone number';
        return null;
      },
      style: TextStyle(color: AppColor.darkText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColor.darkText.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: AppColor.primary),
        filled: true,
        fillColor: AppColor.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.darkText.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.darkText.withOpacity(0.4),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}