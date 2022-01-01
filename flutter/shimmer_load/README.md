Building an interesting loading UI is integral to a great looking app. This is a quick mockup of how to create the classic shimmer loading effect in Flutter.

## Animation Code

To achieve the shimmering animation, we are going to use a tween animation repreater on a double. This will give us a constanly updating value to use as an animation value.

```dart
late AnimationController _animationController;
late Animation _animation;

@override
void initState() {
  _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  _animationController.repeat(reverse: true);
  // start the animation of opacity between 0.3 1.0
  // set state in listener to update view
  _animation = Tween(begin: 0.3, end: 1.0).animate(_animationController)
    ..addListener(() {
      setState(() {});
    });
  super.initState();
}
```

Then, we can wrap this functionality into a modular widget. The logic in the initState() and dispose() methods will autimatically handle starting the animation and disposing of it from memory whenever it is initialized / removed.

```dart
class ShimmerLoadCell extends StatefulWidget {
  const ShimmerLoadCell({Key? key}) : super(key: key);

  @override
  _ShimmerLoadCellState createState() => _ShimmerLoadCellState();
}

class _ShimmerLoadCellState extends State<ShimmerLoadCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    // start the animation of opacity between 0.3 1.0
    // set state in listener to update view
    _animation = Tween(begin: 0.3, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // wrap the widget in an opacity to allow for the shimmer effect
    return Opacity(
      opacity: _animation.value,
      child: Material(
        color: _cellColor(context),
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: const SizedBox(
          width: double.infinity,
          height: 50,
        ),
      ),
    );
  }
}
```

Now, all that is left to do is utilize the widget in an example view.

```dart
class ShimmerLoad extends StatefulWidget {
  const ShimmerLoad({Key? key}) : super(key: key);

  @override
  _ShimmerLoadState createState() => _ShimmerLoadState();
}

class _ShimmerLoadState extends State<ShimmerLoad> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: ListView(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Shimmer Load",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (int i = 0; i < 25; i++)
                    Column(
                      children: [
                        if (_isLoading)
                          const ShimmerLoadCell()
                        else
                          Material(
                            color: _cellColor(context),
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(35)),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "item = $i",
                                  style: TextStyle(
                                    color: _textColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16)
                      ],
                    )
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

## Source Code

[Github Link]()