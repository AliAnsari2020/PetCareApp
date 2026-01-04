import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VetAppointmentsScreen extends StatefulWidget {
  final String currentVetId;

  const VetAppointmentsScreen({Key? key, required this.currentVetId}) : super(key: key);

  @override
  _VetAppointmentsScreenState createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Fetch all appointments for this vet, removing duplicates by appointmentId
  Future<List<QueryDocumentSnapshot>> fetchAllAppointments() async {
    QuerySnapshot snapshot = await _firestore
        .collectionGroup('appointments')
        .where('vetId', isEqualTo: widget.currentVetId)
        .where('status', isEqualTo: 'Pending')
        .orderBy('date', descending: false)
        .get();

    final seenAppointmentIds = <String>{};
    final uniqueAppointments = <QueryDocumentSnapshot>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final appointmentId = data['appointmentId'] ?? doc.id;

      if (!seenAppointmentIds.contains(appointmentId)) {
        seenAppointmentIds.add(appointmentId);
        uniqueAppointments.add(doc);
      }
    }

    return uniqueAppointments;
  }

  Future<void> updateAppointmentStatus(
      QueryDocumentSnapshot appointmentDoc, String newStatus) async {
    try {
      await appointmentDoc.reference.update({'status': newStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $newStatus')),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.pets, size: 40, color: Colors.blueAccent),
        title: Text(petName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date/Time: $formattedDate at $time'),
            Text('Reason: $reason'),
            Text('Vet: $vetName'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => updateAppointmentStatus(doc, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Approved',
              child: Text('Approve'),
            ),
            const PopupMenuItem(
              value: 'Rejected',
              child: Text('Reject'),
            ),
          ],
          child: const Icon(Icons.more_vert, color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Appointments'),
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