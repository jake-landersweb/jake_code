# Selector In Flutter

This is a fun little custom widget that I built that I thought I'd share. It takes a list of items and potrays them as cells you can tap on to select whatever content is in the cells. It will add your selections into another list that you are able to read from.

### End Result:

[Video on Website](http://www.jakelanders.com/wp-content/uploads/2020/12/selector.mp4)

<img src="http://www.jakelanders.com/wp-content/uploads/2020/12/selector.png" alt="Selector" width="200"/>

### Create the Widget

First, we will need to define a stateful widget.

```dart
class CustomSelector extends StatefulWidget {
  @override
  _CustomSelectorState createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
```

Next, we need to add two required fields and one optional one.
1. The list of items to choose from
2. The list of items the selected items will be put into
3. (Optional), the padding of the view

Put this at the top of your widget (not the state portion).

```dart
final List<dynamic> items;
final List<dynamic> selectedItems;
final EdgeInsets padding;
CustomSelector({
@required this.items,
@required this.selectedItems,
this.padding,
})  : assert(items != null),
    assert(selectedItems != null),
    assert(items.runtimeType == selectedItems.runtimeType);
```

### Compose the widget

Now it is time to create the widget. First, we need to define a container to hold the styling for the widget, and stylize that widget.

```dart
Padding(
  padding: widget.padding == null ? EdgeInsets.symmetric(horizontal: 16) : widget.padding,
  child: Container(
    decoration: BoxDecoration(
      color: isLight ? lightColor : darkColor,
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);
```

I first wrap my widget in padding to give some distance from the edge of the screen, then I give the container some decoration to give it rounded corners and a color.

### Define the list

For our purposes, the ListView.builder widget is going to serve our needs perfectly. But in more complex cases, an animated list might be a better choice when wanting to add / remove content.

```dart
ListView.builder(
  physics: NeverScrollableScrollPhysics(), 
  itemCount: widget.items.length,
  shrinkWrap: true,
  padding: EdgeInsets.all(0),
  itemBuilder: (context, index) {
    
  },
),
```

###  Define a cell

Now, we need a widget to hold the items we want to display to the user. This cell will need to be clickable, and change its own state based on whether it is clicked or not.

```dart
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
                  ? Colors.red : isLight
                      ? Colors.black.withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
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
```

Lastly, we can use this cell in our list. The listView.builder creates a builder funtion that gives us the current index of whatever cell is being rendered, so we can use that to fill our content.

```dart
itemBuilder: (context, index) {
    return Column(
      children: [
        cell(widget.items[index], isLight),
        // add a divider if the cell is not the last one
        if (index < widget.items.length - 1) divider(isLight),
      ],
    );
  },
```

> Note, I use my own version of a divider here because I prefer the way it looks and interacts with content more than the default divier. Here is that code:

```dart
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
```

And there it is! You have a fully working selector. Here is it implemented in action:

```dart
class Selection extends StatelessWidget {
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
```

### Source Code:

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/flutter/selector/selector.dart)


















