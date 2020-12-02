import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:reorderables/reorderables.dart';
import 'package:sprung/sprung.dart';

class Lists extends StatefulWidget {
  @override
  _ListsState createState() => _ListsState();
}

class _ListsState extends State<Lists> with TickerProviderStateMixin {
  // items
  final List<ListItem> items = [];
  // whether editing controls should be active or not
  bool editing = false;
  // background color for the entire view
  Color backgroundColor = Color.fromRGBO(240, 240, 245, 1);
  // animation duration for the used animations
  final int duration = 800;
  // height of the cells
  final double height = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // custom scroll view for large title support
      body: CustomScrollView(
        slivers: [
          // large title
          CupertinoSliverNavigationBar(
            largeTitle: Text('Lists'),
            // buttons
            leading: editButton(context),
            trailing: addItem(context),
          ),
          // convert box to sliver-able widget
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              // animate the size change when new items are added to the list
              child: AnimatedSize(
                // inherited vsync
                vsync: this,
                duration: Duration(milliseconds: 1000),
                curve: Curves.fastLinearToSlowEaseIn,
                // container to hold list in, has rounded edges
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  width: double.infinity,
                  // reorderable column from imported package
                  child: ReorderableColumn(
                    // separate scroll controller fixes an issue
                    scrollController: ScrollController(),
                    // draggable feedback is what is shown when the cell is being dragged
                    buildDraggableFeedback: (context, constraints, child) {
                      return new ConstrainedBox(
                        constraints: constraints,
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: Container(
                            width: double.infinity,
                            child: child,
                            // show a little transparency
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                    // function to call when list is reordered
                    onReorder: (begin, end) {
                      reorderList(begin, end);
                      setState(() {});
                    },
                    children: [
                      // more generic for loop to get index control
                      for (int i = 0; i < items.length; i++)
                        Column(
                          key: items[i].key,
                          children: [
                            listRow(context, items[i]),
                            // add divider below list tile if it is not
                            // the last in the list
                            if (i < items.length - 1) divider(context),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // custom list row ;; this one is a dousey
  Widget listRow(BuildContext context, ListItem item) {
    // dismissable to allow for draggable delete funtionality
    return Dismissible(
      // only allow one dirrection
      direction: DismissDirection.endToStart,
      key: item.key,
      // funtion to call when successful swipe
      onDismissed: (direction) {
        setState(() {
          items.remove(item);
        });
      },
      // what is shown behind the child
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ),
      // actual list row
      child: Container(
        height: height,
        width: double.infinity,
        // animated positions need stacks
        child: Stack(
          children: [
            // allow the title to slide a bit when clicking edit
            AnimatedPositioned(
              duration: Duration(milliseconds: duration),
              curve: Sprung.overDamped,
              left: editing ? 30 : 0,
              child: Container(
                height: height,
                alignment: Alignment.centerLeft,
                // title of the cell (or can be child)
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  // child can go here if you want to
                  // make this widget more generic and flexable
                  child: Text('Item ${item.index}'),
                ),
              ),
            ),
            //  allow drag indicator to move from the trailing edge
            AnimatedPositioned(
              height: height,
              curve: Sprung.overDamped,
              width: MediaQuery.of(context).size.width,
              duration: Duration(milliseconds: duration),
              right: editing ? 0 : -50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  // opacity for a better looking slide in
                  AnimatedOpacity(
                    curve: Sprung.overDamped,
                    duration: Duration(milliseconds: duration),
                    opacity: editing ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      // icon itself
                      child: Icon(
                        Icons.dehaze,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget for adding an item
  Widget addItem(BuildContext context) {
    // flat buttons are weird
    return SizedBox(
      width: 100,
      // buttom
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Align(
          alignment: Alignment.centerRight,
          // text
          child: Text('Add',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        // add an item on pressed
        onPressed: () {
          setState(() {
            items.add(ListItem(key: UniqueKey(), index: items.length));
          });
        },
      ),
    );
  }

  // toggle the edit mode for the view
  Widget editButton(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(editing ? 'Done' : 'Edit',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      // enable editing / disable editing
      onPressed: () {
        setState(() {
          editing = !editing;
        });
      },
    );
  }

  // custom divder, like more than default flutter
  Widget divider(BuildContext context) {
    return SizedBox(
      height: 0.5,
      width: double.infinity,
      child: ColoredBox(
        color: Colors.black.withOpacity(0.1),
      ),
    );
  }

  // function to reorder the list
  void reorderList(int start, int current) {
    // Lifesaving code from Stackoverflow user: CopsOnRoad
    // https://stackoverflow.com/questions/53908025/flutter-sortable-drag-and-drop-listview
    // dragging from top to bottom
    if (start < current) {
      int end = current;
      ListItem startItem = items[start];
      int i = 0;
      int local = start;
      do {
        items[local] = items[++local];
        i++;
      } while (i < end - start);
      items[end] = startItem;
    }
    // dragging from bottom to top
    else if (start > current) {
      ListItem startItem = items[start];
      for (int i = start; i > current; i--) {
        items[i] = items[i - 1];
      }
      items[current] = startItem;
    }
    // update the view
    setState(() {});
  }
}

// custom list item, not very necessary, needs a key though
class ListItem {
  final Key key;
  final int index;

  ListItem({@required this.key, @required this.index});
}
