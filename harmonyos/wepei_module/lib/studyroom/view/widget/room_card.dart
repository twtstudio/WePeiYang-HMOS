import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';
import 'package:wepei_module/commons/util/text_util.dart';
import 'package:wepei_module/studyroom/model/studyroom_models.dart';

class RoomStateText extends StatelessWidget {
  final Room room;
  final bool onlyCurrent;

  RoomStateText(this.room, {Key? key, this.onlyCurrent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final available = room.isFree;
    Widget stateDot;
    Widget stateText;

    if (available) {
      stateDot = Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.roomFreeColor),
          shape: BoxShape.circle,
        ),
      );

      stateText = Text('空闲',
          style: TextUtil.base.PingFangSC.w400.roomFree(context).sp(10));
    } else {
      stateDot = Container(
        width: 6.w,
        height: 6.w,
        decoration: const BoxDecoration(
          color: Color(0xFFD9534F),
          shape: BoxShape.circle,
        ),
      );

      stateText = Text('占用',
          style: TextUtil.base.PingFangSC.w400.roomOccupied(context).sp(10));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        stateDot,
        SizedBox(width: 3.w),
        stateText,
      ],
    );
  }
}
