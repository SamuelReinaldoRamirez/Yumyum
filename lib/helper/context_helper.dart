import 'package:flutter/material.dart';

class ContextHelper {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context is not set.');
    }
    return _context!;
  }

  static bool get hasContext => _context != null;
}
