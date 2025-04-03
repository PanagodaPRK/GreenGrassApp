import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String) onChanged;
  final int length;

  const OtpInputField({
    super.key,
    required this.onCompleted,
    required this.onChanged,
    this.length = 6,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );

    _focusNodes = List.generate(widget.length, (index) => FocusNode());

    _otpValues = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitInput(int index, String value) {
    if (value.isNotEmpty) {
      // If a digit is entered, move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // If last field, unfocus and trigger completed callback
        _focusNodes[index].unfocus();
        _checkOtpCompleted();
      }
    }

    // Update the OTP values
    setState(() {
      _otpValues[index] = value;
    });

    // Call onChanged callback
    widget.onChanged(_otpValues.join());
  }

  void _onKeyPress(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // If backspace is pressed and current field is empty, move focus to previous field
      if (event.logicalKey == LogicalKeyboardKey.backspace &&
          _controllers[index].text.isEmpty &&
          index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _checkOtpCompleted() {
    // Check if all fields are filled
    final isCompleted = _otpValues.every((value) => value.isNotEmpty);
    if (isCompleted) {
      widget.onCompleted(_otpValues.join());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 45,
          height: 55,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyPress(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.dividerDark,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.dividerDark,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.length <= 1) {
                  _onDigitInput(index, value);
                } else if (value.length > 1) {
                  // Handle paste of the whole OTP code
                  final otpValue = value.substring(0, widget.length);

                  for (int i = 0; i < widget.length; i++) {
                    if (i < otpValue.length) {
                      _controllers[i].text = otpValue[i];
                      _otpValues[i] = otpValue[i];
                    }
                  }

                  _focusNodes[index].unfocus();
                  _checkOtpCompleted();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
