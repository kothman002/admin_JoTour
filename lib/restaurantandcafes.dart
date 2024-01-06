import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatelessWidget {
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
        itemCount: restaurantCollections.length,
        itemBuilder: (context, index) {
          return buildRestaurantButton(
            context,
            restaurantCollections[index]['name']!,
            restaurantCollections[index]['collection']!,
          );
        },
      ),
    );
  }

  Widget buildRestaurantButton(
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
                builder: (context) => RestaurantsScreen(collectionName),
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
class RestaurantsScreen extends StatelessWidget {
  final String collectionName;

  RestaurantsScreen(this.collectionName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 225, 218),
      appBar: AppBar(
        title: Text(
          'Restaurant List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
      ),
      body: RestaurantList(collectionName),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddRestaurantDialog(context);
                },
                child: Text('Add Restaurant', style: TextStyle(color: Colors.white)),
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

  void _showAddRestaurantDialog(BuildContext context) {
    String name = '';
    String city = '';
    String workingHours = '';
    String classification = '';
    String imageUrl = '';
    String location = '';
    String phoneNumber = '';
    String rating = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 248, 225, 218),
          title: Text('Add Restaurant'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Name', (value) => name = value),
                _buildTextField('City', (value) => city = value),
                _buildTextField('Working Hours', (value) => workingHours = value),
                _buildTextField('Classification', (value) => classification = value),
                _buildTextField('Image URL', (value) => imageUrl = value),
                _buildTextField('Location', (value) => location = value),
                _buildTextField('Phone Number', (value) => phoneNumber = value),
                _buildTextField('Rating', (value) => rating = value),
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
                  // Add the restaurant to Firestore
                  await FirebaseFirestore.instance.collection(collectionName).add({
                    'name': name,
                    'city': city,
                    'workingHours': workingHours,
                    'classification': classification,
                    'imageUrl': imageUrl,
                    'location': location,
                    'phoneNumber': phoneNumber,
                    'rating': rating,
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding restaurant: $e');
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

class RestaurantList extends StatelessWidget {
  final String collectionName;

  RestaurantList(this.collectionName);

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
        var restaurants = snapshot.data?.docs ?? [];
        if (restaurants.isEmpty) {
          return Text('No restaurants available');
        }
        return ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            var restaurant = restaurants[index];
            var restaurantName = restaurant['name'];
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      restaurantName,
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
                      showDeleteConfirmationDialog(context, restaurant.id, collectionName);
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

  void showDeleteConfirmationDialog(BuildContext context, String restaurantId, String collectionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this restaurant?'),
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
                  await FirebaseFirestore.instance.collection(collectionName).doc(restaurantId).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting restaurant: $e');
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

final List<Map<String, String>> restaurantCollections = [
  {'name': 'Amman Restaurants', 'collection': 'amman_restaurants'},
  {'name': 'Aqaba Restaurants', 'collection': 'aqaba_restaurants'},
  {'name': 'Dead Sea Restaurants', 'collection': 'deadsea_restaurants'},
  {'name': 'Jerash Restaurants', 'collection': 'jerash_restaurants'},
  {'name': 'Petra Restaurants', 'collection': 'petra_restaurants'},
  {'name': 'Wadi Rum Restaurants', 'collection': 'wadirum_restaurants'},
];





