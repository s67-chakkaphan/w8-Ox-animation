import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: Scaffold(body: MyAnimated())),
    );
  }
}

class MyAnimated extends StatefulWidget {
  @override
  MyAnimatedState createState() => MyAnimatedState();
}

class MyAnimatedState extends State<MyAnimated> with TickerProviderStateMixin {
  bool popstate = false;

  late AnimationController _controller;
  late Animation<double> sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    sizeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 100,
          end: 60,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 60,
          end: 80,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pop_animated',
      home: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(1000, 800),
              painter: drawanimated(sizeAnimation.value),
            );
          },
        ),
      ),
    );
  }
}

class drawanimated extends CustomPainter {
  final double gap;
  drawanimated(this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final xPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    canvas.drawLine(
      Offset(0 + gap, 0 + gap),
      Offset(300 - gap, 300 - gap),
      xPaint,
    );
    canvas.drawLine(
      Offset(300 - gap, 0 + gap),
      Offset(0 + gap, 300 - gap),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(covariant drawanimated oldDelegate) {
    return oldDelegate.gap != gap;
  }
}
