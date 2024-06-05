import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CirclePageState createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  double _outerRadius = 200;
  double _innerRadius = 8;
  Offset _position = Offset.zero;
  Offset _velocity = const Offset(1, 1);
  final double _speed = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Normalize the velocity vector
    double magnitude = sqrt(_velocity.dx * _velocity.dx + _velocity.dy * _velocity.dy);
    _velocity = Offset(_velocity.dx / magnitude, _velocity.dy / magnitude);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updatePosition();
    });
  }

  void _updatePosition() {
    // Apply velocity to current position to get new position
    Offset newPos = _position + _velocity * _speed;

    // Distance from center to new position
    double newPosDistance = newPos.distance;

    // Check if the new position is outside the outer circle
    if (newPosDistance + _innerRadius > _outerRadius) {
      // Reflect the position and adjust velocity to bounce off the boundary
      double overshoot = newPosDistance + _innerRadius - _outerRadius;
      double correctionDistance = newPosDistance - overshoot;
      newPos = newPos * (correctionDistance / newPosDistance);

      // Reflect velocity
      double angle = atan2(newPos.dy, newPos.dx);
      _velocity = Offset(cos(angle), sin(angle)) * -1;

      // Trigger radius change animations
      triggerRadiusChange();
    }

    setState(() {
      _position = newPos;
    });
  }

  void triggerRadiusChange() {
    if (_innerRadius >= _outerRadius) return;

    _controller.forward(from: 0).then((_) {
      if (_outerRadius > _innerRadius + 10) {
        setState(() {
          _innerRadius += 10;
          _outerRadius -= 10;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: CirclePainter(_outerRadius, _innerRadius, _position),
          child: const SizedBox(
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double outerRadius;
  final double innerRadius;
  final Offset position;

  CirclePainter(this.outerRadius, this.innerRadius, this.position);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, outerRadius, paint);
    paint.color = Colors.white;
    canvas.drawCircle(center + position, innerRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}