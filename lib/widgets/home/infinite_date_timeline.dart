import 'package:flutter/material.dart';

class InfiniteDateTimeline extends StatefulWidget { 
  final Function(String) onDateSelected;

  InfiniteDateTimeline({super.key, required this.onDateSelected});

  @override
  _InfiniteDateTimelineState createState() => _InfiniteDateTimelineState();
}

class _InfiniteDateTimelineState extends State<InfiniteDateTimeline> {
  final List<DateTime> _dates = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialDates();
    _scrollController.addListener(_scrollListener);
  }

  void _loadInitialDates() {
  DateTime today = DateTime.now();

  // Inclui a data de hoje se for válida
  if (_isValidDate(today, allowToday: true)) {
    _dates.add(today);
  }

  for (int i = 1; i < 30; i++) {
    DateTime dateToAdd = today.add(Duration(days: i));
    if (_isValidDate(dateToAdd)) {
      _dates.add(dateToAdd);
    }
  }
}
  void _loadMoreDates() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      DateTime lastDate = _dates.isNotEmpty ? _dates.last : DateTime.now();
      for (int i = 1; i <= 10; i++) {
        DateTime dateToAdd = lastDate.add(Duration(days: i));
        if (_isValidDate(dateToAdd)) {
          _dates.add(dateToAdd);
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

bool _isValidDate(DateTime date, {bool allowToday = false}) {
  DateTime today = DateTime.now();
  bool isAfterToday = allowToday ? !date.isBefore(today) : date.isAfter(today);
  // Permite apenas segundas (1) e quartas (3)
  return isAfterToday && 
         (date.weekday == DateTime.monday || date.weekday == DateTime.wednesday);
}

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: _dates.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _dates.length) {
            return Center(child: CircularProgressIndicator());
          }
          DateTime date = _dates[index];
          String monthName = _getMonthName(date.month);
          String dayOfWeek = _getDayOfWeek(date.weekday);
      
          return InkWell(
            onTap: () {
              widget.onDateSelected("${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
            },
            splashColor: Colors.grey[300],
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(monthName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(date.day.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(dayOfWeek, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return monthNames[month - 1];
  }

  String _getDayOfWeek(int weekday) {
    const List<String> dayNames = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    return dayNames[weekday];
  }
}
