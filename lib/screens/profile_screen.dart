import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Login theke pawa basic info

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};

  final String profileApiUrl =
      "https://amarpratisthan.com/AppAPI/Profile/get_profile_data";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      var response = await http.post(
        Uri.parse(profileApiUrl),
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
            _profileData = Map<String, dynamic>.from(data['data']);
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

  String getProfileImageUrl() {
    if (_profileData.containsKey('profile') &&
        _profileData['profile'] != null &&
        _profileData['profile']['profile_picture'] != null) {
      String url = _profileData['profile']['profile_picture'].toString();
      if (url.isNotEmpty) {
        return "https://api.allorigins.win/raw?url=${Uri.encodeComponent(url.replaceAll('http://', 'https://'))}";
      }
    }
    return "https://api.allorigins.win/raw?url=${Uri.encodeComponent('https://amarpratisthan.com/uploads/images/defualt.png')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF15803d)));
    }

    if (_profileData.isEmpty || !_profileData.containsKey('profile')) {
      return const Center(child: Text("Profile data not available"));
    }

    Map<String, dynamic> profile = _profileData['profile'];
    Map<String, dynamic>? parent = _profileData['parent_info'];
    List<dynamic> books = _profileData['book_list'] ?? [];
    List<dynamic> documents = _profileData['documents'] ?? [];
    List<dynamic> promotions = _profileData['promotion_history'] ?? [];
    List<dynamic> fees = _profileData['fees_history'] ?? [];

    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(color: Color(0xFF15803d)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.network(
                      getProfileImageUrl(),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.person,
                              color: Color(0xFF15803d), size: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(profile['full_name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("${profile['class_section']} | Roll: ${profile['roll']}",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // Tabs
          Container(
            color: const Color(0xFF15803d),
            child: const TabBar(
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(icon: Icon(Icons.person), text: "Details"),
                Tab(icon: Icon(Icons.trending_up), text: "Promotion"),
                Tab(icon: Icon(Icons.payment), text: "Fees"),
                Tab(icon: Icon(Icons.family_restroom), text: "Parents"),
                Tab(icon: Icon(Icons.library_books), text: "Books"),
                Tab(icon: Icon(Icons.folder), text: "Docs"),
              ],
            ),
          ),

          // Tab Contents
          Expanded(
            child: TabBarView(
              children: [
                _buildDetailsTab(profile),
                _buildPromotionTab(promotions),
                _buildFeesTab(fees),
                _buildParentTab(parent),
                _buildBooksTab(books),
                _buildDocsTab(documents),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Profile Details ---
  Widget _buildDetailsTab(Map<String, dynamic> profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text("Academic Details",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803d),
                fontSize: 16)),
        const SizedBox(height: 10),
        _buildInfoCard([
          {"title": "Register No", "val": profile['register_no']},
          {"title": "Admission Date", "val": profile['admission_date']},
          {"title": "Category", "val": profile['category']},
        ]),
        const SizedBox(height: 20),
        const Text("Personal Details",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803d),
                fontSize: 16)),
        const SizedBox(height: 10),
        _buildInfoCard([
          {"title": "Gender", "val": profile['gender']},
          {"title": "Blood Group", "val": profile['blood_group']},
          {"title": "Religion", "val": profile['religion']},
          {"title": "Birthday", "val": profile['birthday']},
          {"title": "Mother Tongue", "val": profile['mother_tongue']},
          {"title": "Caste", "val": profile['caste']},
        ]),
        const SizedBox(height: 20),
        const Text("Contact Details",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803d),
                fontSize: 16)),
        const SizedBox(height: 10),
        _buildInfoCard([
          {"title": "Mobile No", "val": profile['mobile_no']},
          {"title": "Email", "val": profile['email']},
          {"title": "City", "val": profile['city']},
          {"title": "State", "val": profile['state']},
          {"title": "Present Addr.", "val": profile['present_address']},
          {"title": "Permanent Addr.", "val": profile['permanent_address']},
        ]),
      ],
    );
  }

  // --- TAB 2: Promotion ---
  Widget _buildPromotionTab(List<dynamic> promotions) {
    if (promotions.isEmpty)
      return const Center(child: Text("No Promotion History"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        var promo = promotions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Session: ${promo['pre_session_year']} ➔ ${promo['pro_session_year']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803d))),
                    const Icon(Icons.trending_up, color: Colors.green),
                  ],
                ),
                const Divider(),
                Text(
                    "From: ${promo['pre_class_name']} (${promo['pre_section_name']})"),
                Text(
                    "To: ${promo['pro_class_name']} (${promo['pro_section_name']})"),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 3: Fees ---
  Widget _buildFeesTab(List<dynamic> fees) {
    if (fees.isEmpty) return const Center(child: Text("No Fee Records"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fees.length,
      itemBuilder: (context, index) {
        var fee = fees[index];
        bool isPaid = double.tryParse(fee['balance'].toString()) == 0;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPaid
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(isPaid ? Icons.check_circle : Icons.warning,
                  color: isPaid ? Colors.green : Colors.red),
            ),
            title: Text(fee['name'] ?? 'Fee',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Due: ${fee['due_date']}\nPaid: ৳${fee['paid']} | Bal: ৳${fee['balance']}"),
            trailing: Text("৳${fee['amount']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }

  // --- TAB 4: Parents ---
  Widget _buildParentTab(Map<String, dynamic>? parent) {
    if (parent == null)
      return const Center(child: Text("No Parent Info Found"));

    // Proxy removed - Using direct secure URL
    String pImg = parent['parent_photo'] ?? '';
    if (pImg.isNotEmpty) {
      pImg = pImg.replaceAll('http://', 'https://');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(pImg),
            onBackgroundImageError: (e, s) => const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoCard([
          {"title": "Guardian Name", "val": parent['name']},
          {"title": "Relation", "val": parent['relation']},
          {"title": "Father's Name", "val": parent['father_name']},
          {"title": "Mother's Name", "val": parent['mother_name']},
          {"title": "Occupation", "val": parent['occupation']},
          {
            "title": "Income",
            "val": parent['income'] != null &&
                    parent['income'].toString().isNotEmpty
                ? "৳${parent['income']}"
                : "N/A"
          },
          {"title": "Mobile No", "val": parent['mobileno']},
          {"title": "Email", "val": parent['email']},
        ]),
      ],
    );
  }

  // --- TAB 5: Books ---
  Widget _buildBooksTab(List<dynamic> books) {
    if (books.isEmpty) return const Center(child: Text("No Books Issued"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        var book = books[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.brown),
            title: Text(book['book_title'] ?? 'Unknown Book',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Issued: ${book['date_of_issue']} \nExpiry: ${book['date_of_expiry']}"),
          ),
        );
      },
    );
  }

  // --- TAB 6: Docs ---
  Widget _buildDocsTab(List<dynamic> docs) {
    if (docs.isEmpty) return const Center(child: Text("No Documents Found"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.folder, color: Colors.blue),
            title: Text(doc['title'] ?? 'Document',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(doc['remarks'] ?? 'No remarks'),
            trailing: IconButton(
                icon: const Icon(Icons.download, color: Color(0xFF15803d)),
                onPressed: () {}),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(List<Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(item['title'],
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13))),
                  Expanded(
                      flex: 3,
                      child: Text(item['val']?.toString() ?? 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14))),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
