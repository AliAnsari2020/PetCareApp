import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedOwnerId;
  String? _selectedPetId;
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllPetOwnersPets();
  }

  Future<void> _loadAllPetOwnersPets() async {
    final ownersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Pet Owner')
        .get();

    List<Map<String, dynamic>> allPets = [];

    for (var ownerDoc in ownersSnapshot.docs) {
      final ownerId = ownerDoc.id;
      final ownerName = ownerDoc.data()['name'] ?? 'Unknown Owner';

      final petsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .collection('pets')
          .get();

      for (var petDoc in petsSnapshot.docs) {
        final petData = petDoc.data();
        allPets.add({
          'ownerId': ownerId,
          'ownerName': ownerName,
          'petId': petDoc.id,
          'petName': petData['name'] ?? 'Unnamed Pet',
        });
      }
    }

    setState(() {
      _pets = allPets;
      if (allPets.isNotEmpty) {
        _selectedOwnerId = allPets[0]['ownerId'];
        _selectedPetId = allPets[0]['petId'];
      }
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedPetId == null || _selectedOwnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a pet")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_selectedOwnerId)
          .collection("pets")
          .doc(_selectedPetId)
          .collection("health_records")
          .add({
        "title": _titleController.text.trim(),
        "notes": _notesController.text.trim(),
        "date": _selectedDate,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _notesController.clear();
      setState(() {
        _selectedDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Health record added")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("🐾 Pet Health Records", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2E86C1),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ----------------- PET DROPDOWN -----------------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.pets, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pets.isEmpty
                          ? const Text("No pets found for any owner.")
                          : DropdownButtonFormField<String>(
                              value: _selectedPetId,
                              decoration: const InputDecoration(
                                labelText: "Select Pet",
                                border: OutlineInputBorder(),
                              ),
                              items: _pets.map((pet) {
                                return DropdownMenuItem<String>(
                                  value: pet['petId'],
                                  child: Text("${pet['petName']} (Owner: ${pet['ownerName']})"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedPetId = val;
                                  // Update ownerId based on selected pet
                                  final selectedPet = _pets.firstWhere((pet) => pet['petId'] == val);
                                  _selectedOwnerId = selectedPet['ownerId'];
                                });
                              },
                              validator: (val) => val == null ? "Please select a pet" : null,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ----------------- FORM CARD -----------------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Add New Record",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        validator: (val) => val!.isEmpty ? "Enter title" : null,
                        decoration: InputDecoration(
                          labelText: "Title (e.g. Vaccination)",
                          prefixIcon: const Icon(Icons.medical_services, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Notes",
                          prefixIcon: const Icon(Icons.note_alt, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? "📅 No date chosen"
                                  : "📅 ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text("Pick Date"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _saveRecord,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E86C1),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text("Save Record",
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ----------------- RECORDS LIST -----------------
            Expanded(
              child: _selectedPetId == null
                  ? const Center(child: Text("Please select a pet to view health records."))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(_selectedOwnerId)
                          .collection("pets")
                          .doc(_selectedPetId)
                          .collection("health_records")
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No health records yet.",
                                style: TextStyle(fontSize: 16, color: Colors.black54)),
                          );
                        }

                        final records = snapshot.data!.docs;

                        return ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final data = records[i].data() as Map<String, dynamic>;

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.pets, color: Colors.blue),
                                ),
                                title: Text(
                                  data["title"] ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data["notes"] != null && data["notes"].toString().isNotEmpty)
                                      Text(data["notes"], style: const TextStyle(color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Text(
                                      data["date"] != null
                                          ? (data["date"] as Timestamp).toDate().toLocal().toString().split(" ")[0]
                                          : "",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}