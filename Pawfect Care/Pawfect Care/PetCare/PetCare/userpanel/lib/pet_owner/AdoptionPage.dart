import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userpanel/pet_owner/AdoptionRequestForm.dart';

class AdoptionPage extends StatelessWidget {
  const AdoptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adopt a Pet")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pets")
            .where("status", isEqualTo: "Available")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: pet["image"] != ""
                      ? Image.network(
                          pet["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.pets, size: 40),
                  title: Text(pet["name"]),
                  subtitle: Text(
                    "Type: ${pet["type"] ?? "Unknown"}\n"
                    "Health: ${pet["healthStatus"] ?? "Not set"}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdoptionRequestForm(
                            petId: pet.id,
                            petName: pet["name"],
                          ),
                        ),
                      );
                    },
                    child: const Text("Adopt Now"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}