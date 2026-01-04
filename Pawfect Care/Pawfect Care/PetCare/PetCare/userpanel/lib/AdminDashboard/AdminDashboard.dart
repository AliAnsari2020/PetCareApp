import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userpanel/AdminDashboard/BlogManagementPage.dart';
import 'package:userpanel/AdminDashboard/ManageAppointmentsPage.dart';
import 'package:userpanel/AdminDashboard/ManagePetsPage.dart';
import 'package:userpanel/AdminDashboard/ManageUsersPage.dart';
import 'package:userpanel/AdminDashboard/PetStorePage.dart';
import 'package:userpanel/AdminDashboard/SuccessStoriesPage.dart';
import 'package:userpanel/AdminDashboard/VolunteersDonationsPage%20.dart';
import 'package:lottie/lottie.dart';
import 'package:userpanel/auth/login.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Stream<int> getCollectionCount(String subCollection) {
    return FirebaseFirestore.instance
        .collectionGroup(subCollection) // ✅ sab users ke pets count hoga
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600
        ? 1
        : width < 900
        ? 2
        : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 4,
        centerTitle: true,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: ClipOval(
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Lottie.asset(
                    "images/AdminPanel.json",
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ),
              accountName: const Text("Admin Panel"),
              accountEmail: const Text("admin@gmail.com"),
            ),

            _buildDrawerItem(
              context,
              icon: Icons.dashboard,
              title: "Dashboard",
              page: const DashboardPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.article,
              title: "Blog Management",
              page: const BlogManagementPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calendar_month,
              title: "Manage Appointments",
              page: const ManageAppointmentsPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.pets,
              title: "Manage Pets",
              page: const ManagePetsPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.group,
              title: "Manage Users",
              page: const ManageUsersPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.store,
              title: "Pet Store",
              page: const PetStorePage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.check_circle,
              title: "Success Stories",
              page: const SuccessStoriesPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.volunteer_activism,
              title: "Volunteers & Donations",
              page: const VolunteersDonationsPage(),
            ),

            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2, // Makes cards more rectangular
              children: [
                StatCard(
                  title: "Total Users",
                  icon: Icons.person,
                  color: Colors.blue,
                  stream: getCollectionCount("users"),
                ),
                StatCard(
                  title: "Total Pets",
                  icon: Icons.pets,
                  color: Colors.orange,
                  stream: getCollectionCount("pets"),
                ),
                StatCard(
                  title: "Appointments",
                  icon: Icons.calendar_month,
                  color: Colors.green,
                  stream: getCollectionCount("appointments"),
                ),
                StatCard(
                  title: "Blogs",
                  icon: Icons.article,
                  color: Colors.purple,
                  stream: getCollectionCount("blogs"),
                ),
                StatCard(
                  title: "Donations",
                  icon: Icons.volunteer_activism,
                  color: Colors.red,
                  stream: getCollectionCount("donations"),
                ),
                StatCard(
                  title: "Success Stories",
                  icon: Icons.check_circle,
                  color: Colors.teal,
                  stream: getCollectionCount("success_stories"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            DashboardSection(
              title: "📊 Appointment Trends",
              child: const SizedBox(height: 200, child: AppointmentLineChart()),
            ),
            DashboardSection(
              title: "🐾 Adoption Success Rate",
              child: const SizedBox(height: 200, child: AdoptionPieChart()),
            ),
            DashboardSection(
              title: "🛒 Store Sales Stats",
              child: const SizedBox(height: 200, child: StoreBarChart()),
            ),
            DashboardSection(
              title: "💝 Donations Breakdown",
              child: const SizedBox(height: 200, child: DonationPieChart()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}

class DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const DashboardSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Stream<int> stream;

  const StatCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? snapshot.data.toString() : '0';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 200;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.85), color.withOpacity(0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmall ? 24 : 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            value,
                            key: ValueKey<String>(value),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmall ? 18 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AppointmentLineChart extends StatelessWidget {
  const AppointmentLineChart({super.key});
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: const [
              FlSpot(1, 2),
              FlSpot(2, 3),
              FlSpot(3, 5),
              FlSpot(4, 4),
              FlSpot(5, 6),
              FlSpot(6, 7),
            ],
            dotData: const FlDotData(show: true),
            color: Colors.blueAccent,
            barWidth: 4,
          ),
        ],
      ),
    );
  }
}

class AdoptionPieChart extends StatelessWidget {
  const AdoptionPieChart({super.key});
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        sections: [
          PieChartSectionData(
            value: 70,
            title: "70%",
            color: Colors.green,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          PieChartSectionData(
            value: 30,
            title: "30%",
            color: Colors.orange,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class StoreBarChart extends StatelessWidget {
  const StoreBarChart({super.key});
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: [
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 20)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 7, color: Colors.blue, width: 20)],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 3, color: Colors.blue, width: 20)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 20)],
          ),
        ],
      ),
    );
  }
}

class DonationPieChart extends StatelessWidget {
  const DonationPieChart({super.key});
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        sections: [
          PieChartSectionData(
            value: 40,
            title: "40%",
            color: Colors.purple,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white),
          ),
          PieChartSectionData(
            value: 25,
            title: "25%",
            color: Colors.red,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white),
          ),
          PieChartSectionData(
            value: 20,
            title: "20%",
            color: Colors.orange,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white),
          ),
          PieChartSectionData(
            value: 15,
            title: "15%",
            color: Colors.blue,
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}