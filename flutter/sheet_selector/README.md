This is some simple UI for an item picker utilizing a slide up sheet. This can be especially useful when you have multiple options that do not quite fit on one page, but do not want to navigate to a new screen. And, the slide up looks good.

## Dependencies

For this project, you will need the amazing package [Sprung](https://pub.dev/packages/sprung) for open and closing animation, and [modal_bottom_sheet](https://pub.dev/packages/modal_bottom_sheet) for some built in functionality when designing our own floating sheet.

```yaml
sprung: ^3.0.0
modal_bottom_sheet: ^2.0.0
```

## Sheet

First, we need to define a sheet view. This will leverage the modal bottom sheet package for some presentation functionality. This code is pretty much copy and paste, feel free to use it however you would like (without charging for usage).

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';

/// Shows a floating sheet with padding based on the platform
class FloatingSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingSheet({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, Platform.isIOS ? 50 : 10),
      child: Material(
        color: backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: child,
      ),
    );
  }
}

/// Presents a floating model.
Future<T> showFloatingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool useRootNavigator = false,
  Curve? curve,
}) async {
  final result = await showCustomModalBottomSheet(
    context: context,
    builder: builder,
    animationCurve: curve ?? Sprung.overDamped,
    duration: const Duration(milliseconds: 700),
    containerWidget: (_, animation, child) => FloatingSheet(
      child: child,
      backgroundColor: backgroundColor,
    ),
    expand: false,
    useRootNavigator: useRootNavigator,
  );

  return result;
}
```

> show_sheet.dart

## Global Helpers

Whenever I have some attributes I would like to use over and over in a project, I like to define them as global functions. This same functionality can be accomplished with the style classes, but I find a functional programming approach is much easier to understand from a code readability standpoint.

This will give us access to a basic text color we can use: white when darkmode black when lightmode. A background color that is a bit softer than black or white, and the sheet color, which is a ligher variation of the sheet

```dart
Color textColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.black
      : Colors.white;
}

Color backgroundColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(240, 240, 250, 1)
      : const Color.fromRGBO(40, 40, 40, 1);
}

Color sheetColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.white
      : const Color.fromRGBO(40, 40, 40, 1);
}
```

## Sheet Selector

Now for the actual view.

I gave myself a stateful class with the following properties:

- String title
- T selection
- Function(T) onSelection
- List<T> available
- List<String> titles
- Color color
- Color selectedTextColor

We can use <T> to define a dynamic type that will get set by the user using the widget. This allows us to handle mutliple primative types such as String, int, double, bool etc. There is also an optional titles list that lets you specify a human friendly name to your selections. This is helpful when selecting from a list of numbers. This requires a list of the same length as available, and the titles will be mapped in the same order as the available list.

This looks like:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'root.dart';

class SheetSelector<T> extends StatefulWidget {
  SheetSelector({
    Key? key,
    required this.title,
    required this.selection,
    required this.onSelect,
    required this.available,
    this.titles,
    this.color = Colors.blue,
    this.selectedTextColor = Colors.white,
  }) : super(key: key);
  final String title;
  T selection;
  final Function(T) onSelect;
  final List<T> available;
  final List<String>? titles;
  final Color color;
  final Color selectedTextColor;

  @override
  _SheetSelectorState<T> createState() => _SheetSelectorState<T>();
}

class _SheetSelectorState<T> extends State<SheetSelector<T>> {
  @override
  void initState() {
    // assert that selections and titles are the same length
    if (widget.titles != null) {
      if (widget.titles!.length != widget.available.length) {
        throw "Available selections list and titles need to be the same length";
      }
    }
    super.initState();
  }
  ...
}
```

Then, I defined a cell that will render with a background color when selected and a transparent one when not selected. This takes a T value which is a dynamic type specified by the user, and a title.

```dart
Widget _cell(BuildContext context, T val, String title) {
  return CupertinoButton(
    color: Colors.transparent,
    disabledColor: Colors.transparent,
    padding: const EdgeInsets.all(0),
    minSize: 0,
    onPressed: () {
      setState(() {
        widget.onSelect(val);
        widget.selection = val;
      });
    },
    // rounded container with half height radius for complete circle effect.
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: val == widget.selection ? widget.color : Colors.transparent,
      ),
      width: double.infinity,
      height: 50,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: val == widget.selection
                ? widget.selectedTextColor
                : textColor(context),
          ),
        ),
      ),
    ),
  );
}
```

Next, I designed a list that holds the available cells. This dynamically handles whether there is a title list or not and provides the right data to _cell

```dart
Widget _selector(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int index = 0; index < widget.available.length; index++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _cell(
                  context,
                  widget.available[index],
                  widget.titles != null
                      ? widget.titles![index]
                      : widget.available[index].toString()),
              if (index < widget.available.length) const SizedBox(height: 16),
            ],
          ),
        ),
    ],
  );
}
```

Now we can arrange this view into a nice package with a header into the build method like:

```dart
@override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // header
      _header(context),
      const SizedBox(height: 16),
      _selector(context),
    ],
  );
}

Widget _header(BuildContext context) {
  return Container(
    width: double.infinity,
    height: 45,
    color: MediaQuery.of(context).platformBrightness == Brightness.light
        ? Colors.black.withOpacity(0.1)
        : Colors.white.withOpacity(0.1),
    // wrap with a stack to allow for centered title with button on right side
    child: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        // title widget
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor(context),
          ),
        ),
        // push button to the left side
        // not using expanded, sometimes button becomes clickable across entire width
        Row(children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            // edited cupertino button to only show slightly opaqued when tapped. No other styling
            child: CupertinoButton(
              color: Colors.transparent,
              disabledColor: Colors.transparent,
              padding: const EdgeInsets.all(0),
              minSize: 0,
              onPressed: () {
                // close the view
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ])
      ],
    ),
  );
}
```

## Main View

Here is an example page to show the functionality of the widget

```dart
class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  final List<String> _titles = ["Hello", "I", "Am", "Jake"];
  late String _selectedTitle;
  final List<int> _ids = [1, 2, 3, 4, 5];
  late int _selectedId;

  @override
  void initState() {
    _selectedTitle = _titles.first;
    _selectedId = _ids.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(context),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Custom Selector",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          color: textColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // example using strings
                  Center(
                    child: CupertinoButton(
                      color: Colors.transparent,
                      disabledColor: Colors.transparent,
                      padding: const EdgeInsets.all(0),
                      minSize: 0,
                      onPressed: () {
                        showFloatingSheet(
                          context: context,
                          backgroundColor: sheetColor(context),
                          builder: (context) {
                            return SheetSelector<String>(
                              title: "Select Title",
                              selection: _selectedTitle,
                              available: _titles,
                              onSelect: (value) {
                                setState(() {
                                  _selectedTitle = value;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        _selectedTitle,
                        style: TextStyle(
                          color: textColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // example using integer and titles
                  Center(
                    child: CupertinoButton(
                      color: Colors.transparent,
                      disabledColor: Colors.transparent,
                      padding: const EdgeInsets.all(0),
                      minSize: 0,
                      onPressed: () {
                        showFloatingSheet(
                          context: context,
                          backgroundColor: sheetColor(context),
                          builder: (context) {
                            return SheetSelector<int>(
                              title: "Select ID",
                              selection: _selectedId,
                              available: _ids,
                              onSelect: (value) {
                                setState(() {
                                  _selectedId = value;
                                });
                              },
                              titles: const [
                                "One",
                                "Two",
                                "Three",
                                "Four",
                                "Five"
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        _selectedId.toString(),
                        style: TextStyle(
                          color: textColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

As always, the source code is available on [github](https://github.com/jake-landersweb/jake_code/blob/main/flutter/sheet_selector/lib/main.dart)