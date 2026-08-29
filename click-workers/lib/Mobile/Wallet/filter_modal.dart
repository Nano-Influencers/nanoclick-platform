import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final String selectedStatus;
  final TextEditingController minController;
  final TextEditingController maxController;
  final void Function(String) onStatusChange;

  const FilterModal({
    super.key,
    required this.selectedStatus,
    required this.minController,
    required this.maxController,
    required this.onStatusChange,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  DateTime? fromDate;
  DateTime? toDate;
  late TextEditingController dobEditingController1 = TextEditingController();
  late TextEditingController dobEditingController2 = TextEditingController();

  Future<void> _selectDate1(
      BuildContext context, void Function(VoidCallback) localSetState) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      localSetState(() {
        dobEditingController1.text = formattedDate;
        fromDate = pickedDate;
        // resets toDate if it's before new fromDate
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> _selectDate2(
      BuildContext context, void Function(VoidCallback) localSetState) async {
    if (fromDate == null) {
      // enforces selecting fromDate first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select 'From' date first")),
      );
      return;
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      localSetState(() {
        dobEditingController2.text = formattedDate;
        toDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: SafeArea(
        child: StatefulBuilder(builder: (context, localSetState) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Date Range",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Done",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate1(context, localSetState),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dobEditingController1,
                            validator: (val) =>
                                val!.isEmpty ? 'Fill out this field' : null,
                            readOnly: true, // prevent manua
                            decoration: InputDecoration(
                              hintText: "From",
                              suffix:
                                  const Icon(Icons.calendar_today, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate2(context, localSetState),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dobEditingController2,
                            validator: (val) =>
                                val!.isEmpty ? 'Fill out this field' : null,
                            readOnly: true, // prevent manua
                            decoration: InputDecoration(
                              hintText: "To",
                              suffix:
                                  const Icon(Icons.calendar_today, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Status",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 5,
                    children:
                        ["All", "Completed", "Pending", "Failed"].map((status) {
                      final isSelected = status == widget.selectedStatus;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (_) {
                          Navigator.of(context).pop();
                          widget.onStatusChange(status);
                        },
                        selectedColor: const Color(0xfff4cbbd),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xffff6533)
                              : const Color(0xffff6533),
                          fontWeight: FontWeight.bold,
                        ),
                        shape: const StadiumBorder(
                            side: BorderSide(color: Color(0xffff6533))),
                        backgroundColor: const Color(0xffeeeeee),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Amount Range",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.minController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.numbers),
                          hintText: 'Min',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: widget.maxController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.numbers),
                          hintText: 'Max',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
