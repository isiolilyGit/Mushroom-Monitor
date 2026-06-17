import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/farm.dart';
import '../services/api_service.dart';


class SensorDashboardScreen extends StatefulWidget {

  final SensorSource sensor;

  const SensorDashboardScreen({
    super.key,
    required this.sensor,
  });


  @override
  State<SensorDashboardScreen> createState() =>
      _SensorDashboardScreenState();

}



class _SensorDashboardScreenState
    extends State<SensorDashboardScreen> {


  late Future<List<Map<String,dynamic>>> _dataFuture;



  @override
  void initState() {

    super.initState();

    _dataFuture = _loadData();

  }



  Future<List<Map<String,dynamic>>> _loadData() async {

    final data = await ThingSpeakApi.getFieldFeed(
      channelId: widget.sensor.channelId,
      readApiKey: widget.sensor.readApiKey,
      fieldKey: widget.sensor.fieldKey,
      results: 500,
    );

    final cutoff = DateTime.now().subtract(const Duration(hours: 6));

    return data.where((entry) {

      final time = DateTime.parse(entry['created_at']);

      return time.isAfter(cutoff);

    }).toList();

  }



  Future<void> _refresh() async {

    setState(() {

      _dataFuture = _loadData();

    });

  }



  bool _outOfRange(double value) {

    final min =
        widget.sensor.minIdeal ??
        double.negativeInfinity;


    final max =
        widget.sensor.maxIdeal ??
        double.infinity;


    return value < min || value > max;

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text(widget.sensor.label),
      ),


      body: RefreshIndicator(

        onRefresh: _refresh,


        child: FutureBuilder(

          future: _dataFuture,


          builder: (context, snapshot) {


            if(snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );

            }



            if(!snapshot.hasData ||
                snapshot.data!.isEmpty) {

              return const Center(
                child: Text(
                  "No sensor data available",
                ),
              );

            }



            final data =
                snapshot.data!;


            final values =
                data.map(
                  (e) {
                  return double.tryParse(
                    e['value']
                        .toString()
                  ) ?? 0;
          }).toList();
          debugPrint("VALUES: $values");



            final latest =
                values.last;

            final minValue = values.reduce((a,b) => a < b ? a : b);
            final maxValue = values.reduce((a,b) => a > b ? a : b);
            final padding = (maxValue - minValue) * 0.2;



            final spots =
                List.generate(
                  values.length,
                  (i) {

                    return FlSpot(
                      i.toDouble(),
                      values[i],
                    );

                  },
                );



            return ListView(

              physics:
              const AlwaysScrollableScrollPhysics(),


              padding:
              const EdgeInsets.all(16),


              children: [


                Card(

                  child: Padding(

                    padding:
                    const EdgeInsets.all(16),


                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,


                      children: [


                        Text(

                          "Current Reading",

                          style:
                          Theme.of(context)
                              .textTheme
                              .titleMedium,

                        ),



                        const SizedBox(height:10),



                        Text(

                          latest
                              .toStringAsFixed(2),

                          style:
                          const TextStyle(
                            fontSize:32,
                            fontWeight:
                            FontWeight.bold,
                          ),

                        ),



                        const SizedBox(height:10),



                        Text(

                          _outOfRange(latest)
                              ? "OUT OF RANGE"
                              : "Within Ideal Range",

                          style:

                          TextStyle(

                            color:

                            _outOfRange(latest)

                            ? Colors.red

                            : Colors.green,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ],

                    ),

                  ),

                ),



                const SizedBox(height:20),



                SizedBox(

                  height:300,


                  child: LineChart(

                    LineChartData(

                      minY: minValue - padding,
                      maxY: maxValue + padding,
                      
                      gridData:
                      const FlGridData(
                        show:true,
                      ),


                      borderData:
                      FlBorderData(
                        show:false,
                      ),



                      lineBarsData:[


                        LineChartBarData(

                          spots:spots,

                          isCurved:true,

                          barWidth:3,


                          color:

                          _outOfRange(latest)

                          ? Colors.red

                          : Colors.green,



                          dotData:
                          const FlDotData(
                            show:false,
                          ),

                        ),

                      ],


                    ),

                  ),

                ),


              ],

            );


          },


        ),

      ),

    );

  }

}