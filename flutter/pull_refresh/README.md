# Custom Pull To Refresh Flutter 2.0

Pull to refresh is one of those things that is easy to implement, but hard to make look good. There are a few packages that give you this functionality and do it quite well, but I believe there is a lot to be learned by implementing it yourself. Plus, if you are like me and implement your own Navigation Bar and drawer, this solution can be adapted to any use case. 

## Dependencies

There is only one optional dependency, which is the amazing [Sprung](https://pub.dev/packages/sprung/install) package. Seriously. If I could only have one package this would be it. It provides stunning animation curves that I use ANYWHERE I can specify the animation curve. Seriously, the Sprung.overdampened is amazing.

```yaml
dependencies:
  flutter:
    sdk: flutter
  sprung: ^3.0.0
```

## Beginning Code

To start, we need to set up our stateful widget and define a few internal variables.

```dart
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
    _controller = ScrollController();
  }

  @override
  void dispose() {
    // memory management
    _controller.dispose();
    super.dispose();
  }
}
```

Then, we can define a pleasant view to add our scroll to refresh to. This is a basic view which has a title and a list of cells that will change color while the view is loading.

```dart
Scaffold(
      backgroundColor: const Color.fromRGBO(245, 242, 247, 1),
      body: Stack(
        children: [
          ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              children: [
                // animated padding to animate changes. This allows
                // the entire view to remain scrolled down while the
                // function is loading in new data
                Padding(
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
        ],
      ),
    );
```

## Scroll Code

In order to get the scroll offset for a view, we need to add a listener to the scroll controller. This is easily done with adding a simple modifier on the scroll controller, with the offset retreived from the controller itself.

We can then add a few things to this controller:
1. Detect when the user is scrolling in the downwards direction
2. set the load progress to a fraction of this scrolling
3. determine when the user has pulled down far enough and allow the view to refresh

```dart
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
          setState(() {
            _canLoad = true;
          });
        }
      }
    });
  }
```

After this, the ListView needs to be wrapped with a NotificationListener to listen for Scroll changes. This uses an interesting hack I found that allows you to determine when the user **releases the screen** as opposed to when the view stops scrolling. This is essential as we do not want the children of the widget sliding all the way up, the view then detects the view has stopped scrolling, then animate back upwards to reveal the loading indicator. There may very well be a better way of accomplishing this behavior, but this seems to work well for me.

Once the user has stopped scrolling and our scroll controller has told us it was a large enough scroll, we can call our update function to fetch our async data.

```dart
NotificationListener(
    onNotification: (ScrollNotification notification) {
        // weird hack to determine still dragging
        // may be better way to detect, but this works well
        // does NOT detect if still scrolling, only if user
        // physically has finger on the screen
        if (!notification.toString().contains("DragUpdateDetails")) {
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
    child: ListView(...),
)
```

The async function also contains the necessary code to return our view to the beginning state, to allow for the entire process to repeat.

```dart
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
```

Lastly, we need a way to hold the view stack above the indicator, and to add the indicator ourselves. To hold the view up, we will use an AnimatedPadding to animate the transition when we set the value to 50 in the code above. To show the progress of the scroll and of the function, we will use the CircularProgressIndicator as it has two modes. One to show linear load progress, and another to show indeterminate progress. We can use both of these contructors to show the two different load states present. One to show how much further the user has to drag down, and the other to show that the function is being called.

We can replace the padding on the Column with

```dart
AnimatedPadding(
    duration: const Duration(
        milliseconds:
            800), // probably do not change this value, I have found it works well
    curve: Sprung
        .overDamped, // amazing sping function that avoids jitters when moving
    padding: EdgeInsets.only(top: _scrollAmount),
    child: Column(...),
),
```

Then we can add the indicator at the bottom of the Stack like shown:

```dart
Padding(
    padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            (Platform.isIOS ? 0 : 10)),
    child: Align(
        alignment: Alignment.topCenter,
        child: _canLoad && _scrollAmount != 0
            ? const CircularProgressIndicator()
            : CircularProgressIndicator(
                value: _loadAmount,
            ),
    ),
),
```

## Source Code

As always, taking a look at the full code will help immensely.

That can be found [Here](https://github.com/jake-landersweb/jake_code/blob/a1f94f4899b1ce1479b324ee45014a9690f192f9/flutter/pull_refresh/scroll_refresh.dart)