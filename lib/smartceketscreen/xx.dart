import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:skolyozapp/blogscreen/bloglarpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavBarPage(),
    );
  }
}

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
      HomePage(),
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Smart Ceket'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'KİFOZ'),
              Tab(text: 'LORDOZ'),
              Tab(text: 'SKOLYOZ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SensorDataPage(
              title: 'ÖLÇÜM',
              smallBoxTitle: 'TKA',
              imagePath: 'assets/images/kifoz.jpeg',
            ),
            SensorDataPage(
              title: 'LLA',
              smallBoxTitle: 'LLA',
              imagePath: 'assets/images/lordoz.jpeg',
            ),
            SensorDataPage(
              title: 'LLA',
              smallBoxTitle: 'KFZ',
              imagePath: 'assets/images/skolyoz.jpeg',
            ),
          ],
        ),
      ),
    );
  }
}

class SensorDataPage extends StatelessWidget {
  final String title;
  final String smallBoxTitle;
  final String imagePath;

  SensorDataPage({
    required this.title,
    required this.smallBoxTitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20.0),
          InfoBox(
            title: title,
            sensor1: '1. sensör grubu: 30,07°',
            sensor2: '2. sensör grubu: 30,19°',
            color: Colors.brown,
          ),
          SizedBox(height: 30.0),
          InfoBox(
            title: smallBoxTitle,
            sensor1: '30,19° (Normal)',
            sensor2: '',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final String sensor1;
  final String sensor2;
  final Color color;

  InfoBox({
    required this.title,
    required this.sensor1,
    required this.sensor2,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 10),
          if (sensor1.isNotEmpty)
            Text(sensor1, style: TextStyle(fontSize: 16.0)),
          if (sensor2.isNotEmpty)
            Text(sensor2, style: TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}
