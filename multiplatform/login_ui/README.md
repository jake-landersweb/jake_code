Flutter is a great platform for building complex and elegant UI that compiles to many platforms. But, sometimes a native solution can allow for greater functionality. for example, building apps for macOS in SwiftUI just ***looks and feels*** better. 

As a challenge, I decided to build the same login UI with both Flutter and SwiftUI to compile to iPhone, Android, iPad, and macOS.

I will lay this out in a side by side comparison so that the two frameworks can be directly compared in functionality and syntax.

## Assets

The needed assets can be found [here.](https://github.com/jake-landersweb/jake_code/tree/main/multiplatform/login_ui/assets)

Both projects will use apple.png and google.png, but because SwiftUI does not support packages out of the box, SwiftUI will utilize wave.png and Flutter will use wave.svg.

### SwiftUI Assets

<img src="https://jakelanders.com/media/images/swiftui_assets_loginui.png" height="200px">

### Flutter Assets

<img src="https://jakelanders.com/media/images/flutter_assets_loginui_71dPCQR.png" height="200px">

> In Flutter, you will also have to add this into your <code>pubspec.yaml</code> file.

```yaml
assets:
  - assets/svg/wave.svg
  - assets/images/google.png
  - assets/images/apple.png
```

## Global Setup

There are some global varialbes and extensions that are needed for functionality of the app.

### Swift

For SwiftUI, we need to define some colors and extensions to handle hiding the keyboard along with removing a focus ring around text fields.

```swift
// static colors
fileprivate func backgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color(.sRGB, red: 240/255, green: 240/255, blue: 250/255, opacity: 1) : Color(.sRGB, red: 40/255, green: 40/255, blue: 40/255, opacity: 1)
}

fileprivate func textColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.black : Color.white
}

fileprivate func cellColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.white : Color(.sRGB, red: 80/255, green: 80/255, blue: 80/255, opacity: 1)
}

extension View {
    func hideKeyboard() {
        #if canImport(UIKit)
        // hide keyboard on iOS devices
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #elseif os(macOS)
        // hide keyboard on macOS
        NSApp.keyWindow?.makeFirstResponder(nil)
        #endif
        // do nothing on any other device
    }
}

#if os(macOS)
// remove ring around NSTextFields on MacOS
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
```

### Flutter

Flutter is a little simpler, as we only need to define the colors.

```dart
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
      ? const Color.fromRGBO(15, 15, 25, 1)
      : const Color.fromRGBO(240, 240, 250, 1);
}
```

## View Setup

View set up on both platforms is fairly similar, but there are some key differences. SwiftUI uses the <code>View</code> protocol, and Flutter uses <code>Stateful</code> widgets.

### SwiftUI

For Swift, we are going to use an <code>ObservableObject</code> class to handle our state. Then, we can define our colors and fields there. Then in our view, we can use a <code>FocusState</code> to control what field we are currently editing, and handle keyboard actions.

```swift
class LoginModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    let color1 = Color.red
    let color2 = Color.orange
    
    func onSubmit() {
        print("submitted ...")
    }
    
    func forgotPassword() {
        print("forgot password ...")
    }
}

struct LoginUI: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var model = LoginModel()
    
    @FocusState var focused: Field?
    
    // available text fields
    enum Field {
        case name
        case email
        case password
    }
}
```

### Flutter

For Flutter, we can define the two colors we need as params on the class. Then, instead of using a package like <code>Provider</code>, we can just handle state inside the class with basic fields.

```dart
class LoginUI extends StatefulWidget {
  const LoginUI({
    Key? key,
    this.color1 = Colors.orange,
    this.color2 = Colors.red,
  }) : super(key: key);
  final Color color1;
  final Color color2;

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  String _name = "";
  String _email = "";
  String _password = "";
}
```

## Text Field

### Swift

In Swift we are going to use a new view to define our text fields. This will take a number of parameters:

```swift
struct FieldWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var field: String
    var isFocused: Bool
    let label: String
    let icon: String
    var obscure = false
    var color1 = Color.blue
    var color2 = Color.green

    var body: some View {}
}
```

Then, inside the view we can control certain aspects of the view. We can highlight the icon when the field is focused, and show a <code>SecureField</code> when a password input is needed.

```swift
var body: some View {
    HStack(spacing: 16) {
        // show highlighted icon when field is actively being edited
        if isFocused {
            LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .top, endPoint: .bottom)
                .mask(Image(systemName: icon))
                .frame(width: 32)
        } else {
            Image(systemName: icon)
                .frame(width: 32)
        }
        // show obscure text field when specified
        if obscure {
            SecureField(label, text: $field)
                .textFieldStyle(PlainTextFieldStyle())
        } else {
            TextField(label, text: $field)
                .textFieldStyle(PlainTextFieldStyle())
        }
    }
    .accentColor(color2)    // text line color
    .padding(16)
    .frame(height: 50)
    .background(cellColor(colorScheme: colorScheme))
    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
}
```

### Flutter

In Flutter, we again take a different approach. We can specify a function inside the class that returns a <code>Widget</code>. There is some extra boilerplate that needs to be written to remove all styling from the <code>TextFormField</code>. But in return, later we can easily specify what color everything becomes when the field is highlighed. Also, instead of using a <code>@Published</code> value to auto update state, we specify a function that returns whatever is typed into the field.

```dart
Widget _field(BuildContext context, String label, IconData icon,
    Function(String) onChanged,
    {bool obscure = false}) {
  return Material(
    color: _cellColor(context),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    // remove shadow
    elevation: 0,
    child: SizedBox(
      height: 50,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          onChanged: (value) => onChanged(value),
          obscureText: obscure,
          style: TextStyle(
            color: _textColor(context),
          ),
          decoration: InputDecoration(
            icon: Icon(icon),
            hintText: label,

            hintStyle: TextStyle(color: _textColor(context).withOpacity(0.5)),
            // to remove the underline on the field
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ),
    ),
  );
}
```

## Fields View

The fieldsView is similar for both platforms, with SwiftUI utilizing the view modifier <code>.onSubmit</code> to change the field focus when the action button is hit on the keyboard

### Swift

```swift
private var fields: some View {
    VStack(spacing: 16) {
        // name field
        FieldWrapper(field: $model.name, isFocused: focused == .name, label: "Name", icon: "person", color1: model.color1, color2: model.color2)
            .focused($focused, equals: .name)
            .submitLabel(.next)
        // if on iOS, show a different keyboard
        #if canImport(UIKit)
            .textContentType(.givenName)
        #endif
        // email field
        FieldWrapper(field: $model.email, isFocused: focused == .email, label: "Email", icon: "mail", color1: model.color1, color2: model.color2)
            .focused($focused, equals: .email)
            .submitLabel(.next)
        // if on iOS, show a different keyboard
        #if canImport(UIKit)
            .textContentType(.emailAddress)
        #endif
        // password field
        FieldWrapper(field: $model.password, isFocused: focused == .password, label: "Password", icon: "lock", obscure: true, color1: model.color1, color2: model.color2)
            .focused($focused, equals: .password)
            .textContentType(.password)
            .submitLabel(.go)
        // login button
        Button(action: {
            model.onSubmit()
        }) {
            Text("Submit")
                .foregroundColor(Color.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.0001))    // to make entire button clickable
                .overlay(
                    // add a white border around button
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 16)
        Button(action: {
            model.forgotPassword()
        }) {
            Text("Forgot your password?")
                .foregroundColor(Color.black)
                .opacity(0.5)
                .font(.system(size: 14, weight: .light))
        }
        .buttonStyle(PlainButtonStyle())
    }
    .onSubmit {
        // when defined submit key is clicked, perform a different action
        switch focused {
        case .name:
            focused = .email
        case .email:
            focused = .password
        default:
            // login code here
            model.onSubmit()
        }
    }
}
```

### Flutter

```dart
Widget _fields(BuildContext context) {
  return Column(
    children: [
      // name
      _field(context, "Name", Icons.person, (p0) {
        setState(() {
          _name = p0;
        });
      }),
      const SizedBox(height: 16),
      // email
      _field(context, "Email", Icons.mail, (p0) {
        setState(() {
          _email = p0;
        });
      }),
      const SizedBox(height: 16),
      // password
      _field(context, "Password", Icons.lock, (p0) {
        setState(() {
          _password = p0;
        });
      }, obscure: true),
      const SizedBox(height: 16)
      CupertinoButton(
        // first 4 params to remove all styling on the button and just make
        // it behave as an inkwell that gets an opacity when clicked
        color: Colors.transparent,
        disabledColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
        minSize: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            color: Colors.transparent,
          ),
          height: 50,
          width: double.infinity,
          child: const Center(
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        onPressed: () {
          //
        },
      ),
    ],
  );
}
```

## Host

Now, we need a host to hold the field view. Both platforms have a sililar approach. Wrap the field view in a container that has a <code>LinearGradient</code> as the background, then the <code>wave</code> image is below this view, with a spacer pushing everything to the top.

### Swift

// In SwiftUI, we can add the <code>.onTapGesture</code> to detect when the user taps the screen to dismiss the keyboard.

```swift
var body: some View {
    VStack(spacing: 0) {
        // all fields with background of a linear gradient to allow for dynamic sizing before wave
        fields
            .padding(32)
            .background(LinearGradient(gradient: Gradient(colors: [model.color1, model.color2]), startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea(.keyboard)
        // wave with same color as bottom of gradient to blend
        Image("wave")
            .renderingMode(.template)
            .resizable()
            .foregroundColor(model.color2)
            .frame(height: 100)
        // space from bottom of screen
        Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(backgroundColor(colorScheme: colorScheme))
    .onTapGesture {
        // hide keyboard on tap
        hideKeyboard()
    }
}
```

### Flutter

In flutter, we can wrap the entire view in a <code>GestureDetector</code> in order to hide the keyboard whenever the user taps the screen.

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // for dismissing keybaord when tapping on the screen
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
      }
    },
    child: _body(context),
  );
}

Widget _body(BuildContext context) {
  return Theme(
    // to remove the border on the field
    data: Theme.of(context).copyWith(
      colorScheme: ThemeData().colorScheme.copyWith(primary: widget.color1),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            color: Colors.transparent,
          ),
        ),
      ),
    ),
    child: Scaffold(
      backgroundColor: _backgroundColor(context),
      resizeToAvoidBottomInset: false,
      body: _form(context),
    ),
  );
}

Widget _form(BuildContext context) {
  return Column(
    children: [
      // dynamic size background with fields
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color1,
              widget.color2,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
            child: Column(
              children: [
                // all fields
                _fields(context),
                const SizedBox(height: 16),
                // forgot password
                CupertinoButton(
                  // first 4 params to remove all styling on the button and just make
                  // it behave as an inkwell that gets an opacity when clicked
                  color: Colors.transparent,
                  disabledColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  minSize: 0,
                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(
                      color: _textColor(context).withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      // save svg for transition
      SizedBox(
        width: double.infinity,
        child: SvgPicture.asset(
          "assets/svg/wave.svg",
          color: widget.color1,
          fit: BoxFit.fill,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.1,
          semanticsLabel: 'Wave',
        ),
      ),
    ],
  );
}
```

## Sign In Buttons

For an added flare, I decided to create my own Sign in with X buttons. This view code is very similar for both. THe Flutter code is written a little less optimized, and a more similar approach to SwiftUI could be used.

### Swift

There is some extra code used to stack the buttons on iOS and present them side by side on macOS

```swift
#if os(macOS)
// show HStack sign in buttons on macOS
private var signInButtons: some View {
    HStack(spacing: 16) {
        // google
        googleButton
        // apple
        appleButton
    }
    .padding(.horizontal, 32)
}
#else
// show VStack sign in buttons on every other platform
private var signInButtons: some View {
    VStack(spacing: 16) {
        // google
        googleButton
        // apple
        appleButton
    }
    .padding(.horizontal, 32)
}
#endif

private var googleButton: some View {
    Button(action: {
        print("sign in with google")
    }) {
        signInButtonHelper(image: "google", label: "Sign in with Google", labelColor: (colorScheme == .light ? Color.black : Color.white).opacity(0.7), imageBg: colorScheme == .light ? Color.clear : Color.white, cellBg: colorScheme == .light ? Color.white : Color(.sRGB, red: 66/255, green: 133/255, blue: 244/255, opacity: 1))
    }
    .buttonStyle(PlainButtonStyle())
}

private var appleButton: some View {
    Button(action: {
        print("sing in with apple")
    }) {
        signInButtonHelper(image: "apple", label: "Sign in with Apple", labelColor: Color.black, imageBg: Color.clear, cellBg: Color.white)
    }
    .buttonStyle(PlainButtonStyle())
}

// wrapper for sign in buttons to help with code reusability
private func signInButtonHelper(image: String, label: String, labelColor: Color, imageBg: Color, cellBg: Color) -> some View {
    return ZStack(alignment: .center) {
        // logo
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(imageBg)
                Image(image)
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .frame(width: 40, height: 40)
            Spacer()
        }
        .padding(.leading, 5)
        // text
        Text(label)
            .foregroundColor(labelColor)
    }
    .frame(height: 50)
    .frame(maxWidth: .infinity)
    .background(cellBg)
    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
}
```

### Flutter

```dart
Widget _signInButtons(BuildContext context) {
  return Column(
    children: [
      // google
      CupertinoButton(
        onPressed: () {},
        color: Colors.transparent,
        disabledColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
        minSize: 0,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Colors.white
                    : const Color.fromRGBO(66, 133, 244, 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                // icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/google.png",
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                ),
                // text
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      color: _textColor(context).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      // apple
      CupertinoButton(
        onPressed: () {},
        color: Colors.transparent,
        disabledColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
        minSize: 0,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                // icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Image.asset(
                        "assets/images/apple.png",
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                ),
                // text
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Sign in with Apple",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
```

Then, you just need to add those buttons to the bottom of the view above the <code>Spacer</code>, then your view is done!

This was an interesting dive into seeing what can be accomplished by both platforms, and you can see that the look is very similar.

Swift line number: 280
Flutter line number: 348

## Source Code

[Github](https://github.com/jake-landersweb/jake_code/tree/main/multiplatform/login_ui)
