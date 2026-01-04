import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final String petId;

  const AddHealthRecordScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("pets")
          .doc(widget.petId)
          .collection("health_records")
          .add({
        "title": _titleController.text.trim(),
        "notes": _notesController.text.trim(),
        "date": _selectedDate,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Health record added")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Health Record"), backgroundColor: Color(0xFF2E86C1)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                validator: (val) => val!.isEmpty ? "Enter title" : null,
                decoration: InputDecoration(labelText: "Title (e.g. Vaccination)"),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: "Notes"),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? "No date chosen"
                        : "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text("Pick Date"),
                  )
                ],
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E86C1),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Save Record", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
