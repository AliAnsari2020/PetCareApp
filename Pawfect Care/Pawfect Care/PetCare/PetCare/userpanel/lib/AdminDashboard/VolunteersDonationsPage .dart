import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteersDonationsPage extends StatefulWidget {
  const VolunteersDonationsPage({super.key});

  @override
  State<VolunteersDonationsPage> createState() =>
      _VolunteersDonationsPageState();
}

class _VolunteersDonationsPageState extends State<VolunteersDonationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildTable({
    required AsyncSnapshot<QuerySnapshot> snapshot,
    required List<DataColumn> columns,
    required List<DataRow> rows,
    required Color headerColor,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(headerColor),
          columnSpacing: 20,
          dataRowHeight: 50,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(fontSize: 13),
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Volunteers & Donations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.group, color: Colors.white),
              text: "Volunteers",
            ),
            Tab(
              icon: Icon(Icons.volunteer_activism, color: Colors.white),
              text: "Donations",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ Volunteers Table
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 5,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("volunteers")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "🚫 No volunteers found",
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  }

                  final volunteers = snapshot.data!.docs;

                  return _buildTable(
                    snapshot: snapshot,
                    headerColor: Colors.deepPurple.shade100,
                    columns: const [
                      DataColumn(label: Text("👤 Name")),
                      DataColumn(label: Text("📞 Contact")),
                      DataColumn(label: Text("💡 Skill")),
                    ],
                    rows: volunteers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(
                        color: WidgetStateProperty.all(
                          index % 2 == 0 ? Colors.grey.shade100 : Colors.white,
                        ),
                        cells: [
                          DataCell(Text(data["name"].toString())),
                          DataCell(Text(data["contact"].toString())),
                          DataCell(Text(data["skill"].toString())),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          // ✅ Donations Table
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 5,
              shadowColor: Colors.teal.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("donations")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "🚫 No donations found",
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  }

                  final donations = snapshot.data!.docs;

                  return _buildTable(
                    snapshot: snapshot,
                    headerColor: Colors.teal.shade100,
                    columns: const [
                      DataColumn(label: Text("🙋 Donor")),
                      DataColumn(label: Text("💳 Mode")),
                      DataColumn(label: Text("💵 Amount")),
                    ],
                    rows: donations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(
                        color: WidgetStateProperty.all(
                          index % 2 == 0 ? Colors.grey.shade100 : Colors.white,
                        ),
                        cells: [
                          DataCell(Text(data["donor"].toString())),
                          DataCell(Text(data["mode"].toString())),
                          DataCell(Text(data["amount"].toString())),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
