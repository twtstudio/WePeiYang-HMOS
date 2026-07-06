import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';

class Loading extends StatefulWidget {
  final Color? dotOneColor;
  final Color? dotTwoColor;
  final Color? dotThreeColor;
  final Duration duration;
  final DotType dotType;
  final Icon dotIcon;

  const Loading({
    this.dotOneColor,
    this.dotTwoColor,
    this.dotThreeColor,
    this.duration = const Duration(seconds: 1),
    this.dotType = DotType.circle,
    this.dotIcon = const Icon(Icons.adjust),
    Key? key,
  }) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late Animation<double> animation_1;
  late Animation<double> animation_2;
  late Animation<double> animation_3;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.70, curve: Curves.linear),
      ),
    );

    animation_2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.80, curve: Curves.linear),
      ),
    );

    animation_3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.90, curve: Curves.linear),
      ),
    );

    controller.addListener(() {
      setState(() {});
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final dotOneColor =
        widget.dotOneColor ?? WpyTheme.of(context).get(WpyColorKey.loadPointA);
    final dotTwoColor =
        widget.dotOneColor ?? WpyTheme.of(context).get(WpyColorKey.loadPointC);
    final dotThreeColor =
        widget.dotOneColor ?? WpyTheme.of(context).get(WpyColorKey.loadPointB);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _dotWidget(animation_1, dotOneColor),
        _dotWidget(animation_2, dotTwoColor),
        _dotWidget(animation_3, dotThreeColor),
      ],
    );
  }

  Widget _dotWidget(Animation<double> anim, Color color) {
    final opacity = anim.value <= 0.4
        ? 2.5 * anim.value
        : (anim.value > 0.40 && anim.value <= 0.60)
            ? 1.0
            : 2.5 - (2.5 * anim.value);

    final dot = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Dot(
        radius: 10.0,
        color: color,
        type: widget.dotType,
        icon: widget.dotIcon,
      ),
    );

    // Skip Opacity widget when fully opaque to avoid saveLayer()
    if (opacity >= 1.0) return dot;
    return Opacity(opacity: opacity, child: dot);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color? color;
  final DotType? type;
  final Icon? icon;

  const Dot({
    this.radius,
    this.color,
    this.type,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: type == DotType.icon
          ? Icon(
              icon!.icon,
              color: color,
              size: 1.3 * radius!,
            )
          : Transform.rotate(
              angle: type == DotType.diamond ? pi / 4 : 0.0,
              child: Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                    color: color,
                    shape: type == DotType.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle),
              ),
            ),
    );
  }
}

enum DotType { square, circle, diamond, icon }
