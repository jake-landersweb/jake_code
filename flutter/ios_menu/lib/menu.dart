import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Color acc = Colors.blue;
  double padding = 16;

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

  Color _bgColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return const Color.fromRGBO(245, 245, 250, 1);
    } else {
      return Colors.black;
    }
  }

  Color _plain(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  Color _textColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}
