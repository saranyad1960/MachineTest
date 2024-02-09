import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:machinetest/profile_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
      '/user': (context) => ProfilePageRoute(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/user') {
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => ProfilePageRoute());
      }
      return null;
    },
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Tasks'),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            DropdownWidget(),
            SizedBox(height: 50),
            DependentSelectBoxes(),
            SizedBox(height: 50,),
            DisplayName(
              firstName: "George",
              secondName: "Bluth",
              prefix: "UserName: ",
              suffix: '',
            ),
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user', arguments: {'userId': 1});
              },
              child: Text('View User Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// Task 1
class DropdownWidget extends StatefulWidget {
  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      hint: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('More Actions'),
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['View', 'Edit', 'Send', 'Delete']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: value == 'Delete' ? TextStyle(color: Colors.red) : null,
          ),
        );
      }).toList(),
    );
  }
}


//Task 2
class DependentSelectBoxes extends StatefulWidget {
  @override
  _DependentSelectBoxesState createState() => _DependentSelectBoxesState();
}

class _DependentSelectBoxesState extends State<DependentSelectBoxes> {
  String? selectedCountry;
  String? selectedState;

  Map<String, List<String>> statesData = {
    'IN': ['KA', 'KL', 'TN', 'MH'],
    'US': ['AL', 'DE', 'GA'],
    'CA': ['ON', 'QC', 'BC'],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          value: selectedCountry,
          hint: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Country'),
          ),
          items: statesData.keys.map((String country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(country),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCountry = newValue;
              selectedState = null;
            });
          },
        ),
        SizedBox(width: 20),
        DropdownButton<String>(
          value: selectedState,
          hint: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('State'),
          ),
          items: (selectedCountry != null)
              ? statesData[selectedCountry]?.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(city),
              ),
            );
          }).toList()
              : [],
          onChanged: (String? newValue) {
            setState(() {
              selectedState = newValue;
            });
          },
        ),
      ],
    );
  }
}

// Task 3
class DisplayName extends StatelessWidget {
  final String firstName;
  final String secondName;
  final String prefix;
  final String suffix;

  DisplayName({
    required this.firstName,
    required this.secondName,
    required this.prefix,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Text(prefix + firstName +' '+ secondName + suffix,
    style: TextStyle(fontSize: 14,color: Colors.blue,fontWeight: FontWeight.w500),
    );
  }
}

// Task 4
class ProfileInfo extends StatefulWidget {
  final int userId;

  ProfileInfo({required this.userId});

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  late Future<Map<String, dynamic>> _userData;
  int? userId;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users/${widget.userId}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final userData = snapshot.data!;
          final String firstName = userData['data']['first_name'];
          final String lastName = userData['data']['last_name'];
          final String email = userData['data']['email'];
          final String avatarUrl = userData['data']['avatar'];
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2.0),
                ),
                padding: EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              SizedBox(width: 20),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayName(
                      firstName: firstName,
                      secondName: lastName,
                      prefix: '',
                      suffix: '',
                    ),
                    Text(email),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

