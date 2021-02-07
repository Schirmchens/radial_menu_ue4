# fl_radial_menu

A simple and easy to use radial menu widget for Flutter that supports fanout direction.

![screem ca[tire]](screenshot/screen.gif)

## install
```
dependencies:
  fl_radial_menu: <version>
```


## Usage

- create a list of RadialMenuItem
```
  final items = [
    RadialMenuItem(Icon(FontAwesome.glass, color: Colors.white), Colors.red,
        () => print('red')),
    RadialMenuItem(Icon(FontAwesome.glass, color: Colors.white), Colors.green,
        () => print('green')),
    RadialMenuItem(Icon(FontAwesome.glass, color: Colors.white), Colors.blue,
        () => print('blue')),
  ];
```


- Instantiate RadialMenu with the items and some parameters.
```
RadialMenu(mainItems)
```

- RadialMenu supports some parameters like isClockwise, fanout.

- Change the direction of the menu items

```
RadialMenu(mainItems, isClockwise: false)
```

- Specify the direction to fanout the menu items.

```
// enum Fanout {
//   topLeft,
//   topRight,
//   bottomLeft,
//   bottomRight,
//   top,
//   bottom,
//   left,
//   right,
//   circle,
// }
RadialMenu(mainItems, fanout: fanout: Fanout.topLeft,)
```

