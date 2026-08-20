import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaveScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const LeaveScreen({super.key, required this.userData});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<dynamic> _leaveList = [];
  List<dynamic> _categories = [];

  // Form Variables
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();

  final String fetchUrl = "https://amarpratisthan.com/AppAPI/Leave/get_leaves";
  final String submitUrl =
      "https://amarpratisthan.com/AppAPI/Leave/submit_request";

  @override
  void initState() {
    super.initState();
    _fetchLeaveData();
  }

  Future<void> _fetchLeaveData() async {
    setState(() => _isLoading = true);
    try {
      var response = await http.post(
        Uri.parse(fetchUrl),
        body: {
          'user_id': widget.userData['user_id'].toString(),
          'branch_id': widget.userData['branch_id'].toString()
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _leaveList = data['data']['leave_list'] ?? [];
            _categories = data['data']['categories'] ?? [];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitLeave() async {
    if (_selectedCategory == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select Category and Dates!'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    // Custom Date Formatting (YYYY-MM-DD) Without intl package
    String startStr =
        "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}";
    String endStr =
        "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}";

    try {
      var response = await http.post(
        Uri.parse(submitUrl),
        body: {
          'user_id': widget.userData['user_id'].toString(),
          'branch_id': widget.userData['branch_id'].toString(),
          'category_id': _selectedCategory,
          'start_date': startStr,
          'end_date': endStr,
          'reason': _reasonController.text,
        },
      );

      var data = jsonDecode(response.body);
      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']), backgroundColor: Colors.green));

        // Form Clear Kora
        setState(() {
          _selectedCategory = null;
          _startDate = null;
          _endDate = null;
          _reasonController.clear();
        });

        // Data refresh kora
        _fetchLeaveData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error Submitting Request'),
          backgroundColor: Colors.red));
    }
    setState(() => _isSubmitting = false);
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF15803d), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  String _formatSimpleDate(String dateStr) {
    try {
      List<String> parts = dateStr.split(' ');
      return parts[0]; // Returns only YYYY-MM-DD
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15803d),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Leave Application",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list), text: "Leave List"),
              Tab(icon: Icon(Icons.add_circle_outline), text: "Apply Leave"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF15803d)))
            : TabBarView(
                children: [
                  _buildLeaveListTab(),
                  _buildApplyLeaveTab(),
                ],
              ),
      ),
    );
  }

  // --- TAB 1: LEAVE LIST ---
  Widget _buildLeaveListTab() {
    if (_leaveList.isEmpty) {
      return const Center(
          child: Text("No Leave History Found",
              style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaveList.length,
      itemBuilder: (context, index) {
        var leave = _leaveList[index];

        // Status Badge Logic
        String statusText = "Pending";
        Color statusColor = Colors.orange;
        if (leave['status'].toString() == '2') {
          statusText = "Accepted";
          statusColor = Colors.green;
        } else if (leave['status'].toString() == '3') {
          statusText = "Rejected";
          statusColor = Colors.red;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leave['category_name'] ?? 'Unknown Type',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF15803d))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                ),
                const Divider(),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Start: ${_formatSimpleDate(leave['start_date'])}")
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.event, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("End: ${_formatSimpleDate(leave['end_date'])}")
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Days: ${leave['leave_days']}")
                ]),
                const SizedBox(height: 5),
                if (leave['reason'] != null &&
                    leave['reason'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text("Reason: ${leave['reason']}",
                        style: const TextStyle(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic)),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 2: APPLY FOR LEAVE ---
  Widget _buildApplyLeaveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Leave Type *",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text("Select category"),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text("${cat['name']} (${cat['days']} days)"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Leave Dates *",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateRange,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: Color(0xFF15803d)),
                      const SizedBox(width: 10),
                      Text(
                        _startDate == null
                            ? "Select Date Range"
                            : "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}  to  ${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}",
                        style: TextStyle(
                            color: _startDate == null
                                ? Colors.grey
                                : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Reason (Optional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your reason here...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803d),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSubmitting ? null : _submitLeave,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SUBMIT REQUEST",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
