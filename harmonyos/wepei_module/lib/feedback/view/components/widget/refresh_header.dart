import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';
import 'package:wepei_module/main.dart';

class RefreshHeader extends MaterialClassicHeader {
  @override
  double get offset => 2 * WePeiYangApp.screenHeight / 5;

  @override
  double get distance => 10.w;

  RefreshHeader(BuildContext context)
      : super(
          color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        );
}
