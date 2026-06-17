import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/farm.dart';
import '../services/api_service.dart';
import '../screens/farm_settings_screen.dart';
import '../screens/sensor_dashboard_screen.dart';

class FarmDashboardScreen extends StatefulWidget {
  final Farm farm;

  const FarmDashboardScreen({
    super.key,
    required this.farm,
  });

  @override
  State<FarmDashboardScreen> createState() =>
      _FarmDashboardScreenState();
}


class _FarmDashboardScreenState extends State<FarmDashboardScreen> {

  late Future<List<List<Map<String, dynamic>>>> _dataFuture;


  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllSensors();
  }


  double _safeDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0.0;
  }


  DateTime _safeDate(dynamic value) {

    final parsed = DateTime.tryParse(value.toString());

    return parsed?.toLocal() ?? DateTime.now();

  }


  Future<void> _refresh() async {

    setState(() {
      _dataFuture = _fetchAllSensors();
    });

  }



  Future<List<List<Map<String,dynamic>>>> _fetchAllSensors() async {

    final results = await Future.wait(

      widget.farm.sensors.map((sensor){

        return ThingSpeakApi.getFieldFeed(
          channelId: sensor.channelId,
          readApiKey: sensor.readApiKey,
          fieldKey: sensor.fieldKey,
          results: 200,
        );

      })

    );


    return results;

  }



  bool _isOutOfRange(
      double value,
      SensorSource sensor
      ){

    final min =
        sensor.minIdeal ?? double.negativeInfinity;

    final max =
        sensor.maxIdeal ?? double.infinity;


    return value < min || value > max;

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: Text(widget.farm.name),

        actions: [

          IconButton(

            icon: const Icon(Icons.settings),

            onPressed: () async {

              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      FarmSettingsScreen(
                        farm: widget.farm,
                      ),

                ),

              );


              setState(() {

                _dataFuture = _fetchAllSensors();

              });


            },

          ),

        ],

      ),



      body: RefreshIndicator(

        onRefresh: _refresh,


        child: FutureBuilder(

          future: _dataFuture,


          builder: (context, snapshot){


            if(snapshot.connectionState ==
                ConnectionState.waiting){

              return const Center(
                child: CircularProgressIndicator(),
              );

            }



            final data = snapshot.data ??
                <List<Map<String,dynamic>>>[];



            return ListView.builder(

              physics:
                  const AlwaysScrollableScrollPhysics(),


              padding:
                  const EdgeInsets.all(16),


              itemCount:
                  widget.farm.sensors.length,


              itemBuilder:(context,index){


                return _buildSensorCard(

                  widget.farm.sensors[index],

                  data[index],

                );


              },


            );


          },

        ),

      ),

    );


  }






  Widget _buildSensorCard(

      SensorSource sensor,

      List<Map<String,dynamic>> rawData

      ){



    if(rawData.isEmpty){

      return Card(

        child: Padding(

          padding: const EdgeInsets.all(16),

          child:
          Text("${sensor.label}: No data"),

        ),

      );

    }




    final points = rawData.map((entry){


      return {

        "time":
        _safeDate(entry["created_at"]),


        "value":
        _safeDouble(entry["value"]),


      };


    }).toList();




    points.sort((a,b)=>

        (a["time"] as DateTime)
            .compareTo(
            b["time"] as DateTime
        )

    );



    final values =
    points.map(
            (e)=>e["value"] as double
    ).toList();



    final spots = <FlSpot>[];



    for(int i=0;i<values.length;i++){


      spots.add(

        FlSpot(

          i.toDouble(),

          values[i],

        ),

      );


    }




    final latest = values.last;


    final isOut =
    _isOutOfRange(latest,sensor);



    final minY =
    values.reduce(
            (a,b)=>a<b?a:b
    );


    final maxY =
    values.reduce(
            (a,b)=>a>b?a:b
    );



    return InkWell(


      onTap:(){

        Navigator.push(

          context,

          MaterialPageRoute(

            builder:(_)=>
                SensorDashboardScreen(
                  sensor:sensor,
                ),

          ),

        );


      },



      child: Card(


        margin:
        const EdgeInsets.only(bottom:16),



        child: Padding(

          padding:
          const EdgeInsets.all(16),



          child:Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,



            children:[



              Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,


                children:[


                  Text(

                    sensor.label,

                    style:
                    Theme.of(context)
                        .textTheme
                        .titleMedium,

                  ),



                  Container(

                    padding:
                    const EdgeInsets.all(8),


                    decoration:
                    BoxDecoration(

                      color:
                      isOut
                          ? Colors.red
                          : Colors.green,


                      borderRadius:
                      BorderRadius.circular(10),

                    ),


                    child:Text(

                      "${latest.toStringAsFixed(1)} ${sensor.unit}",

                      style:
                      const TextStyle(
                        color:Colors.white,
                      ),

                    ),

                  )

                ],

              ),



              const SizedBox(height:20),




              SizedBox(

                height:220,


                child:LineChart(


                  LineChartData(


                    minY:minY-1,

                    maxY:maxY+1,


                    lineBarsData:[


                      LineChartBarData(

                        spots:spots,


                        isCurved:true,


                        barWidth:3,


                        color:
                        isOut
                            ? Colors.red
                            : Colors.green,


                        dotData:
                        const FlDotData(
                          show:false,
                        ),

                      )


                    ],


                  ),


                ),


              )



            ],


          ),

        ),

      ),

    );

  }

}