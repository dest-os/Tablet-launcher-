import 'package:flutter/material.dart';

class LiveCalendar extends StatefulWidget {
  const LiveCalendar({super.key});

  @override
  State<LiveCalendar> createState() => _LiveCalendarState();
}

class _LiveCalendarState extends State<LiveCalendar> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  final List<String> _monthNames = const [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  final List<String> _weekDays = const [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _displayedMonth = DateTime(
      now.year,
      now.month,
    );
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _selectDate(int day) {
    setState(() {
      _selectedDate = DateTime(
        _displayedMonth.year,
        _displayedMonth.month,
        day,
      );
    });
  }

  void _showYearPicker() {
    final currentYear = _displayedMonth.year;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF20252B),
          title: const Text(
            'Yıl Seç',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: 300,
            height: 350,
            child: ListView.builder(
              itemCount: 201,
              itemBuilder: (context, index) {
                final year = 1900 + index;
                final isSelected = year == currentYear;

                return ListTile(
                  title: Text(
                    '$year',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00BFFF)
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _displayedMonth = DateTime(
                        year,
                        _displayedMonth.month,
                      );

                      final maxDay = DateTime(
                        year,
                        _displayedMonth.month + 1,
                        0,
                      ).day;

                      if (_selectedDate.year == currentYear) {
                        _selectedDate = DateTime(
                          year,
                          _selectedDate.month,
                          _selectedDate.day > maxDay
                              ? maxDay
                              : _selectedDate.day,
                        );
                      }
                    });

                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  int _daysInMonth() {
    return DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
  }

  int _firstWeekday() {
    final weekday = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    ).weekday;

    return weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth();
    final firstWeekday = _firstWeekday();

    final totalCells = firstWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                color: Colors.white,
                iconSize: 22,
              ),
              GestureDetector(
                onTap: _showYearPicker,
                child: Text(
                  '${_monthNames[_displayedMonth.month - 1]} '
                  '${_displayedMonth.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                color: Colors.white,
                iconSize: 22,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: _weekDays.map(
              (day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 4),
          for (int row = 0; row < rowCount; row++)
            Row(
              children: List.generate(
                7,
                (column) {
                  final cellIndex = row * 7 + column;
                  final day = cellIndex - firstWeekday + 1;

                  if (day < 1 || day > daysInMonth) {
                    return const Expanded(
                      child: SizedBox(height: 30),
                    );
                  }

                  final isSelected =
                      _selectedDate.year == _displayedMonth.year &&
                      _selectedDate.month == _displayedMonth.month &&
                      _selectedDate.day == day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(day),
                      child: Container(
                        height: 30,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF00BFFF)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
