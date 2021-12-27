A good looking animated slide out menu is essential for any project. Luckily, the engineers at Apple have already created a great looking menu that is used mainly on their iPad and Mac devices. We are going to mimic that in flutter today.

## Dependencies

There are two dependencies for this project, [Provider](https://pub.dev/packages/provider) for managing state, and [Sprung](https://pub.dev/packages/sprung) for good looking spring animations.

## A Menu Item

First, we are going to need an object to hold some information about each view we want represented in the menu. We will use a basic data class for this with the following fields:
1. title: String
2. icon: IconData
3. content: Widget

```dart
class MenuItem {
  late String title;
  late IconData icon;
  late Widget content;

  MenuItem({
    required this.title,
    required this.icon,
    required this.content,
  });

  MenuItem.empty() {
    title = "";
    icon = Icons.settings;
    content = Container();
  }

  String getTitle() {
    return title;
  }

  Widget getContent() {
    return content;
  }

  IconData getIcon() {
    return icon;
  }
}
```

## The Model

To manage the menu's state, we will be using a class that extends change notifier. This will let us handle all of the constraint manipulation in the view in a single place so all views stay updated. The point is not to keep ALL of the state manipulation in one place, just enough for it to make sense.

```dart
class MenuModel extends ChangeNotifier {
  double offset = 0;
  double cachedOffset = 0;
  double dragStart = 0;
  bool isPan = false;
  bool isOpen = false;

  bool animate = false;

  MenuItem selectedItem = MenuItem.empty();

  MenuModel() {
    selectedItem = items.first;
  }

  final double sizeThreashold = 1.5;

  void open(Size size) {
    offset = -size.width / sizeThreashold;
    cachedOffset = -size.width / sizeThreashold;
    isOpen = true;
    // update state
    notifyListeners();
  }

  void close() {
    offset = 0;
    cachedOffset = 0;
    isOpen = false;
    // update state
    notifyListeners();
  }

  void setSelected(MenuItem item) {
    selectedItem = item;
    notifyListeners();
  }

  List<MenuItem> items = [
    MenuItem(
        title: "Homepage",
        icon: Icons.home,
        content: const BasicPage(title: "Homepage")),
    MenuItem(
        title: "Social",
        icon: Icons.person,
        content: const BasicPage(title: "Social")),
    MenuItem(
        title: "Settings",
        icon: Icons.settings,
        content: const BasicPage(title: "Settings")),
  ];
}
```

## Menu

Now, we need to build an acual menu. This consists of two parts. The menu button, and the container that holds the buttons. Here is an iOS style menu button:

```dart
Widget _menuCell(BuildContext context, MenuModel model, MenuItem item) {
  return Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: (MediaQuery.of(context).size.width / model.sizeThreashold) -
          (2 * padding),
      child: CupertinoButton(
        color: Colors.transparent,
        disabledColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
        minSize: 0,
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          color: item == model.selectedItem ? acc : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: item == model.selectedItem
                        ? Colors.white
                        : _textColor(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    item.getTitle(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: item == model.selectedItem
                          ? Colors.white
                          : _textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onPressed: () {
          // set the selected page to this items page
          model.setSelected(item);
          // close the menu
          Future.delayed(const Duration(milliseconds: 200), () {
            model.close();
          });
        },
        borderRadius: BorderRadius.zero,
      ),
    ),
  );
}
```

And here is the menu that holds these cells.

> Note, you can see here I am looping through the menu items to compose the menu. If you want something more custom you will put that extra logic here.

```dart
Widget _menu(BuildContext context, MenuModel model) {
  return Container(
    height: double.infinity,
    width: double.infinity,
    color: _bgColor(context),
    child: SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            for (var item in model.items)
              Column(
                children: [
                  _menuCell(context, model, item),
                  // padding between menu items
                  if (item != model.items.last) SizedBox(height: padding)
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
```

Now, is the menu. There is a lot of complex logic that occurs in this menu that I am not going to go over here, but feel free to look through what I have here. The basic idea is there is an AnimatedPositioned that controls the position of the content and is controlled by a pan gesture. Then, The menu sits behind this in a stack.

```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<MenuModel>(
    create: (_) => MenuModel(),
    builder: (context, child) {
      return _body(context);
    },
  );
}

Widget _body(BuildContext context) {
  var model = Provider.of<MenuModel>(context);
  var size = MediaQuery.of(context).size;
  return Stack(
    // make sure everything plays nice
    alignment: Alignment.center,
    children: [
      // menu
      _menu(context, model),
      // allow view to be in a container that can animate its relative position
      AnimatedPositioned(
        duration: model.animate
            ? const Duration(milliseconds: 800)
            : const Duration(milliseconds: 0),
        // custom curve
        curve: Sprung.overDamped,
        // offset to the right direction
        right: model.offset,
        width: size.width,
        height: size.height,
        // let entire view track gestures
        child: GestureDetector(
          // absorb pointer so the view cannot be interacted with when the view is open
          child: AbsorbPointer(
            absorbing: model.isOpen ? true : false,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _plain(context),
                border: Border(
                  left: BorderSide(
                      color: model.offset < 0
                          ? _textColor(context).withOpacity(0.2)
                          : Colors.transparent,
                      width: 0.5),
                ),
              ),
              // keep view out of top safe area
              child: model.selectedItem.getContent(),
            ),
          ),
          // when the gesture starts
          onHorizontalDragStart: (value) {
            // turn off animation so dragging feels natural
            model.animate = false;
            // detext if a pan drag
            if (value.globalPosition.dx < 50) {
              model.isPan = true;
            } else {
              model.isPan = false;
            }
            // get starting location for jitterless drag
            model.dragStart = value.localPosition.dx;
            // update the state
            setState(() {});
          },
          // while drag is occuring
          onHorizontalDragUpdate: (value) {
            if (model.isOpen) {
              // if the menu is being dragged left but not past the screen edge
              if ((value.localPosition.dx - model.dragStart) < 0 &&
                  (value.localPosition.dx - model.dragStart) >=
                      -size.width / model.sizeThreashold) {
                // set the offset to follow the users finger
                setState(() {
                  model.offset = (model.cachedOffset -
                      (value.localPosition.dx - model.dragStart));
                });
              }
              // if menu is closed, let the user open it
              // if swipe is going right but not greater than 1/3 of screen width
            } else if ((value.globalPosition.dx - model.dragStart) <=
                    size.width / model.sizeThreashold &&
                value.globalPosition.dx - model.dragStart > 0 &&
                model.isPan) {
              setState(() {
                model.offset = -value.globalPosition.dx + model.dragStart;
              });
            }
          },
          // on drag end
          onHorizontalDragEnd: (value) {
            // allow menu movement to animate
            setState(() {
              model.animate = true;
            });
            // if menu was open or closed enough / velocity was high enough open / close it
            if (model.isOpen) {
              if (model.offset > -size.width / (model.sizeThreashold * 2) ||
                  (value.primaryVelocity ?? 0) < -700) {
                model.close();
              } else {
                model.open(size);
              }
            } else {
              if (model.offset < -size.width / (model.sizeThreashold * 2) ||
                  (value.primaryVelocity ?? 0) > 700) {
                model.open(size);
              } else {
                model.close();
              }
            }
          },
          // when the menu is open, let the user tap the screen to close it
          onTap: () {
            if (model.isOpen) {
              model.close();
            }
          },
        ),
      ),
    ],
  );
}
```

## Content View

Lastly, here is a quick demo view that I am using to show the views. This also contains a menu button.

### Menu Button
```dart
class MenuButton extends StatefulWidget {
  const MenuButton({Key? key}) : super(key: key);

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<MenuModel>(context);
    return CupertinoButton(
      color: Colors.transparent,
      disabledColor: Colors.transparent,
      padding: const EdgeInsets.all(0),
      minSize: 0,
      child: Icon(model.isOpen ? Icons.close : Icons.menu,
          color: Theme.of(context).colorScheme.primary),
      // actionn of the button
      onPressed: () {
        // allow for animation
        model.animate = true;
        // toggle menu
        if (model.isOpen) {
          model.close();
        } else {
          model.open(MediaQuery.of(context).size);
        }
      },
    );
  }
}
```

### MBasic Page
```dart
class BasicPage extends StatelessWidget {
  const BasicPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
          largeTitle: Text(title,
              style: TextStyle(
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.black
                    : Colors.white,
              )),
          // close / open menu button
          leading: const MenuButton(),
        ),
        // actual view itself
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(
                child: Text(title, style: const TextStyle(color: Colors.grey))),
          ),
        ),
      ],
    );
  }
}
```

## Source

As always, all source code files can be found on [Github](https://github.com/jake-landersweb/jake_code/blob/2d6c720f399c7c3d2a789cee0368a5aca56f9cba/flutter/ios_menu/lib/menu.dart)