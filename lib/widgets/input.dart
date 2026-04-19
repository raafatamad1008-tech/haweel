import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final bool isScure;
  final int lineHeight;
  final String type; // text / date / time

  const Input({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    this.isScure = false,
    this.lineHeight = 1,
    this.type = "text",
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool isView = false;

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      widget.controller.text =
          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      widget.controller.text = pickedTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            maxLines: widget.lineHeight,
            obscureText: widget.isScure ? !isView : false,
             readOnly: widget.type != "text",
  showCursor: widget.type == "text",
  keyboardType: widget.type == "text"
      ? TextInputType.text
      : TextInputType.none,
            onTap: () {
              if (widget.type == "date") {
                pickDate();
              }

              if (widget.type == "time") {
                pickTime();
              }
            },
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(widget.icon, color: widget.iconColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.borderColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),

          if (widget.isScure)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  isView
                      ? FluentIcons.eye_off_24_regular
                      : FluentIcons.eye_24_regular,
                ),
                onPressed: () {
                  setState(() {
                    isView = !isView;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}