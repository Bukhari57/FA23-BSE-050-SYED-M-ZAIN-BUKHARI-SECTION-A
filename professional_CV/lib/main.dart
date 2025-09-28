import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = "Syed Muhammad Zain Bukhari";
  final String email = "shahsyed1120@gmail.com";
  final String phone = "+923220190466";
  final String tagline = "Full-Stack Developer & AI Enthusiast";

  // Multiple profile images
  final List<String> profileImages = [
    "assets/images/zain.jpg",
    "assets/images/zain2.jpg",
    "assets/images/zain3.jpg",
  ];
  int currentImageIndex = 0;

  // ✅ Social Links
  final String github = "https://github.com/Bukhari57";
  final String linkedin =
      "https://www.linkedin.com/in/syed-zain-bukhari-7b9b922b1";
  final String instagram =
      "https://www.instagram.com/reels_by_zainy?igsh=MnN2Z256Ymw3cHVr";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text("MY 1ST PROFILE APP"),
        backgroundColor: Colors.cyan,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          setState(() {
            currentImageIndex =
                (currentImageIndex + 1) % profileImages.length;
          });
        },
        child: Icon(Icons.account_circle),
      ),
      body: Column(
        children: [
          // Content with scroll
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                      AssetImage(profileImages[currentImageIndex]),
                    ),
                    SizedBox(height: 12),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      tagline,
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),

                    // Contact Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildContactCard(Icons.email, "Email", email),
                        _buildContactCard(Icons.phone, "Phone", phone),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Skills Section
                    _buildSkillItem(
                        Icons.android, "Flutter Development"),
                    _buildSkillItem(Icons.web, "Web Development"),
                    _buildSkillItem(
                        Icons.storage, "Database Management"),
                    _buildSkillItem(
                        Icons.design_services, "UI/UX Design"),
                    _buildSkillItem(Icons.psychology, "AI Development"),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Social Media Buttons at Bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(FontAwesomeIcons.github, github),
                _socialButton(FontAwesomeIcons.linkedin, linkedin),
                _socialButton(FontAwesomeIcons.instagram, instagram),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Contact Card
  Widget _buildContactCard(IconData icon, String title, String value) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 30),
          SizedBox(height: 6),
          Text(title,
              style:
              TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  // Reusable Skill Item
  Widget _buildSkillItem(IconData icon, String skill) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(skill, style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Social Media Buttons with FontAwesome
  Widget _socialButton(IconData icon, String url) {
    return IconButton(
      icon: FaIcon(icon, size: 30, color: Colors.black87),
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri,
              mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
