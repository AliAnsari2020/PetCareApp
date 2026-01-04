import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionStatusPage extends StatelessWidget {
  const AdoptionStatusPage({super.key});

  Future<void> _updateStatus(String requestId, String status) async {
    await FirebaseFirestore.instance
        .collection("adoption_requests")
        .doc(requestId)
        .update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adoption Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("adoption_requests")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No adoption requests yet."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Pet: ${req["petName"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Owner: ${req["ownerName"]}"),
                      Text("Address: ${req["address"]}"),
                      Text("Contact: ${req["contact"]}"),
                      Text("Status: ${req["status"]}"),
                    ],
                  ),
                  trailing: req["status"] == "Pending"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  _updateStatus(req.id, "Approved"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _updateStatus(req.id, "Rejected"),
                            ),
                          ],
                        )
                      : Text(
                          req["status"],
                          style: TextStyle(
                            color: req["status"] == "Approved"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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