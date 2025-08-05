import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:siapbos/api/userMemoApi.dart';
import 'package:siapbos/provider/authProvider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> assignedMemos = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedMemos();
  }

  Future<void> _loadAssignedMemos() async {
    final auth = Provider.of<AuthState>(context, listen: false);
    try {
      assignedMemos = await UserMemoApi.getAssignedMemos(auth.userId ?? 0);
      setState(() {});
    } catch (e) {
      print('Error loading memos: $e');
    }
  }

  Future<void> _acceptMemo(int memoId) async {
    final auth = Provider.of<AuthState>(context, listen: false);
    try {
      await UserMemoApi.acceptMemo(memoId, auth.userId ?? 0);
      _loadAssignedMemos(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept memo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Memos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await Provider.of<AuthState>(context, listen: false).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: assignedMemos.isEmpty
          ? const Center(child: Text('No assigned memos'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: assignedMemos.length,
              itemBuilder: (context, index) {
                final memo = assignedMemos[index];
                final accepted = memo['accepted'] == 1;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: accepted ? Colors.white : Colors.blue.shade50,
                  elevation: accepted ? 3 : 5,
                  shadowColor: accepted ? Colors.black26 : Colors.blue,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!accepted)
                          Row(
                            children: const [
                              Icon(Icons.notifications_active, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'New Memo Assigned',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        if (!accepted) const SizedBox(height: 10),

                        Text(
                          memo['nama_aktiviti'] ?? 'No title',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('📅 ${memo['tarikh']} 🕒 ${memo['masa']}'),
                        if (memo['lokasi'] != null && memo['lokasi'].toString().isNotEmpty)
                          Text('📍 ${memo['lokasi']}'),
                        if (memo['keterangan'] != null && memo['keterangan'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(memo['keterangan']),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            accepted
                                ? Chip(
                                    label: const Text("Accepted"),
                                    backgroundColor: Colors.green.shade100,
                                    labelStyle: const TextStyle(color: Colors.green),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => _acceptMemo(memo['id']),
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    label: const Text("Accept", style: TextStyle(color: Colors.white)),
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
