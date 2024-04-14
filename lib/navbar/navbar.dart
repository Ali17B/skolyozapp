import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:skolyozapp/anasayfascreen/anasayfapage.dart';
import 'package:skolyozapp/blogscreen/bloglarpage.dart';

class NavBarPage extends StatefulWidget {
  final bool hideNavBar;

  const NavBarPage({Key? key, this.hideNavBar = false}) : super(key: key);

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  PersistentTabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      AnasayfaPage(),
      BloglarPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.library_add_rounded, size: 22),
        title: ("Anasayfa"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey.shade800,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.forum_outlined, size: 22),
        title: ("Blog"), 
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey.shade800,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller!,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      onItemSelected: (int) {
        setState(() {});
      },
      backgroundColor: Colors.white,
      navBarStyle: NavBarStyle.style8,
      hideNavigationBar: widget.hideNavBar,
    );
  }
}
