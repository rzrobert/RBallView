import 'dart:convert';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

typedef OnTapRBallTagCallback = void Function(RBallTagData);

//手指按下时命中的point
PointAnimationSequence? pointAnimationSequence;

//球半径
int radius = 150;

///文字颜色
Color textColor = const Color(0xFF333333);

///文字高亮颜色
Color highLightTextColor = const Color(0xFF000000);

class RBallView extends StatefulWidget {
  final MediaQueryData mediaQueryData;

  ///需要展示的关键词
  final List<RBallTagData> keywords;

  ///需要高亮的关键词
  final List<RBallTagData> highlight;

  /// 最多显示多个字符
  final int maxChar;

  /// 点击回调
  final OnTapRBallTagCallback? onTapRBallTagCallback;

  /// 是否运行动画
  final bool isAnimate;

  /// 球体容器装饰
  final Decoration? decoration;

  /// 是否展示球体容器装饰
  final bool isShowDecoration;

  ///仰角基准值
  ///均匀分布仰角
  final List<double>? centers;

  ///球体半径
  final int? radius;

  ///文字颜色
  final Color? textColor;

  ///文字高亮颜色
  final Color? highLightTextColor;

  const RBallView({
    Key? key,
    required this.mediaQueryData,
    required this.keywords,
    required this.highlight,
    this.maxChar = 5,
    this.onTapRBallTagCallback,
    this.isAnimate = true,
    this.decoration,
    this.isShowDecoration = false,
    this.centers,
    this.radius,
    this.textColor,
    this.highLightTextColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RBallViewState();
  }
}

class _RBallViewState extends State<RBallView>
    with SingleTickerProviderStateMixin {
  //带光晕的球图片宽度
  late double sizeOfBallWithFlare;

  List<Point> points = [];

  late Animation<double> animation;
  late AnimationController controller;
  double currentRadian = 0;

  //手指移动的上一个位置
  late Offset lastPosition;

  //手指按下的位置
  late Offset downPosition;

  //上次点击并命中关键词的时间
  int lastHitTime = 0;

  //当前的旋转轴
  Point axisVector = getAxisVector(Offset(2, -1));

  @override
  void initState() {
    super.initState();

    /// 初始化工具类
    if (widget.keywords.length < 10) {
      RBallViewUtil.nameHalfSize = 12;
      RBallViewUtil.pointHalfTop = 6;
      RBallViewUtil.pointHalfWidth = 16;
    } else if (widget.keywords.length < 20) {
      RBallViewUtil.nameHalfSize = 10;
      RBallViewUtil.pointHalfTop = 6;
      RBallViewUtil.pointHalfWidth = 14;
    } else if (widget.keywords.length < 30) {
      RBallViewUtil.nameHalfSize = 8;
      RBallViewUtil.pointHalfTop = 5;
      RBallViewUtil.pointHalfWidth = 12;
    } else {
      RBallViewUtil.nameHalfSize = 6;
      RBallViewUtil.pointHalfTop = 3;
      RBallViewUtil.pointHalfWidth = 9;
    }

    // 初始化常量值
    textColor = widget.textColor ?? const Color(0xFF333333);
    highLightTextColor = widget.highLightTextColor ?? const Color(0xFF000000);

    //计算球尺寸、半径等
    sizeOfBallWithFlare = widget.mediaQueryData.size.width - 2 * 10;
    radius = widget.radius ?? ((sizeOfBallWithFlare * 32 / 35) / 2).round();

    //初始化点
    generatePoints(widget.keywords, widget.maxChar);

    //动画
    controller = AnimationController(
        duration: Duration(milliseconds: 40000), vsync: this);
    animation = Tween(begin: 0.0, end: pi * 2).animate(controller);
    animation.addListener(() {
      setState(() {
        for (int i = 0; i < points.length; i++) {
          rotatePoint(axisVector, points[i], animation.value - currentRadian);
        }
        currentRadian = animation.value;
      });
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentRadian = 0;
        controller.forward(from: 0.0);
      }
    });
    controller.forward();
  }

  @override
  void didUpdateWidget(RBallView oldWidget) {
    super.didUpdateWidget(oldWidget);

    //数据有变化，重新初始化点
    if (oldWidget.keywords != widget.keywords) {
      generatePoints(widget.keywords, widget.maxChar);
    }

    // 动画状态改变
    if (oldWidget.isAnimate != widget.isAnimate) {
      if (controller.isAnimating && !widget.isAnimate) {
        controller.stop();
      } else if (!controller.isAnimating && widget.isAnimate) {
        double from = currentRadian / (pi * 2);
        controller.forward(from: from);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void generatePoints(List<RBallTagData> keywords, int maxChar) {
    points.clear();
    Random random = Random();
    //仰角基准值
    //均匀分布仰角
    List<double> centers = widget.centers ??
        [
          0.5,
          0.35,
          0.65,
          0.35,
          0.2,
          0.5,
          0.65,
          0.35,
          0.65,
          0.8,
        ];

    //将2pi分为keywords.length等份
    double dAngleStep = 2 * pi / keywords.length;
    for (int i = 0; i < keywords.length; i++) {
      //极坐标方位角
      double dAngle = dAngleStep * i;
      //仰角
      double eAngle = (centers[i % 10] + (random.nextDouble() - 0.5) / 10) * pi;

      //球极坐标转为直角坐标
      double x = radius * sin(eAngle) * sin(dAngle);
      double y = radius * cos(eAngle);
      double z = radius * sin(eAngle) * cos(dAngle);

      Point point = Point(x, y, z);
      point.data = keywords[i];
      String showName = point.data.tag;
      bool needHight = _needHight(point.data);
      if (point.data.tag.characters.length > maxChar) {
        showName =
            keywords[i].tag.characters.getRange(0, maxChar).toString() + '...';
      }
      //计算point在各个z坐标时的paragraph
      point.paragraphs = [];
      //每3个z生成一个paragraphs，节省内存
      for (int z = -radius; z <= radius; z += 3) {
        point.paragraphs.add(
          buildText(
            showName,
            2.0 * radius,
            RBallViewUtil.getNameFontsize(z.toDouble()),
            RBallViewUtil.getPointOpacity(z.toDouble()),
            needHight,
          ),
        );
      }
      points.add(point);
    }
  }

  ///检查此关键字是否需要高亮
  bool _needHight(RBallTagData tag) {
    bool ret = false;
    if (widget.highlight.length > 0) {
      for (int i = 0; i < widget.highlight.length; i++) {
        if (tag == widget.highlight[i]) {
          ret = true;
          break;
        }
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShowDecoration) {
      return Container(
        decoration: widget.decoration ??
            BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(radius.toDouble()),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffeeeeee),
                  blurRadius: 5.0,
                )
              ],
            ),
        child: _buildBall(),
      );
    }
    return _buildBall();
  }

  Widget _buildBall() {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        downPosition = convertCoordinate(event.localPosition);
        lastPosition = convertCoordinate(event.localPosition);

        //速度跟踪队列
        clearQueue();
        addToQueue(PositionWithTime(downPosition, now));

        //手指触摸时停止动画
        controller.stop();
      },
      onPointerMove: (PointerMoveEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        Offset currentPostion = convertCoordinate(event.localPosition);

        addToQueue(PositionWithTime(currentPostion, now));

        Offset delta = Offset(currentPostion.dx - lastPosition.dx,
            currentPostion.dy - lastPosition.dy);
        double distance = sqrt(delta.dx * delta.dx + delta.dy * delta.dy);
        //若计算量级太小，框架内部会报精度溢出的错误
        if (distance > 2) {
          //旋转点
          setState(() {
            lastPosition = currentPostion;

            //球体应该旋转的弧度角度 = 距离/radius
            double radian = distance / radius;
            //旋转轴
            axisVector = getAxisVector(delta);
            //更新点的位置
            for (int i = 0; i < points.length; i++) {
              rotatePoint(axisVector, points[i], radian);
            }
          });
        }
      },
      onPointerUp: (PointerUpEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        Offset upPosition = convertCoordinate(event.localPosition);

        addToQueue(PositionWithTime(upPosition, now));

        //检测是否是fling手势
        Offset velocity = getVelocity();
        if (widget.isAnimate) {
          //速度模量>=1就认为是fling手势
          if (sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy) >=
              1) {
            //开始fling动画
            currentRadian = 0;
            controller.fling();
          } else {
            //开始匀速动画
            currentRadian = 0;
            controller.forward(from: 0.0);
          }
        }

        //检测点击事件
        double distanceSinceDown = sqrt(
            pow(upPosition.dx - downPosition.dx, 2) +
                pow(upPosition.dy - downPosition.dy, 2));
        //按下和抬起点的距离小于4，认为是点击事件
        if (distanceSinceDown < 4) {
          //寻找命中的point
          int searchRadiusW = RBallViewUtil.nameHalfSize.toInt() * 3;
          int searchRadiusH = (RBallViewUtil.nameHalfSize +
                      RBallViewUtil.pointHalfTop +
                      RBallViewUtil.pointHalfWidth)
                  .toInt() *
              2;
          for (int i = 0; i < points.length; i++) {
            //points[i].z >= 0：只在球正面的点中寻找
            if (points[i].z >= 0 &&
                (upPosition.dx - points[i].x).abs() < searchRadiusW &&
                (upPosition.dy - points[i].y).abs() < searchRadiusH) {
              int now = DateTime.now().millisecondsSinceEpoch;
              //防止双击
              if (now - lastHitTime > 2000) {
                lastHitTime = now;
                //创建点选中动画序列
                pointAnimationSequence = PointAnimationSequence(
                    points[i], _needHight(points[i].data));

                // 回调
                widget.onTapRBallTagCallback?.call(points[i].data);
              }
              break;
            }
          }
        }
      },
      onPointerCancel: (_) {
        //开始匀速动画
        currentRadian = 0;
        controller.forward(from: 0.0);
      },
      child: ClipOval(
        child: CustomPaint(
          size: Size(2.0 * radius, 2.0 * radius),
          painter: MyPainter(points),
        ),
      ),
    );
  }

  ///速度跟踪队列
  Queue<PositionWithTime> queue = Queue();

  ///添加跟踪点
  void addToQueue(PositionWithTime p) {
    int lengthOfQueue = 5;
    if (queue.length >= lengthOfQueue) {
      queue.removeFirst();
    }

    queue.add(p);
  }

  ///清空队列
  void clearQueue() {
    queue.clear();
  }

  ///计算速度
  ///速度单位：像素/毫秒
  Offset getVelocity() {
    Offset ret = Offset.zero;

    if (queue.length >= 2) {
      PositionWithTime first = queue.first;
      PositionWithTime last = queue.last;
      ret = Offset(
        (last.position.dx - first.position.dx) / (last.time - first.time),
        (last.position.dy - first.position.dy) / (last.time - first.time),
      );
    }

    return ret;
  }
}

class MyPainter extends CustomPainter {
  List<Point> points;
  late Paint ballPaint, pointPaint;

  MyPainter(this.points) {
    pointPaint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //绘制文字
    for (int i = 0; i < points.length; i++) {
      Point point = points[i];
      List<double> xy = transformCoordinate(point);
      ui.Paragraph p;
      //是被选中的点，需要展示放大缩小效果
      if (pointAnimationSequence != null &&
          pointAnimationSequence?.point == point) {
        //动画未播放完毕
        if (pointAnimationSequence!.paragraphs.isNotEmpty) {
          p = pointAnimationSequence!.paragraphs.removeFirst();
          //动画已播放完毕
        } else {
          p = point.getParagraph(radius);
          pointAnimationSequence = null;
        }
      } else {
        p = point.getParagraph(radius);
      }

      //获得文字的宽高
      double halfWidth = p.minIntrinsicWidth / 2;
      double halfHeight = p.height / 2;
      //绘制文字（point中是3d模型坐标系中的坐标，需要转换为绘图坐标系中的坐标）
      canvas.drawParagraph(
        p,
        Offset(xy[0] - halfWidth, xy[1] - halfHeight),
      );
      //绘制圆点
      pointPaint
        ..color = Colors.primaries[i % 17]
            .withOpacity(RBallViewUtil.getPointOpacity(point.z))
        ..strokeWidth = RBallViewUtil.getPointStrokeWidth(point.z);

      canvas.drawPoints(
          ui.PointMode.points,
          [
            Offset(xy[0],
                xy[1] + p.height + RBallViewUtil.getPointTopMargin(point.z))
          ],
          pointPaint);
    }
  }

  ///将3d模型坐标系中的坐标转换为绘图坐标系中的坐标
  ///x2 = r+x1;y2 = r-y1;
  List<double> transformCoordinate(Point point) {
    return [radius + point.x, radius - point.y, point.z];
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

///计算点point绕轴axis旋转radian弧度后的点坐标
///计算依据：罗德里格旋转矢量公式
void rotatePoint(
  Point axis,
  Point point,
  double radian,
) {
  double x = cos(radian) * point.x +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.x +
      sin(radian) * (axis.y * point.z - axis.z * point.y);

  double y = cos(radian) * point.y +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.y +
      sin(radian) * (axis.z * point.x - axis.x * point.z);

  double z = cos(radian) * point.z +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.z +
      sin(radian) * (axis.x * point.y - axis.y * point.x);

  point.x = x;
  point.y = y;
  point.z = z;
}

///根据手指触摸移动的直线距离，计算球体应该转动的近似角度
///单位角度对应的圆弧长度：2*pi*r/2*pi = 1/r
double getRadian(double distance) {
  return distance / radius;
}

//将绘图坐标系中的坐标转换为3d模型坐标系中的坐标
Offset convertCoordinate(Offset offset) {
  return Offset(offset.dx - radius, radius - offset.dy);
}

///由旋转矢量得到旋转轴方向的单位矢量
///将旋转矢量(x,y)逆时针旋转90度即可
///x2 = xcos(pi/2)-ysin(pi/2)
///y2 = xsin(pi/2)+ycos(pi/2)
Point getAxisVector(Offset scrollVector) {
  double x = -scrollVector.dy;
  double y = scrollVector.dx;
  double module = sqrt(x * x + y * y);
  return Point(x / module, y / module, 0);
}

ui.Paragraph buildText(
  String content,
  double maxWidth,
  double fontSize,
  double opacity,
  bool highLight,
) {
  String text = content;

  ui.ParagraphBuilder paragraphBuilder =
      ui.ParagraphBuilder(ui.ParagraphStyle());
  paragraphBuilder.pushStyle(
    ui.TextStyle(
        fontSize: fontSize,
        color: highLight
            ? highLightTextColor.withOpacity(opacity)
            : textColor.withOpacity(opacity),
        height: 1.0,
        shadows: highLight
            ? [
                Shadow(
                  color: Colors.white.withOpacity(opacity),
                  offset: Offset(0, 0),
                  blurRadius: 10,
                )
              ]
            : []),
  );
  paragraphBuilder.addText(text);

  ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
  return paragraph;
}

class Point {
  double x, y, z;
  late RBallTagData data;
  late List<ui.Paragraph> paragraphs;

  Point(this.x, this.y, this.z);

  //z取值[-radius,radius]时的paragraph，依次存储在paragraphs中
  //每3个z生成一个paragraphs
  getParagraph(int radius) {
    int index = (z + radius).round() ~/ 3;
    return paragraphs[index];
  }
}

class PositionWithTime {
  Offset position;
  int time;

  PositionWithTime(this.position, this.time);
}

class PointAnimationSequence {
  late Point point;
  late bool needHighLight;
  late Queue<ui.Paragraph> paragraphs;

  PointAnimationSequence(this.point, this.needHighLight) {
    paragraphs = Queue();

    double fontSize = RBallViewUtil.getNameFontsize(point.z);
    double opacity = RBallViewUtil.getPointOpacity(point.z);
    //字号从fontSize变化到16
    for (double fs = fontSize;
        fs <= RBallViewUtil.nameHalfSize * 2 + 5;
        fs += 1) {
      paragraphs.addLast(
          buildText(point.data.tag, 2.0 * radius, fs, opacity, needHighLight));
    }
    //字号从16变化到fontSize
    for (double fs = RBallViewUtil.nameHalfSize * 2 + 5;
        fs >= fontSize;
        fs -= 1) {
      paragraphs.addLast(
          buildText(point.data.tag, 2.0 * radius, fs, opacity, needHighLight));
    }
  }
}

RBallTagData tagModelFromJson(String str) =>
    RBallTagData.fromJson(json.decode(str));

String tagModelToJson(RBallTagData data) => json.encode(data.toJson());

class RBallTagData {
  RBallTagData({
    required this.tag,
    required this.id,
  });

  String tag;
  String id;

  factory RBallTagData.fromJson(Map<String, dynamic> json) => RBallTagData(
        tag: json["tag"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "tag": tag,
        "id": id,
      };
}

/// 工具方法
class RBallViewUtil {
  static int itemCount = 30;

  static double nameHalfSize = 6;
  static double pointHalfTop = 3;
  static double pointHalfWidth = 9;

  ///
  /// 获取名字大小, 对应文字的尺寸为[6,12]
  static double getNameFontsize(double z, {double? halfSize}) {
    halfSize ??= nameHalfSize;
    return _getDisplaySize(z, halfSize);
  }

  /// 获取透明度, 对应点的透明度为[0.5,1]
  static double getPointOpacity(double z, [double halfOpacity = 0.5]) {
    return _getDisplaySize(z, halfOpacity);
  }

  /// 获取点和文字间距
  static double getPointTopMargin(double z, {double? halfTop}) {
    halfTop ??= pointHalfTop;
    return _getDisplaySize(z, halfTop);
  }

  /// 获取点大小
  static double getPointStrokeWidth(double z, {double? halfWidth}) {
    halfWidth ??= pointHalfWidth;
    return _getDisplaySize(z, halfWidth);
  }

  /// 根据比例获取大小
  static double _getDisplaySize(double z, double halfValue) {
    return halfValue + halfValue * (z + radius) / (2 * radius);
  }
}
