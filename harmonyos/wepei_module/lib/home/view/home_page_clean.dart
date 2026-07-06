import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemNavigator, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wepei_module/auth/network/auth_service.dart';
import 'package:wepei_module/commons/channel/push/push_manager.dart';
import 'package:wepei_module/commons/channel/statistics/umeng_statistics.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';
import 'package:wepei_module/feedback/view/lake_home_page/home_page.dart';
import 'package:wepei_module/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:wepei_module/feedback/view/profile_page.dart';
import 'package:wepei_module/home/view/wpy_page.dart';
import 'package:wepei_module/main.dart';
import 'package:wepei_module/studyroom/model/studyroom_provider.dart';
import 'package:wepei_module/xiaotian/view/page/xiaotian_page.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../auth/view/user/account_upgrade_dialog.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/colored_icon.dart';

class HomePage extends StatefulWidget {
  final int? page;

  HomePage(this.page);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// bottomNavigationBar对应的分页
  List<Widget> pages = [];
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  late final TabController _tabController;
  final feedbackKey = GlobalKey<FeedbackHomePageState>();

  @override
  void initState() {
    super.initState();
    pages
      ..add(WPYPage())
      ..add(FeedbackHomePage(key: feedbackKey))
      ..add(AiPage())
      ..add(ProfilePage());
    _tabController = TabController(
      length: pages.length,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        if (_tabController.index != _tabController.previousIndex) {
          setState(() {
            _currentIndex = _tabController.index;
          });
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {

