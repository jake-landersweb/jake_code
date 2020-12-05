# Dynamic Page Controller

One of the issues I have faced with Apple's new implementation of the PageTabViewStyle() style for TabView has been its relative inability to handle dynamic data.

In my experience, I have observed a weird stutter when trying to put a ForEach loop inside a view controller like this:

```swift
TabView {
	ForEach(views, id:\.self) { view in
		view
	}
}
tabViewStyle(PageTabViewStyle())
```

That's why I have decided to build my own and share it with all of you!

Here is an example:

[Website Video Link](http://www.jakelanders.com/wp-content/uploads/2020/12/custom_page_view.mp4)

There are also different styles for the indicators:

###### Light Indicator
<img src="http://www.jakelanders.com/wp-content/uploads/2020/12/page_light.png" alt="Light Indicator" width="200"/>

###### Dark Indicator
<img src="http://www.jakelanders.com/wp-content/uploads/2020/12/page_dark.png" alt="Light Indicator" width="200"/>

###### Numbered Indicator
<img src="http://www.jakelanders.com/wp-content/uploads/2020/12/page_numbered.png" alt="Light Indicator" width="200"/>

Usage:

```swift
struct DynamicPageView: View {
    @State var colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    
    var body: some View {
        PageView(viewCount: colors.count) {
            ForEach(colors, id:\.self) { color in
                color.frame(width: UIScreen.main.bounds.width)
            }
        }
    }
}
```

Finally, lets get into the code.

### Create a view builder

First, you need to create a view builder to allow for view composition between {}

In addition, we will also need a couple parameters:
1. a view count Int
	- This is because there is no way for the TabView to know how many separate views are created by the dynamic struct, so that needs to be supplied.
2. an Indicator mode bool
	- This will be used later, but basically lets you set the background color of the view index indicator to allow for covering of different content based on light / dark views

```swift
struct PageView<Content>: View where Content : View {
	var content: () -> Content

	var viewCount: Int

	var darkIndicator: Bool = true

	init?(viewCount: Int, darkIndicator: Bool? = true, @ViewBuilder content: @escaping () -> Content) {
		self.content = content
		self.viewCount = viewCount

		self.darkIndicator = darkIndicator!
	}

	var body: some View {
		Text("Hello World")
	}
}
```

### Compose the view

Now, we need to create the actual view the content will be hosted in.

Also, there are a few parameters that are going to be needed for handling swiping between pages, so we will initialize those here.

```swift
// for controlling swipe animation and offset
@State private var offset: CGFloat = .zero
@State private var c_offset: CGFloat = .zero
@State private var lastDragPosition: DragGesture.Value?
@State private var view_index: Int = 0

// animation - I find this one feels good on the fingers
private let animation = Animation.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.85)

var body: some View {
	GeometryReader { geo in
		ZStack(alignment: .bottom) {
			HStack(spacing: 0) {
				content()
			}
		}
	}
}
```

As you can see here the code has a few interesting things.
1. The view is wrapped in a GeometryReader, because the view width is going to be the screen width * the view count. The geometry reader lets us elegantly handle that.
2. The view has a ZStack. This allows for the indicator to show on top of all content
3. The content is arranged in an HStack. Because this view is meant to be used in tandem with a ForEach, this will work nicely for us.

### Swipe Functionality

Because of the nature of this view, we will have to create our own swipe to move to the next page functionality. This is tricky, but certainly do-able. The code is a bit lengthy, but try and read through it with the comments I have made and it will all start to make sense.

This view functionality is as follows:
- Swiping between pages
- Moves to next page if swipe is more than half screen width
- Moves to next page if view was 'fast' enough (using velocity of finger swipe)
- When trying to scroll past the bounds of the view, it will scroll at half speed


```swift
content()
	.offset(x: offset)
	.gesture(
        // only have gesture if more than one view
        viewCount > 1 ? DragGesture(minimumDistance: 10, coordinateSpace: .local)
        .onChanged { value in
            if value.translation.width > 0 {
                if view_index == 0 {
                    offset = (value.translation.width / 2) + c_offset
                } else {
                    offset = value.translation.width + c_offset
                }
            } else {
                if view_index == viewCount - 1 {
                    offset = (value.translation.width / 2) + c_offset
                } else {
                    offset = value.translation.width + c_offset
                }
            }
            // track position for determining swipe speed
            lastDragPosition = value
        }
        .onEnded { value in
            // for getting swipe velocity
            let timeDiff = value.time.timeIntervalSince(lastDragPosition!.time)
            let speed = CGFloat(value.translation.width - lastDragPosition!.translation.width) / CGFloat(timeDiff)
            // screen going right
            if value.translation.width < 0 {
                // if the translation is more than 0.5 screen, or swipe was fast enough, and not at the end
                if -(value.translation.width) > UIScreen.main.bounds.width * 0.5 && view_index < viewCount - 1 || -speed > 500 && view_index < viewCount - 1 {
                    // set the offset to move to next page
                    withAnimation(animation) {
                        offset = c_offset - geo.size.width
                        view_index += 1
                    }
                    // cache the offset
                    c_offset = offset
                } else {
                    // set the offset to the old offset
                    withAnimation(animation) {
                        offset = c_offset
                    }
                }
            }
            // screen going left
            else {
                // if more than half screen, or fast enough, and not at the end of the screen
                if value.translation.width > UIScreen.main.bounds.width * 0.5 && view_index > 0 || speed > 500 && view_index > 0 {
                    // move the view by a screen
                    withAnimation(animation) {
                        offset = c_offset + geo.size.width
                        view_index -= 1
                    }
                    c_offset = offset
                } else {
                    withAnimation(animation) {
                        offset = c_offset
                    }
                }
            }
        }
        : nil
    )
```

This will get you a good amount of the way there. But, there still are a few more things to take care of.

### Adding an indicator

First, we need to specify the HStack's frame and offset to allow for the indicator to sit properly on the screen.

```swift
HStack(spacing: 0) {
	...
}
.frame(width: CGFloat(viewCount) * geo.size.width, alignment: .leading)
.offset(x: geo.size.width * CGFloat((viewCount) / 2) - (viewCount % 2 == 0 ? (geo.size.width / 2) : 0))
```

Now, here are some custom page index indicators I whipped together pretty quick. Feel free to implement your own style!

```swift
var default_view_counter: some View {
    HStack(spacing: 10) {
        ForEach(0..<viewCount) { i in
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(view_index == i ? (darkIndicator ? Color.black : Color.white) : (darkIndicator ? Color.black.opacity(0.4) : Color.white.opacity(0.4)))
        }
    }
}

// custom number based view counter
var custom_view_counter: some View {
    Text("\(view_index + 1)/\(viewCount)")
        .font(.system(size: 18, weight: .medium, design: .monospaced))
        .foregroundColor(darkIndicator ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
}
```

Finally, add those indicators ONLY when the view count is greater than one. That is one thing I wanted to pay attention when creating this view, is it should still feel like a normal view when the amount of views is 1.

```swift
if viewCount > 1 {
    Group {
        if viewCount > 9 {
            custom_view_counter
        } else {
            default_view_counter
        }
    }
    .padding(10)
    .background(darkIndicator ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    .padding(.bottom, 25)
}
```

One last note, set the ZStack's frame to the geometry size frame, and ignore the safe areas.

```swift 
GeometryReader { geo in
	ZStack(alignment: .bottom) {
		...
	}
	.frame(width: geo.size.width)
}
.edgesIgnoringSafeArea(.all)
```

And thats all!

### Source Code

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/swift/dynamic_page_view/DynamicPageView.swift)
