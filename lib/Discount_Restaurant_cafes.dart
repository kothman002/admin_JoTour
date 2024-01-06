import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetDiscountRestaurantScreen extends StatelessWidget {
  final String userId;
  final String userEmail;

  SetDiscountRestaurantScreen({required this.userId, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 225, 218),
      appBar: AppBar(
        title: Text(' Discount for $userEmail'),
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
        automaticallyImplyLeading: false,
      ),
      body: RestaurantAdmin(userId: userId),
    );
  }
}

class RestaurantAdmin extends StatefulWidget {
  final String userId;

  RestaurantAdmin({required this.userId});

  @override
  _RestaurantAdminState createState() => _RestaurantAdminState();
}

class _RestaurantAdminState extends State<RestaurantAdmin> {
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
        itemCount: restaurantsCollections.length,
        itemBuilder: (context, index) {
          return buildRestaurantButton(
            context,
            restaurantsCollections[index]['name']!,
            restaurantsCollections[index]['collection']!,
          );
        },
      ),
    );
  }

  Widget buildRestaurantButton(
    BuildContext context,
    String buttonText,
    String collectionName,
  ) {
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
          'Restaurants List',
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
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantList extends StatefulWidget {
  final String collectionName;

  RestaurantList(this.collectionName);

  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
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
        var restaurants = snapshot.data?.docs ?? [];
        if (restaurants.isEmpty) {
          return Text('No restaurants available');
        }
        return ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            var restaurant = restaurants[index];
            var restaurantName = restaurant['name'];
            var restaurantId = restaurant.id;

            return ExpansionTile(
              title: Text(
                restaurantName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection(widget.collectionName).doc(restaurantId).collection('table_boking').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    var tables = snapshot.data?.docs ?? [];
                    if (tables.isEmpty) {
                      return Text('No tables available');
                    }
                    return Column(
                      children: tables.asMap().entries.map<Widget>((entry) {
                        var table = entry.value;
                        var tableNumber = table['tableNumber'];
                        var numberOfPersons = table['numberOfPersons'];

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
                                            'Table Number: $tableNumber',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Number of Persons: $numberOfPersons',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3A1B0F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          DropdownButton<double>(
                                            value: selectedDiscount,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedDiscount = value!;
                                              });
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
                                            'Additional Information',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3A1B0F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (entry.key < tables.length - 1) Divider(),
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

}

final List<Map<String, String>> restaurantsCollections = [
  {'name': 'Amman Restaurant', 'collection': 'amman_restaurants'},
  {'name': 'Ajloun Restaurant', 'collection': 'ajloun_restaurants'},
  {'name': 'Aqaba Restaurant', 'collection': 'aqaba_restaurants'},
  {'name': 'Dead Sea Restaurant', 'collection': 'deadsea_restaurants'},
  {'name': 'Jerash Restaurant', 'collection': 'jerash_restaurants'},
  {'name': 'Petra Restaurant', 'collection': 'petra_restaurants'},
  {'name': 'Wadi Rum Restaurant', 'collection': 'wadirum_restaurants'},
];