import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:userpanel/auth/signup.dart';
import 'package:userpanel/shelter/AdoptionRequests.dart';
import 'package:userpanel/shelter/ManagePetListings.dart';
import 'package:userpanel/shelter/ProfileScreen.dart';
import 'package:userpanel/shelter/SuccessStories.dart';
import 'package:userpanel/shelter/VolunteerDonationPage.dart';

class ShelterDashboard extends StatefulWidget {
  const ShelterDashboard({super.key});

  @override
  State<ShelterDashboard> createState() => _ShelterDashboardState();
}

class _ShelterDashboardState extends State<ShelterDashboard> {
  // 🎨 Color Theme
  static const Color primaryColor = Color(0xFF2E86C1);
  static const Color secondaryColor = Color(0xFF28B463);
  static const Color accentColor = Color(0xFFF39C12);
  static const Color backgroundColor = Color(0xFFF4F6F7);
  static const Color darkTextColor = Color(0xFF2C3E50);

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(), // Default Dashboard Home
    AdoptionRequests(),
    ManagePetListings(),
ProfileScreen(vetId: 'vetId'),
    SuccessStories(),
    VolunteerDonationPage(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.dashboard, "label": "Dashboard"},
    {"icon": Icons.assignment, "label": "Adoption Requests"},
    {"icon": Icons.pets, "label": "Manage Pets"},
    {"icon": Icons.settings, "label": "Profile Settings"},
    {"icon": Icons.star, "label": "Success Stories"},
    {"icon": Icons.volunteer_activism, "label": "Volunteers & Donations"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildAnimatedDrawer(context),
      appBar: AppBar(
        title: Text(
          _navItems[_selectedIndex]["label"],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildAnimatedDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Lottie.asset(
                    "images/AdminPanel.json",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Shelter Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _navItems[index]["icon"],
                      color: isSelected ? primaryColor : darkTextColor,
                    ),
                    title: Text(
                      _navItems[index]["label"],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? primaryColor : darkTextColor,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ✅ Dashboard Home
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final petsCollection = FirebaseFirestore.instance.collection('pets');
    final adoptionCollection = FirebaseFirestore.instance.collection(
      'adoption_requests',
    );
    final volunteersCollection = FirebaseFirestore.instance.collection(
      'volunteers',
    );
    final donationsCollection = FirebaseFirestore.instance.collection(
      'donations',
    );

    return StreamBuilder<List<int>>(
      stream: StreamZip([
        petsCollection.snapshots().map((snap) => snap.docs.length),
        adoptionCollection.snapshots().map((snap) => snap.docs.length),
        volunteersCollection.snapshots().map((snap) => snap.docs.length),
        donationsCollection.snapshots().map(
          (snap) => snap.docs.fold<int>(
            0,
            (sum, doc) => sum + ((doc.data()['amount'] ?? 0) as int),
          ),
        ),
      ]),

      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final petsAvailable = snapshot.data![0];
        final adoptionRequests = snapshot.data![1];
        final volunteers = snapshot.data![2];
        final donations = snapshot.data![3];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  StatCard(
                    title: "Pets Available",
                    value: petsAvailable.toString(),
                    icon: Icons.pets,
                    color1: AppColors.primaryColor,
                    color2: AppColors.secondaryColor,
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    title: "Adoption Requests",
                    value: adoptionRequests.toString(),
                    icon: Icons.assignment,
                    color1: AppColors.accentColor,
                    color2: Colors.deepOrangeAccent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatCard(
                    title: "Volunteers",
                    value: volunteers.toString(),
                    icon: Icons.group,
                    color1: AppColors.secondaryColor,
                    color2: const Color(0xFF52BE80),
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    title: "Donations",
                    value: "\PKR-$donations",
                    icon: Icons.attach_money,
                    color1: Colors.green,
                    color2: const Color(0xFF82E0AA),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Dashboard Card
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _ShelterDashboardState.darkTextColor,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ✅ Stat Card
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Pie Chart
class AdoptionPieChart extends StatelessWidget {
  final int petsAvailable;
  final int adoptionRequests;

  const AdoptionPieChart({
    super.key,
    required this.petsAvailable,
    required this.adoptionRequests,
  });

  @override
  Widget build(BuildContext context) {
    double total = petsAvailable + adoptionRequests.toDouble();
    double adoptedPercent = total > 0 ? (adoptionRequests / total) * 100 : 0;
    double availablePercent = total > 0 ? (petsAvailable / total) * 100 : 0;

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 45,
        sections: [
          PieChartSectionData(
            value: availablePercent,
            color: _ShelterDashboardState.secondaryColor,
            title: "${availablePercent.toStringAsFixed(1)}%",
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: adoptedPercent,
            color: _ShelterDashboardState.accentColor,
            title: "${adoptedPercent.toStringAsFixed(1)}%",
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Line Chart
class VolunteerLineChart extends StatelessWidget {
  final int volunteers;

  const VolunteerLineChart({super.key, required this.volunteers});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, horizontalInterval: 5),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 1:
                    return const Text("Jan");
                  case 2:
                    return const Text("Feb");
                  case 3:
                    return const Text("Mar");
                  case 4:
                    return const Text("Apr");
                }
                return const Text("");
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 5),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, volunteers.toDouble() * 0.25),
              FlSpot(2, volunteers.toDouble() * 0.5),
              FlSpot(3, volunteers.toDouble() * 0.75),
              FlSpot(4, volunteers.toDouble()),
            ],
            isCurved: true,
            barWidth: 4,
            color: _ShelterDashboardState.primaryColor,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _ShelterDashboardState.primaryColor.withOpacity(0.3),
                  _ShelterDashboardState.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Colors
class AppColors {
  static const Color primaryColor = Color(0xFF2E86C1);
  static const Color secondaryColor = Color(0xFF28B463);
  static const Color accentColor = Color(0xFFF39C12);
  static const Color darkTextColor = Color(0xFF2C3E50);
}