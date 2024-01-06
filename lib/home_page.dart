import 'package:flutter/material.dart';
import 'package:web_login_page/auth.dart';
import 'package:web_login_page/Discount_Hotels.dart';
import 'package:web_login_page/drawers.dart';
import 'package:web_login_page/responsive.dart';
import 'package:web_login_page/top_app_bar.dart';
import 'package:web_login_page/user_control.dart';
import 'package:web_login_page/restaurantandcafes.dart';
import 'package:web_login_page/hotels.dart';
import 'package:web_login_page/most_visit.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _scrollPosition = 0;
  double _opacity = 0;

  Widget buildButtons(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: screenSize.width / 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserControlPage()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'User Control',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        SizedBox(width: screenSize.width / 20),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Restaurant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        SizedBox(width: screenSize.width / 20),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HotelsAdmin()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hotels',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        SizedBox(width: screenSize.width / 20),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MostBooking()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Most Booking',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: 300,
        height: 200,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
                    color: Color(0xFF3A1B0F),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 225, 218),
      extendBodyBehindAppBar: true,
      appBar: ResponsiveWidget.isSmallScreen(context)
          ? AppBar(
              backgroundColor:
                  Theme.of(context).cardColor.withOpacity(_opacity),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'ADMIN PAGE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            )
          : PreferredSize(
              preferredSize: Size(screenSize.width, 1000),
              child: TopAppBar(_opacity),
            ),
      drawer: Drawers(),
      body: Center(
  child: userEmail == null
    ? Container(
        child: Text(
          'Welcome Every One',
          style: TextStyle(
            color: Colors.black,
            fontSize: 36,
            fontWeight: FontWeight.bold),
        ),
      )
    : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton("User Control", UserControlPage()),
                buildButton("Most Booking", MostBooking()),
               // buildButton("Discount Restaurant&cafes", RestaurantAdmin(userId: '',)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton("Hotels", HotelsAdmin()),
                buildButton("Discount Hotels", HotelAdmin(userId: '',)),
                buildButton("Restaurant", MyHomePage()),
              ],
            ),
          ]
        ),
      ),
),
   
    );
  }
}