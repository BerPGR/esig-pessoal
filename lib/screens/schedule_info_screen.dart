import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esigp/themes/app_colors.dart';
import 'package:esigp/themes/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleInfoScreen extends StatefulWidget {
  const ScheduleInfoScreen({super.key, required this.docId, required this.appointmentDetails});

  final String docId;
  final Map<String, dynamic> appointmentDetails; 

  @override
  State<ScheduleInfoScreen> createState() => _ScheduleInfoScreenState();
}

class _ScheduleInfoScreenState extends State<ScheduleInfoScreen> {
  String formatDate(String date, String hour) {
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat("dd/MM");
    final formattedDate = formatter.format(parsedDate);

    return "${formattedDate} - ${hour}";
  }

  String formatSintomas(List doencas) {
    return doencas.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    print(widget.docId);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(widget.appointmentDetails['user_id']).get(),
                builder: (ctx, snapshot) {
                  print(snapshot.data);
                  if (snapshot.hasError) {
                    return const Text('Erro ao carregar dados do cliente');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasData) {
                    var clientData = snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(CupertinoIcons.chevron_back)
                              ),
                              Text("Agendamento", style: Styles.normalBold,)
                            ],
                          )
                        ),
                        Padding(padding: EdgeInsets.only(top: 16), child: Text(clientData['name'] ?? '', style: Styles.normalBold,),),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(formatDate(widget.appointmentDetails['date'], widget.appointmentDetails['hour'])),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text("Sintomas/Doenças", style: Styles.normalBold,),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            formatSintomas(widget.appointmentDetails['reason']),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text("Descrição", style: Styles.normalBold,),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            (widget.appointmentDetails['description']),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: 250,),
                        SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.white,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                  color: ColorPalette.darkGreen,
                                  width: 2
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance.collection('appointments').doc(widget.docId).delete()
                              .then((_) => {
                                Navigator.pop(context)
                              });
                            },
                            child: Text(
                              "Cancelar Consulta",
                              style: Styles.normalBold.merge(
                                TextStyle(color: ColorPalette.darkGreen),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12,),
                        SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.darkGreen,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Editar Consulta",
                              style: Styles.normalBold.merge(
                                TextStyle(color: ColorPalette.white),
                              ),
                            ),
                          ),
                        ),
                      ]
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }
              )
            ],
          )
        )
      ),
    );
  }
}