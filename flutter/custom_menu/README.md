# Custom Slide Out Menu In Flutter

A menu can be a great way to add an interesting design pattern into your app and when done right, can extremely influence the perceived 'polish' your app has. 

Slide out menus are not always the best option for navigation, but it is extremely versatile and you will most definitely come across a time when you will need to use one.

> Note: Apple recommends using a bottom nav bar for 5 or less items.

## Finished Product:

[Video on my website](http://www.jakelanders.com/wp-content/uploads/2020/11/custom_menu.mp4)

In order to create a beautiful slide out menu that will work equally well on Android and iOS, you need three things:

1. A class to contain the menu.
2. A class to host the menu.
3. A way for those two classes to talk to each other as best as possible.

For number 3, the best way I have found for classes to update each others states is with provider. It is a custom package state manager.

## Add this to your pubsec.yaml file:

```dart
provider: ^4.3.2+2
```

And while you are add it, add this package as well. It has some animation curves that I find look great on all devices.

```dart
sprung: ^2.0.0+13
```

> You can find Srung package page created by [Luke Pighetti](https://twitter.com/luke_pighetti) [here](https://pub.dev/packages/sprung)

We will now work on 2.

## Create a class to host your menu items.

For this menu, you will need the following things:

- An offset double
- A cached offset double
- A double to hold where a drag started
- A bool indicating whether the gesture is a pan gesture
- A bool indicating whether the menu is open
- An open function
- And a close function

### Here is the code for the class:

```dart
class Menu extends ChangeNotifier {
  double _offset = 0;
  double _cachedOffset = 0;
  double _dragStart = 0;
  bool _isPan = false;
  bool _isOpen = false;

  void _open(Size size) {

  }

  void _close() {
    
  }
}
```

> Note: Make sure to add these at the top of your file:

```dart
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
```

### There are two more support things we need before we begin with the meat of the code:

1. An enum to hold all the available views
2. A Menu Item class to hold information about the individual menu item

```dart
enum pages { home, social, shopping, contact, settings, logout }

class MenuItem {
  final String title;
  final IconData icon;
  final pages page;

  const MenuItem(
      {@required this.title, @required this.icon, @required this.page});
}
```

#### The menu class will also need a variable to determine the current page.

> I named mine **_selectedPage**

Now we can work on the view itself.

## Create a stateful widget:

```dart
class CustomMenu extends StatefulWidget {
  @override
  _CustomMenuState createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

You will also need access to the Menu class through provider, so add that to your main() method in main.dart
*example*

```dart
void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => Menu()),
    ], child: MyApp()),
  );
}
```

And add access to your class with this inside the build widget:

*Also add a variable to get screen size*

```dart
var _menu = Provider.of<Menu>(context);
var _size = MediaQuery.of(context).size;
```

Also, create an array of menu items like this:

```dart
List<MenuItem> _menuItems = [
	MenuItem(
	  title: 'Home',
	  icon: Icons.home,
	  page: pages.home,
	),
	MenuItem(
	  title: 'Social',
	  icon: Icons.person,
	  page: pages.social,
	),
	MenuItem(
	  title: 'Shopping',
	  icon: Icons.shopping_bag,
	  page: pages.shopping,
	),
	MenuItem(
	  title: 'Contact',
	  icon: Icons.phone,
	  page: pages.contact,
	),
	MenuItem(
	  title: 'Settings',
	  icon: Icons.settings,
	  page: pages.settings,
	),
	MenuItem(
	  title: 'Log Out',
	  icon: Icons.logout,
	  page: pages.logout,
	),
];
```

Now it is time to design the view:

I first added these two variables for a selected and unselected color and for whether the view should be animated or not (*fixes some visual issues later*).

```dart
Color _selectedColor = Colors.red;
Color _unselectedColor = Color.fromRGBO(20, 20, 20, 1);

bool _animate = false;
```

### Menu row widget:

First, a menu row widget needs to be constructed. This is done with a flat button that contains a colored container that is colored to indicate the selected view.

```dart
  // menu row widget
  Widget menuRow(MenuItem _item, Menu _menu, Size _size) {
    return Row(
      children: [
        // entire view is a button
        FlatButton(
          // fizes weird padding on button
          padding: EdgeInsets.all(0),
          onPressed: () {
            // set the selected page to this items page
            setState(() {
              _menu._selectedPage = _item.page;
            });
            // close the menu
            Future.delayed(const Duration(milliseconds: 200), () {
              _menu._close();
            });
          },
          // styling for the button
          child: Container(
            color: _menu._selectedPage == _item.page
                ? _selectedColor
                : _unselectedColor,
            height: _size.width / 3,
            width: _size.width / 3,
            // center the entire view
            child: Center(
              // column so icon is on top of text
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(_item.icon, color: Colors.white, size: 30),
                  ),
                  // title
                  Text(
                    _item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        // spacer so view is on left side of screen
        Spacer(),
      ],
    );
  }
```

### Menu widget:

Next is composing the actual menu widget, which contains some stylized backgrounds to help with safe area covering and a list of all of the menu items:

```dart
  Widget menu(BuildContext context, Menu _menu, Size _size) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            // these two containers are to account for safe area spill over of the selected color
            children: [
              // for first menu item
              Container(
                color: _menu._selectedPage == pages.home
                    ? _selectedColor
                    : _unselectedColor,
                child:
                    SizedBox(height: _size.height / 2, width: _size.width / 3),
              ),
              // for last menu item
              Container(
                color: _menu._selectedPage == pages.logout
                    ? _selectedColor
                    : _unselectedColor,
                child:
                    SizedBox(height: _size.height / 2, width: _size.width / 3),
              ),
            ],
          ),
          // menu itself
          ListView.builder(
            // disable scroll
            physics: NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            itemBuilder: (context, _index) {
              return Column(
                children: [
                  menuRow(_menuItems[_index], _menu, _size),
                  // dividers for the views
                  if (_index != _menuItems.length - 1)
                    // my own custom divider that i like more
                    SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Color.fromRGBO(10, 10, 10, 1),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
```

Now for the main event: all of the logic to control the menu:

## Actual View

This view is responsible for a number of things:

- Controlling the offset of the main views
- Detecting different gestures
- Displaying each page
- Allowing the menu to be shown / hidden with gestures and a button

Here is the completed code of the main view

```dart
  @override
  Widget build(BuildContext context) {
    var _menu = Provider.of<Menu>(context);
    var _size = MediaQuery.of(context).size;
    return Stack(
      // make sure everything plays nice
      alignment: Alignment.center,
      children: [
        // menu
        menu(context, _menu, _size),
        // allow view to be in a container that can animate its relative position
        AnimatedPositioned(
          duration: _animate
              ? Duration(milliseconds: 800)
              : Duration(milliseconds: 0),
          // custom curve
          curve: Sprung.overDamped,
          // offset to the right direction
          right: _menu._offset,
          width: _size.width,
          height: _size.height,
          // let entire view track gestures
          child: GestureDetector(
            // absorb pointer so the view cannot be interacted with when the view is open
            child: AbsorbPointer(
              absorbing: _menu._isOpen ? true : false,
              child: Container(
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.white
                    : Colors.black,
                // keep view out of top safe area
                child: SafeArea(
                  bottom: false,
                  child: Material(
                    // account for dark vs light mode
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.white
                        : Colors.black,
                    child: CustomScrollView(
                      slivers: [
                        CupertinoSliverNavigationBar(
                          backgroundColor:
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.black,
                          largeTitle: Text(_getTitle(_menu._selectedPage),
                              style: TextStyle(
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                              )),
                          // close / open menu button
                          leading: IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.centerLeft,
                            icon: Icon(_menu._isOpen ? Icons.close : Icons.menu,
                                color: Colors.blue),
                            // actionn of the button
                            onPressed: () {
                              // allow for animation
                              _animate = true;
                              // toggle menu
                              if (_menu._isOpen) {
                                _menu._close();
                              } else {
                                _menu._open(_size);
                              }
                            },
                          ),
                        ),
                        // actual view itself
                        SliverToBoxAdapter(
                          child: _getView(_menu._selectedPage),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // when the gesture starts
            onHorizontalDragStart: (value) {
              // turn off animation so dragging feels natural
              _animate = false;
              // detext if a pan drag
              if (value.globalPosition.dx < 50) {
                _menu._isPan = true;
              } else {
                _menu._isPan = false;
              }
              // get starting location for jitterless drag
              _menu._dragStart = value.localPosition.dx;
              // update the state
              setState(() {});
            },
            // while drag is occuring
            onHorizontalDragUpdate: (value) {
              if (_menu._isOpen) {
                // if the menu is being dragged left but not past the screen edge
                if ((value.localPosition.dx - _menu._dragStart) < 0 &&
                    (value.localPosition.dx - _menu._dragStart) >=
                        -_size.width / 3) {
                  // set the offset to follow the users finger
                  setState(() {
                    _menu._offset = (_menu._cachedOffset -
                        (value.localPosition.dx - _menu._dragStart));
                  });
                }
                // if menu is closed, let the user open it
                // if swipe is going right but not greater than 1/3 of screen width
              } else if ((value.globalPosition.dx - _menu._dragStart) <=
                      _size.width / 3 &&
                  value.globalPosition.dx - _menu._dragStart > 0 &&
                  _menu._isPan) {
                setState(() {
                  _menu._offset = -value.globalPosition.dx + _menu._dragStart;
                });
              }
            },
            // on drag end
            onHorizontalDragEnd: (value) {
              // allow menu movement to animate
              setState(() {
                _animate = true;
              });
              // if menu was open or closed enough / velocity was high enough open / close it
              if (_menu._isOpen) {
                if (_menu._offset > -_size.width / 6 ||
                    value.primaryVelocity < -700) {
                  _menu._close();
                } else {
                  _menu._open(_size);
                }
              } else {
                if (_menu._offset < -_size.width / 6 ||
                    value.primaryVelocity > 700) {
                  _menu._open(_size);
                } else {
                  _menu._close();
                }
              }
            },
            // when the menu is open, let the user tap the screen to close it
            onTap: () {
              if (_menu._isOpen) {
                _menu._close();
              }
            },
          ),
        ),
      ],
    );
  }
```

You will also need these methods for this view to work:

```dart
  // for getting correct view
  Widget _getView(pages _selection) {
    switch (_selection) {
      case pages.home:
        return Text('Home');
      case pages.social:
        return Text('Social');
      case pages.shopping:
        return Text('Shopping');
      case pages.contact:
        return Text('Contact');
      case pages.settings:
        return Text('Settings');
      case pages.logout:
        return Text('Logout');
      default:
        return Text('Home');
    }
  }

  // for getting title
  String _getTitle(pages _selection) {
    switch (_selection) {
      case pages.home:
        return 'Home';
      case pages.social:
        return 'Social';
      case pages.shopping:
        return 'Shopping';
      case pages.contact:
        return 'Contact';
      case pages.settings:
        return 'Settings';
      case pages.logout:
        return 'Logout';
      default:
        return 'Home';
    }
  }
```

Lastly, we need to configure the open and close methods in the parent class!

## Open and close methods:

```dart
  void _open(Size size) {
    _offset = -size.width / 3;
    _cachedOffset = -size.width / 3;
    _isOpen = true;
    // update state
    notifyListeners();
  }

  void _close() {
    _offset = 0;
    _cachedOffset = 0;
    _isOpen = false;
    // update state
    notifyListeners();
  }
```

And there it is! I hope you enjoyed this tutorial and learned something! If you have any questions, feel free to drop a comment or send me an email.

## Source Code:

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/flutter/custom_menu/custom_menu.dart)