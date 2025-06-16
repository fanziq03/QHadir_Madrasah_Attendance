import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String title;
  final String hint;
  final double? height;
  final double? width;
  final int? maxLines;
  final TextEditingController? controller;
  final Widget? widget;
  final bool readOnly;
  final bool hasBorder;
  final Color titleColor;
  final Color hintColor;
  final Color containerColor;
  final bool obscureText; // Add this parameter
  final VoidCallback? onToggleObscureText; // Add this parameter
  final String? Function(String?)? validator;

  const InputField({
    Key? key,
    required this.title,
    required this.hint,
    this.height,
    this.width,
    this.controller,
    this.widget,
    this.maxLines,
    this.readOnly = false,
    this.hasBorder = true,
    this.titleColor = Colors.black,
    this.hintColor = Colors.black,
    this.containerColor = Colors.white,
    this.obscureText = false, // Default to false
    this.onToggleObscureText, // Default to null
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor
            ),
          ),
          Container(
            width: width,
            height: height,
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              border: hasBorder ? Border.all(
                color: Colors.grey,
                width: 1.0,
              ) : null,
              borderRadius: BorderRadius.circular(12),
              color: containerColor
            ),
            
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    maxLines: obscureText? 1 : maxLines,
                    readOnly: readOnly, 
                    autofocus: false,
                    cursorColor: Colors.grey[700],
                    controller: controller,
                    obscureText: obscureText, // Use the provided obscureText parameter
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                      border: InputBorder.none,
                      suffixIcon: onToggleObscureText != null ? GestureDetector(
                        onTap: onToggleObscureText,
                        child: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ) : null, // Add a suffix icon to toggle obscure text
                    ),
                    validator: validator,
                  ),
                ),
                if (widget != null) widget!, 
              ],
            ),
          ),
        ],
      ),
    );
  }
}