import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_pic/post_preview_pic.dart';
import '../../../commons/environment/config.dart';
import '../../../commons/util/text_util.dart';
import '../../../main.dart';
import '../../feedback_router.dart';
import '../components/widget/round_taggings.dart';
import '../image_view/image_view_page.dart';

final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
final radius = 4.r;

//内侧的单张图片
class InnerSinglePostPic extends StatelessWidget {
  final String imgUrl;
  final ValueNotifier<bool> isFullView = ValueNotifier(false);

  InnerSinglePostPic({required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        return ValueListenableBuilder(
          valueListenable: isFullView,
          builder: (context, bool isExpanded, child) {
            // 加载图片并获取图片尺寸
            Completer<ui.Image> completer = Completer<ui.Image>();
            Image image = Image.network(
              picBaseUrl + 'origin/' + imgUrl,
              width: layout.maxWidth,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            );

            // 图片信息异步获取
            if (!completer.isCompleted) {
              image.image
                  .resolve(ImageConfiguration())
                  .addListener(ImageStreamListener((info, _) {
                if (!completer.isCompleted) completer.complete(info.image);
              }));
            }

            return FutureBuilder<ui.Image>(
              future: completer.future.timeout(Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorHint(layout.maxWidth);
                }
                // 处理加载状态
                if (!snapshot.hasData) {
                  return _buildPlaceholder(layout.maxWidth);
                }

                // 判断是否为长图
                bool isLongImage =
                    snapshot.data!.height / snapshot.data!.width > 2.0;

                // 根据是否为长图和展开状态渲染不同的UI
                if (isLongImage) {
                  return AnimatedSize(
                    duration: Duration(milliseconds: 250),
                    child: isExpanded
                        ? _buildExpandedImageView(context, image)
                        : _buildCollapsedImageView(context, image),
                  );
                } else {
                  return _buildRegularImageView(context, image);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(double width) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Builder(builder: (context) {
          return Shimmer.fromColors(
            child: Container(
              color: Colors.black12,
              width: width,
              height: width,
            ),
            baseColor:
                WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
            highlightColor: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
          );
        }));
  }

  Widget _buildExpandedImageView(BuildContext context, Image image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              FeedbackRouter.imageView,
              arguments: ImageViewPageArgs([imgUrl], 1, 0, true),
            ),
            child: image,
          ),
        ),
        TextButton(
          onPressed: () => isFullView.value = false,
          child: Text(
            '收起',
            style:
                TextUtil.base.textButtonPrimary(context).w600.NotoSansSC.sp(14),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedImageView(BuildContext context, Image image) {
    return SizedBox(
      height: WePeiYangApp.screenWidth * 1.2,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                FeedbackRouter.imageView,
                arguments: ImageViewPageArgs([imgUrl], 1, 0, true),
              ),
              child: image,
            ),
            Positioned(
              top: 8,
              left: 8,
              child: TextPod('长图'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () => isFullView.value = true,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0, -0.7),
                      end: Alignment(0, 1),
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        '点击展开\n',
                        style: TextUtil.base.w600.bright(context).sp(14).h(0.6),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(16)),
                        ),
                        padding: EdgeInsets.fromLTRB(12, 4, 10, 6),
                        child: Text(
                          '长图模式',
                          style: TextUtil.base.w300.bright(context).sp(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularImageView(BuildContext context, Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          FeedbackRouter.imageView,
          arguments: ImageViewPageArgs([imgUrl], 1, 0, false),
        ),
        child: image,
      ),
    );
  }

  Widget _buildErrorHint(double maxWidth) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          width: maxWidth,
          height: maxWidth / 3,
          child: WpyPic.errorPlaceHolder,
        ));
  }
}

class InnerMultiPostPic extends StatelessWidget {
  final List<String> imgUrls;

  const InnerMultiPostPic({Key? key, required this.imgUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OuterMultiPostPic(imgUrls: imgUrls, isOuter: false);
  }
}

class PostDetailPic extends StatelessWidget {
  final List<String> imgUrls;

  const PostDetailPic({Key? key, required this.imgUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imgUrls.length == 0) {
      return SizedBox.shrink();
    } else if (imgUrls.length == 1) {
      return InnerSinglePostPic(imgUrl: imgUrls[0]);
    } else {
      return InnerMultiPostPic(imgUrls: imgUrls);
    }
  }
}
