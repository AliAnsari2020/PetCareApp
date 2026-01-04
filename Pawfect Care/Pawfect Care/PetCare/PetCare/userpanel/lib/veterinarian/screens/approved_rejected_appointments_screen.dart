import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:userpanel/theme.dart';

// Dummy data for appointments
final Map<DateTime, List<Map<String, String>>> dummyAppointments = {
  DateTime.utc(2025, 9, 11): [
    {
      'time': '10:00 AM',
      'pet': 'Bella',
      'owner': 'John Doe',
      'status': 'pending',
    },
  ],
  DateTime.utc(2025, 9, 15): [
    {
      'time': '11:30 AM',
      'pet': 'Max',
      'owner': 'Jane Smith',
      'status': 'confirmed',
    },
  ],
  DateTime.utc(2025, 10, 16): [
    {
      'time': '09:00 AM',
      'pet': 'Milo',
      'owner': 'Alice',
      'status': 'pending',
    },
  ],
};

class VetAppointmentsCalendarScreen extends StatefulWidget {
  const VetAppointmentsCalendarScreen({super.key});

  @override
  State<VetAppointmentsCalendarScreen> createState() => _VetAppointmentsCalendarScreenState();
}

class _VetAppointmentsCalendarScreenState extends State<VetAppointmentsCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _availability = {}; // Orange dot
  Set<DateTime> _booked = {}; // Green background

  @override
  void initState() {
    super.initState();
    // Pre-populate _booked with dummy appointments
    _booked = dummyAppointments.keys.toSet();
  }

  List<Map<String, String>> getAppointmentsForDay(DateTime day) {
    return dummyAppointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  bool isBooked(DateTime day) {
    return _booked.any((d) => isSameDay(d, day));
  }

  bool isAvailable(DateTime day) {
    return _availability.any((d) => isSameDay(d, day));
  }

  @override
  Widget build(BuildContext context) {
    final bookedDates = _booked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments Calendar'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: AppColors.white,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Your Consultation Calendar",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Row(
                  children: [
                    _LegendDot(color: AppColors.secondary),
                    const SizedBox(width: 4),
                    const Text("Booked", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.accent),
                    const SizedBox(width: 4),
                    const Text("Available", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.all,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: AppColors.fontDark),
                  weekendTextStyle: TextStyle(color: AppColors.primary),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final isBookedDay = isBooked(day);
                    final isAvailableDay = isAvailable(day);
                    if (isBookedDay) {
                      // Booked: green background, orange dot if also available
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDayCircle(day, AppColors.secondary, AppColors.white),
                          if (isAvailableDay)
                            Positioned(
                              bottom: 6,
                              child: _Dot(color: AppColors.accent),
                            ),
                        ],
                      );
                    } else if (isAvailableDay) {
                      // Only available: orange dot
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: AppColors.fontDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            child: _Dot(color: AppColors.accent),
                          ),
                        ],
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final isBookedDay = isBooked(day);
                    final isAvailableDay = isAvailable(day);
                    if (isBookedDay) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDayCircle(day, AppColors.secondary, AppColors.white, border: true),
                          if (isAvailableDay)
                            Positioned(
                              bottom: 6,
                              child: _Dot(color: AppColors.accent),
                            ),
                        ],
                      );
                    } else if (isAvailableDay) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDayCircle(day, AppColors.accent, AppColors.white, border: true),
                        ],
                      );
                    }
                    return _buildDayCircle(day, AppColors.accent, AppColors.white, border: true);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final isBookedDay = isBooked(day);
                    final isAvailableDay = isAvailable(day);
                    if (isBookedDay) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDayCircle(day, AppColors.secondary, AppColors.white, border: true),
                          if (isAvailableDay)
                            Positioned(
                              bottom: 6,
                              child: _Dot(color: AppColors.accent),
                            ),
                        ],
                      );
                    } else if (isAvailableDay) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDayCircle(day, AppColors.accent, AppColors.white, border: true),
                        ],
                      );
                    }
                    return _buildDayCircle(day, AppColors.primary, AppColors.white, border: true);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Mark as Available"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _selectedDay == null
                        ? null
                        : () {
                            final day = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                            if (!_availability.any((d) => isSameDay(d, day))) {
                              setState(() {
                                _availability.add(day);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Marked ${DateFormat('dd MMM yyyy').format(day)} as available!",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.accent,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Already marked as available.",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.accent,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: const Text("Mark as Booked"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _selectedDay == null
                        ? null
                        : () {
                            final day = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                            if (!_booked.any((d) => isSameDay(d, day))) {
                              setState(() {
                                _booked.add(day);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Marked ${DateFormat('dd MMM yyyy').format(day)} as booked!",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Already marked as booked.",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Booked Dates List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Booked Dates:",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: bookedDates
                      .map((date) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event, color: AppColors.secondary, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy').format(date),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              // Appointments for selected day
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _selectedDay == null
                      ? Center(
                          child: Text(
                            "Select a day to view appointments.",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Appointments for ${DateFormat('dd MMM yyyy').format(_selectedDay!)}",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final appts = getAppointmentsForDay(_selectedDay!);
                                  if (appts.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No appointments for this day.",
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: appts.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final appt = appts[i];
                                      return Card(
                                        color: AppColors.primary.withOpacity(0.08),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            appt['status'] == 'confirmed'
                                                ? Icons.check_circle
                                                : Icons.pending_actions,
                                            color: appt['status'] == 'confirmed'
                                                ? AppColors.secondary
                                                : AppColors.accent,
                                          ),
                                          title: Text(
                                            '${appt['pet']} (${appt['time']})',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text('Owner: ${appt['owner']}'),
                                          trailing: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'confirm') {
                                                setState(() {
                                                  appt['status'] = 'confirmed';
                                                });
                                              } else if (value == 'reschedule') {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Reschedule feature coming soon!'),
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              if (appt['status'] != 'confirmed')
                                                const PopupMenuItem(
                                                  value: 'confirm',
                                                  child: Text('Confirm'),
                                                ),
                                              const PopupMenuItem(
                                                value: 'reschedule',
                                                child: Text('Reschedule'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCircle(DateTime day, Color color, Color textColor, {bool border = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      width: 38,
      height: 38,
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Helper widget for legend
class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Helper widget for orange dot
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}