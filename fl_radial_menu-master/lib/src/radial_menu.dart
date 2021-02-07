
import 'dart:math';

import 'package:flutter/material.dart';
import 'radial_menu_item.dart';


class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
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

  double animationRelativePosX(int index) {
    return childDistance *
        cos(_degreeToRadian(angularWidth / (numDivide) * index + startAngle));
  }

  double animationRelativePosY(int index) {
    return childDistance *
        sin(_degreeToRadian(angularWidth / (numDivide) * index + startAngle)) *
        (isClockwise ? 1 : -1);
  }

  Offset get posDelta {
    final x = (mainButtonRadius + _mainButtonPadding) -
        (itemButtonRadius + _itemButtonPadding);
    final y = (mainButtonRadius + _mainButtonPadding) -
        (itemButtonRadius + _itemButtonPadding);
    return Offset(x, y);
  }

  RadialMenu(this.items,
      {this.childDistance = 90.0,
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

    if(!secondaryOut){
      list = [];
      list.addAll(_buildChildren());
      list.add(_buildMainButton());
    }
    print("list build: "); print(list.length);
    Widget out = Container(
      key: _key,
      width: widget.containersize.width,
      height: widget.containersize.height,
      //for debug
      // color: Colors.grey,
      child: Stack(
        alignment: widget.stackAlignment,
        children: list,
      ),
    );
    secondaryOut=false;
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
                      borderRadius: BorderRadius.circular(widget.itemButtonRadius),
                      color: item.color),
                  child: Center(child: item.child))),
          onTap: () {
            item.onSelected();

            setState(() {
              list.addAll(_buildSecondaryChildren());
              print("list in second: "); print(list.length);
              secondaryOut = true;
              //opened = false;
            });
          },
        ));
  }

  List<Widget> _buildSecondaryChildren() {
    return widget.items.asMap().entries.map((e) {
      int index = e.key;
      RadialMenuItem item = e.value;

      return AnimatedPositioned(
          duration: Duration(milliseconds: widget.dialOpenDuration),
          curve: widget.curve,
          left: opened
              ? position.dx + (widget.animationRelativePosX(index) * 1.5)
              : position.dx,
          top: opened
              ? position.dy + (widget.animationRelativePosY(index) * 1.5)
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
                      borderRadius: BorderRadius.circular(widget.itemButtonRadius*2),
                      color: item.color),
                  child: Center(child: item.child))),
          onTap: () {
            item.onSelected();
            setState(() {
              opened = false;
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
    final x = _size.width / 2 -
        (widget.mainButtonRadius + widget._mainButtonPadding);
    final y = _size.height / 2 -
        (widget.mainButtonRadius + widget._mainButtonPadding);
    return Offset(x, y);
  }

}

double _degreeToRadian(double degree) {
  return degree * pi / 180;
}



