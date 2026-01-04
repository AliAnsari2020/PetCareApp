import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequestForm extends StatefulWidget {
  final String petId;
  final String petName;

  const AdoptionRequestForm({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<AdoptionRequestForm> createState() => _AdoptionRequestFormState();
}

class _AdoptionRequestFormState extends State<AdoptionRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String address = "";
  String contact = "";

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection("adoption_requests").add({
        "petId": widget.petId,
        "petName": widget.petName,
        "ownerName": name,
        "address": address,
        "contact": contact,
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // ✅ Modal dialog on success
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("✅ Request Submitted"),
          content: Text(
            "Your adoption request for ${widget.petName} has been sent successfully.\n\nWe will notify you once the shelter responds.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to adoption page
              },
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Adoption Request"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.pets, size: 60, color: Colors.teal),
                    const SizedBox(height: 10),
                    Text(
                      "Adopting: ${widget.petName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Your Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Your Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Enter your name" : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Enter address" : null,
                onSaved: (v) => address = v!,
              ),
              const SizedBox(height: 16),

              // Contact Number
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Enter contact number" : null,
                onSaved: (v) => contact = v!,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitRequest,
                  child: const Text(
                    "Send Request",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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