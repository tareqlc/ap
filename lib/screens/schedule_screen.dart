import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ScheduleScreen({super.key, required this.userData});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = true;
  List<dynamic> _schedule = [];
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final String apiURL =
      "https://amarpratisthan.com/AppAPI/Academic/get_class_schedule";

  int _currentDayIndex = 0; // Ajker diner index rakhar jonno variable

  @override
  void initState() {
    super.initState();
    _calculateToday(); // Screen load hobar sathe sathe ajker din calculate korbe
    _fetchSchedule();
  }

  // 🔥 Ajker din ber korar function 🔥
  void _calculateToday() {
    int weekday = DateTime.now().weekday; // Dart e: 1=Mon, 2=Tue... 7=Sun
    // Amader list e: 0=Sun, 1=Mon, 2=Tue... tai ektu logic lagate hobe
    setState(() {
      _currentDayIndex = (weekday == 7) ? 0 : weekday;
    });
  }

  Future<void> _fetchSchedule() async {
    try {
      var response = await http.post(
        Uri.parse(apiURL),
        body: {'user_id': widget.userData['user_id'].toString()},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _schedule = data['data'];
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

  // Time Formatter
  String _formatTime(String time) {
    try {
      List<String> parts = time.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        String period = hour >= 12 ? "PM" : "AM";

        if (hour == 0)
          hour = 12;
        else if (hour > 12) hour -= 12;

        String minuteStr = minute.toString().padLeft(2, '0');
        return "$hour:$minuteStr $period";
      }
    } catch (e) {
      return time;
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      initialIndex:
          _currentDayIndex, // 🔥 Default vabe ajker din select thakbe 🔥
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15803d),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Class Schedule",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor:
                Colors.orangeAccent, // Active tab er nicher line orange hobe
            indicatorWeight: 4,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            tabs: List.generate(days.length, (index) {
              bool isToday = (index == _currentDayIndex);

              // 🔥 Ajker din k highlight korar jonno custom Tab design 🔥
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isToday ? Colors.orangeAccent : Colors.white,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("Today",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
              );
            }),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF15803d)))
            : TabBarView(
                children: days.map((day) {
                  var daySchedule = _schedule
                      .where((item) =>
                          item['day'].toString().toLowerCase() ==
                          day.toLowerCase())
                      .toList();

                  if (daySchedule.isEmpty)
                    return const Center(
                        child: Text("No Class Scheduled",
                            style: TextStyle(color: Colors.grey)));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daySchedule.length,
                    itemBuilder: (context, index) {
                      var cls = daySchedule[index];
                      bool isBreak = cls['break'].toString() == '1';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: isBreak
                                          ? Colors.orange
                                          : const Color(0xFF15803d),
                                      width: 5)),
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                                isBreak
                                    ? "BREAK"
                                    : (cls['subject_name'] ??
                                        'Unknown Subject'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isBreak
                                        ? Colors.orange
                                        : Colors.black87)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Row(children: [
                                  const Icon(Icons.access_time,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                      "${_formatTime(cls['time_start'])} - ${_formatTime(cls['time_end'])}")
                                ]),
                                if (!isBreak) ...[
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    const Icon(Icons.person,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                        "Teacher: ${cls['teacher_name'] ?? 'N/A'}")
                                  ]),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    const Icon(Icons.meeting_room,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text("Room: ${cls['class_room'] ?? 'N/A'}")
                                  ]),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
