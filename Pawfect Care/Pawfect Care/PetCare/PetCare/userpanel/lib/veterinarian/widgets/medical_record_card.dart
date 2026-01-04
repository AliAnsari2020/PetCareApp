import 'package:flutter/material.dart';
import 'package:userpanel/models/medical_record.dart';
import 'package:userpanel/theme.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  const MedicalRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.12), AppColors.secondary.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withOpacity(0.15),
          child: Icon(Icons.description_rounded, color: AppColors.accent),
        ),
        title: Text(
          record.diagnosis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Treatment: ${record.treatment}", style: const TextStyle(fontSize: 15)),
              Text("Prescription: ${record.prescription}", style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    "${record.date.day}/${record.date.month}/${record.date.year}",
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: record.fileUrls.isNotEmpty
            ? Icon(Icons.attachment, color: AppColors.accent)
            : null,
      ),
    );
  }
}