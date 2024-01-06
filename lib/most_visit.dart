import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MostBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 225, 218),
      appBar: AppBar(
        title: Text('Most visited statistics'),
        backgroundColor: Color.fromARGB(255, 248, 225, 218),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (userSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${userSnapshot.error}'),
                  );
                } else {
                  return FutureBuilder(
                    future: fetchUserData(userSnapshot.data!.docs),
                    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> userDataSnapshot) {
                      if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (userDataSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${userDataSnapshot.error}'),
                        );
                      } else {
                        userDataSnapshot.data!.sort((a, b) => b['count'].compareTo(a['count']));

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 50,
                            mainAxisSpacing: 50,
                            childAspectRatio: 2.0, 
                          ),
                          itemCount: userDataSnapshot.data!.length,
                          itemBuilder: (context, index) {
                            String email = userDataSnapshot.data![index]['email'];
                            int count = userDataSnapshot.data![index]['count'];

                            return GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                                child: Card(
                                  color: Color(0xFF3A1B0F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(' $email', style: TextStyle(color: Colors.white)),
                                        SizedBox(height: 8.0),
                                        Text('Booking Count: $count', style: TextStyle(color: Colors.white)),
                                        SizedBox(height: 8.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchUserData(List<QueryDocumentSnapshot> userDocs) async {
    List<Map<String, dynamic>> userDataList = [];

    for (DocumentSnapshot userDoc in userDocs) {
      String email = userDoc['email'];
      int count = await getBookingCount(userDoc.id);

      userDataList.add({
        'email': email,
        'count': count,
      });
    }

    return userDataList;
  }

  Future<int> getBookingCount(String userId) async {
    QuerySnapshot bookingSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).collection('bookedhotel').get();
    return bookingSnapshot.docs.length;
  }



}