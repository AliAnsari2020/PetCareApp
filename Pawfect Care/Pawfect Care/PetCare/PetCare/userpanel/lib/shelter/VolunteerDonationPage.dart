import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class VolunteerDonationPage extends StatefulWidget {
  const VolunteerDonationPage({Key? key}) : super(key: key);

  @override
  State<VolunteerDonationPage> createState() => _VolunteerDonationPageState();
}

class _VolunteerDonationPageState extends State<VolunteerDonationPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ✅ Volunteer Add Form
  Future<void> _addVolunteer() async {
    String name = "";
    String skill = "";
    String availability = "";
    String contact = "";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Add Volunteer"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Name"),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Contact"),
                  onChanged: (val) => contact = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Skills"),
                  onChanged: (val) => skill = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Availability"),
                  onChanged: (val) => availability = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.isEmpty) return;
                await _firestore.collection("volunteers").add({
                  "name": name,
                  "contact": contact,
                  "skill": skill,
                  "availability": availability,
                  "createdAt": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Donation Add Form
  Future<void> _addDonation() async {
    String donor = "";
    String amount = "";
    String mode = "";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Add Donation"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Donor Name"),
                  onChanged: (val) => donor = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => amount = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Payment Mode"),
                  onChanged: (val) => mode = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (donor.isEmpty || amount.isEmpty) return;
                await _firestore.collection("donations").add({
                  "donor": donor,
                  "amount": double.tryParse(amount) ?? 0,
                  "mode": mode,
                  "date": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVolunteers() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("volunteers")
              .orderBy("createdAt", descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Lottie.asset("images/Trailloading.json", height: 120),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No volunteers yet."));
        }

        return ListView(
          children:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.group, color: Colors.green),
                    title: Text(data["name"]),
                    subtitle: Text(
                      "Skill: ${data["skill"]}\nAvailability: ${data["availability"]}",
                    ),
                    trailing: Text(data["contact"]),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildDonations() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("donations")
              .orderBy("date", descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Lottie.asset("images/Trailloading.json", height: 120),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No donations yet."));
        }

        return ListView(
          children:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                    ),
                    title: Text("Donor: ${data["donor"]}"),
                    subtitle: Text("Mode: ${data["mode"]}"),
                    trailing: Text("\$${data["amount"].toString()}"),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text("Volunteers & Donations"),
        automaticallyImplyLeading: false,
        centerTitle: true, // 👈 back arrow remove
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: "Volunteers"),
            Tab(icon: Icon(Icons.volunteer_activism), text: "Donations"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_tabController.index == 0) {
                _addVolunteer();
              } else {
                _addDonation();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVolunteers(), _buildDonations()],
      ),
    );
  }
}
