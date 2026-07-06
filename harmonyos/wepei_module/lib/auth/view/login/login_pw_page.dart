import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:wepei_module/auth/network/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/auth/view/privacy/privacy_dialog.dart';
import 'package:wepei_module/auth/view/privacy/user_agreement_dialog.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/token/lake_token_manager.dart';
import 'package:wepei_module/commons/util/router_manager.dart';
import 'package:wepei_module/commons/util/text_util.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';
import 'package:wepei_module/commons/widgets/w_button.dart';

import '../../../commons/themes/wpy_theme.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> {
  final checkNotifier = ValueNotifier<bool>(true); // 是否勾选隐私政策
  bool _usePwLogin = true;
  String md = "";
  _login() async {
    debugPrint('_login called');
    FocusScope.of(context).requestFocus(FocusNode());
    if (_usePwLogin) {
      if (account == "" || password == "") {
        showDialog(context: context, builder: (_) => AlertDialog(content: Text('账号或密码为空')));
        return;
      }
      ToastProvider.running("登录中...");
      debugPrint('calling pwLogin');
      try {
        await AuthService.pwLogin(account, password,
          onResult: (result) {
            ToastProvider.cancelCurrent();
            if (result['telephone'] == null || result['email'] == null) {
              Navigator.pushNamed(context, AuthRouter.addInfo);
            } else {
              LakeTokenManager().refreshToken();
              Navigator.pushNamedAndRemoveUntil(context, HomeRouter.home, (route) => false);
            }
          },
          onFailure: (e) {
            ToastProvider.cancelCurrent();
            showDialog(context: context, builder: (_) => AlertDialog(content: Text('失败: ${e.error}'))); 
          });
      } catch (e) {
        ToastProvider.cancelCurrent();
        showDialog(context: context, builder: (_) => AlertDialog(content: Text('网络异常: $e')));
      }
    } else {
      if (account == "") {
        showDialog(context: context, builder: (_) => AlertDialog(content: Text('手机号为空')));
      } else if (code == "") {
        showDialog(context: context, builder: (_) => AlertDialog(content: Text('验证码为空')));
      } else {
        ToastProvider.running("登录中...");
        AuthService.codeLogin(account, code,
          onResult: (result) {
            ToastProvider.cancelCurrent();
            if (result['telephone'] == null || result['email'] == null) {
              Navigator.pushNamed(context, AuthRouter.addInfo);
            } else {
              LakeTokenManager().refreshToken();
              Navigator.pushNamedAndRemoveUntil(context, HomeRouter.home, (route) => false);
            }
          },
          onFailure: (e) {
            ToastProvider.cancelCurrent();
            showDialog(context: context, builder: (_) => AlertDialog(content: Text('失败: ${e.error}')));
          });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    ///隐私政策markdown加载
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return GestureDetector(
      onTap: () {
        // 当点击空白区域时，关闭键盘
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: WpyTheme.of(context)
                .getGradient(WpyColorSetKey.primaryGradientAllScreen),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "Welcome\n\n",
                      style: TextUtil.base.normal.NotoSansSC
                          .sp(40)
                          .w700
                          .bright(context)),
                ])),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //SizedBox(height: Platform.isIOS? 20: 50),
                          _usePwLogin ? _pwWidget : _codeWidget,
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: checkNotifier,
                                builder: (context, bool value, _) {
                                  return Transform.scale(
                                    scaleX: 1.3,
                                    scaleY: 1.3,
                                    child: Checkbox(
                                      value: value,
                                      side: MaterialStateBorderSide.resolveWith(
                                        (_) => BorderSide(
                                            color: WpyTheme.of(context).get(
                                                WpyColorKey.brightTextColor),
                                            width: 2),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      activeColor: WpyTheme.of(context)
                                          .get(WpyColorKey.primaryActionColor),
                                      onChanged: (_) {
                                        checkNotifier.value =
                                            !checkNotifier.value;
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 10),
                              Text.rich(TextSpan(
                                  text: "我已阅读并同意",
                                  style: TextUtil.base.normal.NotoSansSC.w400
                                      .sp(10)
                                      .label(context))),
                              WButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    //直接传入check=checkNotifier会导致_detail组件不显示
                                    builder: (context) =>
                                        UserAgreementDialog()),
                                child: Text.rich(TextSpan(
                                    text: "《用户协议》",
                                    style: TextUtil.base
                                        .link(context)
                                        .NotoSansSC
                                        .w400
                                        .sp(10)
                                        .underLine)),
                              ),
                              Text.rich(TextSpan(
                                  text: "与",
                                  style: TextUtil.base
                                      .link(context)
                                      .NotoSansSC
                                      .w400
                                      .sp(10)
                                      .label(context))),
                              WButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => PrivacyDialog(md,
                                        check: checkNotifier)),
                                child: Text.rich(TextSpan(
                                    text: "《隐私政策》",
                                    style: TextUtil.base
                                        .link(context)
                                        .NotoSansSC
                                        .w400
                                        .sp(10)
                                        .underLine)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30)
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final visNotifier = ValueNotifier<bool>(true); // 是否隐藏密码
  final countDownNotifier = ValueNotifier<int>(0); // 获取验证码冷却
  String account = "";
  String password = "";

  String code = "";

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Widget get _pwWidget {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
            text: "账号",
            style:
                TextUtil.base.normal.NotoSansSC.w400.sp(16).bright(context))),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            style: TextUtil.base.normal.w400.sp(14).NotoSansSC.bright(context),
            cursorColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            textInputAction: TextInputAction.next,
            focusNode: _accountFocus,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  width: 1.0,
                ),
              ),
              hintText: "学号/手机号/邮箱",
              hintStyle: TextUtil.base.normal.sp(14).w400.bright(context),
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
            ),
            onChanged: (input) => setState(() => account = input),
            onEditingComplete: () {
              _accountFocus.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
        ),
        SizedBox(height: 20),
        Text.rich(TextSpan(
            text: "密码",
            style:
                TextUtil.base.normal.NotoSansSC.w400.sp(16).bright(context))),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: ValueListenableBuilder(
            valueListenable: visNotifier,
            builder: (context, bool value, _) {
              return Theme(
                data: Theme.of(context).copyWith(
                    primaryColor:
                        WpyTheme.of(context).get(WpyColorKey.oldActionColor)),
                child: TextField(
                  style: TextUtil.base.normal.w400
                      .sp(14)
                      .NotoSansSC
                      .bright(context),
                  obscureText: value,
                  cursorColor: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          width: 1.0,
                        ),
                      ),
                      hintText: "请输入密码",
                      hintStyle:
                          TextUtil.base.normal.sp(14).w400.bright(context),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                      suffixIcon: WButton(
                        onPressed: () {
                          visNotifier.value = !visNotifier.value;
                        },
                        child: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.brightTextColor),
                        ),
                      )),
                  onChanged: (input) => setState(() => password = input),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 50),
        WButton(
          onPressed: () async {
            final ctx = RouterManager.navigatorKey.currentState?.context;
            if (ctx == null || account.isEmpty || password.isEmpty) return;
            ToastProvider.running("登录中...");
            try {
              final dio = Dio(BaseOptions(
                baseUrl: 'https://api.twt.edu.cn/api/',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: AuthDio().headers ?? {},
              ));
              (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
                final client = HttpClient();
                client.badCertificateCallback = (cert, host, port) => true;
                return client;
              };
              final rsp = await dio.post('auth/common',
                data: {'account': account, 'password': password},
                options: Options(contentType: Headers.formUrlEncodedContentType),
              );
              final ec = rsp.data['error_code'];
              if (ec != null && ec != 0) {
                final msg = rsp.data['msg'] ?? rsp.data['message'] ?? '错误码: $ec';
                ToastProvider.cancelCurrent();
                ToastProvider.error(msg);
                return;
              }
              // Save login state
              final data = rsp.data['result'] as Map? ?? {};
              CommonPreferences.token.value = data['token'] ?? '';
              CommonPreferences.account.value = account;
              CommonPreferences.password.value = password;
              CommonPreferences.nickname.value = data['nickname'] ?? '';
              CommonPreferences.userNumber.value = data['userNumber'] ?? '';
              CommonPreferences.phone.value = data['telephone'] ?? '';
              CommonPreferences.email.value = data['email'] ?? '';
              CommonPreferences.realName.value = data['realname'] ?? '';
              CommonPreferences.department.value = data['department'] ?? '';
              CommonPreferences.major.value = data['major'] ?? '';
              CommonPreferences.stuType.value = data['stuType'] ?? '';
              CommonPreferences.avatar.value = data['avatar'] ?? '';
              CommonPreferences.isLogin.value = true;
              // Persist login state
              try {
                final f = File('${Directory.systemTemp.path}/wepeiyang_state.json');
                f.writeAsStringSync(jsonEncode({
                  'token': data['token'] ?? '',
                  'account': account,
                  'password': password,
                  'nickname': data['nickname'] ?? '',
                  'userNumber': data['userNumber'] ?? '',
                  'avatar': data['avatar'] ?? '',
                  'phone': data['telephone'] ?? '',
                  'email': data['email'] ?? '',
                  'realName': data['realname'] ?? '',
                }));
              } catch (_) {}
              ToastProvider.cancelCurrent();
              Navigator.pushNamedAndRemoveUntil(ctx, HomeRouter.home, (route) => false);
            } on DioException catch (e) {
              ToastProvider.cancelCurrent();
              showDialog(context: context, builder: (_) => AlertDialog(content: Text('错误: ${e.type} ${e.message}')));
            } catch (e) {
              ToastProvider.cancelCurrent();
            }
          },
          child: Container(
            width: width - 60,
            height: 48,
            decoration: BoxDecoration(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text.rich(TextSpan(
                  text: "登录",
                  style: TextUtil.base.normal.NotoSansSC.w400
                      .sp(16)
                      .primaryAction(context))),
            ),
          ),
        ),
        SizedBox(height: 23),
        Row(
          children: [
            Spacer(),
            SizedBox(width: 16),
            WButton(
              child: Text.rich(TextSpan(
                  text: "短信登录",
                  style: TextUtil.base.normal.NotoSansSC.w400
                      .sp(14)
                      .bright(context))),
              onPressed: () {
                if (_usePwLogin) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  _usePwLogin = false;
                } else {
                  code = '';
                  _usePwLogin = true;
                }
                setState(() {});
              },
            ),
            SizedBox(width: 16),
            WButton(
              child: Text.rich(TextSpan(
                  text: "忘记密码?",
                  style: TextUtil.base.normal.NotoSansSC.w400
                      .sp(14)
                      .bright(context))),
              onPressed: () =>
                  Navigator.pushNamed(context, AuthRouter.findHome),
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  _fetchCaptcha() async {
    if (account == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnReset(account,
        onSuccess: () {
          setState(() {
            countDownNotifier.value = 60;
            Stream.periodic(Duration(seconds: 1)).take(60).listen((event) {
              countDownNotifier.value = countDownNotifier.value - 1;
            });
          });
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget get _codeWidget {
    final size = MediaQuery.of(context).size;
    double width = size.width;
    var builder = (index) {
      return Container(
        alignment: AlignmentDirectional.center,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: WpyTheme.of(context)
              .get(WpyColorKey.primaryBackgroundColor)
              .withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          code.length > index ? code.substring(index, index + 1) : '',
          style: TextUtil.base.normal.NotoSansSC.primaryAction(context).sp(16),
        ),
      );
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
            text: "手机号",
            style:
                TextUtil.base.normal.NotoSansSC.w400.sp(16).bright(context))),
        SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextUtil.base.normal.w400.sp(14).NotoSansSC.bright(context),
            cursorColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  width: 1.0,
                ),
              ),
              hintText: "请输入手机号",
              hintStyle: TextUtil.base.normal.sp(14).w400.bright(context),
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
            ),
            onChanged: (input) => setState(() => account = input),
          ),
        ),
        SizedBox(height: 20),
        Text.rich(TextSpan(
          text: "验证码",
          style: TextUtil.base.normal.NotoSansSC.w400.sp(16).bright(context),
        )),
        SizedBox(height: 20),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, builder),
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextUtil.base.normal.w400.sp(16).NotoSansSC.transParent,
              showCursor: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
              ),
              onChanged: (input) => setState(() => code = input),
            ),
          ],
        ),
        SizedBox(height: 11),
        WButton(
          onPressed: () async {
              debugPrint('sms login');
              if (account.isEmpty) {
                showDialog(context: context, builder: (_) => AlertDialog(content: const Text('请输入手机号')));
              } else if (code.isEmpty) {
                showDialog(context: context, builder: (_) => AlertDialog(content: const Text('请输入验证码')));
              } else {
                ToastProvider.running("登录中...");
                AuthService.codeLogin(account, code,
                  onResult: (_) {
                    ToastProvider.cancelCurrent();
                    Navigator.pushNamedAndRemoveUntil(context, HomeRouter.home, (route) => false);
                  },
                  onFailure: (e) {
                    ToastProvider.cancelCurrent();
                    showDialog(context: context, builder: (_) => AlertDialog(content: Text('失败: ${e.error}')));
                  },
                );
              }
            },
            child: Container(
              width: width - 60,
              height: 48,
              decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text.rich(TextSpan(
                    text: "登录",
                    style: TextUtil.base.normal.NotoSansSC.w400
                        .sp(16)
                        .primaryAction(context))),
              ),
            ),
          ),
        const SizedBox(height: 9),
        Row(
          children: [
            ValueListenableBuilder(
              valueListenable: countDownNotifier,
              builder: (context, value, _) {
                if (value == 0) {
                  return WButton(
                    onPressed: (_fetchCaptcha),
                    child: Text(
                      '获取验证码',
                      style: TextUtil.base.normal.NotoSansSC.w400
                          .sp(14)
                          .bright(context),
                    ),
                  );
                } else {
                  return WButton(
                    onPressed: () {},
                    child: Text(
                      '重新获取验证码($value)',
                      style: TextUtil.base.normal.NotoSansSC.w400
                          .sp(14)
                          .bright(context),
                    ),
                  );
                }
              },
            ),
            Spacer(),
            WButton(
              child: Text.rich(TextSpan(
                  text: "密码登录",
                  style: TextUtil.base.normal.NotoSansSC.w400
                      .sp(14)
                      .bright(context))),
              onPressed: () {
                if (_usePwLogin) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  _usePwLogin = false;
                } else {
                  code = '';
                  _usePwLogin = true;
                }
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
