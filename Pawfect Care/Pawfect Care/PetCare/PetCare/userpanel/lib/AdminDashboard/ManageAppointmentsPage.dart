import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ManageAppointmentsPage extends StatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  State<ManageAppointmentsPage> createState() => _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState extends State<ManageAppointmentsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, String>> appointments = [
    {
      "pet": "Bella",
      "owner": "Ali Khan",
      "vet": "Dr. Sara",
      "datetime": "2025-09-15 10:00 AM",
      "status": "Pending",
    },
    {
      "pet": "Milo",
      "owner": "John Smith",
      "vet": "Dr. Ahmad",
      "datetime": "2025-09-15 02:30 PM",
      "status": "Confirmed",
    },
    {
      "pet": "Rocky",
      "owner": "Zain",
      "vet": "Dr. Sara",
      "datetime": "2025-09-16 11:00 AM",
      "status": "Completed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Appointments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Appointments List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.deepPurple.shade50,
                ),
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columns: const [
                  DataColumn(
                    label: Text(
                      "Pet",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Owner",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Vet",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Date/Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Actions",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: appointments.map((appt) {
                  return DataRow(
                    cells: [
                      DataCell(Text(appt["pet"]!)),
                      DataCell(Text(appt["owner"]!)),
                      DataCell(Text(appt["vet"]!)),
                      DataCell(Text(appt["datetime"]!)),
                      DataCell(
                        Chip(
                          label: Text(appt["status"]!),
                          backgroundColor: appt["status"] == "Confirmed"
                              ? Colors.green.shade100
                              : appt["status"] == "Completed"
                              ? Colors.blue.shade100
                              : appt["status"] == "Cancelled"
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                          labelStyle: TextStyle(
                            color: appt["status"] == "Confirmed"
                                ? Colors.green
                                : appt["status"] == "Completed"
                                ? Colors.blue
                                : appt["status"] == "Cancelled"
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
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                setState(() {
                                  appt["status"] = "Confirmed";
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  appt["status"] = "Cancelled";
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.done_all,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() {
                                  appt["status"] = "Completed";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
