import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'student_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('siswa').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final int totalStudents = docs.length;

          double totalGrades = 0;
          double maxGrade = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              final gradeVal = data['nilai'];
              double grade = 0;
              if (gradeVal is num) {
                grade = gradeVal.toDouble();
              } else if (gradeVal is String) {
                grade = double.tryParse(gradeVal) ?? 0;
              }
              totalGrades += grade;
              if (grade > maxGrade) {
                maxGrade = grade;
              }
            }
          }

          final double averageGrade = totalStudents > 0 ? totalGrades / totalStudents : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Ringkasan Data Akademik',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context,
                  title: 'Total Siswa',
                  value: '$totalStudents',
                  icon: Icons.people,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context,
                  title: 'Rata-Rata Nilai',
                  value: averageGrade.toStringAsFixed(1),
                  icon: Icons.analytics,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context,
                  title: 'Nilai Tertinggi',
                  value: maxGrade.toStringAsFixed(0),
                  icon: Icons.star,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'Kelola Data Siswa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          );
        },
      );
  }


  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: .2),
              radius: 28,
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
