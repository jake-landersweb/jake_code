import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  List<String> selectedDays = [];

  final Color backgroundColor = Color.fromRGBO(240, 240, 245, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Custom Selector'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: 16),
          child: CustomSelector(
            items: days,
            selectedItems: selectedDays,
          ),
        ),
      ),
    );
  }
}

class CustomSelector extends StatefulWidget {
  final List<dynamic> items;
  final List<dynamic> selectedItems;
  final EdgeInsets padding;
  CustomSelector({
    @required this.items,
    @required this.selectedItems,
    this.padding,
  })  : assert(items != null),
        assert(selectedItems != null),
        assert(items.runtimeType ==
            selectedItems
                .runtimeType); // for making sure the list and selected list are the same types
  @override
  _CustomSelectorState createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  final Color lightColor = Colors.white;
  final Color darkColor = Color.fromRGBO(40, 40, 40, 1);

  @override
  Widget build(BuildContext context) {
    final bool isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Padding(
      padding: widget.padding == null
          ? EdgeInsets.symmetric(horizontal: 16)
          : widget.padding, // padding from edge of screen
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? lightColor : darkColor, // background color
          borderRadius: BorderRadius.circular(20), // corner radius
        ),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(), // disable scroll
          itemCount: widget.items.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return Column(
              children: [
                cell(widget.items[index], isLight),
                // add a divider if the cell is not the last one
                if (index < widget.items.length - 1) divider(isLight),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget cell(dynamic item, bool isLight) {
    return FlatButton(
      onPressed: () {
        // update the state of the cell based on its previous state
        setState(() {
          if (widget.selectedItems.contains(item.toLowerCase())) {
            widget.selectedItems
                .removeWhere((element) => element == item.toLowerCase());
          } else {
            widget.selectedItems.add(item.toLowerCase());
          }
        });
      },
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              widget.selectedItems.contains(item.toLowerCase())
                  ? Icons.check_circle
                  : Icons.circle,
              color: widget.selectedItems.contains(item.toLowerCase())
                  ? Colors.red
                  : isLight
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
            ),
            SizedBox(
              width: 16,
            ),
            Text(item,
                style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  // color for dividers
  final Color lightDivider = Colors.black.withOpacity(0.2);
  final Color darkDivider = Colors.white.withOpacity(0.2);

  // custom divider that i like more
  Widget divider(bool isLight) {
    return SizedBox(
      height: 0.5,
      width: double.infinity,
      child: ColoredBox(
        color: isLight ? lightDivider : darkDivider,
      ),
    );
  }
}
