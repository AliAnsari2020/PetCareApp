import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_appointment.dart';

enum AppointmentFilter { All, Upcoming, Past, Cancelled }

class OwnerAppointmentsScreen extends StatefulWidget {
  const OwnerAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerAppointmentsScreen> createState() => _OwnerAppointmentsScreenState();
}

class _OwnerAppointmentsScreenState extends State<OwnerAppointmentsScreen> {
  AppointmentFilter _filter = AppointmentFilter.All;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Appointments"),
        backgroundColor: Color(0xFF2E86C1),
        actions: [
          PopupMenuButton<AppointmentFilter>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: AppointmentFilter.All, child: Text("All")),
              PopupMenuItem(value: AppointmentFilter.Upcoming, child: Text("Upcoming")),
              PopupMenuItem(value: AppointmentFilter.Past, child: Text("Past")),
              PopupMenuItem(value: AppointmentFilter.Cancelled, child: Text("Cancelled")),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("appointments")
            .orderBy("date", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final allAppointments = snapshot.data!.docs;
          final now = DateTime.now();

          // Filter logic
          final filteredAppointments = allAppointments.where((app) {
            final data = app.data() as Map<String, dynamic>;
            final status = data["status"] ?? "Pending";
            final date = (data["date"] as Timestamp).toDate();

            switch (_filter) {
              case AppointmentFilter.Upcoming:
                return status != "Cancelled" && date.isAfter(now);
              case AppointmentFilter.Past:
                return status != "Cancelled" && date.isBefore(now);
              case AppointmentFilter.Cancelled:
                return status == "Cancelled";
              case AppointmentFilter.All:
              default:
                return true;
            }
          }).toList();

          if (filteredAppointments.isEmpty)
            return Center(child: Text("No appointments found for this filter"));

          return ListView.builder(
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              final app = filteredAppointments[index];
              final data = app.data() as Map<String, dynamic>;

              Color statusColor;
              switch ((data["status"] ?? "Pending").toString()) {
                case "Approved":
                  statusColor = Colors.green;
                  break;
                case "Rejected":
                  statusColor = Colors.red;
                  break;
                case "Cancelled":
                  statusColor = Colors.grey;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(Icons.pets, color: statusColor),
                  ),
                  title: Text("${data["vetName"] ?? "Vet"} - ${data["reason"] ?? ""}"),
                  subtitle: Text(
                      "Pet: ${data["petName"]}\nDate: ${(data["date"] as Timestamp).toDate().toLocal().toString().split(" ")[0]} at ${data["time"]}"),
                  trailing: Text(
                    data["status"] ?? "Pending",
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _showAppointmentActions(context, app.id, data);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2E86C1),
        child: Icon(Icons.add),
        onPressed: () async {
          final pets = await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("pets")
              .get();

          if (pets.docs.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Add a pet first before booking an appointment")),
            );
            return;
          }

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Select Pet"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: pets.docs.map((doc) {
                  final pet = doc.data();
                  return ListTile(
                    leading: Icon(Icons.pets, color: Color(0xFF2E86C1)),
                    title: Text(pet["name"] ?? "Unnamed"),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddAppointmentScreen(
                            petId: doc.id,
                            petName: pet["name"] ?? "Unnamed",
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAppointmentActions(BuildContext context, String appointmentId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("Reschedule"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddAppointmentScreen(
                      petId: data["petId"],
                      petName: data["petName"],
                      // optionally prefill date/time/reason for reschedule
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text("Cancel Appointment"),
              onTap: () async {
                Navigator.pop(context);
                await _cancelAppointment(appointmentId, data);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text("Close"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(String appointmentId, Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Update owner collection
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("appointments")
          .doc(appointmentId)
          .update({"status": "Cancelled"});

      // Update vet collection
      final vetId = data["vetId"];
      final ownerId = uid;
      final vetAppointments = await FirebaseFirestore.instance
          .collection("users")
          .doc(vetId)
          .collection("appointments")
          .where("ownerId", isEqualTo: ownerId)
          .get();

      for (var doc in vetAppointments.docs) {
        await doc.reference.update({"status": "Cancelled"});
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text("Appointment cancelled successfully")));
    } catch (e) {
      print("Error cancelling appointment: $e");
    }
  }
}

// Add a global navigatorKey in main.dart for snackbar in async callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
