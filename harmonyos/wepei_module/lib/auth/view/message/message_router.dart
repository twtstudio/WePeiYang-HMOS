import 'package:flutter/material.dart';
import 'package:wepei_module/auth/network/message_service.dart';

import 'user_mails_page.dart';

class MessageRouter {
  static String mailPage = 'feedback/html_page';
  static final Map<String, Widget Function(dynamic arguments)> routers = {
    mailPage: (args) {
      final data = args as UserMail;
      return MailPage(data: data);
    },
  };
}
