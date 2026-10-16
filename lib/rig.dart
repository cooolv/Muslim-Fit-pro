import 'dart:math' as m;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'parts_data.dart';

/// وضعية الجسم. الزوايا بالدرجات على الشاشة: 0=يمين، 90=أسفل، -90=أعلى (الشخصية تنظر لليمين).
/// الترتيب: الجذع، الرأس، العضد، الساعد، الفخذ، الساق، القدم
class Pose {
  final double torso, head, ua, fa, th, sh, ft;
  const Pose(this.torso, this.head, this.ua, this.fa, this.th, this.sh, this.ft);
  static Pose lerp(Pose a, Pose b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return Pose(l(a.torso, b.torso), l(a.head, b.head), l(a.ua, b.ua), l(a.fa, b.fa), l(a.th, b.th), l(a.sh, b.sh), l(a.ft, b.ft));
  }
}

class Rig {
  final Pose a, b; // البداية والنهاية (ذهابًا وإيابًا)
  final bool dumbbell;
  final double? handAbs; // زاوية اليد المطلقة (وإلا تتبع الساعد)
  const Rig(this.a, this.b, {this.dumbbell = false, this.handAbs});
}

// عدّل الزوايا هنا لضبط أي تمرين بدقة.
const rigs = <String, Rig>{
  'pushup': Rig(Pose(-32, -32, 90, 90, 148, 148, 65), Pose(-5, -5, 170, 38, 175, 175, 65), handAbs: 0),
  'squat': Rig(Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-60, -60, 0, 0, 10, 100, 0)),
  'dbcurl': Rig(Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 90, -50, 90, 90, 0), dumbbell: true),
  'dbpress': Rig(Pose(-90, -90, 90, -90, 90, 90, 0), Pose(-90, -90, -90, -90, 90, 90, 0), dumbbell: true),
  'situp': Rig(Pose(180, 180, 0, 0, -55, 75, 0), Pose(310, 310, 0, 0, -55, 75, 0)),
  'glute': Rig(Pose(180, 180, 0, 0, -55, 75, 0), Pose(160, 160, 0, 0, -20, 49, 0)),
};

class Sprites {
  static Future<Map<String, ui.Image>>? _f;
  static Future<Map<String, ui.Image>> load() => _f ??= () async {
        final r = <String, ui.Image>{};
        for (final k in partMeta.keys) {
          final d = await rootBundle.load('assets/rig/$k.png');
          final c = await ui.instantiateImageCodec(d.buffer.asUint8List());
          r[k] = (await c.getNextFrame()).image;
        }
        return r;
      }();
}

double _len(String k) {
  final p = partMeta[k]!;
  return m.sqrt(m.pow(p[4] - p[2], 2) + m.pow(p[5] - p[3], 2));
}

final double _s = 60 / _len('torso'); // وحدة: الجذع = 60
double _rad(double d) => d * m.pi / 180;
Offset _dir(double deg, double len) => Offset(len * m.cos(_rad(deg)), len * m.sin(_rad(deg)));
double _rot(String k, double theta) {
  final p = partMeta[k]!;
  return theta - m.atan2(p[5] - p[3], p[4] - p[2]) * 180 / m.pi;
}

List<Offset> _corners(String k, Offset pos, double theta) {
  final p = partMeta[k]!;
  final r = _rad(_rot(k, theta));
  return [for (final c in [Offset(0, 0), Offset(p[0], 0), Offset(p[0], p[1]), Offset(0, p[1])])
    pos + Offset(((c.dx - p[2]) * m.cos(r) - (c.dy - p[3]) * m.sin(r)) * _s, ((c.dx - p[2]) * m.sin(r) + (c.dy - p[3]) * m.cos(r)) * _s)];
}

class _Geo {
  final List<(String, Offset, double)> parts;
  final Offset ankle, wrist;
  final double hand, ground;
  final Rect bounds; // نسبةً لموضع الكاحل والأرض
  _Geo(this.parts, this.ankle, this.wrist, this.hand, this.ground, this.bounds);
}

_Geo _geo(Pose p, Rig r) {
  double L(String k) => _len(k) * _s;
  const hip = Offset.zero;
  final neck = hip + _dir(p.torso, L('torso')), sho = hip + _dir(p.torso, L('torso') * .83);
  final knee = hip + _dir(p.th, L('thigh')), ankle = knee + _dir(p.sh, L('shin'));
  final elbow = sho + _dir(p.ua, L('uarm')), wrist = elbow + _dir(p.fa, L('farm'));
  final hand = r.handAbs ?? p.fa;
  final parts = <(String, Offset, double)>[
    ('foot', ankle, p.ft), ('shin', knee, p.sh), ('thigh', hip, p.th), ('torso', hip, p.torso),
    ('head', neck, p.head), ('hand', wrist, hand), ('farm', elbow, p.fa), ('uarm', sho, p.ua),
  ];
  final all = [for (final x in parts) ..._corners(x.$1, x.$2, x.$3)];
  final contact = [..._corners('foot', ankle, p.ft), ..._corners('hand', wrist, hand), hip + const Offset(0, 13), neck + const Offset(0, 13), knee + const Offset(0, 9), elbow + const Offset(0, 7)];
  final ground = contact.map((o) => o.dy).reduce(m.max);
  final b = all.fold<Rect?>(null, (a, o) => a == null ? Rect.fromLTWH(o.dx, o.dy, 0, 0) : a.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0)))!;
  return _Geo(parts, ankle, wrist, hand, ground, b.shift(Offset(-ankle.dx, -ground)));
}

class RigView extends StatefulWidget {
  final Rig rig;
  final double size;
  const RigView(this.rig, {super.key, this.size = 64});
  @override
  State<RigView> createState() => _RigViewState();
}

class _RigViewState extends State<RigView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  Map<String, ui.Image>? _img;
  @override
  void initState() {
    super.initState();
    Sprites.load().then((v) {
      if (mounted) setState(() => _img = v);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size, height: widget.size,
        child: _img == null
            ? const SizedBox.shrink()
            : AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final tri = _c.value < .5 ? _c.value * 2 : (1 - _c.value) * 2;
                  return CustomPaint(painter: _P(widget.rig, Curves.easeInOut.transform(tri), _img!));
                }),
      );
}

class _P extends CustomPainter {
  final Rig r;
  final double t;
  final Map<String, ui.Image> img;
  _P(this.r, this.t, this.img);
  @override
  void paint(Canvas cv, Size sz) {
    final g = _geo(Pose.lerp(r.a, r.b, t), r);
    final u = _geo(r.a, r).bounds.expandToInclude(_geo(r.b, r).bounds).inflate(6); // إطار ثابت للحركة كلها
    final k = m.min(sz.width / u.width, sz.height / u.height);
    cv.save();
    cv.translate(sz.width / 2 - k * u.center.dx, sz.height / 2 - k * u.center.dy);
    cv.scale(k);
    cv.translate(-g.ankle.dx, -g.ground);
    cv.drawLine(Offset(g.ankle.dx + u.left, g.ground), Offset(g.ankle.dx + u.right, g.ground), Paint()..color = Colors.grey.withValues(alpha: .5)..strokeWidth = 2);
    final paint = Paint()..filterQuality = FilterQuality.high..isAntiAlias = true;
    for (final (name, pos, theta) in g.parts) {
      final p = partMeta[name]!;
      cv.save();
      cv.translate(pos.dx, pos.dy);
      cv.rotate(_rad(_rot(name, theta)));
      cv.scale(_s);
      cv.drawImage(img[name]!, Offset(-p[2], -p[3]), paint);
      cv.restore();
      if (name == 'hand' && r.dumbbell) {
        cv.save();
        cv.translate(g.wrist.dx, g.wrist.dy);
        cv.rotate(_rad(g.hand));
        cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 10), width: 30, height: 7), const Radius.circular(3)), Paint()..color = const Color(0xFF37474F));
        cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-14, 10), width: 6, height: 17), const Radius.circular(2)), Paint()..color = const Color(0xFF263238));
        cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(14, 10), width: 6, height: 17), const Radius.circular(2)), Paint()..color = const Color(0xFF263238));
        cv.restore();
      }
    }
    cv.restore();
  }

  @override
  bool shouldRepaint(_P o) => o.t != t;
}
