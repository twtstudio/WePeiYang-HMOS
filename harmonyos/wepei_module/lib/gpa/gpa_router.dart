import 'package:flutter/material.dart' show Widget;
import 'package:wepei_module/gpa/view/gpa_page.dart';

class GPARouter {
  static String gpa = 'gpa/home';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    gpa: (_) => GPAPage(),
  };
}
