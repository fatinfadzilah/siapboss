import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:siapbos/api/memoAPI.dart';
import 'package:siapbos/provider/authProvider.dart';
import 'package:siapbos/screen/allMomeScreen.dart';
import 'package:siapbos/screen/createMemoScreen.dart';
import 'package:siapbos/utils/color_utils.dart';
import 'package:siapbos/widget/memoCardWidget.dart';

class Homepage extends StatefulWidget {
  final int projectId;
  const Homepage({super.key, required this.projectId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  String searchQuery = '';
  final List<Map<String, dynamic>> tasks = [];
  List<String> members = [];
  List<Map<String, dynamic>> projectList = [];
  late Future<List<Map<String, dynamic>>> memoList;
  Map<int, int> memoCountByProject = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_toggleFabVisibility);
    memoList = MemoApi.getMemos(widget.projectId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _refreshMemos() async {
    setState(() {
      memoList = MemoApi.getMemos(widget.projectId);
    });
  }

  void _toggleFabVisibility() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_toggleFabVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthState>(context);
    final displayName = auth.name ?? '';
    final isManager = auth.role == 'manager';

    return Scaffold(
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
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(15.0),
            children: [
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, $displayName 👋",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Welcome to MemoZapp",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 1.0),
                  itemCount: projectList.length,
                  itemBuilder: (context, index) {
                    final project = projectList[index];
                    return _buildCardContent(project, isManager);
                  },
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Latest Memo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMemosScreen(
                              projectId: widget.projectId,
                              userRole: auth.role ?? '', 
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 16, 55, 123),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              RefreshIndicator(
                onRefresh: () async {
                  await _refreshMemos();
                  await _loadProjects();
                },
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: memoList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No memos found'));
                    }
          
                    final memos = snapshot.data!;
                    final limitedMemos = memos.length > 5 ? memos.sublist(0, 5) : memos;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: limitedMemos.length,
                      itemBuilder: (context, index) {
                        final memo = limitedMemos[index];
                        return Slidable(
                          key: ValueKey(memo['id']),
                          endActionPane: isManager
                              ? null
                              : ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        try {
                                          await MemoApi.deleteMemo(memo['id']);
                                          await _refreshMemos();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Failed to delete memo")),
                                          );
                                        }
                                      },
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                          child: MemoCardWidget(
                            memo: memo,
                            onTap: () {
                              if (isManager) return; // block manager
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => createMemoScreen(
                                    projectName: memo['project_name'] ?? 'Unknown Project',
                                    isEdit: true,
                                    existingMemo: memo,
                                  ),
                                ),
                              ).then((_) {
                                _refreshMemos();
                                _loadProjects();
                              });
                            },
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
      floatingActionButton: isManager ? null: (_isFabVisible
        ? FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 16, 55, 123),
            onPressed: () async {
              String projectName = getProjectNameById(widget.projectId);
              final newtask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => createMemoScreen(
                    projectName: projectName,
                    isEdit: false,
                    existingMemo: null,
                  ),
                ),
              );
              if (newtask != null) {
                _refreshMemos();
                _loadProjects();
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null),
    );
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await MemoApi.getProjects();
      final allMemos = await MemoApi.getMemoCount();

      final counts = <int, int>{};
      for (final memo in allMemos) {
        final projectId = memo['project_id'] as int;
        final total = memo['total'] as int;
        counts[projectId] = total;
      }

      setState(() {
        projectList = projects;
        memoCountByProject = counts;
      });
    } catch (e) {
      print("Failed to load data: $e");
    }
  }

  Widget _buildCardContent(Map<String, dynamic> project, bool isManager) {
    final projectName = project['name'];
    final projectId = project['id'];
    final cardColor = getColorForProject(projectName);
    final memoCount = memoCountByProject[projectId] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 170,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('$memoCount',
                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 7),
                                const Text('Total Memo',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Staff', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 40,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: members.length + (isManager ? 0 : 1),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 70,
                                  mainAxisSpacing: 2,
                                ),
                                itemBuilder: (context, index) {
                                  if (index < members.length) {
                                    final member = members[index];
                                    return CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Tooltip(
                                        message: member,
                                        child: Text(
                                          _getInitials(member),
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return GestureDetector(
                                       onTap: () => _showAddMemberDialog(projectId),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey.shade300,
                                        child: const Icon(Icons.add, color: Colors.black54, size: 20),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  String getProjectNameById(int projectId) {
    final project = projectList.firstWhere(
      (p) => p['id'] == projectId,
      orElse: () => {'name': 'Unknown Project'},
    );
    return project['name'];
  }

//   Future<void> _showAddMemberDialog() async {
//   try {
//     final staffNames = await MemoApi.getStaffMembers(); 
//     List<String> tempSelected = List.from(members); 
//     String searchQuery = '';

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             final filteredNames = staffNames
//                 .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
//                 .toList();

//             return AlertDialog(
//               backgroundColor:Colors.white, 
//               title: const Text('Select Staff'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search staff',
//                       prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Colors.grey),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                     ),
//                     onChanged: (value) {
//                       setModalState(() => searchQuery = value);
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     height: 300,
//                     width: double.maxFinite,
//                     child: Scrollbar(
//                       child: ListView.builder(
//                         itemCount: filteredNames.length,
//                         itemBuilder: (_, index) {
//                           final name = filteredNames[index];
//                           return CheckboxListTile(
//                             title: Text(name),
//                             value: tempSelected.contains(name),
//                             onChanged: (bool? selected) {
//                               setModalState(() {
//                                 if (selected == true) {
//                                   tempSelected.add(name);
//                                 } else {
//                                   tempSelected.remove(name);
//                                 }
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         members = List.from(tempSelected); 
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: Text('Done (${tempSelected.length})'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to load staff members')),
//       );
//     }
// }

Future<void> _showAddMemberDialog(int projectId) async {
  final staffList = await MemoApi.getAvailableStaffForProject(projectId);
  List<int> tempSelectedIds = [];
  String searchQuery = '';

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        final filtered = staffList.where((s) =>
          s['name'].toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();

        return AlertDialog(
          title: const Text('Add Staff to Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Search'),
                onChanged: (val) => setModalState(() => searchQuery = val),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final staff = filtered[index];
                    final isSelected = tempSelectedIds.contains(staff['id']);
                    return ListTile(
                      title: Text(staff['name']),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.radio_button_unchecked),
                      onTap: () {
                        setModalState(() {
                          isSelected
                            ? tempSelectedIds.remove(staff['id'])
                            : tempSelectedIds.add(staff['id']);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                await MemoApi.assignStaffToProject(projectId, tempSelectedIds);
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              },
            ),
          ],
        );
      });
    },
  );
}



}
