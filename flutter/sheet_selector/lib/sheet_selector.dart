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
}
