import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart' hide Navigator;
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Navigator;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:wepei_module/commons/font/font_loader.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/token/lake_token_manager.dart';
import 'package:wepei_module/commons/widgets/colored_icon.dart';
import 'package:wepei_module/studyroom/model/studyroom_provider.dart';
import 'package:wepei_module/xiaotian/model/xiaotian_state.dart';

import 'auth/network/auth_service.dart';
import 'auth/network/message_service.dart';
import 'auth/network/screen_splash_service.dart';
import 'auth/view/message/message_router.dart';
import 'commons/channel/local_setting/local_setting.dart';
import 'commons/channel/push/push_manager.dart';
import 'commons/channel/remote_config/remote_config_manager.dart';
import 'commons/environment/config.dart';
import 'commons/local/animation_provider.dart';
import 'commons/network/wpy_dio.dart';
import 'commons/preferences/common_prefs.dart';
import 'commons/themes/scheme/red_scheme.dart';
import 'commons/themes/wpy_theme.dart';
import 'commons/update/update_manager.dart';
import 'commons/util/logger.dart';
import 'commons/util/navigator_observers.dart';
import 'commons/util/router_manager.dart';
import 'commons/util/storage_util.dart';
import 'commons/util/text_util.dart';
import 'commons/widgets/wpy_pic.dart';
import 'feedback/model/feedback_providers.dart';
import 'feedback/network/post.dart';
import 'gpa/model/gpa_notifier.dart';
import 'lost_and_found/module/lost_and_found_providers.dart';
import 'message/model/message_provider.dart';
import 'schedule/model/course_provider.dart';
import 'package:wepei_module/schedule/model/exam_provider.dart';
import 'schedule/schedule_providers.dart';
import 'auth/auth_router.dart';
import 'home/home_router.dart';

final _stateFile = File('${Directory.systemTemp.path}/wepeiyang_state.json');

void main() async {
  // Bypass SSL verification for qnhdpic.twt.edu.cn (trusted internal CA)
  HttpOverrides.global = _InsecureHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.init();
  await CommonPreferences.init();
  WpyTheme.init();
  _loadLoginState();
  debugPrint('[FONT_DEBUG] Platform.isAndroid=${Platform.isAndroid} Platform.isIOS=${Platform.isIOS} Platform.OS=${Platform.operatingSystem}');
  debugPrint('[FONT_DEBUG] TextUtil.base.fontFamily BEFORE loadFontFromList=${TextUtil.base.fontFamily}');
  await _loadHarmonyOSFonts();
  debugPrint('[FONT_DEBUG] TextUtil.base.fontFamily AFTER loadFontFromList=${TextUtil.base.fontFamily}');
  runApp(const WePeiYangApp());

}

Future<void> _loadHarmonyOSFonts() async {
  // Fonts registered via pubspec.yaml 'fonts:' section (FontManifest.json) are already loaded by the Flutter framework.
  // No need for loadFontFromList — the OHOS engine reads FontManifest.json on startup.
  debugPrint('[FONT_DEBUG] Fonts declared in pubspec fonts: section are loaded via FontManifest.json');
}

void _loadLoginState() {
  try {
    if (!_stateFile.existsSync()) return;
    final data = jsonDecode(_stateFile.readAsStringSync()) as Map<String, dynamic>;
    CommonPreferences.token.value = data['token'] as String? ?? '';
    CommonPreferences.account.value = data['account'] as String? ?? '';
    CommonPreferences.password.value = data['password'] as String? ?? '';
    CommonPreferences.nickname.value = data['nickname'] as String? ?? '';
    CommonPreferences.userNumber.value = data['userNumber'] as String? ?? '';
    CommonPreferences.avatar.value = data['avatar'] as String? ?? '';
    CommonPreferences.phone.value = data['phone'] as String? ?? '';
    CommonPreferences.email.value = data['email'] as String? ?? '';
    CommonPreferences.realName.value = data['realName'] as String? ?? '';
    CommonPreferences.tjuuname.value = data['tjuuname'] as String? ?? '';
    CommonPreferences.tjupasswd.value = data['tjupasswd'] as String? ?? '';
    CommonPreferences.isLogin.value = true;
    if ((data['tjuuname'] as String? ?? '').isNotEmpty) {
      CommonPreferences.isBindTju.value = true;
    }
  } catch (_) {}
}

final _messageChannel = MethodChannel('com.twt.service/message');
final _pushChannel = MethodChannel('com.twt.service/push');

class WePeiYangApp extends StatefulWidget {
  const WePeiYangApp({super.key});
  @override
  State<WePeiYangApp> createState() => _appState;
  static double screenWidth = 390;
  static double screenHeight = 844;
  static late NavigatorState navigatorState;
}

final _appState = WePeiYangAppState._();

class WePeiYangAppState extends State<WePeiYangApp> with WidgetsBindingObserver {
  WePeiYangAppState._();
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(state) { super.didChangeAppLifecycleState(state); }
  void checkEventList() {}
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.of(context);
    WePeiYangApp.screenWidth = mq.size.width;
    WePeiYangApp.screenHeight = mq.size.height;
  }

  @override
  Widget build(BuildContext context) {
    // Set white background while Flutter initializes
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GPANotifier()),
            ...scheduleProviders,
            ChangeNotifierProvider(create: (_) => CampusProvider()),
            ChangeNotifierProvider(create: (_) => TimeProvider()),
            ChangeNotifierProvider(create: (_) => MessageProvider()),
            ...feedbackProviders,
            ...lostAndFoundProviders,
            ChangeNotifierProvider(create: (_) => PushManager()),
            ChangeNotifierProvider(create: (_) => UpdateManager()),
            ChangeNotifierProvider(create: (_) => AnimationProvider()),
            ChangeNotifierProvider(create: (_) => xiaotianInputState()),
            ChangeNotifierProvider(create: (_) => RemoteConfig()),
            ChangeNotifierProvider(create: (_) => xiaotianChatState()),
          ],
          child: WpyTheme(
            themeData: WpyThemeData.themeList[0],
            child: MaterialApp(
              navigatorKey: RouterManager.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'WePeiYang',
              theme: ThemeData.light().copyWith(
                platform: TargetPlatform.android,
              ),
              home: const SplashScreen(),
              navigatorObservers: [AppRouteAnalysis()],
              builder: FlutterSmartDialog.init(
                toastBuilder: (String msg) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                  child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
              onGenerateRoute: RouterManager.create,
            ),
          ),
        );
      },
    );
  }
  bool _navInited = false;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WePeiYangApp.navigatorState = Navigator.of(context);
      _redirect();
    });
  }

  void _redirect() {
    if (!context.mounted) return;
    // Load cached course/GPA/exam data before navigating
    try {
      context.read<CourseProvider>().readPref();
    } catch (_) {}
    try {
      context.read<GPANotifier>().readPref();
    } catch (_) {}
    try {
      context.read<ExamProvider>().readPref();
    } catch (_) {}

    final route = CommonPreferences.isLogin.value && CommonPreferences.token.value.isNotEmpty
        ? HomeRouter.home
        : AuthRouter.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _InsecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
