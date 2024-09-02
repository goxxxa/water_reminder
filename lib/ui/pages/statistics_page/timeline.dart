import 'package:flutter/material.dart';

class TimeLine extends StatefulWidget {
  final Size size;
  const TimeLine({required this.size, super.key});

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: LinePainter(),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const startPoint = Offset(0, 0);
    final endPoint = Offset(size.width, 0);
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    drawTimeLine(startPoint, endPoint, canvas, paint);
    drawLineDashes(startPoint, endPoint, canvas, paint);
  }

  void drawTimeLine(
      Offset startPoint, Offset endPoint, Canvas canvas, Paint paint) {
    canvas.drawLine(startPoint, endPoint, paint);
  }

  void drawLineDashes(
      Offset startPoint, Offset endPoint, Canvas canvas, Paint paint) {
    const int dashWidth = 10;
    final int timeLineWidth =
        (endPoint.dx / 4 - startPoint.dx / 4).abs().toInt();
    for (int index = 0; index < 5; index++) {
      double dx = (timeLineWidth * index).toDouble();
      double dy = startPoint.dy;
      canvas.drawLine(Offset(dx, dy), Offset(dx, dy + dashWidth), paint);

      drawText(Offset(dx, dy + dashWidth + 5), Size(endPoint.dx, endPoint.dy),
          canvas, (6 * index).toString());
      //(index == 0 ? 0 : 24 ~/ (index + (3 - 2 * (index - 1)))).toString());
    }
  }

  void drawText(Offset offset, Size size, Canvas canvas, String displayedTime) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: displayedTime, style: TextStyle(color: Colors.grey.shade400)),
        textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    offset = Offset(offset.dx - (textPainter.size.width / 2), offset.dy);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
