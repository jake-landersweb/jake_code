import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

class CustomMenu extends StatefulWidget {
  @override
  _CustomMenuState createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
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

  Color _selectedColor = Colors.red;
  Color _unselectedColor = Color.fromRGBO(20, 20, 20, 1);

  bool _animate = false;

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
}

class Menu extends ChangeNotifier {
  double _offset = 0;
  double _cachedOffset = 0;
  double _dragStart = 0;
  bool _isPan = false;
  bool _isOpen = false;

  pages _selectedPage = pages.home;

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
}

enum pages { home, social, shopping, contact, settings, logout }

class MenuItem {
  final String title;
  final IconData icon;
  final pages page;

  const MenuItem(
      {@required this.title, @required this.icon, @required this.page});
}
