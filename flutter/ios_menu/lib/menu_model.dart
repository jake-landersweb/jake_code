import 'package:flutter/material.dart';
import 'package:ios_menu/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

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
