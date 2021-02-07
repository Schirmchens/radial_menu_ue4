import 'package:fl_radial_menu/fl_radial_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

void main() => runApp(MyApp());

Widget _withRoundedRectangleBorder() {
  return RaisedButton(
    child: Text("RaisedButton with RoundedRectangleBorder"),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    onPressed: () {},
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final items = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
         /* RadialMenu(items, fanout: Fanout.bottomRight),
          Divider(),
          RadialMenu(items, fanout: Fanout.bottom),
          Divider(),
          RadialMenu(items, fanout: Fanout.bottomLeft),
          Divider(),
          RadialMenu(items, fanout: Fanout.right),
          Divider(),*/
          RadialMenu(items)
          /*RadialMenu(items, fanout: Fanout.left),
          Divider(),
          RadialMenu(items, fanout: Fanout.topRight),
          Divider(),
          RadialMenu(items, fanout: Fanout.top),
          Divider(),
          RadialMenu(items, fanout: Fanout.topLeft),*/
        ),
      ),
    );
  }
}
