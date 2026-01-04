import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:userpanel/pet_owner/AdoptionPage.dart';
import 'package:userpanel/pet_owner/AdoptionStatusPage.dart';
import 'package:userpanel/pet_owner/ai_chat_screen.dart';
import 'package:userpanel/pet_owner/appointments_list.dart';
import 'package:userpanel/pet_owner/blogandtips/viewblog.dart';
import 'package:userpanel/pet_owner/health/healthrecord.dart';
import 'package:userpanel/pet_owner/pet_store/petstorehome.dart';
import 'package:userpanel/shelter/ProfileScreen.dart';
import 'add_pet.dart';
import 'view_pet.dart';
import 'package:iconsax/iconsax.dart';

class PetOwnerDashboard extends StatefulWidget {
  @override
  State<PetOwnerDashboard> createState() => _PetOwnerDashboardState();
}

class _PetOwnerDashboardState extends State<PetOwnerDashboard> {
  int _selectedIndex = 0;
  int _carouselIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Carousel items with actual image paths
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Health Tracking',
      'subtitle': 'Monitor your pet\'s health records',
      'image': 'images/health_banner.jpg',
      'color': Color(0xFF28B463),
      'route': 'health',
    },
    {
      'title': 'Pet Store',
      'subtitle': 'Premium products for your furry friends',
      'image': 'images/store_banner.jpg',
      'color': Color(0xFFF39C12),
      'route': 'store',
    },
    {
      'title': 'Expert Tips',
      'subtitle': 'Learn from veterinary professionals',
      'image': 'images/tip_banner.jpg',
      'color': Color(0xFF2E86C1),
      'route': 'blogs',
    },
    {
      'title': 'Appointments',
      'subtitle': 'Schedule vet visits with ease',
      'image': 'images/health_banner.jpg', // Using same image as placeholder
      'color': Color(0xFF8E44AD),
      'route': 'appointments',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateFromCarousel(String route) {
    switch (route) {
      case 'health':
        _navigateToHealth();
        break;
      case 'store':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetProductsPage()),
        );
        break;
      case 'blogs':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BlogsPage()),
        );
        break;
      case 'appointments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OwnerAppointmentsScreen()),
        );
        break;
      case 'adoption': 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdoptionPage()),
        );
    }
  }

  Future<void> _navigateToHealth() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pets = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("pets")
        .get();

    if (pets.docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add a pet first")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Pet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: pets.docs.map((doc) {
            final pet = doc.data();
            return ListTile(
              leading: const Icon(Iconsax.pet, color: Color(0xFF2E86C1)),
              title: Text(pet["name"] ?? "Unnamed"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthRecordsScreen(petId: doc.id),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Pages for Bottom Nav
    final List<Widget> _pages = [
      _buildHomePage(uid), // Home
      OwnerAppointmentsScreen(), // Schedule
      PetProductsPage(), // Pet Store
      ProfileScreen(vetId: 'vetId'),
    ];
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),

      // 👇 Chatbot Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AiChatScreen()),
          );
        },
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Enhanced Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2E86C1),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: _selectedIndex == 0
                    ? BoxDecoration(
                        color: Color(0xFF2E86C1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(Iconsax.home, size: 24),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: _selectedIndex == 1
                    ? BoxDecoration(
                        color: Color(0xFF2E86C1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(Iconsax.calendar, size: 24),
              ),
              label: "Schedule",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: _selectedIndex == 2
                    ? BoxDecoration(
                        color: Color(0xFF2E86C1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(Iconsax.shop, size: 24),
              ),
              label: "Store",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: _selectedIndex == 3
                    ? BoxDecoration(
                        color: Color(0xFF2E86C1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(Iconsax.user, size: 24),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced Home Page UI
  Widget _buildHomePage(String uid) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message - REPLACED APPBAR
          _buildWelcomeSection(uid),

          SizedBox(height: 24),

          // Promotional Carousel with ACTUAL IMAGES
          _buildPromoCarousel(),

          SizedBox(height: 24),

          // My Pets Section
          _buildPetsSection(uid),

          SizedBox(height: 24),

          // Quick Actions
          _buildQuickActionsGrid(),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Welcome Section with user greeting - NOW ACTS AS HEADER
  Widget _buildWelcomeSection(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = "Pet Lover";

        if (snapshot.hasData && snapshot.data!.exists) {
          userName = snapshot.data!['name'] ?? "Pet Lover";
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.notification,
                  color: Color(0xFF2E86C1),
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180, // slightly increased for better spacing
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselItems.length,
            onPageChanged: (index) {
              setState(() {
                _carouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return GestureDetector(
                onTap: () => _navigateFromCarousel(item['route']),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: item['color'],
                    boxShadow: [
                      BoxShadow(
                        color: item['color'].withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(item['image']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: Text(
                              item['subtitle'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item['color'],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Iconsax.arrow_right_2,
                                  size: 14,
                                  color: item['color'],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _carouselItems.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _carouselIndex == entry.key ? 20 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: _carouselIndex == entry.key
                    ? BoxShape.rectangle
                    : BoxShape.circle,
                // borderRadius: _carouselIndex == entry.key
                //     ? BorderRadius.circular(10)
                //     : null,
                color: _carouselIndex == entry.key
                    ? const Color(0xFF2E86C1)
                    : Colors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// My Pets Section
  Widget _buildPetsSection(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Pets",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddPetScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF2E86C1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Add New",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("pets")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildAddPetCard();
              }

              final pets = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length + 1,
                itemBuilder: (context, index) {
                  if (index < pets.length) {
                    final pet = pets[index];
                    return _buildPetCard(pet, true);
                  } else {
                    return _buildAddPetCard();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Individual Pet Card
  Widget _buildPetCard(QueryDocumentSnapshot pet, bool hasData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewPetScreen(petId: pet.id, petData: pet),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: _getPetImage(pet["image"]) != null
                    ? Image(
                        image: _getPetImage(pet["image"])!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Icon(Iconsax.pet, size: 40, color: Color(0xFF2E86C1)),
              ),
            ),
            SizedBox(height: 8),
            Text(
              pet["name"] ?? "Unnamed",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              pet["breed"] ?? "",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Add Pet Card
  Widget _buildAddPetCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddPetScreen()),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(Iconsax.add, size: 30, color: Color(0xFF2E86C1)),
            ),
            SizedBox(height: 8),
            Text(
              "Add Pet",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions Grid
  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildQuickAction(
              Iconsax.health,
              "Health Tracking",
              Color(0xFF28B463),
              onTap: _navigateToHealth,
            ),
            _buildQuickAction(
              Iconsax.calendar,
              "Appointments",
              Color(0xFF2E86C1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OwnerAppointmentsScreen()),
                );
              },
            ),
            _buildQuickAction(
              Iconsax.shop,
              "Pet Store",
              Color(0xFFF39C12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetProductsPage()),
                );
              },
            ),
            _buildQuickAction(
              Iconsax.book,
              "Tips & Blogs",
              Color(0xFF8E44AD),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlogsPage()),
                );
              },
            ),
            // ✅ New Quick Action for Adoption
            _buildQuickAction(
              Iconsax.heart, // ya koi aur icon jo adoption suit kare
              "Pet Adoption Page",
              Color(0xFFE74C3C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdoptionPage()),
                );
              },
            ),

            _buildQuickAction(
              Iconsax.heart, // ya koi aur icon jo adoption suit kare
              "Adoption Status Page",
              Color(0xFFE74C3C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdoptionStatusPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Enhanced Quick Action Card
  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Text(
                    "View",
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Iconsax.arrow_right_3, size: 14, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for image (URL/Base64)
  ImageProvider? _getPetImage(String? imageString) {
    if (imageString == null || imageString.isEmpty) return null;

    if (imageString.startsWith("http")) {
      return NetworkImage(imageString);
    } else {
      try {
        Uint8List bytes = base64Decode(imageString);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint("Image decode error: $e");
        return null;
      }
    }
  }
}