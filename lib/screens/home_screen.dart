import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esigp/screens/schedule_info_screen.dart';
import 'package:esigp/themes/app_colors.dart';
import 'package:esigp/themes/app_text_styles.dart';
import 'package:esigp/widgets/home/infinite_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DateTime _focusDate = DateTime.now();
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

  String formatarData(String dataString)  {
    final dateTime = DateTime.parse(dataString);
 
    final formatter = DateFormat.yMMMMd('pt_BR');
    final formattedDate = formatter.format(dateTime);
    var finaD = formattedDate.split(" ");
    finaD[2] = finaD[2][0].toUpperCase() + finaD[2].substring(1);

    final dayOfWeek = DateFormat.EEEE('pt_BR').format(dateTime);

    return '${dayOfWeek[0].toUpperCase()+dayOfWeek.substring(1)}, ${finaD.sublist(0, 3).join(" ")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: Colors.black,)),
        ],
        backgroundColor: ColorPalette.white,
        elevation: 1,
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
                child: InfiniteDateTimeline(selectedDate: _selectedDate,)),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('appointments').snapshots(), 
                builder: (ctx, snapshot) {
                  if(snapshot.hasError) {
                    return const Text('Erro ao carregar agendamentos');
                  }

                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if(snapshot.hasData) {
                    var documents = snapshot.data!.docs;

                    List<Widget> appointmentWidgets = [];
        
                    for (var detail in documents) {
                      String docid = detail.id;
                      appointmentWidgets.add(
                        InkWell(
                          splashColor: Colors.blueGrey[400],
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ScheduleInfoScreen(docId: docid, appointmentDetails: detail.data() as Map<String, dynamic>,)));
                          },
                          child: SizedBox(
                            height: 94,
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20))
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
                                          Text(formatarData(detail['date']), style: Styles.normal.merge(TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                                          Text(detail['hour'], style: Styles.normal.merge(TextStyle(fontSize: 10, fontWeight: FontWeight.w100))),
                                          const Spacer(),
                                          Text("Agendamento", style: Styles.normal.merge(TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Color(0xff797979))))
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
              )
            ]
          ),
        ),
      ),
    );
  }
}