import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:intl/intl.dart';

class Country extends StatefulWidget {
  final Map country;
  Country(this.country);

  @override
  _CountryState createState() => _CountryState();
}

class _CountryState extends State<Country> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.country['country'],
          style: TextStyle(fontSize: 24),
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(child: Text('Cases', style: TextStyle(fontSize: 20))),
            Tab(child: Text('Recoverd', style: TextStyle(fontSize: 20))),
            Tab(child: Text('Deaths', style: TextStyle(fontSize: 20))),
          ],
        ),
      ),
      body: TabBarView(controller: tabController, children: [
        TabBody(widget.country, 'cases'),
        TabBody(widget.country, 'recovered'),
        TabBody(widget.country, 'deaths'),
      ]),
    );
  }
}

class TabBody extends StatefulWidget {
  final Map country;
  final String mode;
  TabBody(this.country, this.mode);

  @override
  _TabBodyState createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  getData() async {
    try {
      var response = await Dio().get(
          'https://disease.sh/v3/covid-19/historical/${widget.country['country']}?lastdays=$span');
      // .then((value) => value.data)
      // .catchError((e) => throw Exception());
      return response.data;
    } catch (e) {
      return null;
    }
  }

  String span = 'all';

  List<double> date = [];
  @override
  void initState() {
    setData();
    super.initState();
  }

  void setData() {
    getData().then((data) {
      setState(() {
        if (data != null) {
          data['timeline'][widget.mode]
              .forEach((k, v) => date.add(v.toDouble()));
        } else {
          date = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String today =
        'today${widget.mode[0].toUpperCase()}${widget.mode.substring(1)}';
    print(today);
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.teal[800],
                            offset: Offset(3.0, 4.0),
                            blurRadius: 1,
                            spreadRadius: 1),
                      ],
                      gradient: LinearGradient(
                          colors: [
                            Colors.teal[100],
                            Colors.teal[50],
                            Colors.teal[100],
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Total ${widget.mode}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.teal[400]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          NumberFormat('###,###,###')
                              .format(widget.country[widget.mode])
                              .toString(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.teal[800],
                            offset: Offset(3.0, 4.0),
                            blurRadius: 1,
                            spreadRadius: 1),
                      ],
                      gradient: LinearGradient(
                          colors: [
                            Colors.teal[100],
                            Colors.teal[50],
                            Colors.teal[100],
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Today ${widget.mode}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal[400]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          NumberFormat('###,###,###')
                              .format(widget.country[today])
                              .toString(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            // flex: 1,
            child: Container(
              height: 50,
              child: ListView(
                // itemExtent: 50,
                scrollDirection: Axis.horizontal,
                children: List.from(['All', 15, 30, 60, 100])
                    .map(
                      (day) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          label: Text(
                              '${day.toString().toLowerCase() != 'all' ? 'Last ' : ''}$day days'),
                          labelStyle: TextStyle(
                            color: day.toString().toLowerCase() == span
                                ? Colors.white 
                                : Colors.black,
                          ),
                          selected: day.toString().toLowerCase() == span,
                          onSelected: (bool s) => setState(() {
                            span = day.toString().toLowerCase();
                            date.clear();
                            setData();
                          }),
                          selectedColor: Colors.teal[400],
                          backgroundColor: Colors.teal[100],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Expanded(
              flex: 3,
              child: date != null
                  ? Stack(
                      alignment: Alignment.center,
                      overflow: Overflow.visible,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          height: MediaQuery.of(context).size.height * 0.40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: Colors.teal[900], width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.teal[100],
                                  offset: Offset(4.0, 4.0),
                                  blurRadius: 1,
                                  spreadRadius: 1),
                            ],
                            gradient: LinearGradient(
                                colors: [Colors.white, Colors.teal[50]],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight),
                          ),
                          child: Center(
                            child: date.isNotEmpty
                                ? Sparkline(
                                    data: date,
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
                        Positioned(
                          top: 10,
                          left: 35,
                          child: Text(
                            '${widget.mode}'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.teal[500],
                              fontSize: 24,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -25,
                          left: MediaQuery.of(context).size.width / 2 - 40,
                          child: Text(
                            'Days',
                            style: TextStyle(
                              color: Colors.teal[500],
                              fontSize: 20,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 180,
                          left: widget.mode == 'recovered' ? -70 : -55,
                          child: Transform.rotate(
                            angle: -pi / 2,
                            child: Text(
                              'No. of ${widget.mode}',
                              style: TextStyle(
                                color: Colors.teal[500],
                                fontSize: 20,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.center,
                      height: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.info_outline),
                          Text(
                            '  No data available!',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
