import 'package:flutter/material.dart';
import 'package:myapp/home/party/PartyPage.dart';
import 'package:myapp/home/profile/ProfilePage.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';

class HomePage extends StatefulWidget {
  static const route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;
  final pages = [
    PartyPage(),
    ProfilePage(),
  ];
  @override
  void initState() {
    _tabController = TabController(
        length: 2,
        initialIndex: 0,
        animationDuration: const Duration(milliseconds: 250),
        vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          shadowColor: Colors.transparent,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: theme.selectedRowColor,
            controller: _tabController,
            tabs: [
              Text(
                "Party",
                style: TextStyle(color: theme.hintColor, fontSize: 32),
              ),
              Text("Profile",
                  style: TextStyle(color: theme.hintColor, fontSize: 32))
            ],
          )),
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: pages,
        ),
      ),
    );
  }
}
