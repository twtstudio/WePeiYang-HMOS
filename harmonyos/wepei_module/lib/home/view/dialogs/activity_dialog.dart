// @dart=2.12

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wepei_module/auth/model/banner_pic.dart';
import 'package:wepei_module/auth/network/splash_service.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';
import 'package:wepei_module/commons/token/lake_token_manager.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';
import 'package:wepei_module/commons/widgets/loading.dart';
import 'package:wepei_module/commons/widgets/w_button.dart';
import 'package:wepei_module/commons/widgets/wpy_pic.dart';
import 'package:wepei_module/feedback/feedback_router.dart';
import 'package:wepei_module/home/view/web_views/festival_page.dart';

/// 活动弹窗
class ActivityDialog extends Dialog {
  ActivityDialog();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SplashService.getBanner(),
      builder: (context, AsyncSnapshot<List<BannerPic>> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data.isEmpty) {
            Navigator.pop(context);
            return SizedBox.shrink();
          }
          return Column(
            children: [
              Spacer(),
              if (data.length == 1)
                SizedBox(
                  width: 0.81.sw,
                  height: 1.08.sw,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: WButton(
                      onPressed: () async {
                        if (data[0].url.startsWith('browser:')) {
                          if (await canLaunchUrlString(
                              data[0].url.replaceAll('browser:', '')).catchError((_) => false)) {
                            launchUrlString(
                                data[0]
                                    .url
                                    .replaceAll('browser:', '')
                                    .replaceAll('<token>',
                                        '${CommonPreferences.token.value}')
                                    .replaceAll('<laketoken>',
                                        '${await LakeTokenManager().refreshToken()}'),
                                mode: LaunchMode.externalApplication).catchError((_) {});
                          } else {
                            ToastProvider.error('好像无法打开活动呢，请联系天外天工作室');
                          }
                        }
                        else if (data[0].url.isEmpty) {}
                        else {
                          Navigator.pushNamed(context, FeedbackRouter.haitang,
                              arguments: FestivalArgs(data[0].url, '活动'));
                        }
                      },
                      child: WpyPic(
                        data[0].picUrl,
                        fit: BoxFit.cover,
                        withHolder: true,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 1.08.sw,
                  child: Swiper(
                    loop: true,
                    autoplay: true,
                    autoplayDelay: 4000,
                    itemCount: data.length,
                    pagination: SwiperPagination(
                        margin: EdgeInsets.zero,
                        builder: DotSwiperPaginationBuilder(
                          activeColor: WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor),
                          space: 5,
                        ),
                        alignment: Alignment.bottomCenter),
                    itemBuilder: (BuildContext context, int index) {
                      // if (data.length == 0) return SizedBox();
                      return ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: WButton(
                          onPressed: () async {
                            if (data[index].url.startsWith('browser:')) {
                              if (await canLaunchUrlString(
                                  data[index].url.replaceAll('browser:', '')).catchError((_) => false)) {
                                launchUrlString(
                                    data[index].url.replaceAll('browser:', '')).catchError((_) {});
                              } else {
                                ToastProvider.error('好像无法打开活动呢，请联系天外天工作室');
                              }
                            } else
                              Navigator.pushNamed(
                                  context, FeedbackRouter.haitang,
                                  arguments:
                                      FestivalArgs(data[index].url, '活动'));
                          },
                          child: WpyPic(
                            data[index].picUrl,
                            fit: BoxFit.cover,
                            withHolder: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              WButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 1.sw,
                    height: 0.55.sh - 0.54.sw,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/lake_butt_icons/x.png',
                        width: 50.w,
                        height: 100.w,
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.reverseTextColor),
                      ),
                    ),
                  ))
            ],
          );
        } else if (snapshot.hasError) {
          Navigator.pop(context);
          return SizedBox.shrink();
        } else {
          return Loading();
        }
      },
    );
  }
}
