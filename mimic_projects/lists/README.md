# Building Identical lists in Flutter and SwiftUI

An interesting exercise that I have recently liked to explore is building native iOS framworks in flutter multiplatform.

This week I decided to try lists!

## Native list in SwiftUI:

[Link on my website](http://www.jakelanders.com/wp-content/uploads/2020/12/iOS_list.mp4)

## Recreation in Flutter:

[List on my website](http://www.jakelanders.com/wp-content/uploads/2020/12/flutter_list.mp4)

As you can see, it is not a perfect recreation, but it is quite good! Making the add animations could be a little smoother, and having the list rows contain their own background rather than a container representing it could also make for a better look.

> Note: In the flutter version, I use two packages. [Reorderables](https://pub.dev/packages/reorderables) and [Sprung](https://pub.dev/packages/sprung). Make sure to add those to your pubspec.yaml file.

Anyways, here is the code!

## iOS:

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/mimic_projects/lists/iOS_list.swift)

## Flutter:

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/mimic_projects/lists/flutter_lists.dart)