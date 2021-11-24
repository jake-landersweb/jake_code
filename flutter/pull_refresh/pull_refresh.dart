import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

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
        primarySwatch: Colors.red,
      ),
      home: const Refreshable(),
    );
  }
}

class Refreshable extends StatefulWidget {
  const Refreshable({Key? key}) : super(key: key);

  @override
  _RefreshableState createState() => _RefreshableState();
}

class _RefreshableState extends State<Refreshable> {
  late ScrollController _controller;

  bool _canLoad = false;
  bool _isLoading = false;
  double _loadAmount = 0;
  double _scrollAmount = 0;

  @override
  void initState() {
    super.initState();

    // written this way incase this view
    // gets encapsulated, and want other
    // unrelated scollcontroller functionality
    // outside this class
    _controller = ScrollController();

    // attach a listener onto the scroll controller
    // so we have access to the current offset
    _controller.addListener(() {
      // check for scrolling down
      if (_controller.offset < 0) {
        // set the loadAmount, this gets represented
        // in the progress indicator between 0 and 1
        // with 0 being invisible and 1 being a full circle
        setState(() {
          _loadAmount = -0.2 + -(_controller.offset * 0.012);
        });
        // if fully scrolled down, let the view know it can
        // load when the user releases the screen
        if (_loadAmount >= 1) {
          _canLoad = true;
        } else {
          _canLoad = false;
        }
      }
    });
  }

  @override
  void dispose() {
    // memory management
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 242, 247, 1),
      body: Stack(
        children: [
          // notification listener for tracking whether the user is still actively
          // dragging onto the screen
          NotificationListener(
            onNotification: (ScrollNotification notification) {
              // weird hack to determine still dragging
              // may be better way to detect, but this works well
              // does NOT detect if still scrolling, only if user
              // physically has finger on the screen
              if (!notification.toString().contains("DragUpdateDetails") &&
                  !notification.toString().contains("direction")) {
                // user released the screen, animate the position change
                if (_scrollAmount == 0 && _canLoad) {
                  // set the padding to be any value you want
                  setState(() {
                    _scrollAmount = 50;
                  });
                  // call the async function that resets the values
                  _function();
                }
              }
              return true;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              children: [
                // animated padding to animate changes. This allows
                // the entire view to remain scrolled down while the
                // function is loading in new data
                AnimatedPadding(
                  duration: const Duration(
                      milliseconds:
                          800), // probably do not change this value, I have found it works well
                  curve: Sprung
                      .overDamped, // amazing sping function that avoids jitters when moving
                  padding: EdgeInsets.only(top: _scrollAmount),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Refreshable",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      // can control what gets shown for loading state
                      // here red cells get shown when the view
                      // is actively loading something
                      for (int i = 0; i < 20; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Material(
                                shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                                color: _isLoading
                                    ? Colors.red
                                    : Colors.black.withOpacity(0.1),
                                child: const SizedBox(
                                  height: 100,
                                  width: double.infinity,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // for showing progress
          // this will use the _loadAmount variable
          // to determine how far along the scroll-to-load
          // process is
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    (Platform.isIOS ? 0 : 10)),
            child: Align(
              alignment: Alignment.topCenter,
              child: _scrollAmount != 0
                  ? const CircularProgressIndicator()
                  : CircularProgressIndicator(
                      value: _loadAmount,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // an example of an async function
  Future<void> _function() async {
    setState(() {
      _isLoading = true;
    });
    // put any Future<void> async function that calls data here
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // reset all of the variables, this is essential
      // for resetting functionality and returning
      // screen to starting state
      _isLoading = false;
      _canLoad = false;
      _scrollAmount = 0;
    });
  }
}
