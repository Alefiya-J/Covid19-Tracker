import 'package:covidtracker/Country.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List countries = [];
  List filteredCountries = [];
  bool isSearching = false;
  TextEditingController controller;
  getCountries() async {
    var response = await Dio().get('https://disease.sh/v3/covid-19/countries');
    return response.data;
  }

  @override
  void initState() {
    getCountries().then((data) {
      setState(() {
        countries = filteredCountries = data;
      });
    });

    controller = TextEditingController(text: '');
    super.initState();
  }

  void filterCountries(value) {
    setState(() {
      filteredCountries = countries
          .where((country) =>
              country['country'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 248, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        elevation: 0,
        centerTitle: true,
        title: TextField(
          controller: controller,
          onChanged: (value) {
            filterCountries(value);
          },
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintText: "Search country here",
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  controller.clear();
                  isSearching = false;
                  filteredCountries = countries;
                });
              })
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.all(8),
        child: filteredCountries.length > 0
            ? ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              Country(filteredCountries[index])));
                    },
                    child: Card(
                      elevation: 3,
                      shadowColor: Colors.teal[400],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2,
                                  spreadRadius: 1),
                            ],
                            gradient: LinearGradient(
                                colors: [
                                  Colors.teal[50],
                                  Colors.white,
                                  Colors.teal[50],
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight)),
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              child: Image.network(
                                filteredCountries[index]['countryInfo']['flag'],
                              ),
                            ),
                            title: Text(
                              filteredCountries[index]['country'],
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.teal[400],
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: CircularProgressIndicator(
                //  backgroundColor: Colors.teal[400],
                valueColor: AlwaysStoppedAnimation(Colors.teal[400]),
              )),
      ),
    );
  }
}
