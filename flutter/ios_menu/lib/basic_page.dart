import 'package:flutter/material.dart';
import 'root.dart';
import 'package:flutter/cupertino.dart';

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
