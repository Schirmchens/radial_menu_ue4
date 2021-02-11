import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RadialMenuItem {
  Widget child;
  Color color;
  Function onSelected;
  String baseColor;

  RadialMenuItem(this.child, this.color, this.onSelected){
    if(this.color == Colors.red){
      baseColor="RED";
    }
    else if(this.color == Colors.green){
      baseColor="GREEN";
    }

    else if(this.color == Colors.blue){
      baseColor="BLUE";
    }

    else if(this.color == Colors.yellow){
      baseColor="YELLOW";
    }

    else if(this.color == Colors.purple){
      baseColor="PURPLE";
    }
    else if(this.color == Colors.black){
      baseColor="RANDOM";
    }
    else if(this.color == Colors.grey){
      baseColor="GREY";
    }
    else{
      baseColor="RANDOM";
    }
  }

}
