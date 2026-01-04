import 'package:flutter/material.dart';
import 'package:userpanel/models/pet.dart';
import 'package:userpanel/theme.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: AppColors.secondary, size: 32),
            Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(pet.type, style: const TextStyle(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}