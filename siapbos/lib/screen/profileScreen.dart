import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siapbos/api/userAuthApi.dart';
import 'package:siapbos/provider/authProvider.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserAuthApi.getProfile(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));

          if (!snapshot.hasData)
            return Center(child: Text("No profile data found"));

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    profile['profile_picture'] ??
                        'https://ui-avatars.com/api/?name=${profile['name']}&background=0D8ABC&color=fff',
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  profile['name'] ?? '',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(profile['email'] ?? '',
                    style: TextStyle(color: Colors.blueGrey)),
                SizedBox(height: 30),

                // Info Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 25.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.business, "Department",
                              profile['department'] ?? '-'),
                          Divider(),
                          _buildInfoRow(Icons.work, "Designation",
                              profile['designation'] ?? '-'),
                          Divider(),
                          _buildInfoRow(Icons.verified_user, "Role",
                              profile['role'].toString().toUpperCase()),
                          Divider(),
                          _buildInfoRow(Icons.event, "Joined",
                              profile['created_at']?.toString().substring(0, 10) ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 16, 55, 123),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Logout'),
                            content: Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Logout')),
                            ],
                          ),
                        );
                                    
                        if (confirm == true) {
                          await auth.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: Icon(Icons.logout,color: Colors.white,),
                      label: Text('Logout',style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
