import 'package:flutter/material.dart';

class JobVaaniLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const JobVaaniLogo({
    Key? key,
    this.size = 72,
    this.showText = false,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A), // Deep Indian Navy Blue
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withOpacity(0.18),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Stylized 'J' and 'V' soundwave / opportunity crest
              CustomPaint(
                size: Size(size * 0.6, size * 0.6),
                painter: _LogoPainter(),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Job',
                  style: TextStyle(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Vaani',
                  style: TextStyle(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D9488), // Professional Teal
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = const Color(0xFF2DD4BF) // Teal Accent
      ..style = PaintingStyle.fill;

    // Briefcase handle & body stylized
    final w = size.width;
    final h = size.height;

    // Opportunity Beacon arcs
    final arcPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.52), radius: w * 0.38),
      -2.4,
      1.6,
      false,
      arcPaint,
    );

    // Main letterform 'J' & 'V'
    final path = Path()
      ..moveTo(w * 0.32, h * 0.28)
      ..lineTo(w * 0.48, h * 0.66)
      ..lineTo(w * 0.68, h * 0.28)
      ..lineTo(w * 0.80, h * 0.28)
      ..lineTo(w * 0.54, h * 0.78)
      ..lineTo(w * 0.42, h * 0.78)
      ..lineTo(w * 0.20, h * 0.28)
      ..close();

    canvas.drawPath(path, paint);

    // Accent dot for "Vaani" (broadcast point)
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.07, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
