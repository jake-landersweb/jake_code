import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _signInButtons(context),
        ),
      ],
    );
  }

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
        const SizedBox(height: 16),
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
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2),
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
}

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
