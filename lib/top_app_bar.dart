import 'package:flutter/material.dart';
import 'auth.dart';
import 'dialog_auth.dart';
import 'home_page.dart';

class TopAppBar extends StatefulWidget {
  final double opacity;

  TopAppBar(this.opacity);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Theme.of(context).primaryColorLight.withOpacity(widget.opacity),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ADMIN PAGE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: screenSize.width / 8),
                   
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width / 60,
              ),
              InkWell(
                onTap: userEmail == null
                    ? () {
                  showDialog(
                    context: context,
                    builder: (context) => AuthDialog(),
                  );
                }
                    : null,
                child: userEmail == null
                    ? Container(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8, left: 12, right: 0),
                    width: 75,
                    height: 38,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Color(0xFF3A1B0F),
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ))
                    : Row(
                  children: [
                    SizedBox(width: 5),
                    Text(
                      name ?? userEmail!,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                        setState(() {
                          _isProcessing = true;
                        });
                        await signOut().then((result) {
                          print(result);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => HomePage(),
                            ),
                          );
                        }).catchError((error) {
                          print('Sign Out Error: $error');
                        });
                        setState(() {
                          _isProcessing = false;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: _isProcessing
                            ? CircularProgressIndicator()
                            : Text(
                          'Sign out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}