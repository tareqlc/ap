import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Ebar File Picker ar URL Launcher add kora holo
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeworkScreen({super.key, required this.userData});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  bool _isLoading = true;
  List<dynamic> _homeworkList = [];

  final String fetchUrl =
      "https://amarpratisthan.com/AppAPI/Homework/get_homework";
  final String submitUrl =
      "https://amarpratisthan.com/AppAPI/Homework/submit_assignment";

  @override
  void initState() {
    super.initState();
    _fetchHomework();
  }

  Future<void> _fetchHomework() async {
    setState(() => _isLoading = true);
    try {
      var response = await http.post(
        Uri.parse(fetchUrl),
        body: {'user_id': widget.userData['user_id'].toString()},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _homeworkList = data['data'];
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

  // 🔥 REAL DOWNLOAD FUNCTION 🔥
  Future<void> _downloadFile(String url) async {
    try {
      // ignore: deprecated_member_use
      if (await canLaunch(url)) {
        // ignore: deprecated_member_use
        await launch(url);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Could not open download link"),
              backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error opening link"), backgroundColor: Colors.red));
    }
  }

  // --- SUBMIT ASSIGNMENT BOTTOM SHEET (WITH REAL FILE UPLOAD) ---
  void _openSubmitModal(Map<String, dynamic> homework) {
    TextEditingController messageController =
        TextEditingController(text: homework['submit_message'] ?? '');
    bool isSubmitting = false;
    PlatformFile? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Submit Assignment",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803d))),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),

                  // 🔥 REAL FILE PICKER SECTION 🔥
                  const Text("Attachment File :",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      try {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setModalState(() {
                            selectedFile = result.files.first;
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Error selecting file"),
                                backgroundColor: Colors.red));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file,
                              color: Color(0xFF15803d)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFile != null
                                  ? selectedFile!.name
                                  : (homework['submit_file'] != null &&
                                          homework['submit_file']
                                              .toString()
                                              .isNotEmpty
                                      ? "Existing File Uploaded"
                                      : "Select a file to upload"),
                              style: TextStyle(
                                  color: selectedFile != null
                                      ? Colors.black87
                                      : Colors.grey,
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text("Message / Answer :",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type your answer here...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803d),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (messageController.text.trim().isEmpty &&
                                  selectedFile == null &&
                                  (homework['submit_file'] == null ||
                                      homework['submit_file'].isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please provide a message or attach a file!"),
                                        backgroundColor: Colors.red));
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                // 🔥 MULTIPART REQUEST FOR REAL FILE UPLOAD 🔥
                                var request = http.MultipartRequest(
                                    'POST', Uri.parse(submitUrl));
                                request.fields['user_id'] =
                                    widget.userData['user_id'].toString();
                                request.fields['homework_id'] =
                                    homework['id'].toString();
                                request.fields['message'] =
                                    messageController.text;

                                if (selectedFile != null) {
                                  if (selectedFile!.bytes != null) {
                                    // Web/FlutLab er jonno
                                    request.files.add(
                                        http.MultipartFile.fromBytes(
                                            'attachment_file',
                                            selectedFile!.bytes!,
                                            filename: selectedFile!.name));
                                  } else if (selectedFile!.path != null) {
                                    // Android/iOS er jonno
                                    request.files.add(
                                        await http.MultipartFile.fromPath(
                                            'attachment_file',
                                            selectedFile!.path!));
                                  }
                                }

                                var streamedResponse = await request.send();
                                var response = await http.Response.fromStream(
                                    streamedResponse);
                                var data = jsonDecode(response.body);

                                if (data['status'] == true) {
                                  if (mounted) Navigator.pop(context);
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(data['message']),
                                            backgroundColor: Colors.green));
                                  _fetchHomework(); // Refresh List
                                } else {
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(data['message'] ??
                                                "Upload Failed"),
                                            backgroundColor: Colors.red));
                                }
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Error Submitting"),
                                          backgroundColor: Colors.red));
                              }
                              setModalState(() => isSubmitting = false);
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SUBMIT ASSIGNMENT",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15803d),
        elevation: 0,
        title: const Text("Homework List",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF15803d)))
          : _homeworkList.isEmpty
              ? const Center(
                  child: Text("No Homework Found",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _homeworkList.length,
                  itemBuilder: (context, index) {
                    var hw = _homeworkList[index];

                    String status = hw['final_status'] ?? 'Unknown';
                    Color statusColor = status == 'Complete'
                        ? Colors.green
                        : (status == 'Submitted' ? Colors.blue : Colors.red);

                    DateTime submissionDate =
                        DateTime.tryParse(hw['date_of_submission'] ?? '') ??
                            DateTime.now();
                    DateTime today = DateTime.now();
                    bool canSubmit = hw['ev_status'] != 'c' &&
                        submissionDate
                            .isAfter(today.subtract(const Duration(days: 1)));

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        collapsedIconColor: const Color(0xFF15803d),
                        iconColor: const Color(0xFF15803d),
                        leading: const Icon(Icons.sticky_note_2,
                            color: Colors.orange),
                        title: Text(
                            "${hw['subject_name']} - ${hw['date_of_homework']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text("Status: $status",
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Description :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF15803d))),
                                const SizedBox(height: 5),
                                Text(hw['description'] ?? 'N/A',
                                    style:
                                        const TextStyle(color: Colors.black87)),
                                const Divider(height: 20),

                                _buildInfoRow(Icons.calendar_today,
                                    "Homework Date:", hw['date_of_homework']),
                                _buildInfoRow(Icons.event, "Submission Date:",
                                    hw['date_of_submission']),
                                _buildInfoRow(
                                    Icons.fact_check,
                                    "Evaluation Date:",
                                    hw['evaluation_date'] ?? 'N/A'),
                                _buildInfoRow(Icons.star, "Rank (out of 5):",
                                    hw['rank'] ?? 'N/A'),
                                _buildInfoRow(Icons.comment, "Remarks:",
                                    hw['ev_remarks'] ?? 'N/A'),

                                const SizedBox(height: 15),

                                // 🔥 REAL DOWNLOAD ORIGINAL DOCUMENT BUTTON 🔥
                                if (hw['document'] != null &&
                                    hw['document'].toString().isNotEmpty)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.picture_as_pdf,
                                        color: Colors.red),
                                    title: const Text("Download Homework Doc",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                    trailing: IconButton(
                                        icon: const Icon(Icons.download,
                                            color: Color(0xFF15803d)),
                                        onPressed: () => _downloadFile(
                                            hw['homework_doc_url'])),
                                  ),

                                // 🔥 REAL DOWNLOAD SUBMITTED FILE BUTTON 🔥
                                if (hw['submit_file'] != null &&
                                    hw['submit_file'].toString().isNotEmpty)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    title: const Text("Your Submitted File",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                    trailing: IconButton(
                                        icon: const Icon(Icons.download,
                                            color: Color(0xFF15803d)),
                                        onPressed: () => _downloadFile(
                                            hw['submitted_doc_url'])),
                                  ),

                                if (canSubmit) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.upload_file,
                                          color: Color(0xFF15803d)),
                                      label: Text(
                                          status == 'Submitted'
                                              ? "Update Assignment"
                                              : "Submit Assignment",
                                          style: const TextStyle(
                                              color: Color(0xFF15803d),
                                              fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFF15803d))),
                                      onPressed: () => _openSubmitModal(hw),
                                    ),
                                  )
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 5),
          Text("$title ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
              child: Text(val,
                  style: const TextStyle(color: Colors.black87, fontSize: 13))),
        ],
      ),
    );
  }
}
