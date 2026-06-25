import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBiSJF5ziZz5XHKJvIAiR83_CYmk2kvKlA",
      authDomain: "medicinie-app.firebaseapp.com",
      projectId: "medicinie-app",
      storageBucket: "medicinie-app.firebasestorage.app",
      messagingSenderId: "454090128372",
      appId: "1:454090128372:web:8e6c676f439ac02a7797a1",
      measurementId: "G-RHVCQDLC4H",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDINUS Student Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationContainer(),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 1; // Profile tab selected by default as in Screen 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E36), // Deep navy blue background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card Header: UDINUS Banner
                      Container(
                        color: const Color(0xFF2196F3), // Bright blue
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Image.network(
                                'https://cc.dinus.ac.id/assets/img/logo-udinus.png',
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.school,
                                    color: Color(0xFF2196F3),
                                    size: 24,
                                  );
                                },
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'UNIVERSITAS DIAN NUSWANTORO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Card Body: Swapped based on tab
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 380,
                        ),
                        child: _buildBodyContent(),
                      ),
                      // Card Footer: Custom Bottom Navigation Bar
                      Container(
                        color: const Color(0xFF2196F3), // Bright blue navigation background
                        height: 64,
                        child: Row(
                          children: [
                            _buildNavItem(
                              index: 0,
                              icon: Icons.person, // Labeled "Dashboard" in screenshot
                              label: 'Dashboard',
                            ),
                            _buildNavItem(
                              index: 1,
                              icon: Icons.book, // Labeled "Profile" in screenshot
                              label: 'Profile',
                            ),
                            _buildNavItem(
                              index: 2,
                              icon: Icons.settings, // Labeled "Setting" in screenshot
                              label: 'Setting',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0:
        // Dashboard Tab
        return const _DashboardTabContent();
      case 1:
        // Profile Tab (Matches Screen 1 UI)
        return const _ProfileTabContent();
      case 2:
        // Settings Tab
        return const _SettingsTabContent();
      default:
        return const _ProfileTabContent();
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected ? Colors.white : Colors.white.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PROFILE TAB CONTENT
class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent();

  Future<DocumentSnapshot> _getOrCreateProfile() async {
    final docRef = FirebaseFirestore.instance.collection('profil').doc('baby_bozz');
    final doc = await docRef.get();
    if (!doc.exists) {
      // Seed default profile data
      await docRef.set({
        'nim': 'A18.1234567',
        'nama': 'Baby Bozz',
        'jurusan': 'Teknik Informatika',
        'email': 'babybosscoy@udin.ac.id',
        'telepon': '08852342344',
        'foto': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300&h=300&fit=crop',
      });
      return await docRef.get();
    }
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getOrCreateProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat profil: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final String nim = data['nim'] ?? 'A18.1234567';
        final String nama = data['nama'] ?? 'Baby Bozz';
        final String jurusan = data['jurusan'] ?? 'Teknik Informatika';
        final String email = data['email'] ?? 'babybosscoy@udin.ac.id';
        final String telepon = data['telepon'] ?? '08852342344';
        final String foto = data['foto'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Student Profile Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 140,
                  height: 160,
                  child: foto.isNotEmpty
                      ? Image.network(
                          foto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // NIM
              Text(
                nim,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Nama
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Jurusan
              Text(
                jurusan,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Telepon
              Text(
                telepon,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

// DASHBOARD TAB CONTENT (Wraps the DashboardScreen structure inside the card)
class _DashboardTabContent extends StatelessWidget {
  const _DashboardTabContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: const DashboardScreen(),
    );
  }
}

// SETTINGS TAB CONTENT (Wraps the SettingsScreen structure inside the card)
class _SettingsTabContent extends StatelessWidget {
  const _SettingsTabContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: const SettingsScreen(),
    );
  }
}
