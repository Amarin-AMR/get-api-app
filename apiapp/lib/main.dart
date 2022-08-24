import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('http://159.65.2.88/api/predict'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
    //var jsonString = response.body;
    //var jsonMap = jsonDecode(jsonString);
    //print(jsonMap);
    //var userModel = Album.fromJson(jsonMap[1]);
    //return userModel;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  Album({
    required this.date,
    required this.data,
    required this.accuracy,
    required this.totalCase,
    required this.predictTomorrow,
    required this.todayCase,
  });
  late final String date;
  late final Data data;
  late final int accuracy;
  late final int totalCase;
  late final int predictTomorrow;
  late final int todayCase;

  Album.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    data = Data.fromJson(json['data']);
    accuracy = json['accuracy'];
    totalCase = json['totalCase'];
    predictTomorrow = json['predictTomorrow'];
    todayCase = json['todayCase'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['date'] = date;
    _data['data'] = data.toJson();
    _data['accuracy'] = accuracy;
    _data['totalCase'] = totalCase;
    _data['predictTomorrow'] = predictTomorrow;
    _data['todayCase'] = todayCase;
    return _data;
  }
}

class Data {
  Data({
    required this.date,
    required this.real,
    required this.forecast,
  });
  late final List<String> date;
  late final List<int?> real;
  late final List<int?> forecast;

  Data.fromJson(Map<String, dynamic> json) {
    date = List.castFrom<dynamic, String>(json['date']);
    real = List.castFrom<dynamic, int?>(json['real']);
    forecast = List.castFrom<dynamic, int?>(json['forecast']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['real'] = real;
    data['forecast'] = forecast;
    return data;
  }
}

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Fetch Data Example',
  //     theme: ThemeData(
  //       primarySwatch: Colors.blue,
  //     ),
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Fetch Data Example'),
  //       ),
  //       body: Center(
  //         child: FutureBuilder<Album>(
  //           future: futureAlbum,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               //print(snapshot.data!.data.date);

  //                var item = snapshot.data!.data.forecast;
  //                for(var i =0;i<item.length;i++){
  //                  if(item[i] == null){
  //                    item[i] = 0;
  //                  }
  //                }
  //                return Text(item.toString());

  //             } else if (snapshot.hasError) {
  //               return Text('${snapshot.error}');
  //             }

  //             // By default, show a loading spinner.
  //             return const CircularProgressIndicator();
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: Column(children: [
          FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //print(snapshot.data!.data.date);
                var item = snapshot.data!.data.forecast;
                for (var i = 0; i < item.length; i++) {
                  if (item[i] == null) {
                    item[i] = 0;
                  }
                }
                var item2 = snapshot.data!.data.real;
                for (var i = 0; i < item2.length; i++) {
                  if (item2[i] == null) {
                    item2[i] = 0;
                  }
                }
                
                List<_SalesData> data = [];
                List<_SalesData> data2 = [];
                for (var i = 0; i < 20; i++) {
                  data.add( _SalesData(snapshot.data!.data.date[i], item[i]!.toInt()),);
                  data2.add( _SalesData(snapshot.data!.data.date[i], item2[i]!.toInt()),);
                }
                return SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(text: 'Test'),
                    // Enable legend
                    legend: Legend(isVisible: true),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_SalesData, String>>[
                      LineSeries<_SalesData, String>(
                          dataSource: data,
                          xValueMapper: (_SalesData sales, _) => sales.year,
                          yValueMapper: (_SalesData sales, _) => sales.sales,
                          name: 'forecast',
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: true)),
                                                LineSeries<_SalesData, String>(
                          dataSource: data2,
                          xValueMapper: (_SalesData sales, _) => sales.year,
                          yValueMapper: (_SalesData sales, _) => sales.sales,
                          name: 'real',
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: true)),
                    ]);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          //Initialize the chart widget

          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     //Initialize the spark charts widget
          //     child: SfSparkLineChart.custom(
          //       //Enable the trackball
          //       trackball: SparkChartTrackball(
          //           activationMode: SparkChartActivationMode.tap),
          //       //Enable marker
          //       marker: SparkChartMarker(
          //           displayMode: SparkChartMarkerDisplayMode.all),
          //       //Enable data label
          //       labelDisplayMode: SparkChartLabelDisplayMode.all,
          //       xValueMapper: (int index) => data[index].year,
          //       yValueMapper: (int index) => data[index].sales,
          //       dataCount: 5,
          //     ),
          //   ),
          // )
        ]));
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final int sales;
}
