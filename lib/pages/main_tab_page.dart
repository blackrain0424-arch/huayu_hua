import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'map_home_page.dart';
import 'discover_page.dart';
import 'community_page.dart';
import 'chatbot_page.dart';
import 'mine_page.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    MapHomePage(),
    DiscoverPage(),
    CommunityPage(),
    ChatbotPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: appGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            activeIcon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined),
            activeIcon: Icon(Icons.local_florist),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: '社区',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant_outlined),
            activeIcon: Icon(Icons.assistant),
            label: '花语Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
