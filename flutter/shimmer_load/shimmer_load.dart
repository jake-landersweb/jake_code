import 'package:flutter/material.dart';

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

  List<int> _items = [];

  Future<void> _load() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _items = List.filled(25, 1);
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
                  if (_isLoading)
                    for (int i = 0; i < 25; i++)
                      Column(
                        children: const [
                          ShimmerLoadCell(),
                          SizedBox(height: 16)
                        ],
                      )
                  else
                    for (var item in _items)
                      Column(
                        children: [
                          Material(
                            color: _cellColor(context),
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(35)),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "item = $item",
                                  style: TextStyle(
                                    color: _textColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
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

Color _cellColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.white
      : const Color.fromRGBO(80, 80, 80, 1);
}

Color _backgroundColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(240, 240, 250, 1)
      : const Color.fromRGBO(40, 40, 40, 1);
}

Color _textColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.black
      : Colors.white;
}
