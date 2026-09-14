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
              itemCount: 101,
              itemBuilder: (context, index) {
                final year = currentYear - 50 + index;
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

                      if (_selectedDate.year == currentYear) {
                        _selectedDate = DateTime(
                          year,
                          _selectedDate.month,
                          _selectedDate.day,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AY / YIL BAŞLIĞI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
                icon: const Icon(Icons.chevron_right),
                color: Colors.white,
                iconSize: 22,
              ),
            ],
          ),

          const SizedBox(height: 7),

          // HAFTANIN GÜNLERİ
          Row(
            children: _weekDays.map(
              (day) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    child: Center(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 7),

          // TAKVİM GÜNLERİ
          for (int row = 0; row < rowCount; row++)
            Row(
              children: List.generate(
                7,
                (column) {
                  final cellIndex = row * 7 + column;
                  final day = cellIndex - firstWeekday + 1;

                  if (day < 1 || day > daysInMonth) {
                    return const Expanded(
                      child: SizedBox(
                        height: 31,
                      ),
                    );
                  }

                  final isSelected =
                      _selectedDate.year == _displayedMonth.year &&
                      _selectedDate.month == _displayedMonth.month &&
                      _selectedDate.day == day;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      child: GestureDetector(
                        onTap: () => _selectDate(day),
                        child: Container(
                          height: 31,
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
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
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
