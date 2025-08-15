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
          begin: 60,
          end: 100,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 100,
          end: 90,
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
  final double radius;
  drawanimated(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final oPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final c = size.center(Offset.zero);
    canvas.drawCircle(c, radius, oPaint);
  }

  @override
  bool shouldRepaint(covariant drawanimated oldDelegate) {
    return oldDelegate.radius != radius;
  }
}
