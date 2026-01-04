class MedicalRecord {
  final String id;
  final String petId;
  final String diagnosis;
  final String treatment;
  final String prescription;
  final List<String> fileUrls;
  final DateTime date;

  MedicalRecord({
    required this.id,
    required this.petId,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.fileUrls,
    required this.date,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> data, String documentId) {
    return MedicalRecord(
      id: documentId,
      petId: data['petId'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      treatment: data['treatment'] ?? '',
      prescription: data['prescription'] ?? '',
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'fileUrls': fileUrls,
      'date': date.toIso8601String(),
    };
  }
}