import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esigp/screens/schedule_info_screen.dart';
import 'package:esigp/themes/app_colors.dart';
import 'package:esigp/themes/app_text_styles.dart';
import 'package:esigp/widgets/home/infinite_date_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DateTime _focusDate = DateTime.now();
    late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getNextValidDate(DateTime.now());
  }

  String _getNextValidDate(DateTime date) {
    while (_isDisabled(date)) {
      date = date.add(const Duration(days: 1));
    }
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  bool _isDisabled(DateTime date) {
    return date.weekday == DateTime.sunday ||
           date.weekday == DateTime.tuesday ||
           date.weekday == DateTime.thursday ||
           date.weekday == DateTime.friday ||
           date.weekday == DateTime.saturday;
  }

  void _updateSelectedDate(String newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  String formatarData(String dataString)  {
    final dateTime = DateTime.parse(dataString);
 
    final formatter = DateFormat.yMMMMd('pt_BR');
    final formattedDate = formatter.format(dateTime);
    var finaD = formattedDate.split(" ");
    finaD[2] = finaD[2][0].toUpperCase() + finaD[2].substring(1);

    final dayOfWeek = DateFormat.EEEE('pt_BR').format(dateTime);

    return dayOfWeek[0].toUpperCase()+dayOfWeek.substring(1);
  }

  String formatarDataAgendamento(String dataString) {
    final dateTime = DateTime.parse(dataString);
 
    final formatter = DateFormat.yMMMMd('pt_BR');
    final formattedDate = formatter.format(dateTime);
    var finaD = formattedDate.split(" ");
    finaD[2] = finaD[2][0].toUpperCase() + finaD[2].substring(1);

    return 'Agendamentos de ${finaD.sublist(0, 3).join(" ")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: Colors.black,)),
        ],
        backgroundColor: ColorPalette.white,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12,),
              
              const Text('Dias de agendamento', style: Styles.normalBold,),

              SizedBox(
                height: 130,
                child: InfiniteDateTimeline(onDateSelected: _updateSelectedDate,)),

              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(formatarDataAgendamento(_selectedDate), style: Styles.normalBold,),
              ),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('appointments').where('date', isEqualTo: _selectedDate).where('isAppointmentFinished', isEqualTo: false).snapshots(), 
                builder: (ctx, snapshot) {
                  if(snapshot.hasError) {
                    return const Text('Erro ao carregar agendamentos');
                  }

                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if(snapshot.hasData) {
                    var documents = snapshot.data!.docs;

                    if (documents.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(child: Text('Nenhum agendamento para esse dia')),
                      );
                    }

                    List<Widget> appointmentWidgets = [];
        
                    for (var detail in documents) {
                      String docid = detail.id;
                      appointmentWidgets.add(
                        InkWell(
                          splashColor: Colors.blueGrey[400],
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ScheduleInfoScreen(docId: docid, appointmentDetails: detail.data(),)));
                          },
                          child: SizedBox(
                            height: 94,
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: ColorPalette.darkGreen
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<String>(
                                            future: getAppointmentUser(detail['user_id']), // O Future que está sendo esperado
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return SizedBox(
                                                  width: MediaQuery.of(ctx).size.width * 0.5,
                                                  child: const LinearProgressIndicator()
                                                ); // Mostra um indicador de carregamento enquanto o Future está pendente

                                              } else if (snapshot.hasError) {
                                                return const Text('Erro ao carregar o nome'); // Mostra uma mensagem de erro
                                              } else if (snapshot.hasData) {
                                                return Text(snapshot.data ?? '', style: Styles.normal.merge(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))); // Exibe o nome do usuário
                                              } else {
                                                return const Text('Nenhum dado disponível'); // Caso o Future não tenha dados
                                              }
                                            },
                                          ),
                                          Text(detail['hour'], style: Styles.normal.merge(const TextStyle(fontSize: 10, fontWeight: FontWeight.w100))),
                                          const Spacer(),
                                          Text("Agendamento", style: Styles.normal.merge(const TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Color(0xff797979))))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    }
        
                    return Column(
                      children: appointmentWidgets,
                    );
                  }

                  return const Text('Carregando...');
                }
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  height: 65,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkGreen,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    onPressed: () {
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ver agendamentos",
                          style: Styles.normalBold.merge(
                            const TextStyle(color: ColorPalette.white),
                          ),
                        ),
                        const Icon(CupertinoIcons.arrow_right, color: ColorPalette.white,)
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
  
  Future<String> getAppointmentUser(String clientId) async {
    DocumentSnapshot docRef = await FirebaseFirestore.instance.collection('users').doc(clientId).get();
    if (docRef.exists) {
      print(docRef.data());
      Map<String, dynamic> data = docRef.data() as Map<String, dynamic>;
      return data['name'];
    }
    return '';
  }
}