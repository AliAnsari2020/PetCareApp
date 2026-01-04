class Appointment {
  final String id;
  final String petId;
  final String vetId;
  final DateTime dateTime;
  final String status; // confirmed, pending, rescheduled
  final String ownerId;

  Appointment({
    required this.id,
    required this.petId,
    required this.vetId,
    required this.dateTime,
    required this.status,
    required this.ownerId,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String documentId) {
    return Appointment(
      id: documentId,
      petId: data['petId'] ?? '',
      vetId: data['vetId'] ?? '',
      dateTime: DateTime.parse(data['dateTime']),
      status: data['status'] ?? 'pending',
      ownerId: data['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'vetId': vetId,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'ownerId': ownerId,
    };
  }
}