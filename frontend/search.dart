import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> recentSearches = [
    {
      'name': 'Sutarnthip Luangthip',
      'imageUrl': 'https://via.placeholder.com/50',
    },
    {
      'name': 'Siradanai Ektananjit',
      'imageUrl': 'https://via.placeholder.com/50',
    },
    {
      'name': 'Kornwisarut Supataravanich',
      'imageUrl': 'https://via.placeholder.com/50',
    },
    {
      'name': 'Kittisak Yamdee',
      'imageUrl': 'https://via.placeholder.com/50',
    },
    {
      'name': 'Yurikurami Puttachat',
      'imageUrl': 'https://via.placeholder.com/50',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[100],
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Find',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: เพิ่มโค้ดค้นหา
            },
          ),
        ],
      ),
      body: Container(
        // color: Colors.lightBlueAccent[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  final search = recentSearches[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(search['imageUrl']),
                    ),
                    title: Text(search['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          recentSearches.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // TODO: เพิ่ม Keyboard และ Microphone
          ],
        ),
      ),
    );
  }
}