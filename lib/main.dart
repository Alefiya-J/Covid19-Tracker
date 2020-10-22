import 'package:covidtracker/searchpage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid-19 Tracker',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map worldwide = {};
  Map graph = {};
  getData() async {
    var response = await Dio().get('https://disease.sh/v3/covid-19/all');
    return response.data;
  }

  getGraph() async {
    var response =
        await Dio().get('https://disease.sh/v3/covid-19/historical/all');
    return response.data;
  }

  @override
  @override
  void initState() {
    getData().then((data) {
      setState(() {
        worldwide = data;
      });
    });
    getGraph().then((data) {
      setState(() {
        graph = data;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[400],
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            ClipPath(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/undraw_world_9iqb.png',
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Worldwide Cases',
                            style: TextStyle(
                              color: Colors.teal[400],
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            NumberFormat('###,###,###')
                                .format(worldwide['cases'] ?? 0)
                                .toString(),
                            style: TextStyle(
                              color: Colors.teal[00],
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Last Updated: ' +
                                DateFormat.yMMMMd().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    worldwide['updated'] ??
                                        DateTime.now().millisecondsSinceEpoch,
                                  ),
                                ),
                            style: TextStyle(
                              color: Colors.teal[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              clipper: CustomClipPath(),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'COVID-19 TRACKER',
                style: TextStyle(
                  color: Colors.teal[500],
                  fontSize: 26,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.search),
                color: Colors.teal[500],
                iconSize: 28,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ),
                  );
                },
              ),
            ),
            graph.isNotEmpty
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    top: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        CardBox(
                          'Active',
                          worldwide['active'] ?? 0,
                          graph['cases'],
                        ),
                        CardBox(
                          'Recovered',
                          worldwide['recovered'] ?? 0,
                          graph['recovered'],
                        ),
                        CardBox(
                          'Deaths',
                          worldwide['deaths'] ?? 0,
                          graph['deaths'],
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CardBox extends StatefulWidget {
  final String title;
  final int stat;
  final Map graphData;

  CardBox(this.title, this.stat, this.graphData);

  @override
  _CardBoxState createState() => _CardBoxState();
}

class _CardBoxState extends State<CardBox> {
  List<double> data = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.graphData.forEach((key, value) => data.add(value.toDouble()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(3.0, 4.0),
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.teal[50],
                Colors.white,
                Colors.teal[50],
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.teal[400],
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          NumberFormat('###,###,###')
                              .format(widget.stat)
                              .toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 300,
                    child: data.isNotEmpty
                        ? Sparkline(
                            data: data,
                            lineWidth: 3,
                            lineColor: Colors.teal[800],
                            fillMode: FillMode.below,
                            fillGradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.teal[400],
                                Colors.teal[100],
                              ],
                            ),
                          )
                        : CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Colors.teal[400],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
