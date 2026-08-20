import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeachersScreen extends StatefulWidget {
  final String branchId;
  const TeachersScreen({super.key, required this.branchId});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  bool _isLoading = true;
  List<dynamic> _teachersList = [];

  final String apiURL =
      "https://amarpratisthan.com/AppAPI/Dashboard/get_teachers_list";

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      var response = await http.post(
        Uri.parse(apiURL),
        body: {'branch_id': widget.branchId},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _teachersList = data['data'];
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
  String _getTeacherImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return url.replaceAll('http://', 'https://');
    }
    return "https://amarpratisthan.com/uploads/images/defualt.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15803d),
        elevation: 0,
        title: const Text("Teachers List",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF15803d)))
          : _teachersList.isEmpty
              ? const Center(
                  child: Text("No teachers found",
                      style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _teachersList.length,
                  itemBuilder: (context, index) {
                    var teacher = _teachersList[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Teacher Photo
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF15803d).withOpacity(0.2),
                                  shape: BoxShape.circle),
                              child: ClipOval(
                                child: Image.network(
                                  _getTeacherImage(teacher['photo']),
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                          width: 65,
                                          height: 65,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.person,
                                              color: Color(0xFF15803d))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Teacher Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(teacher['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                                  Text(
                                      "${teacher['designation']} - ${teacher['department']}",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF15803d),
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text("Staff ID: ${teacher['staff_id']}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),

                                  // Show Phone if not hidden
                                  if (teacher['phone'] != 'Hidden')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(children: [
                                        const Icon(Icons.phone,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 5),
                                        Text(teacher['phone'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ]),
                                    ),

                                  // Show Email if not hidden
                                  if (teacher['email'] != 'Hidden')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(children: [
                                        const Icon(Icons.email,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 5),
                                        Text(teacher['email'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ]),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
