import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAppointmentScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const AddAppointmentScreen({Key? key, required this.petId, required this.petName}) : super(key: key);

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String? _selectedVetId;
  String? _selectedVetName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() || _selectedVetId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final appointmentData = {
        "ownerId": uid,
        "petId": widget.petId,
        "petName": widget.petName,
        "vetId": _selectedVetId,
        "vetName": _selectedVetName,
        "date": _selectedDate,
        "time": _selectedTime!.format(context),
        "reason": _reasonController.text.trim(),
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save in Owner collection
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("appointments")
          .add(appointmentData);

      // Save in Vet collection
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_selectedVetId)
          .collection("appointments")
          .add(appointmentData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment booked successfully")),
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Color(0xFF2E86C1),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vet Dropdown
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("role", isEqualTo: "Veterinarian")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final vets = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedVetId,
                    hint: Text("Select Veterinarian"),
                    items: vets.map((doc) {
                      final vet = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(vet["name"] ?? "No Name"),
                        onTap: () => _selectedVetName = vet["name"],
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedVetId = val),
                    validator: (val) => val == null ? "Select a vet" : null,
                  );
                },
              ),
              SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                validator: (val) => val!.isEmpty ? "Enter reason" : null,
                decoration: InputDecoration(labelText: "Reason for appointment"),
              ),
              SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? "No date chosen"
                        : "Date: ${_selectedDate!.toLocal().toString().split(" ")[0]}"),
                  ),
                  TextButton(onPressed: _pickDate, child: Text("Pick Date"))
                ],
              ),
              SizedBox(height: 12),

              // Time Picker
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedTime == null
                        ? "No time chosen"
                        : "Time: ${_selectedTime!.format(context)}"),
                  ),
                  TextButton(onPressed: _pickTime, child: Text("Pick Time"))
                ],
              ),
              SizedBox(height: 20),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E86C1),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Book Appointment", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
