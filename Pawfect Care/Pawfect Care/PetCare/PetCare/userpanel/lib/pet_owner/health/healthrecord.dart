import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_health.dart';

class HealthRecordsScreen extends StatelessWidget {
  final String petId;

  const HealthRecordsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Health Records"),
        backgroundColor: Color(0xFF2E86C1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("pets")
            .doc(petId)
            .collection("health_records")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No health records yet"));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final data = record.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: Icon(Icons.health_and_safety, color: Color(0xFF2E86C1)),
                  title: Text(data["title"] ?? "Untitled"),
                  subtitle: Text(
                    data["date"] != null
                        ? "📅 ${data["date"].toDate().toLocal().toString().split(" ")[0]}"
                        : "No Date",
                  ),
                  children: [
                    ListTile(
                      title: Text("📝 Notes"),
                      subtitle: Text(data["notes"] ?? "N/A"),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .collection("pets")
                            .doc(petId)
                            .collection("health_records")
                            .doc(record.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Record deleted")),
                        );
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2E86C1),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHealthRecordScreen(petId: petId)),
          );
        },
      ),
    );
  }
}
