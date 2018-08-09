import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bouncing Ball',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new BouncingBall(),
    );
  }
}

class BouncingBall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bouncing Ball"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: TouchHandler(),
      ),
    );
  }
}

class TouchHandler extends StatefulWidget {
  @override
  _TouchHandlerState createState() => _TouchHandlerState();
}

class _TouchHandlerState extends State<TouchHandler>
    with TickerProviderStateMixin {
  AnimationController
      _ballRadiusController; // Will control the size of the ball
  AnimationController
      _ballPositionController; // Will control the ball position when falling
  Offset _ballPosition; // Will tell the position of the ball
  double _screenHeight;
  double _initialHeight;

  void _onTapDown(TapDownDetails details) {
    _ballRadiusController.reset();
    _ballPositionController.reset();
    _ballRadiusController.forward();
    setState(() {
      _ballPosition = details.globalPosition;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _ballPosition = details.globalPosition;
    });
    _ballRadiusController.stop();
    _startFall();
  }

  void _onPanStart(DragStartDetails details) {
    _ballPositionController.reset();
    if (!_ballRadiusController.isAnimating) {
      _ballRadiusController.reset();
      _ballRadiusController.forward();
    }
    setState(() {
      _ballPosition = details.globalPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    print(details.globalPosition.dx.toString() +
        " , " +
        details.globalPosition.dy.toString() +
        " end: " +
        _screenHeight.toString());
    setState(() {
      _ballPosition = details.globalPosition;
    });
  }

  // May use this to add more interactivity to control the ball
  void _onPanEnd(DragEndDetails details) {
    print("Pan End X :" + details.velocity.pixelsPerSecond.dx.toString());
    print("Pan End Y :" + details.velocity.pixelsPerSecond.dy.toString());
    _ballRadiusController.stop();
    _startFall();
  }

  void _startFall() {
    setState(() {
      _initialHeight = _ballPosition.dy;
    });
    _ballPositionController.animateWith(GravitySimulation(8.0, 0.0, _screenHeight + _ballRadiusController.value, 0.0));
  }

  @override
  void initState() {
    super.initState();
    _ballRadiusController = AnimationController(
        duration: Duration(seconds: 5), upperBound: 150.0, vsync: this);
    _ballPositionController = AnimationController(duration: Duration(seconds: 5), vsync: this);
    _ballPosition = Offset.zero;
    _initialHeight = 0.0;
    _ballPositionController.addListener((){
      setState(() {
        _ballPosition = Offset(_ballPosition.dx, _initialHeight + _ballPositionController.value * (_screenHeight + _ballRadiusController.value - _initialHeight));
      });
    });
  }

  @override
  void dispose() {
    _ballRadiusController.dispose();
    _ballPositionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    // Not going to use onPanDown, instead will use onTapDown as will be using onTapUp instead of onPanCancel
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        child: CustomPaint(
          painter: BallPainter(
              radiusController: _ballRadiusController,
              position: _ballPosition ?? Offset.zero,
              color: Colors.redAccent,
              screenHeight: _screenHeight,
          ),
        ),
      ),
    );
  }
}

class BallPainter extends CustomPainter {
  final AnimationController radiusController;
  final Offset position;
  final Color color;
  final double screenHeight;

  BallPainter({
    @required this.radiusController,
    @required this.position,
    this.color = Colors.redAccent,
    @required this.screenHeight
  }) : super(repaint: radiusController);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx, position.dy - (screenHeight - size.height)), radiusController.value, paint);
  }

  @override
  bool shouldRepaint(BallPainter old) => true;
}
