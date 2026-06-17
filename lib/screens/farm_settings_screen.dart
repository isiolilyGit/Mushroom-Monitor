import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/farm.dart';
import '../providers/farm_provider.dart';
import '../services/api_service.dart';


class FarmSettingsScreen extends StatefulWidget {

  final Farm farm;

  const FarmSettingsScreen({
    super.key,
    required this.farm,
  });


  @override
  State<FarmSettingsScreen> createState() =>
      _FarmSettingsScreenState();

}



class _FarmSettingsScreenState extends State<FarmSettingsScreen> {


  late TextEditingController nameController;


  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;
  late List<TextEditingController> writeKeyControllers;



  @override
  void initState(){

    super.initState();


    nameController =
        TextEditingController(
          text: widget.farm.name,
        );


    minControllers =
        widget.farm.sensors.map(
          (s)=>TextEditingController(
            text:(s.minIdeal ?? 0).toString(),
          ),
        ).toList();



    maxControllers =
        widget.farm.sensors.map(
          (s)=>TextEditingController(
            text:(s.maxIdeal ?? 0).toString(),
          ),
        ).toList();



    writeKeyControllers =
        widget.farm.sensors.map(
          (s)=>TextEditingController(
            text:s.writeApiKey ?? "",
          ),
        ).toList();

  }





  Future<void> _save() async {


    final provider =
        context.read<FarmProvider>();



    final updatedFarm = Farm(

      id: widget.farm.id,

      name:
      nameController.text.trim(),

      startDate:
      widget.farm.startDate,

      sensors:
      widget.farm.sensors,

    );





    for(int i = 0;
        i < updatedFarm.sensors.length;
        i++){



      final sensor =
          updatedFarm.sensors[i];



      sensor.minIdeal =
          double.tryParse(
              minControllers[i].text);



      sensor.maxIdeal =
          double.tryParse(
              maxControllers[i].text);




      if(writeKeyControllers[i].text
          .trim()
          .isNotEmpty){

        sensor.writeApiKey =
            writeKeyControllers[i]
                .text
                .trim();

      }





      /*
       Update ThingSpeak if this sensor
       represents editable days.
      */


      if(sensor.label.toLowerCase()
          .contains("day")){


        if(sensor.writeApiKey == null ||
            sensor.writeApiKey!.isEmpty){

          ScaffoldMessenger.of(context)
              .showSnackBar(

              SnackBar(
                content:
                Text(
                  "Missing write API key for ${sensor.label}",
                ),
              )

          );


          continue;

        }




        await ThingSpeakApi.updateThingSpeakField(

          channelId:
          sensor.channelId,


          writeApiKey:
          sensor.writeApiKey!,


          field:
          sensor.fieldKey,


          value:
          minControllers[i].text,


        );


      }



    }




    await provider.updateFarm(updatedFarm);



    if(mounted){

      Navigator.pop(context);

    }

  }








  @override
  Widget build(BuildContext context){


    return Scaffold(

      appBar:
      AppBar(
        title:
        const Text("Farm Settings"),
      ),




      body:

      ListView(

        padding:
        const EdgeInsets.all(16),



        children:[



          TextField(

            controller:nameController,

            decoration:
            const InputDecoration(
              labelText:"Farm Name",
            ),

          ),



          const SizedBox(height:20),





          ...List.generate(

              widget.farm.sensors.length,

              (index){



                final sensor =
                widget.farm.sensors[index];



                return Card(

                  child:

                  Padding(

                    padding:
                    const EdgeInsets.all(12),



                    child:

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,



                      children:[



                        Text(

                          sensor.label,

                          style:
                          Theme.of(context)
                              .textTheme
                              .titleMedium,

                        ),




                        TextField(

                          controller:
                          writeKeyControllers[index],


                          decoration:
                          const InputDecoration(

                            labelText:
                            "Write API Key",

                          ),

                        ),




                        TextField(

                          controller:
                          minControllers[index],


                          keyboardType:
                          TextInputType.number,


                          decoration:
                          const InputDecoration(

                            labelText:
                            "Min Ideal",

                          ),

                        ),




                        TextField(

                          controller:
                          maxControllers[index],


                          keyboardType:
                          TextInputType.number,


                          decoration:
                          const InputDecoration(

                            labelText:
                            "Max Ideal",

                          ),

                        ),



                      ],


                    ),

                  ),

                );


              }

          ),




        ],


      ),





      bottomNavigationBar:

      Padding(

        padding:
        const EdgeInsets.all(16),


        child:

        ElevatedButton(

          onPressed:
          _save,


          child:
          const Text(
            "Save Settings",
          ),

        ),

      ),


    );


  }







  @override
  void dispose(){


    nameController.dispose();


    for(final c in minControllers){
      c.dispose();
    }


    for(final c in maxControllers){
      c.dispose();
    }


    for(final c in writeKeyControllers){
      c.dispose();
    }



    super.dispose();

  }


}