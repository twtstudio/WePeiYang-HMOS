import 'package:flutter/material.dart';
import 'package:wepei_module/auth/auth_router.dart';
import 'package:wepei_module/auth/view/message/message_router.dart';
import 'package:wepei_module/commons/test/test_router.dart';
import 'package:wepei_module/feedback/feedback_router.dart';
import 'package:wepei_module/gpa/gpa_router.dart';
import 'package:wepei_module/home/home_router.dart';
import 'package:wepei_module/lost_and_found/lost_and_found_router.dart';
import 'package:wepei_module/schedule/schedule_router.dart';
import 'package:wepei_module/studyroom/model/studyroom_router.dart';

export 'package:wepei_module/auth/auth_router.dart';
export 'package:wepei_module/feedback/feedback_router.dart';
export 'package:wepei_module/gpa/gpa_router.dart';
export 'package:wepei_module/home/home_router.dart';
export 'package:wepei_module/schedule/schedule_router.dart';

class RouterManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final Map<String, Widget Function(dynamic arguments)> _routers = {};

  static Route<dynamic> create(RouteSettings settings) {
    if (_routers.isEmpty) {
      _routers.addAll(AuthRouter.routers);
      _routers.addAll(FeedbackRouter.routers);
      _routers.addAll(GPARouter.routers);
      _routers.addAll(HomeRouter.routers);
      _routers.addAll(StudyRoomRouter.routers);
      _routers.addAll(ScheduleRouter.routers);
      _routers.addAll(MessageRouter.routers);
      _routers.addAll(TestRouter.routers);
      _routers.addAll(LAFRouter.routers);
    }
    return MaterialPageRoute(
        builder: (ctx) => _routers[settings.name]!(settings.arguments),
        settings: settings);
  }
}