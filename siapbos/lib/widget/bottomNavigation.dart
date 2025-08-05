import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siapbos/api/memoAPI.dart';
import 'package:siapbos/provider/authProvider.dart';
import 'package:siapbos/screen/homepage.dart';
import 'package:siapbos/screen/profileScreen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class bottomNavigationBar extends StatefulWidget {
  @override
  bottomNavigationBarState createState() => bottomNavigationBarState();
}

class bottomNavigationBarState extends State<bottomNavigationBar> {
  int _selectedIndex = 0;
  int? _projectId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectId();
  }
  
   Future<void> _fetchProjectId() async {
    try {
      final projects = await MemoApi.getProjects();
      if (projects.isNotEmpty) {
        setState(() {
          _projectId = projects[0]['id']; 
          _isLoading = false;
        });
      } else {
        throw Exception('No projects found');
      }
    } catch (e) {
      print('Error getting project ID: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthState>(context);
    final int? userId = auth.userId;

    if (_isLoading || _projectId == null) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

    final List<Widget> _pages = [
      Homepage(projectId: _projectId!), 
      ProfileScreen(userId: userId ?? 0),
    ];
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: StylishBottomBar(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        option: AnimatedBarOptions(
          iconSize: 32,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          opacity: 0.3,
        ),
        items: [
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            selectedColor: Colors.blue,
          ),
          BottomBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
            selectedColor: Colors.purple,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
