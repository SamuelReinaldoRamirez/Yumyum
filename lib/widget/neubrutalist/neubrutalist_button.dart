import 'package:flutter/material.dart';

class NeubrutalistButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? height;
  final Color? backgroundColor;

  const NeubrutalistButton({
    required this.onPressed, 
    required this.child,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: backgroundColor != null ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size.fromHeight(height ?? 40),
        ),
        child: child,
      ),
    );
  }
}
