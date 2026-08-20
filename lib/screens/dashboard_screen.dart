import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';
import 'profile_screen.dart';
import 'teachers_screen.dart';
import 'subjects_screen.dart';
import 'schedule_screen.dart';
import 'leave_screen.dart';
import 'homework_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  int _bottomNavIndex = 0;
  bool _showBalance = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String dashboardApiUrl =
      "https://amarpratisthan.com/AppAPI/Dashboard/get_dashboard_data";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      var response = await http.post(
        Uri.parse(dashboardApiUrl),
        body: {
          'user_type': widget.userData['user_type'].toString(),
          'branch_id': widget.userData['branch_id'].toString(),
          'user_id': widget.userData['user_id'].toString()
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _dashboardData = Map<String, dynamic>.from(data['data']);
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

// Proxy removed - Using direct secure URL
  String getProfileImageUrl() {
    if (_dashboardData.containsKey('profile') &&
        _dashboardData['profile'] != null &&
        _dashboardData['profile']['profile_picture'] != null) {
      String url = _dashboardData['profile']['profile_picture'].toString();
      if (url.isNotEmpty) {
        return url.replaceAll('http://', 'https://');
      }
    }
    return "https://amarpratisthan.com/uploads/images/defualt.png";
  }

  Widget _buildProfileImage(double radius) {
    return ClipOval(
      child: Image.network(
        getProfileImageUrl(),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: Colors.white,
            child: Icon(Icons.person,
                color: const Color(0xFF15803d), size: radius * 1.2),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const Center(
          child: CircularProgressIndicator(color: Color(0xFF15803d)));
    } else if (_bottomNavIndex == 2) {
      // ✅ COMPILE ERROR FIXED EKHANE:
      // Profile ekhon nijei data anbe, tai shudhu userData pass kora holo
      bodyContent = ProfileScreen(userData: widget.userData);
    } else {
      bodyContent = _buildHomeTab();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F4F6),
      endDrawer: _buildSidebarDrawer(),
      bottomNavigationBar: _buildBottomNav(),
      body: bodyContent,
    );
  }

  Widget _buildSidebarDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20),
            width: double.infinity,
            color: const Color(0xFF15803d),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: _buildProfileImage(30),
                ),
                const SizedBox(height: 10),
                Text(widget.userData['name'] ?? 'Student',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Text("Student Panel",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 🔥 Academic Dropdown Menu 🔥
                ExpansionTile(
                  leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.school,
                          color: Colors.orange, size: 20)),
                  title: const Text("Academic",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  childrenPadding:
                      const EdgeInsets.only(left: 30), // Ektu dan dike sorano
                  children: [
                    _buildDrawerItem(Icons.menu_book, "Subject", Colors.grey,
                        () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SubjectsScreen(userData: widget.userData)));
                    }),
                    _buildDrawerItem(
                        Icons.schedule, "Class Schedule", Colors.grey, () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ScheduleScreen(userData: widget.userData)));
                    }),
                  ],
                ),

                // 🔥 Teachers Menu 🔥
                _buildDrawerItem(Icons.groups, "Teachers", Colors.blue, () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeachersScreen(
                        branchId: widget.userData['branch_id'].toString(),
                      ),
                    ),
                  );
                }),

                _buildDrawerItem(Icons.video_camera_front, "Live Class Rooms",
                    Colors.red, null),
                // 🔥 Leave Application Menu 🔥
                _buildDrawerItem(
                    Icons.assignment_return, "Leave Application", Colors.teal,
                    () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LeaveScreen(userData: widget.userData),
                    ),
                  );
                }),
                // 🔥 Homework Menu 🔥
                _buildDrawerItem(Icons.menu_book, "Homework", Colors.brown, () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeworkScreen(userData: widget.userData),
                    ),
                  );
                }),
                _buildDrawerItem(
                    Icons.quiz, "Exam Master", Colors.purple, null),
                _buildDrawerItem(
                    Icons.fact_check, "Attendance", Colors.green, null),
                _buildDrawerItem(
                    Icons.local_library, "Library", Colors.cyan, null),
                _buildDrawerItem(
                    Icons.payments, "Fees History", Colors.pink, null),
              ],
            ),
          ),
          const Divider(),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()))),
        ],
      ),
    );
  }

  // 🔥 onTap function support korar jonno eti update kora holo
  Widget _buildDrawerItem(
      IconData icon, String title, Color color, VoidCallback? onTap) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _bottomNavIndex,
      selectedItemColor: const Color(0xFF15803d),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 3) {
          _scaffoldKey.currentState!.openEndDrawer();
        } else {
          setState(() => _bottomNavIndex = index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Notice"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded), label: "Menu"),
      ],
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF15803d),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(2),
                      child: _buildProfileImage(25),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome, ${widget.userData['name'] ?? 'User'}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            setState(() => _showBalance = !_showBalance);
                            Future.delayed(const Duration(seconds: 3), () {
                              if (mounted) setState(() => _showBalance = false);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet,
                                    size: 14, color: Color(0xFF15803d)),
                                const SizedBox(width: 5),
                                Text(
                                    _showBalance
                                        ? "৳ ${_dashboardData['total_due'] ?? '0.00'}"
                                        : "Total Due",
                                    style: const TextStyle(
                                        color: Color(0xFF15803d),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.notifications_active,
                        color: Colors.white),
                    onPressed: () {}),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quick Status",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _buildGlassyCard(
                        "Book Issued",
                        "${_dashboardData['book_issued'] ?? '0'}",
                        Icons.menu_book,
                        Colors.brown),
                    _buildGlassyCard(
                        "Notices",
                        "${_dashboardData['notices'] ?? '0'}",
                        Icons.campaign,
                        Colors.blue),
                    _buildGlassyCard(
                        "Payments",
                        "৳${_dashboardData['monthly_payment'] ?? '0.00'}",
                        Icons.payments,
                        Colors.green),
                    _buildGlassyCard(
                        "Events",
                        "${_dashboardData['events_count'] ?? '0'}",
                        Icons.event,
                        Colors.orange),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("Annual Attendance",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 10),
                _buildDynamicAttendanceGraph(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassyCard(
      String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(val,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDynamicAttendanceGraph() {
    List<dynamic> rawData = _dashboardData['attendance_present'] ??
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
          ]),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(12, (index) {
            double presentDays = 0;
            if (index < rawData.length) {
              presentDays = (rawData[index] as num).toDouble();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildBar(months[index], presentDays),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double presentDays) {
    double percentage = (presentDays / 31) * 100;
    if (percentage > 100) percentage = 100;

    return Column(
      children: [
        Text("${presentDays.toInt()}",
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF15803d),
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
                height: 100,
                width: 16,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8))),
            AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: (percentage / 100) * 100,
                width: 16,
                decoration: BoxDecoration(
                    color: const Color(0xFF15803d),
                    borderRadius: BorderRadius.circular(8))),
          ],
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
