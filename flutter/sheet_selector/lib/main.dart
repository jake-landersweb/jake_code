import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sheet_selector/sheet_selector.dart';
import 'root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Main(),
    );
  }
}

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
