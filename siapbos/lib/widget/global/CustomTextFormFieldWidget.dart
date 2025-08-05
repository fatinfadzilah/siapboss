import 'package:flutter/material.dart';

class CustomTextFormFieldWidget extends StatelessWidget {

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? initialValue;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool autofocus;
  final int minLines;
  final String? helperText;
  final TextCapitalization? textCapitalization;
  final Color? textColor;
  final TextStyle? helperStyle;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign textAlign;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final Widget? prefixIcon;
  final InputBorder? border;
  final Color? borderColor;

  const CustomTextFormFieldWidget
  ({
    Key? key, 
    this.padding = const EdgeInsets.fromLTRB(0, 10, 0, 0),
    this.controller, 
    this.labelText, 
    this.hintText = "Type here", 
    this.keyboardType,
    this.obscureText = false,
    this.initialValue,
    this.readOnly = false, 
    this.suffixIcon, 
    this.validator, 
    this.onChanged,
    this.focusNode,
    this.onTap()?,
    this.autofocus = false,
    this.minLines = 1,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.textColor = Colors.black54,
    this.helperStyle,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 15,
    this.textAlign = TextAlign.start,
    this.borderRadius = 15,
    this.backgroundColor,
    this.prefixIcon,
    this.border,
    this.borderColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        textAlign: textAlign,
        decoration: InputDecoration(
          border: border,
          prefixIcon: prefixIcon != null ? prefixIcon : null,
          prefixIconColor: textColor,
          fillColor: backgroundColor,
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          alignLabelWithHint: true,
          hintText: hintText,
          hintStyle: TextStyle(color: textColor, fontWeight: fontWeight, fontSize: fontSize),
          helperText: helperText,
          helperStyle: helperStyle,
          helperMaxLines: 3,
          errorMaxLines: 2,
          errorStyle: TextStyle(color: Colors.red[200]),
          enabledBorder: border ?? OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? Colors.black54,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          contentPadding: EdgeInsetsDirectional.fromSTEB(16, 18, 0, 18),
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.grey,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: Theme.of(context).textTheme.bodyLarge,
        keyboardType: keyboardType,
        maxLines: 1,
        textCapitalization: textCapitalization!,
        controller: controller,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        initialValue: initialValue,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
        focusNode: focusNode,
        onTap: onTap,
        autofocus: autofocus,
        minLines: minLines,
      ),
    );
  }
}
