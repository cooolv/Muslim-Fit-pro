import 'dart:math' as m;
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app_info.dart';
import 'main.dart';

/// يشغّل Firebase خلف شاشة البداية (3.2 ثانية على الأقل) ثم يفتح التطبيق
class Boot extends StatefulWidget {
  const Boot({super.key});
  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  late Future<void> _f = _init();
  Future<void> _init() async {
    await Future.wait([_fb(), Future.delayed(const Duration(milliseconds: 3200))]);
  }

  Future<void> _fb() async {
    await Firebase.initializeApp(options: fbOptions);
    if (FirebaseAuth.instance.currentUser == null) await FirebaseAuth.instance.signInAnonymously();
  }

  @override
  Widget build(BuildContext c) => FutureBuilder<void>(
        future: _f,
        builder: (_, s) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: s.hasError
              ? Scaffold(
                  key: const ValueKey('err'),
                  body: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 8),
                      const Text('تعذر الاتصال. تحقق من الإنترنت'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => setState(() => _f = _init()), child: const Text('إعادة المحاولة')),
                    ]),
                  ),
                )
              : s.connectionState == ConnectionState.done
                  ? const Home(key: ValueKey('home'))
                  : const Splash(key: ValueKey('splash')),
        ),
      );
}

const _gold = Color(0xFFE2B857), _deep = Color(0xFF04261B), _green = Color(0xFF0B6B4D);

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _fade(double a, double b, Widget w, {double dy = 16}) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final v = Curves.easeOutCubic.transform(Interval(a, b).transform(_c.value));
          return Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: w));
        },
      );

  @override
  Widget build(BuildContext c) => Scaffold(
        backgroundColor: _deep,
        body: Stack(fit: StackFit.expand, children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_deep, Color(0xFF0A4A36), _deep]))),
          AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _Pattern(_c.value))),
          SafeArea(
            child: Column(children: [
              const SizedBox(height: 28),
              _fade(.05, .35, const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: TextStyle(color: _gold, fontSize: 22, letterSpacing: .5))),
              const Spacer(),
              SizedBox(
                width: 240, height: 240,
                child: Stack(alignment: Alignment.center, children: [
                  AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(size: const Size(240, 240), painter: _Ring(_c.value))),
                  _fade(.1, .5, ClipRRect(borderRadius: BorderRadius.circular(36), child: Image.asset('assets/icon/logo.png', width: 150, height: 150)), dy: 0),
                ]),
              ),
              const SizedBox(height: 18),
              _fade(.35, .65, const Text(kAppName, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
              const SizedBox(height: 6),
              _fade(.45, .75, const Text('تمارينك اليومية • بالزاوية والحركة • مجانًا', style: TextStyle(color: _gold, fontSize: 15))),
              const SizedBox(height: 18),
              _fade(.55, .85, const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text('«الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ» — رواه مسلم',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.8)),
              )),
              const Spacer(),
              SizedBox(height: 56, width: 280, child: AnimatedBuilder(animation: _c, builder: (_, __) => CustomPaint(painter: _Pulse(_c.value)))),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => LinearProgressIndicator(value: _c.value, minHeight: 4, color: _gold, backgroundColor: Colors.white12, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 10),
              const Text('v$kVersion  •  Flutter  •  Firestore', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 18),
            ]),
          ),
        ]),
      );
}

Path _star(Offset o, double r, double rot) {
  final p = Path();
  for (var k = 0; k < 2; k++) {
    for (var j = 0; j < 4; j++) {
      final a = rot + k * m.pi / 4 + j * m.pi / 2;
      final pt = o + Offset(r * m.cos(a), r * m.sin(a));
      j == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
  }
  return p;
}

/// زخرفة إسلامية هندسية: نجوم ثمانية على شبكة تنزلق ببطء
class _Pattern extends CustomPainter {
  final double v;
  _Pattern(this.v);
  @override
  void paint(Canvas cv, Size s) {
    const cell = 84.0;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _gold.withValues(alpha: .10);
    final off = v * cell;
    for (var y = -1; y * cell < s.height + cell; y++) {
      for (var x = -1; x * cell < s.width + cell; x++) {
        final o = Offset(x * cell + (y.isOdd ? cell / 2 : 0) + off, y * cell * .86 + off * .86);
        cv.drawPath(_star(o, 26, 0), paint);
        cv.drawCircle(o, 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Pattern o) => o.v != v;
}

class _Ring extends CustomPainter {
  final double v;
  _Ring(this.v);
  @override
  void paint(Canvas cv, Size s) {
    final o = s.center(Offset.zero);
    final k = Curves.easeOutBack.transform(Interval(0, .5).transform(v));
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = _gold.withValues(alpha: .85);
    cv.drawPath(_star(o, 112 * k, v * m.pi / 2), paint);
    cv.drawPath(_star(o, 96 * k, -v * m.pi / 3), paint..color = _gold.withValues(alpha: .4));
    cv.drawCircle(o, 82 * k, Paint()..shader = ui.Gradient.radial(o, 90, [_green.withValues(alpha: .6), Colors.transparent]));
  }

  @override
  bool shouldRepaint(_Ring o) => o.v != v;
}

/// نبض قلب يُرسم تدريجيًا (رمز الرياضة واللياقة)
class _Pulse extends CustomPainter {
  final double v;
  _Pulse(this.v);
  @override
  void paint(Canvas cv, Size s) {
    final h = s.height / 2, w = s.width;
    final p = Path()..moveTo(0, h);
    for (final pt in [[.30, 0.0], [.36, -.10], [.42, .55], [.48, -.95], [.54, .85], [.60, 0.0], [.70, -.18], [.78, 0.0], [1.0, 0.0]]) {
      p.lineTo(pt[0] * w, h + pt[1] * h);
    }
    final len = p.computeMetrics().first.length;
    cv.drawPath(p.computeMetrics().first.extractPath(0, len * Curves.easeInOut.transform(v)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = _gold);
  }

  @override
  bool shouldRepaint(_Pulse o) => o.v != v;
}
