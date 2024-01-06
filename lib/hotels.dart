import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelsAdmin extends StatelessWidget {
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
          'Hotel List',
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
              child: ElevatedButton(
                onPressed: () {
                  _showAddHotelDialog(context);
                },
                child: Text('Add Hotel', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A1B0F),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddHotelDialog(BuildContext context) {
    String name = '';
    String location = '';
    String phone = '';
    String rating = '';
    String website = '';
    String image = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 248, 225, 218),
          title: Text('Add Hotel'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Name', (value) => name = value),
                _buildTextField('Location', (value) => location = value),
                _buildTextField('Phone', (value) => phone = value),
                _buildTextField('Rating', (value) => rating = value),
                _buildTextField('Website', (value) => website = value),
                _buildTextField('Image URL', (value) => image = value),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Add the hotel to Firestore
                  await FirebaseFirestore.instance.collection(collectionName).add({
                    'name': name,
                    'location': location,
                    'phone': phone,
                    'rating': rating,
                    'website': website,
                    'image': image,
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding hotel: $e');
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String labelText, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class HotelList extends StatelessWidget {
  final String collectionName;

  HotelList(this.collectionName);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
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
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      hotelName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDeleteConfirmationDialog(context, hotel.id, collectionName);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String hotelId, String collectionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this hotel?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection(collectionName).doc(hotelId).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting hotel: $e');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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