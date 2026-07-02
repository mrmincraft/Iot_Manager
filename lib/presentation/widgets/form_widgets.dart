import 'package:flutter/material.dart';

/// Custom form text field
class FormTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? onSuffixIconPressed;

  const FormTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey[100] : null,
        ),
      ),
    );
  }
}

/// Custom form dropdown field
class FormDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const FormDropdown({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FormDropdown<T>> createState() => _FormDropdownState<T>();
}

class _FormDropdownState<T> extends State<FormDropdown<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: _selectedValue,
        items: widget.items,
        onChanged: widget.enabled
            ? (value) {
                setState(() => _selectedValue = value);
                widget.onChanged?.call(value);
              }
            : null,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: !widget.enabled,
          fillColor: !widget.enabled ? Colors.grey[100] : null,
        ),
      ),
    );
  }
}

/// Custom form checkbox
class FormCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool?)? onChanged;
  final bool enabled;

  const FormCheckbox({
    Key? key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: enabled ? onChanged : null,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

/// Custom form slider
class FormSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final void Function(double)? onChanged;
  final bool enabled;

  const FormSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FormSlider> createState() => _FormSliderState();
}

class _FormSliderState extends State<FormSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _currentValue.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: widget.enabled
                ? (value) {
                    setState(() => _currentValue = value);
                    widget.onChanged?.call(value);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// Custom form date picker
class FormDatePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final void Function(DateTime)? onDateSelected;
  final bool enabled;

  const FormDatePicker({
    Key? key,
    required this.label,
    this.initialDate,
    this.onDateSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<FormDatePicker> {
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            _selectedDate?.toString().split(' ')[0] ?? 'Select date',
          ),
        ),
      ),
    );
  }
}
