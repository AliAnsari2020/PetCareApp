import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:userpanel/pet_owner/dashboard.dart'; // 🔹 Cloudinary ke liye

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String _gender = "Male";
  String _vaccinated = "Yes";

  Uint8List? _imageBytes;
  File? _imageFile;
  bool _isLoading = false;
  bool _success = false;

  // 🔹 Cloudinary Upload Function
  Future<String?> uploadImageToCloudinary(Uint8List imageBytes) async {
    const cloudName = "dlbnwaj7c"; // 👈 apna cloud name dalna
    const uploadPreset = "PawfectCare"; // 👈 apna preset dalna

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes("file", imageBytes, filename: "pet.jpg"),
      );

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(resBody);
      return data["secure_url"];
    } else {
      print("Cloudinary upload failed: $resBody");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate() ||
        (_imageBytes == null && _imageFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields and select a pet image"),
          backgroundColor: AppColor.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 🔹 Upload image to Cloudinary
      Uint8List bytes;
      if (kIsWeb && _imageBytes != null) {
        bytes = _imageBytes!;
      } else {
        bytes = await _imageFile!.readAsBytes();
      }

      final imageUrl = await uploadImageToCloudinary(bytes);

      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // 🔹 Save pet data to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("pets")
          .add({
            "name": _nameController.text.trim(),
            "breed": _breedController.text.trim(),
            "age": _ageController.text.trim(),
            "weight": _weightController.text.trim(),
            "gender": _gender,
            "vaccinated": _vaccinated,
            "additional_info": _additionalInfoController.text.trim(),
            "image": imageUrl, // 👈 ab sirf Cloudinary ka URL save hoga
            "createdAt": FieldValue.serverTimestamp(),
          });

      setState(() => _success = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Pet added successfully!"),
          backgroundColor: AppColor.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear form after successful submission
      _nameController.clear();
      _breedController.clear();
      _ageController.clear();
      _weightController.clear();
      _additionalInfoController.clear();
      setState(() {
        _imageBytes = null;
        _imageFile = null;
        _gender = "Male";
        _vaccinated = "Yes";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
          _success = false;
        });
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          "Add Pet",
          style: TextStyle(
            color: AppColor.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColor.white,
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColor.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.white,
                    border: Border.all(
                      color: AppColor.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: _imageBytes != null || _imageFile != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? MemoryImage(_imageBytes!)
                                : FileImage(_imageFile!) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageBytes == null && _imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add Photo",
                                style: TextStyle(
                                  color: AppColor.darkText.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              // Pet Name
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: AppColor.darkText),
                decoration: _inputDecoration("Pet Name", Icons.pets),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter pet name" : null,
              ),
              const SizedBox(height: 16),

              // Breed
              TextFormField(
                controller: _breedController,
                style: TextStyle(color: AppColor.darkText),
                decoration: _inputDecoration("Breed", Icons.category),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter breed" : null,
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                style: TextStyle(color: AppColor.darkText),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Age (years)", Icons.cake),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter age" : null,
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                style: TextStyle(color: AppColor.darkText),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  "Weight (kg)",
                  Icons.monitor_weight,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter weight" : null,
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.darkText.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    items: ["Male", "Female"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(color: AppColor.darkText),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val!),
                    dropdownColor: AppColor.white,
                    style: TextStyle(color: AppColor.darkText),
                    decoration: InputDecoration(
                      labelText: "Gender",
                      labelStyle: TextStyle(
                        color: AppColor.darkText.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(Icons.male, color: AppColor.primary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vaccinated Dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.darkText.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _vaccinated,
                    items: ["Yes", "No"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(color: AppColor.darkText),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _vaccinated = val!),
                    dropdownColor: AppColor.white,
                    style: TextStyle(color: AppColor.darkText),
                    decoration: InputDecoration(
                      labelText: "Vaccinated",
                      labelStyle: TextStyle(
                        color: AppColor.darkText.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(Icons.verified, color: AppColor.primary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Information
              TextFormField(
                controller: _additionalInfoController,
                style: TextStyle(color: AppColor.darkText),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Additional Information",
                  labelStyle: TextStyle(
                    color: AppColor.darkText.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(Icons.info, color: AppColor.primary),
                  filled: true,
                  fillColor: AppColor.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColor.darkText.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await _savePet();
                          if (_success) {
                            // Redirect to Dashboard after success
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetOwnerDashboard(),
                                ),
                              );
                            }
                          }
                        },
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
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColor.white,
                            strokeWidth: 3,
                          ),
                        )
                      : _success
                      ? const Icon(Icons.check_circle, size: 24)
                      : const Text(
                          'SAVE PET',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}
