import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siapbos/provider/authProvider.dart';
import 'package:go_router/go_router.dart'; // For navigation after logout


class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'New Memo Assigned',
      'message': 'You have a new task in SHTJ V3',
      'accepted': false,
    },
    {
      'id': 2,
      'title': 'Urgent Meeting',
      'message': 'Meeting with ICT team at 3 PM.',
      'accepted': false,
    },
  ];

  void _acceptNotification(int id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) notifications[index]['accepted'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
    appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await Provider.of<AuthState>(context, listen: false).logout();
                  if (context.mounted) context.go('/login'); // GoRouter redirect
                }
              },
            ),
          ],
        ),
       body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(notification['message']),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            notification['accepted']
                                ? Chip(
                                    label: Text("Accepted",style: TextStyle(color: Colors.black),),
                                    backgroundColor: Colors.green.shade100,
                                    labelStyle: TextStyle(color: Colors.green),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => _acceptNotification(notification['id']),
                                    icon: const Icon(Icons.check,color: Colors.white),
                                    label: const Text("Accept",style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
