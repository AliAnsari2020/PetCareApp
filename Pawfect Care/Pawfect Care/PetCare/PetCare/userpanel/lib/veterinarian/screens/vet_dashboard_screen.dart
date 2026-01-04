import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:userpanel/shelter/ProfileScreen.dart';
import 'package:userpanel/theme.dart';
import 'package:userpanel/veterinarian/screens/approved_rejected_appointments_screen.dart';
import 'package:userpanel/veterinarian/screens/vet_appointments.dart';
import 'vet_appointments_calendar_screen.dart'
    hide VetAppointmentsCalendarScreen;
import 'package:userpanel/veterinarian/screens/vet_medical_records_screen.dart';

class VetDashboardScreen extends StatelessWidget {
  final String vetId;
  const VetDashboardScreen({Key? key, required this.vetId}) : super(key: key);

  // 🔹 Fetch pets from approved appointments and get pet details from 'pets' collection
  Future<List<Map<String, dynamic>>> fetchAssignedPets() async {
    final appointmentSnapshot = await FirebaseFirestore.instance
        .collectionGroup('appointments')
        .where('vetId', isEqualTo: vetId)
        .where('status', isEqualTo: 'Approved')
        .get();

    // Extract unique petIds from appointments
    final petIds = appointmentSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['petId'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (petIds.isEmpty) return [];

    // Firestore 'whereIn' supports max 10 elements, so batch if needed
    List<Map<String, dynamic>> pets = [];
    const batchSize = 10;
    for (var i = 0; i < petIds.length; i += batchSize) {
      final batchPetIds = petIds.sublist(
        i,
        i + batchSize > petIds.length ? petIds.length : i + batchSize,
      );

      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where(FieldPath.documentId, whereIn: batchPetIds)
          .get();

      pets.addAll(
        petsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'type': data['type'] ?? 'Pet',
            'owner': data['ownerName'] ?? 'Owner',
            'photo':
                data['photoUrl'] ??
                'https://cdn-icons-png.flaticon.com/512/616/616408.png', // fallback
          };
        }),
      );
    }

    return pets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 180, 255),
        title: const Text(
          'Vet Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileScreen(vetId: vetId), // 👈 yahan vetId pass karo
                  ),
                );
                ;
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // default profile photo
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome, Doctor!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Center(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(vetId) // 👈 apna vetId pass karo
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // fallback
                            ),
                          ),
                          const SizedBox(height: 20), // 👈 niche ka space
                        ],
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final photoUrl =
                        data['imageUrl'] ??
                        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(photoUrl),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 20), // 👈 niche ka space
                      ],
                    );
                  },
                ),
              ),

              // 🔹 Row Buttons
              Column(
                children: [
                  DashboardRowButton(
                    icon: Icons.medical_services_rounded,
                    label: "Medical Records",
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHealthRecordScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DashboardRowButton(
                    icon: Icons.calendar_month_rounded,
                    label: "Appointments",
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VetAppointmentsScreen(currentVetId: vetId),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DashboardRowButton(
                    icon: Icons.calendar_month_rounded,
                    label: "Appointments Calender",
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 243, 18, 217),
                        AppColors.primary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VetAppointmentsCalendarScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DashboardRowButton(
                    icon: Icons.calendar_month_rounded,
                    label: "Appointments List",
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 29, 243, 18),
                        AppColors.primary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VetAppointmentListScreen(currentVetId: vetId),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // ⚡ keep same UI for appointments (dummy/static for now)
              // you can hook this up to Firestore later
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Row-style button widget
class DashboardRowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const DashboardRowButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}