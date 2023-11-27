import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  DatabaseReference _fallDataRef =
      FirebaseDatabase.instance.reference().child('fall_data');

  List<Map<dynamic, dynamic>> fallDataList = [];

  @override
  void initState() {
    super.initState();
    _loadFallData();
  }

  void _loadFallData() {
    _fallDataRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          fallDataList.add({
            'timestamp': value['timestamp'],
            'acceleration': value['acceleration'],
            'latitude': value['latitude'],
            'longitude': value['longitude'],
            'activity': value['activity'], // Agrega el campo 'activity'
          });
        });

        fallDataList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {});
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List Screen'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: fallDataList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5.0,
                child: ListTile(
                  title: Text(
                    'Aceleración: ${fallDataList[index]['acceleration'].toStringAsFixed(2)} m/s²',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timestamp: ${_formatTimestamp(fallDataList[index]['timestamp'])}',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Latitud: ${fallDataList[index]['latitude']}',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Longitud: ${fallDataList[index]['longitude']}',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: _getActivityCard(fallDataList[index]['activity']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  Widget _getActivityCard(String activity) {
    return Card(
      color: activity == 'De Pie' ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          activity,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
