import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final double? height;
  final double? width;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final String? hintText;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final double? cursorHeight;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Color? focusedBorder;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;

  const CustomTextField({
    Key? key,
    this.controller,
    this.height,
    this.width,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.hintText,
    this.hintStyle,
    this.fillColor,
    this.keyboardType,
    this.focusNode,
    this.cursorHeight,
    this.maxLength,
    this.focusedBorder = PortColor.gray,
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double effectiveHeight = height ?? MediaQuery.of(context).size.height * 0.06;
    double effectiveWidth = width ?? double.infinity;

    return Container(
      height: effectiveHeight,
      width: effectiveWidth,
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        enabled: enabled,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          fillColor: fillColor ?? PortColor.white,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(
            color: enabled
                ? PortColor.black.withOpacity(0.5)
                : PortColor.gray.withOpacity(0.5),
            fontSize: 12,
          ),
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                  color: enabled
                      ? PortColor.black.withOpacity(0.3)
                      : PortColor.gray.withOpacity(0.5)),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide(
              color: enabled ? Colors.grey : PortColor.gray,
              width: Sizes.screenWidth * 0.001,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide(
              color: focusedBorder ?? PortColor.gray,
              width: Sizes.screenWidth * 0.001,
            ),
          ),
          counterText: "",
        ),
        cursorColor: enabled ? PortColor.gray : Colors.transparent,
        style: TextStyle(color: enabled ? PortColor.black : PortColor.gray),
        cursorHeight: cursorHeight,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: [
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          if (inputFormatters != null) ...inputFormatters!,
        ],
      ),
    );
  }
}
