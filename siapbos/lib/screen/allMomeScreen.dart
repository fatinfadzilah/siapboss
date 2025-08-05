import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:siapbos/api/memoAPI.dart';
import 'package:siapbos/screen/createMemoScreen.dart';
import 'package:siapbos/widget/memoCardWidget.dart';
import 'package:siapbos/widget/pdfWidget.dart';

class AllMemosScreen extends StatefulWidget {
  final int projectId;
  final String userRole; 

  const AllMemosScreen({
    super.key,
    required this.projectId,
    required this.userRole,
  });

  @override
  State<AllMemosScreen> createState() => _AllMemosScreenState();
}

class _AllMemosScreenState extends State<AllMemosScreen> {
  late int selectedProjectId;
  List<Map<String, dynamic>> projectList = [];
  Future<List<Map<String, dynamic>>>? memosFuture;

  bool get isManager => widget.userRole.toLowerCase() == 'manager';

  @override
  void initState() {
    super.initState();
    selectedProjectId = widget.projectId;
    _loadProjectsAndMemos();
  }

  Future<void> _loadProjectsAndMemos() async {
    try {
      final projects = await MemoApi.getProjects();
      setState(() {
        projectList = projects;
        memosFuture = MemoApi.getMemos(selectedProjectId);
      });
    } catch (e) {
      print('Failed to load projects: $e');
    }
  }

  void _onProjectSelected(int newProjectId) {
    setState(() {
      selectedProjectId = newProjectId;
      memosFuture = MemoApi.getMemos(selectedProjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: const Text('All Memos'),
        actions: [
          if (!isManager)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              onPressed: () async {
                if (memosFuture != null) {
                  final snapshot = await memosFuture!;
                  if (snapshot.isNotEmpty) {
                    final project = projectList.firstWhere((p) => p['id'] == selectedProjectId);
                    await generatePdf(context, project['name'], snapshot);
                  }
                }
              },
            )
        ],
      ),
      body: Stack(
        children: [
           Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 3,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: DropdownButtonFormField<int>(
                  value: selectedProjectId,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                  decoration: InputDecoration(
                    labelText: 'Select Project',
                    labelStyle: const TextStyle(color: Colors.blueGrey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueGrey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueGrey.shade200, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  dropdownColor: Colors.white,
                  items: projectList.map((project) {
                    return DropdownMenuItem<int>(
                      value: project['id'],
                      child: Text(
                        project['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) _onProjectSelected(value);
                  },
                ),
              ),
              Expanded(
                child: memosFuture == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Map<String, dynamic>>>(
                        future: memosFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No memos found'));
                          }
          
                          final memos = snapshot.data!;
                          return ListView.builder(
                            itemCount: memos.length,
                            padding: const EdgeInsets.only(bottom: 10,left: 16,right: 16),
                            itemBuilder: (context, index) {
                              final memo = memos[index];
          
                              if (isManager) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(memo['title'] ?? 'Memo'),
                                        content: Text(memo['description'] ?? 'No description'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Close'),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: MemoCardWidget(memo: memo),
                                );
                              }
          
                              // 👇 Admin can delete/edit
                              return Slidable(
                                key: ValueKey(memo['id']),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Memo'),
                                            content: const Text('Are you sure you want to delete this memo?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
          
                                        if (confirmed == true) {
                                          await MemoApi.deleteMemo(memo['id']);
                                          setState(() {
                                            memos.removeAt(index);
                                          });
                                        }
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => createMemoScreen(
                                          projectName: memo['project_name'] ?? '',
                                          isEdit: true,
                                          existingMemo: memo,
                                        ),
                                      ),
                                    );
          
                                    if (updated == true) {
                                      setState(() {
                                        memosFuture = MemoApi.getMemos(selectedProjectId);
                                      });
                                    }
                                  },
                                  child: MemoCardWidget(memo: memo),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
