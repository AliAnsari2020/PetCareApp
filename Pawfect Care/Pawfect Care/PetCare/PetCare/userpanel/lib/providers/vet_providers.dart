import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vet_repository.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/medical_record.dart';

// Repository provider
final vetRepositoryProvider = Provider((ref) => VetRepository());

// Assigned pets provider
final assignedPetsProvider = FutureProvider.family<List<Pet>, String>((ref, vetId) {
  return ref.read(vetRepositoryProvider).getAssignedPets(vetId);
});

// Appointments provider
final appointmentsProvider = FutureProvider.family<List<Appointment>, String>((ref, vetId) {
  return ref.read(vetRepositoryProvider).getAppointments(vetId);
});

// Medical records provider
// Dummy initial data for demo
final _dummyRecords = [
  MedicalRecord(
    id: 'm1',
    petId: '1',
    diagnosis: 'Allergy',
    treatment: 'Antihistamines',
    prescription: 'Cetirizine',
    fileUrls: [],
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
];

class MedicalRecordsNotifier extends StateNotifier<List<MedicalRecord>> {
  MedicalRecordsNotifier() : super(_dummyRecords);

  void addRecord(MedicalRecord record) {
    state = [...state, record];
  }

  // You can add edit/delete methods here for future use
}

final medicalRecordsProvider = StateNotifierProvider<MedicalRecordsNotifier, List<MedicalRecord>>(
  (ref) => MedicalRecordsNotifier(),
);