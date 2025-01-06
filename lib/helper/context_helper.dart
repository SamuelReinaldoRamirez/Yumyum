import 'package:flutter/material.dart';

class ContextHelper {
  static final ContextHelper _instance = ContextHelper._internal();
  static BuildContext? _context;

  // Private constructor
  ContextHelper._internal();

  // Factory constructor to return the instance
  factory ContextHelper() {
    return _instance;
  }

  // Method to set the context
  static void setContext(BuildContext context) {
    _context = context;
  }

  // Method to get the context
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context is not set.');
    }
    return _context!;
  }
}
