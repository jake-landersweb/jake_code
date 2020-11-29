# Simple Log in screen in flutter

This is a guide on how to make a simple compact (code-wise) log in screen in flutter.

## Final Product

[Watch Video (local link)](http://www.jakelanders.com/wp-content/uploads/2020/11/login.mp4)

## Create a Stateful Widget:

You will need two fields for this, a form key which controls the state of the form, and a bool to control whether to show the password text or not

```dart
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // key for form
  final _formKey = GlobalKey<FormState>();

  // whether the password is hidden or not
  bool _hidePass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.red,
      ),
      body: Text('Hello, World.')
    );
  }
}
```

## Then, create your specific fields:

### Email Field:
```dart
// email field
Widget _emailField(BuildContext context) {
  return TextFormField(
    decoration: const InputDecoration(
      icon: Icon(Icons.person),
      labelText: 'Email *',
    ),
    validator: (value) {
      // chekc state of the field
      if (!value.contains('@') || !value.contains('co')) {
        // field does not have @ sign or a .co
        return 'Please enter a valid email address';
      }
      return null;
    },
  );
}
```

### Password Field:
```dart
// password field
Widget _passField(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.lock),
            labelText: 'Password *',
          ),
          obscureText: _hidePass,
          validator: (value) {
            if (value.isEmpty) {
              return 'Password cannot be blank';
            }
            return null;
          },
        ),
      ),
      IconButton(
        padding: EdgeInsets.all(0),
        onPressed: () {
          _hidePass = !_hidePass;
          setState(() {});
        },
        icon: Icon(
            _hidePass ? Icons.remove_red_eye_outlined : Icons.remove_red_eye),
        color: _hidePass
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.8),
      ),
    ],
  );
}
```

### Login Button:
```dart
// login button
Widget _loginButton(BuildContext context) {
  // get screen size
  var size = MediaQuery.of(context).size;
  return FlatButton(
    padding: EdgeInsets.all(0),
    onPressed: () {
      // make sure the form is valid
      if (_formKey.currentState.validate()) {
        // navigate to new page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Text('Second Page'),
            ),
          ),
        );
      }
    },
    child: Container(
      height: 50,
      width: size.width / 2,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text('Login', style: TextStyle(color: Colors.white)),
      ),
    ),
    // clip of button will not extend beyond border radius
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
```

## Lastly, put it all together:

You can get creative with padding and columns to get spacing-like control with the column.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // app bar
    appBar: AppBar(
      title: Text("Login"),
      backgroundColor: Colors.red,
    ),
    body: Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // email field
            _emailField(context),
            // password field with padding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _passField(context),
            ),
            // login button
            _loginButton(context),
          ],
        ),
      ),
    ),
  );
}
```

## Source Code:
[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/flutter/login_screen/login.dart)