import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: ThreeDMarqueeFullScreen()),
      ),
    );
  }
}

class ThreeDMarqueeFullScreen extends StatelessWidget {
  const ThreeDMarqueeFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Center(
            child: Stack(
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..rotateX(0.95)
                        ..rotateZ(-0.8),
                  child: const ThreeDMarquee(),
                ),
                const GridLinesOverlay(),
                // upgraded radial glow
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.2),
                      radius: 1.8,
                      colors: [
                        Colors.white.withOpacity(0.07),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ThreeDMarquee extends StatelessWidget {
  const ThreeDMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: FloatingColumn(
            delay: Duration(milliseconds: index * 400),
            duration: Duration(seconds: index % 2 == 0 ? 10 : 15),
            reverse: index % 2 == 0,
          ),
        );
      }),
    );
  }
}

class FloatingColumn extends StatefulWidget {
  final Duration delay;
  final Duration duration;
  final bool reverse;

  const FloatingColumn({
    super.key,
    required this.delay,
    required this.duration,
    this.reverse = false,
  });

  @override
  State<FloatingColumn> createState() => _FloatingColumnState();
}

class _FloatingColumnState extends State<FloatingColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final images = [
    "https://assets.aceternity.com/glare-card.png",
    "https://assets.aceternity.com/carousel.webp",
    "https://assets.aceternity.com/wobble-card.png",
    "https://assets.aceternity.com/vortex.png",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0,
      end: widget.reverse ? -100 : 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                images.map((url) => InteractiveCard(imageUrl: url)).toList(),
          ),
        );
      },
    );
  }
}

class InteractiveCard extends StatefulWidget {
  final String imageUrl;
  const InteractiveCard({super.key, required this.imageUrl});

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            Matrix4.identity()
              ..scale(_pressed ? 1.05 : 1.0)
              ..rotateZ(_pressed ? 0.02 : 0),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(_pressed ? 0.2 : 0.08),
              blurRadius: 25,
              spreadRadius: 10,
            ),
          ],
        ),
        width: double.infinity,
        height: 180,
      ),
    );
  }
}

class GridLinesOverlay extends StatelessWidget {
  const GridLinesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: GridPainter(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;

    // horizontal lines with fade
    for (double y = 0; y < size.height; y += 80) {
      paint.color = Colors.white.withOpacity(0.05 * (1 - y / size.height));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // vertical lines with fade
    for (double x = 0; x < size.width; x += size.width / 4) {
      paint.color = Colors.white.withOpacity(0.05 * (1 - x / size.width));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
