  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class SetDiscountScreen extends StatelessWidget {
    final String userId;
    final String userEmail;

    SetDiscountScreen({required this.userId, required this.userEmail});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
        appBar: AppBar(
          title: Text(' Discount for $userEmail'),
          backgroundColor: Color.fromARGB(255, 248, 225, 218),
                  automaticallyImplyLeading: false,
        ),
        body: HotelAdmin(userId: userId),
      );
    }
  }

  class HotelAdmin extends StatefulWidget {
    final String userId;

    HotelAdmin({required this.userId});

    @override
    _HotelsAdminState createState() => _HotelsAdminState();
  }

  class _HotelsAdminState extends State<HotelAdmin> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
          ),
          itemCount: hotelCollections.length,
          itemBuilder: (context, index) {
            return buildHotelButton(
              context,
              hotelCollections[index]['name']!,
              hotelCollections[index]['collection']!,
            );
          },
        ),
      );
    }

    Widget buildHotelButton(
        BuildContext context, String buttonText, String collectionName) {
      double containerSize = MediaQuery.of(context).size.height / 2;
      return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Container(
          height: containerSize,
          width: containerSize,
          decoration: BoxDecoration(
            color: Color(0xFF3A1B0F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelsScreen(collectionName),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  class HotelsScreen extends StatelessWidget {
    final String collectionName;

    HotelsScreen(this.collectionName);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
        appBar: AppBar(
          title: Text(
            'Hotels List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 248, 225, 218),
        ),
        body: HotelList(collectionName),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                ),
            ],
          ),
        ),
      );
    }

    
  }
  //Hotels list 
  class HotelList extends StatefulWidget {
    final String collectionName;

    HotelList(this.collectionName);

    @override
    _HotelListState createState() => _HotelListState();
  }

  class _HotelListState extends State<HotelList> {
    double selectedDiscount = 0.0;

    @override
    Widget build(BuildContext context) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection(widget.collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          var hotels = snapshot.data?.docs ?? [];
          if (hotels.isEmpty) {
            return Text('No hotels available');
          }
          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              var hotel = hotels[index];
              var hotelName = hotel['name'];
              var hotelId = hotel.id;

              return ExpansionTile(
                title: Text(
                  hotelName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection(widget.collectionName).doc(hotelId).collection('rooms').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      var rooms = snapshot.data?.docs ?? [];
                      if (rooms.isEmpty) {
                        return Text('No rooms available');
                      }
                      return Column(
                        children: rooms.asMap().entries.map<Widget>((entry) {
                          var room = entry.value;
                          var roomPrice = room['price'];
                          var roomType = room['type'];

                          return Column(
                            children: [
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Type: $roomType',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Price: $roomPrice JD',
                                              style: TextStyle(
                                                fontSize: 14,
                                                  color: Color(0xFF3A1B0F),
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          DropdownButton<double>(
    value: selectedDiscount,
    onChanged: (value) {
      setState(() {
        selectedDiscount = value!;
      });
      updateDiscountInDatabase(hotelId, room.id, selectedDiscount);
    },
    items: List.generate(
      10,
      (index) {
        double discount = index * 0.10;
        return DropdownMenuItem<double>(
          value: discount,
          child: Text('${(discount * 100).toInt()}% Discount'),
        );
      },
    ),
  ),
                                            SizedBox(height: 8),
                                            Text(
                                              'New Price: ${(roomPrice * (1 - selectedDiscount)).toStringAsFixed(2)} JD',
                                              style: TextStyle(
                                                fontSize: 14,
                                                  color: Color(0xFF3A1B0F),
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (entry.key < rooms.length - 1) Divider(),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      );
      
    }

    Future<void> updateDiscountInDatabase(String hotelId, String roomId, double newDiscount) async {
    try {
      // Fetch the room data to get the current price
      var roomSnapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(hotelId)
          .collection('rooms')
          .doc(roomId)
          .get();

      var roomData = roomSnapshot.data() as Map<String, dynamic>?;

      if (roomData != null) {
        // Get the current price from the room data
        double roomPrice = roomData['price'];

        // Calculate the new price with the applied discount
        double newPrice = roomPrice * (1 - newDiscount);

        // Update the 'discount' and 'newPrice' fields in Firestore
        await FirebaseFirestore.instance
            .collection(widget.collectionName)
            .doc(hotelId)
            .collection('rooms')
            .doc(roomId)
            .update({
              'discount': newDiscount,
              'newPrice': newPrice,
            });
      } else {
        print('Error: Room data not found');
      }
    } catch (error) {
      print('Error updating discount in database: $error');
    }
  }
 
  }
  final List<Map<String, String>> hotelCollections = [
    {'name': 'Amman Hotels', 'collection': 'hotels'},
    {'name': 'Ajloun Hotels', 'collection': 'ajloun_hotels'},
    {'name': 'Aqaba Hotels', 'collection': 'aqaba_hotels'},
    {'name': 'Dead Sea Hotels', 'collection': 'deadsea_hotels'},
    {'name': 'Jerash Hotels', 'collection': 'jerash_hotels'},
    {'name': 'Petra Hotels', 'collection': 'petra_hotels'},
    {'name': 'Wadi Rum Hotels', 'collection': 'wadirum_hotels'},
  ];