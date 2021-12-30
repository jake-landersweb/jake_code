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
