import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColor {
  static const Color primary = Color(0xFF2E86C1); // Royal Blue
  static const Color secondary = Color(0xFF28B463); // Green
  static const Color accent = Color(0xFFF39C12); // Orange
  static const Color background = Color(0xFFF4F6F7); // Light Grey
  static const Color darkText = Color(0xFF2C3E50); // Dark Grey
  static const Color white = Color(0xFFFFFFFF);
}

class ViewPetScreen extends StatelessWidget {
  final String petId;
  final DocumentSnapshot petData;

  const ViewPetScreen({super.key, required this.petId, required this.petData});

  @override
  Widget build(BuildContext context) {
    final String? imageString = petData["image"];
    ImageProvider? imageProvider;

    if (imageString != null && imageString.isNotEmpty) {
      if (imageString.startsWith("http")) {
        // 🔹 It's a URL
        imageProvider = NetworkImage(imageString);
      } else {
        // 🔹 It's Base64 encoded
        try {
          Uint8List bytes = base64Decode(imageString);
          imageProvider = MemoryImage(bytes);
        } catch (e) {
          debugPrint("Image decode error: $e");
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: Text(
          petData["name"] ?? "Pet Details",
          style: const TextStyle(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Pet Image with decorative container
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
                radius: 80,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(Icons.pets, 
                        size: 60, 
                        color: AppColor.primary.withOpacity(0.5))
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Pet Name
            Text(
              petData["name"] ?? "Unnamed Pet",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Breed
            if (petData["breed"] != null)
              Text(
                petData["breed"],
                style: TextStyle(
                  fontSize: 18,
                  color: AppColor.darkText.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 30),

            // 🔹 Pet Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow("Age", 
                    petData["age"] != null ? "${petData["age"]} years" : "N/A"),
                  const SizedBox(height: 12),
                  _buildInfoRow("Weight", 
                    petData["weight"] != null ? "${petData["weight"]} kg" : "N/A"),
                  const SizedBox(height: 12),
                  _buildInfoRow("Gender", 
                    petData["gender"]?.toString() ?? "N/A"),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Vaccinated", 
                    petData["vaccinated"]?.toString() == "true" ? "Yes" : "No",
                    specialColor: petData["vaccinated"]?.toString() == "true" 
                      ? AppColor.secondary 
                      : Colors.red
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 30),

            // 🔹 Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColor.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.delete_outline, size: 24),
                label: const Text(
                  "Delete Pet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? specialColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.darkText.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: specialColor ?? AppColor.darkText,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${petData["name"] ?? "this pet"}? This action cannot be undone."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColor.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deletePet(BuildContext context) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(petData.reference.parent!.parent!.id)
        .collection("pets")
        .doc(petId)
        .delete()
        .then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${petData["name"] ?? "Pet"} deleted successfully'),
          backgroundColor: AppColor.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting pet: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }
}