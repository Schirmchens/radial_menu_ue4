import 'package:fl_radial_menu/fl_radial_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

void main() => runApp(MyApp());
RadialMenu menu;


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions = <Widget>[
    RadialMenu(items),
    Text('Index 2: School'),
    Text('Index 2: School'),
    Text('Index 2: School'),
  ];

  static final List<RadialMenuItem> items = [
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.red,
            () => print('red')),
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.green,
            () => print('green')),
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.blue,
            () => print('blue')),
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.yellow,
            () => print('yellow')),
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.purple,
            () => print('purple')),
    RadialMenuItem(Icon(Icons.blur_on, color: Colors.white), Colors.grey,
            () => print('grey')),
    RadialMenuItem(Icon(Icons.color_lens, color: Colors.white), Colors.black,
            () => print('grey')),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'RGB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'CMYKA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'HSLA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'HSVA',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black26,
        onTap: _onItemTapped,
      ),
    );

  }
}

