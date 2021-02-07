import 'package:flutter/widgets.dart';

class RadialMenuItem {
  Widget child;
  Color color;
  Function onSelected;
  RadialMenuItem(this.child, this.color, this.onSelected);
}
