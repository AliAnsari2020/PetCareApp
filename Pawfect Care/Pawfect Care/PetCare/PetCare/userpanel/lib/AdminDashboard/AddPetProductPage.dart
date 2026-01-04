import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddPetProductPage extends StatefulWidget {
  const AddPetProductPage({super.key});

  @override
  State<AddPetProductPage> createState() => _AddPetProductPageState();
}

class _AddPetProductPageState extends State<AddPetProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Uint8List? _imageBytes;
  File? _imageFile;
  bool _isLoading = false;
  bool _success = false;

  String? _selectedCategory;
  final List<String> _categories = ['Food', 'Grooming', 'Toys', 'Health'];

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

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate() ||
        (_imageFile == null && _imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields & pick image")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _success = false;
    });

    try {
      String? imageData;
      if (kIsWeb && _imageBytes != null) {
        imageData = base64Encode(_imageBytes!);
      } else if (!kIsWeb && _imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imageData = base64Encode(bytes);
      }

      await FirebaseFirestore.instance.collection('pet_products').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'image': imageData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _success = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Product Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      setState(() {
        _imageBytes = null;
        _imageFile = null;
        _selectedCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          '🛒 Add Pet Product',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white30),
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
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload Product Image",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: const Text(
                              "Edit Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Product Name", Icons.label),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDecoration("Description", Icons.description),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Price (PKR)", Icons.attach_money),
                validator: (val) =>
                    double.tryParse(val!) == null ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                dropdownColor: Colors.black87,
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Select Category", Icons.category),
                validator: (val) => val == null ? 'Select category' : null,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _isLoading ? null : _addProduct,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFFAD00FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : _success
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 28,
                          )
                        : const Text(
                            'ADD PRODUCT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.2,
                            ),
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
