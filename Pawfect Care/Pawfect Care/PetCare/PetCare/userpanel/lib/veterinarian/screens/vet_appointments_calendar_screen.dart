import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VetAppointmentListScreen extends StatefulWidget {
  final String currentVetId;

  const VetAppointmentListScreen({Key? key, required this.currentVetId}) : super(key: key);

  @override
  _VetAppointmentListScreenState createState() => _VetAppointmentListScreenState();
}

class _VetAppointmentListScreenState extends State<VetAppointmentListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Fetch all appointments for this vet with status Approved or Rejected
  Future<List<QueryDocumentSnapshot>> fetchAllAppointments() async {
    QuerySnapshot snapshot = await _firestore
        .collectionGroup('appointments')
        .where('vetId', isEqualTo: widget.currentVetId)
        .where('status', whereIn: ['Approved', 'Rejected'])
        .orderBy('date', descending: false)
        .get();

    // Remove duplicates by appointmentId or doc.id
    final uniqueDocs = <String, QueryDocumentSnapshot>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final appointmentId = data['appointmentId'] ?? doc.id;
      uniqueDocs[appointmentId] = doc;
    }
    return uniqueDocs.values.toList();
  }

  Widget buildAppointmentCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final petName = data['petName'] ?? 'Unknown Pet';
    final dateTimestamp = data['date'] as Timestamp?;
    final date = dateTimestamp != null ? dateTimestamp.toDate() : null;
    final formattedDate = date != null
        ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
        : 'Unknown Date';
    final time = data['time'] ?? '';
    final vetName = data['vetName'] ?? '';
    final reason = data['reason'] ?? '';
    final status = data['status'] ?? '';

    Color statusColor;
    if (status == 'Approved') {
      statusColor = Colors.green;
    } else if (status == 'Rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.pets, size: 40, color: Colors.blueAccent),
        title: Text(
          petName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date/Time: $formattedDate at $time'),
            Text('Reason: $reason'),
            Text('Vet: $vetName'),
            Text('Status: $status', style: TextStyle(color: statusColor)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchAllAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments: ${snapshot.error}'));
          }
          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return buildAppointmentCard(appointments[index]);
            },
          );
        },
      ),
    );
  }
}