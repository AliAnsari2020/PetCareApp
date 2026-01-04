class Pet {
  final String id;
  final String name;
  final String type;
  final String ownerId;
  final String photoUrl;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.photoUrl,
  });

  // For Firebase integration later
  factory Pet.fromMap(Map<String, dynamic> data, String documentId) {
    return Pet(
      id: documentId,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      ownerId: data['ownerId'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'ownerId': ownerId,
      'photoUrl': photoUrl,
    };
  }
}