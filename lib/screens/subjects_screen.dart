import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubjectsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SubjectsScreen({super.key, required this.userData});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  bool _isLoading = true;
  List<dynamic> _subjects = [];
  final String apiURL =
      "https://amarpratisthan.com/AppAPI/Academic/get_subjects";

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      var response = await http.post(
        Uri.parse(apiURL),
        body: {'user_id': widget.userData['user_id'].toString()},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _subjects = data['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15803d),
        title: const Text("Subject List",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF15803d)))
          : _subjects.isEmpty
              ? const Center(
                  child: Text("No Subjects Assigned",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    var sub = _subjects[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(
                                        sub['subject_name'] ?? 'Unknown',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803d)))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(sub['subject_code'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text("Teacher: ${sub['teacher_name'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.black87))
                            ]),
                            const SizedBox(height: 5),
                            Row(children: [
                              const Icon(Icons.merge_type,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text("Type: ${sub['subject_type'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.black87))
                            ]),
                            const SizedBox(height: 5),
                            Row(children: [
                              const Icon(Icons.create,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text("Author: ${sub['subject_author'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.black87))
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
