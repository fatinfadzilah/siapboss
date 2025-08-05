import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pdf/pdf.dart';
import 'package:siapbos/api/memoAPI.dart';
import 'package:siapbos/screen/createMemoScreen.dart';
import 'package:siapbos/widget/memoCardWidget.dart';
import 'package:siapbos/widget/pdfWidget.dart';

class AllMemosScreen extends StatefulWidget {
  final int projectId;
  const AllMemosScreen({super.key, required this.projectId});

  @override
  State<AllMemosScreen> createState() => _AllMemosScreenState();
}

class _AllMemosScreenState extends State<AllMemosScreen> {
  late int selectedProjectId;
  List<Map<String, dynamic>> projectList = [];
  Future<List<Map<String, dynamic>>>? memosFuture;

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
      appBar: AppBar(
      title: Text('All Memos'),
      actions: [
        IconButton(
          icon: Icon(Icons.picture_as_pdf),
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
      body: Column(
        children: [
        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: DropdownButtonFormField<int>(
                value: selectedProjectId,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                decoration: InputDecoration(
                  labelText: 'Select Project',
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueGrey),
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
                style: TextStyle(color: Colors.black87, fontSize: 15),
                dropdownColor: Colors.white,
                items: projectList.map((project) {
                  return DropdownMenuItem<int>(
                    value: project['id'],
                    child: Text(
                      project['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
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
                  ? Center(child: CircularProgressIndicator()) 
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: memosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No memos found'));
                        }
                          final memos = snapshot.data!;
                          return ListView.builder(
                            itemCount: memos.length,
                            padding: EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final memo = memos[index];
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
                                            title: Text('Delete Memo'),
                                            content: Text('Are you sure you want to delete this memo?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text('Delete'),
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
                                        // Refresh the memos
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
    );
  }
}
