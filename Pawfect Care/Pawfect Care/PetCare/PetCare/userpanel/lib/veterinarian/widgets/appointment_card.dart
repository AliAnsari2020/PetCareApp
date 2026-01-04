import 'package:flutter/material.dart';
import 'package:userpanel/models/appointment.dart';
import 'package:userpanel/theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pet ID: ${appointment.petId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Time: ${appointment.dateTime}'),
                Text('Status: ${appointment.status}', style: const TextStyle(color: AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}