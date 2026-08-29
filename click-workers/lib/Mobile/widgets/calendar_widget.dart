import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomCheckInCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime createdOn;
  final ValueChanged<DateTime> onPageChanged;
  final Set<String> checkinDates;
  final bool loadingCheckins;

  const CustomCheckInCalendar({
    super.key,
    required this.focusedDay,
    required this.loadingCheckins,
    required this.checkinDates,
    required this.onPageChanged,
    required this.createdOn,
  });

  @override
  State<CustomCheckInCalendar> createState() => CustomCheckInCalendarState();
}

class CustomCheckInCalendarState extends State<CustomCheckInCalendar> {
  final DateTime _firstDay = DateTime.utc(2015, 1, 1);
  final DateTime _lastDay = DateTime.utc(2025, 12, 31);
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String _dateKey(DateTime d) =>
      _dateFormat.format(DateTime(d.year, d.month, d.day));

  DateTime toDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  int compareByMonth(DateTime a, DateTime b) {
    if (a.year == b.year) {
      return a.month.compareTo(b.month); // -1, 0, or 1
    } else {
      return a.year.compareTo(b.year); // compare year first
    }
  }

  bool isBeforeByMonth(DateTime a, DateTime b) {
    return compareByMonth(a, b) < 0;
  }

  bool isAfterByMonth(DateTime a, DateTime b) {
    return compareByMonth(a, b) > 0;
  }

  bool isSameMonth(DateTime a, DateTime b) {
    return compareByMonth(a, b) == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left arrow area (outside the calendar)
                  SizedBox(
                    width: 8.w,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 32, color: Color(0xff606060)),
                        onPressed:
                            isSameMonth(widget.focusedDay, widget.createdOn)
                                ? null
                                : () {
                                    final newDay = DateTime(
                                      widget.focusedDay.year,
                                      widget.focusedDay.month - 1,
                                      1,
                                    );
                                    widget.onPageChanged(newDay);
                                  },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Stack(
                        children: [
                          TableCalendar(
                              firstDay: _firstDay,
                              lastDay: _lastDay,
                              focusedDay: widget.focusedDay,
                              headerVisible: false,
                              daysOfWeekVisible: false,
                              calendarStyle: const CalendarStyle(
                                outsideDaysVisible: true,
                                defaultTextStyle:
                                    TextStyle(color: Colors.black),
                                weekendTextStyle:
                                    TextStyle(color: Colors.black),
                                todayDecoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  return _buildDay(day);
                                },
                                todayBuilder: (context, day, focusedDay) {
                                  return _buildDay(day, forceStatus: "today");
                                },
                                outsideBuilder: (context, day, focusedDay) {
                                  return Center(
                                    child: Text(
                                      "${day.day}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                              onPageChanged: widget.onPageChanged),
                          // 👇 Overlay the grid lines on top of the calendar
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final gridWidth = constraints.maxWidth;
                                final gridHeight = constraints.maxHeight;

                                // figure out how many weeks (rows) this month needs
                                final firstOfMonth = DateTime(
                                    widget.focusedDay.year,
                                    widget.focusedDay.month,
                                    1);
                                final daysInMonth = DateUtils.getDaysInMonth(
                                    widget.focusedDay.year,
                                    widget.focusedDay.month);
                                final firstIndex =
                                    firstOfMonth.weekday % 7; // sunday=0
                                final rows =
                                    ((firstIndex + daysInMonth) / 7).ceil();

                                final cellWidth = gridWidth / 7;
                                final cellHeight = gridHeight / rows;

                                return CustomPaint(
                                  painter: _GridPainter(
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight,
                                    rows: rows,
                                    columns: 7,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right arrow area (outside the calendar)
                  SizedBox(
                    width: 8.w, // adjust width to taste
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 32, color: Color(0xff606060)),
                        onPressed:
                            isSameMonth(widget.focusedDay, DateTime.now())
                                ? null
                                : () {
                                    final newDay = DateTime(
                                      widget.focusedDay.year,
                                      widget.focusedDay.month + 1,
                                      1,
                                    );
                                    widget.onPageChanged(newDay);
                                  },
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.loadingCheckins)
                const Positioned.fill(
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.grey)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Custom day cell builder
  Widget _buildDay(DateTime day, {String? forceStatus}) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(day.year, day.month, day.day);

    final isFuture = normalizedDay.isAfter(normalizedToday);

    // 1. Outside current month → plain grey text
    if (day.month != widget.focusedDay.month) {
      return Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    //if it's before the user account was created
    if (toDateOnly(day).isBefore(toDateOnly(widget.createdOn))) {
      return Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    // 2. If it's today (and inside the current month) → ash circle
    if (normalizedDay == normalizedToday) {
      return Container(
        alignment: Alignment.center,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.grey, // ash background
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 3. Future days = plain black
    if (isFuture) {
      return Center(
        child: Text(
          "${day.day}",
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    // 4. Past/current days = red or green
    final key = _dateKey(day);
    final bool exists = widget.checkinDates.contains(key);

    final bg = exists ? Colors.green : Colors.red;
    const textColor = Colors.white;

    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double cellWidth;
  final double cellHeight;
  final int rows;
  final int columns;

  _GridPainter({
    required this.cellWidth,
    required this.cellHeight,
    required this.rows,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade300 // 👈 just line color
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke; // 👈 only draw strokes, no fill

    final path = Path();

    // vertical lines
    for (int c = 1; c < columns; c++) {
      final dx = c * cellWidth;
      path.moveTo(dx, 0);
      path.lineTo(dx, rows * cellHeight);
    }

    // horizontal lines
    for (int r = 1; r < rows; r++) {
      final dy = r * cellHeight;
      path.moveTo(0, dy);
      path.lineTo(columns * cellWidth, dy);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
