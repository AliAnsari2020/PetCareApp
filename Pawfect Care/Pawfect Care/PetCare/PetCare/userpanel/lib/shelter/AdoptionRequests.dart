import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class AdoptionRequests extends StatefulWidget {
  const AdoptionRequests({Key? key}) : super(key: key);

  @override
  State<AdoptionRequests> createState() => _AdoptionRequestsState();
}

class _AdoptionRequestsState extends State<AdoptionRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update Status
  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection("adoption_requests").doc(id).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // Show Applicant + Pet Details
  void showDetails(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Applicant: ${doc['applicantName']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Contact: ${doc['contact']}"),
                Text("Email: ${doc['email']}"),
                const Divider(),
                Text(
                  "Pet Name: ${doc['petName']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Pet ID: ${doc['petId']}"),
                const Divider(),
                Text("Status: ${doc['status']}"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        updateStatus(doc.id, "Approved");
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        updateStatus(doc.id, "Rejected");
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adoption Requests"),
        automaticallyImplyLeading: false,
        centerTitle: true, // 👈 back arrow remove ho gaya
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("adoption_requests")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Lottie.asset("images/Trailloading.json", height: 100),
            );
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No adoption requests yet."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.blue.shade100,
              ),
              columns: const [
                DataColumn(label: Text("Applicant")),
                DataColumn(label: Text("Pet")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Action")),
              ],
              rows: requests.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final createdAt = (data["createdAt"] as Timestamp?)?.toDate();

                return DataRow(
                  cells: [
                    DataCell(Text(data["applicantName"] ?? "")),
                    DataCell(Text(data["petName"] ?? "")),
                    DataCell(
                      Text(
                        createdAt != null
                            ? createdAt.toString().split(".").first
                            : "-",
                      ),
                    ),
                    DataCell(
                      Text(
                        data["status"] ?? "Pending",
                        style: TextStyle(
                          color: data["status"] == "Approved"
                              ? Colors.green
                              : data["status"] == "Rejected"
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info, color: Colors.blue),
                            onPressed: () => showDetails(doc),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => updateStatus(doc.id, "Approved"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => updateStatus(doc.id, "Rejected"),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}