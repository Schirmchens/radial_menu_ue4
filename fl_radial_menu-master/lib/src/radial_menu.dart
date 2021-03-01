import 'dart:math';

import 'package:flutter/material.dart';
import 'radial_menu_item.dart';

class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  List<RadialMenuItem> secondaryItems;

  final double childDistance;
  final double itemButtonRadius;
  final double mainButtonRadius;
  final bool isClockwise;
  final int dialOpenDuration;
  final Curve curve;

  final _mainButtonPadding = 8.0;
  final _itemButtonPadding = 8.0;

  Size get containersize {
    double overshootBuffer = 100;
    double w = (childDistance + itemButtonRadius) * 2 + overshootBuffer;
    double h = w;
    return Size(w, h);
  }

  Alignment get stackAlignment {
    return Alignment.center;
  }

  int get startAngle {
    return 0;
  }

  int get angularWidth {
    return 360;
  }

  int get numDivide {
    if (angularWidth == 360.0) {
      return items.length;
    } else {
      return items.length - 1;
    }
  }

  int get numDivideSecondary {
    if (angularWidth == 360.0) {
      return secondaryItems.length;
    } else {
      return secondaryItems.length - 1;
    }
  }

  double animationRelativePosX(int index, [bool secondaryRadial]) {
    int numberToDivide = numDivide;
    if (secondaryRadial != null) {
      numberToDivide = numDivideSecondary;
    }
    return childDistance *
        cos(_degreeToRadian(
            angularWidth / (numberToDivide) * index + startAngle));
  }

  double animationRelativePosY(int index, [bool secondaryRadial]) {
    int numberToDivide = numDivide;
    if (secondaryRadial != null) {
      numberToDivide = numDivideSecondary;
    }

    return childDistance *
        sin(_degreeToRadian(
            angularWidth / (numberToDivide) * index + startAngle)) *
        (isClockwise ? 1 : -1);
  }

  Offset get posDelta {
    final x = (mainButtonRadius + _mainButtonPadding) -
        (itemButtonRadius + _itemButtonPadding);
    final y = (mainButtonRadius + _mainButtonPadding) -
        (itemButtonRadius + _itemButtonPadding);
    return Offset(x, y);
  }

  RadialMenu(
    this.items, {
    this.childDistance = 90.0,
    this.itemButtonRadius = 16.0,
    this.mainButtonRadius = 24.0,
    this.dialOpenDuration = 300,
    this.isClockwise = true,
    this.curve = Curves.easeInOutBack,
  });

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
  bool opened = false;
  bool secondaryOut = false;
  Color background_color = Colors.white;
  double _currentBrihgtness = 1;
  List<Widget> list = List<Widget>();

  final GlobalKey _key = GlobalKey();
  Size _size = Size(0.0, 0.0);

  getSizeAndPosition() {
    RenderBox _renderBox = _key.currentContext.findRenderObject();
    setState(() {
      _size = _renderBox.size;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  @override
  Widget build(BuildContext context) {
    if (!secondaryOut) {
      list = [];
      list.addAll(_buildChildren());
      list.add(_buildMainButton());
    }
    print("list build: ");
    print(list.length);
    Widget out = Scaffold(
        appBar: AppBar(
          title: const Text("RGB-Color Modus"),
          backgroundColor: Colors.white70,
        ),
        backgroundColor: background_color,
        body: Column(children: [
          Center(
              child: Container(
            key: _key,
            width: widget.containersize.width,
            height: widget.containersize.height,
            child: Stack(
              alignment: widget.stackAlignment,
              children: list,
            ),
          )),
          _buildSlider(),
          _buildShowColorValues(),

        ]));

    return out;
  }

  Widget _buildMainButton() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: widget.dialOpenDuration),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: opened
          ? InkWell(
              child: Padding(
                  padding: EdgeInsets.all(widget._mainButtonPadding),
                  child: Container(
                      height: widget.mainButtonRadius * 2,
                      width: widget.mainButtonRadius * 2,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.mainButtonRadius),
                          color: Colors.red),
                      child: Center(
                          child: Icon(Icons.close, color: Colors.white)))),
              onTap: () {
                setState(() {
                  opened = false;
                  secondaryOut = false;
                });
              })
          : InkWell(
              child: Padding(
                  padding: EdgeInsets.all(widget._mainButtonPadding),
                  child: Container(
                      height: widget.mainButtonRadius * 2,
                      width: widget.mainButtonRadius * 2,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.mainButtonRadius),
                          color: Colors.grey),
                      child: Center(
                          child: Icon(Icons.color_lens, color: Colors.white)))),
              onTap: () {
                setState(() {
                  opened = true;
                });
              }),
    );
  }

  List<Widget> _buildChildren() {
    return widget.items.asMap().entries.map((e) {
      int index = e.key;
      RadialMenuItem item = e.value;

      return AnimatedPositioned(
          duration: Duration(milliseconds: widget.dialOpenDuration),
          curve: widget.curve,
          left: opened
              ? position.dx + widget.animationRelativePosX(index)
              : position.dx,
          top: opened
              ? position.dy + widget.animationRelativePosY(index)
              : position.dy,
          child: _buildChild(item));
    }).toList();
  }

  Widget _buildChild(RadialMenuItem item) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: widget.dialOpenDuration),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(child: child, turns: animation);
        },
        child: InkWell(
          key: UniqueKey(),
          child: Padding(
              padding: EdgeInsets.all(widget._itemButtonPadding),
              child: Container(
                  height: widget.itemButtonRadius * 2,
                  width: widget.itemButtonRadius * 2,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(widget.itemButtonRadius),
                      color: item.color),
                  child: Center(child: item.child))),
          onTap: () {
            item.onSelected();

            setState(() {
              print(item.baseColor);
              if (item.baseColor == "RANDOM") {
                background_color = randomColor();
                _changeOppasity();
              }

              list.addAll(_buildSecondaryChildren(item.baseColor));
              print("list in second: ");
              print(list.length);
              secondaryOut = true;
              // opened = false;
            });
          },
        ));
  }

  List<Widget> _buildSecondaryChildren(String baseColor) {
    secondaryOut = false;
    this.buildSecondaryItems(baseColor);
    return widget.secondaryItems.asMap().entries.map((e) {
      int index = e.key;
      RadialMenuItem item = e.value;

      return AnimatedPositioned(
          duration: Duration(milliseconds: widget.dialOpenDuration),
          curve: widget.curve,
          left: opened
              ? position.dx + (widget.animationRelativePosX(index, true) * 1.5)
              : position.dx,
          top: opened
              ? position.dy + (widget.animationRelativePosY(index, true) * 1.5)
              : position.dy,
          child: _buildSecondaryChild(item));
    }).toList();
  }

  Widget _buildSecondaryChild(RadialMenuItem item) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: widget.dialOpenDuration),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(child: child, turns: animation);
        },
        child: InkWell(
          key: UniqueKey(),
          child: Padding(
              padding: EdgeInsets.all(widget._itemButtonPadding),
              child: Container(
                  height: widget.itemButtonRadius * 2,
                  width: widget.itemButtonRadius * 2,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(widget.itemButtonRadius * 2),
                      color: item.color),
                  child: Center(child: item.child))),
          onTap: () {
            item.onSelected();
            setState(() {
              print(item.baseColor);
              background_color = item.color;
              _changeOppasity();
              //opened = false;
            });
          },
        ));
  }

  Offset get position {
    return axisOrigin + widget.posDelta;
  }

  Offset get axisOrigin {
    //getSizeAndPosition();
    print(_size);
    final x =
        _size.width / 2 - (widget.mainButtonRadius + widget._mainButtonPadding);
    final y = _size.height / 2 -
        (widget.mainButtonRadius + widget._mainButtonPadding);
    return Offset(x, y);
  }

  buildSecondaryItems(String color) {
    widget.secondaryItems = [];
    switch (color) {
      case ("RED"):
        buildRedMenu();
        break;
      case ("GREEN"):
        buildGreenMenu();
        break;
      case ("BLUE"):
        buildBlueMenu();
        break;
      case ("YELLOW"):
        buildYellowMenu();
        break;
      case ("PURPLE"):
        buildPurpleMenu();
        break;
      case ("GREY"):
        buildGreyMenu();
        ;
        break;
      default:
        break;
    }
  }

  void buildRedMenu() {
    widget.secondaryItems = [
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 127, 127, 1), () => print('red')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 89, 89, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 50, 50, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 0, 0, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(127, 57, 57, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(178, 62, 62, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(229, 57, 57, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(252, 12, 12, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(204, 10, 10, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(165, 8, 8, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(127, 6, 6, 1), () => print('grey')),
    ];
  }

  void buildGreenMenu() {
    widget.secondaryItems = [
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(46, 127, 6, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(80, 127, 57, 1), () => print('red')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(60, 165, 8, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(101, 178, 62, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(114, 229, 57, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(92, 252, 12, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(74, 204, 10, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(66, 178, 0, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(95, 225, 0, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(151, 225, 50, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(175, 225, 127, 1), () => print('blue')),
    ];
  }

  void buildBlueMenu() {
    widget.secondaryItems = [
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(0, 21, 128, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(0, 60, 179, 1), () => print('red')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(0, 136, 204, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(0, 38, 230, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(25, 64, 255, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(25, 25, 255, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(51, 119, 225, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(51, 153, 255, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(77, 136, 255, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(77, 159, 255, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(135, 221, 255, 1), () => print('blue')),
    ];
  }

  void buildYellowMenu() {
    widget.secondaryItems = [
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(179, 179, 0, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(230, 230, 0, 1), () => print('red')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 225, 0, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 217, 25, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 213, 0, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(221, 225, 51, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 221, 51, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 255, 77, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 225, 77, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(229, 225, 102, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(225, 225, 153, 1), () => print('blue')),
    ];
  }

  void buildPurpleMenu() {
    widget.secondaryItems = [
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(25, 0, 77, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(42, 0, 128, 1), () => print('red')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(77, 0, 153, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(85, 0, 128, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(128, 0, 128, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(128, 0, 85, 1), () => print('green')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(127, 0, 153, 1), () => print('blue')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(204, 0, 204, 1), () => print('yellow')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 0, 170, 1), () => print('purple')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 0, 85, 1), () => print('grey')),
      RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(255, 102, 179, 1), () => print('blue')),
    ];
  }

  void buildGreyMenu() {
    int rot = 0;
    int gelb = 0;
    int blau = 0;
    for (int i = 0; i < 11; i++) {
      rot = (i * 255 / 11).toInt();
      gelb = (i * 255 / 11).toInt();
      blau = (i * 255 / 11).toInt();
      var item = RadialMenuItem(Icon(Icons.blur_on, color: Colors.white),
          Color.fromRGBO(rot, gelb, blau, 1), () => print('grey'));
      widget.secondaryItems.add(item);
    }
  }

  Color randomColor() {
    Random random = new Random();
    int rot = random.nextInt(255);
    int gelb = random.nextInt(255);
    int blau = random.nextInt(255);
    return Color.fromRGBO(rot, gelb, blau, 1);
  }

  Widget _buildSlider() {
    return Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Brightness"),
      Slider(
        value: _currentBrihgtness,
        min: 0,
        max: 1,
        divisions: 10,
        label: _currentBrihgtness.toString(),
        onChanged: (double value) {
          setState(() {
            _currentBrihgtness = value;
            _changeOppasity();
          });
        },
      )
    ]));
  }
  Widget _buildShowColorValues(){
    return Center(
            child: Text(
                "RGB color: " +
                    background_color.red.toString() +
                    ", " +
                    background_color.green.toString() +
                    ", " +
                    background_color.blue.toString() +
                    "  Brightness: " +
                    background_color.opacity.toStringAsFixed(2),
                style: TextStyle(fontSize: 15)));
  }

  void _changeOppasity() {
    int red = background_color.red;
    int green = background_color.green;
    int blue = background_color.blue;
    background_color = Color.fromRGBO(red, green, blue, _currentBrihgtness);
  }
}

double _degreeToRadian(double degree) {
  return degree * pi / 180;
}
