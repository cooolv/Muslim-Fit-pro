import 'dart:math' as m;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'parts_data.dart';

/// وضعية الجسم. الزوايا بالدرجات على الشاشة: 0=يمين، 90=أسفل، -90=أعلى (الشخصية تنظر لليمين).
/// الترتيب: الجذع، الرأس، العضد، الساعد، الفخذ، الساق، القدم. الرجل الثانية (البعيدة) اختيارية: th2, sh2, ft2
/// وزاوية اليد hd اختيارية (وإلا تتبع الساعد).
class Pose {
  final double torso, head, ua, fa, th, sh, ft, th2, sh2, ft2;
  final double? hd;
  const Pose(this.torso, this.head, this.ua, this.fa, this.th, this.sh, this.ft, {double? th2, double? sh2, double? ft2, this.hd})
      : th2 = th2 ?? th, sh2 = sh2 ?? sh, ft2 = ft2 ?? ft;
  static Pose lerp(Pose a, Pose b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    final h = (a.hd == null && b.hd == null) ? null : l(a.hd ?? a.fa, b.hd ?? b.fa);
    return Pose(l(a.torso, b.torso), l(a.head, b.head), l(a.ua, b.ua), l(a.fa, b.fa), l(a.th, b.th), l(a.sh, b.sh), l(a.ft, b.ft),
        th2: l(a.th2, b.th2), sh2: l(a.sh2, b.sh2), ft2: l(a.ft2, b.ft2), hd: h);
  }
}

class Rig {
  final List<Pose> frames; // الحركة تمرّ بالإطارات ذهابًا وإيابًا
  final bool dumbbell, seat, bench, anchorHip;
  final double? handAbs; // زاوية اليد المطلقة (وإلا تتبع الساعد)
  const Rig(this.frames, {this.dumbbell = false, this.handAbs, this.seat = false, this.bench = false, this.anchorHip = false});
}

// عدّل الزوايا هنا لضبط أي تمرين بدقة.
const rigs = <String, Rig>{
  'pushup': Rig([Pose(-32, -32, 90, 90, 148, 148, 65), Pose(-5, -5, 170, 38, 175, 175, 65)], handAbs: 0),
  'squat': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-60, -60, 0, 0, 10, 100, 0)]),
  'dbcurl': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 90, -50, 90, 90, 0)], dumbbell: true),
  'dbpress': Rig([Pose(-90, -90, 90, -90, 90, 90, 0), Pose(-90, -90, -90, -90, 90, 90, 0)], dumbbell: true),
  'situp': Rig([Pose(180, 180, 0, 0, -55, 75, 0), Pose(310, 310, 0, 0, -55, 75, 0)]),
  'glute': Rig([Pose(180, 180, 0, 0, -55, 75, 0), Pose(160, 160, 0, 0, -20, 49, 0)]),
  'plank': Rig([Pose(-11, -11, 90, 0, 169, 169, 65), Pose(-13, -13, 90, 0, 167, 167, 65)], handAbs: 0),
  'mountain': Rig([Pose(-32, -32, 90, 90, 148, 148, 65), Pose(-32, -32, 90, 90, 50, 140, 20)], handAbs: 0),
  'dbgoblet': Rig([Pose(-90, -90, 90, -45, 90, 90, 0), Pose(-72, -72, 90, -45, 10, 100, 0)], dumbbell: true),
  'dbrdl': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-25, -25, 90, 90, 80, 95, 0)], dumbbell: true),
  'deadlift': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-25, -25, 90, 90, 80, 95, 0)], dumbbell: true),
  'dbrow': Rig([Pose(-25, -25, 90, 100, 80, 95, 0), Pose(-25, -25, 160, 100, 80, 95, 0)], dumbbell: true),
  'calf': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 90, 90, 90, 90, 40)]),
  'superman': Rig([Pose(0, 0, 0, 0, 180, 180, 180), Pose(-12, -12, -15, -15, 168, 168, 168)]),
  'legcurl': Rig([Pose(0, 0, 0, 0, 180, 180, 180), Pose(0, 0, 0, 0, 180, 250, 250)]),
  'tricep': Rig([Pose(-90, -90, 90, 0, 90, 90, 0), Pose(-90, -90, 90, 90, 90, 90, 0)]),
  'dbtriext': Rig([Pose(-90, -90, -90, 135, 90, 90, 0), Pose(-90, -90, -90, -90, 90, 90, 0)], dumbbell: true),
  'latpull': Rig([Pose(-90, -90, -90, -90, 0, 90, 0), Pose(-90, -90, 100, -80, 0, 90, 0)], seat: true),
  'seatedrow': Rig([Pose(-90, -90, 0, 0, 0, 90, 0), Pose(-100, -100, 120, -5, 0, 90, 0)], seat: true),
  'shoulderpress': Rig([Pose(-90, -90, 90, -90, 0, 90, 0), Pose(-90, -90, -90, -90, 0, 90, 0)], seat: true),
  'lunge': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 90, 90, 5, 90, 0, th2: 115, sh2: 190, ft2: 75)]),
  'burpee': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-35, -35, 90, 90, 20, 100, 0), Pose(-32, -32, 90, 90, 148, 148, 65, hd: 0)]),
  'jacks': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, -85, -90, 60, 85, 0, th2: 120, sh2: 95, ft2: 0)]),
  'dips': Rig([Pose(-90, -90, 90, 90, 5, 90, 0, hd: 180), Pose(-90, -90, 140, 65, 5, 90, 0, hd: 180)]),
  'pike': Rig([Pose(90, 90, 80, 0, 125, 125, 65, hd: 0), Pose(43, 43, 80, 0, 140, 140, 65, hd: 0)]),
  'dbfly': Rig([Pose(180, 180, -90, -90, -55, 75, 0), Pose(180, 180, -145, -165, -55, 75, 0)], dumbbell: true),
  'dblateral': Rig([Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 15, 10, 90, 90, 0)], dumbbell: true),
  'bench': Rig([Pose(180, 180, 80, -90, -50, 70, 0), Pose(180, 180, -90, -90, -50, 70, 0)], dumbbell: true, bench: true),
  'legpress': Rig([Pose(215, 215, 70, 70, -45, 45, -90), Pose(215, 215, 70, 70, -20, -20, -70)], seat: true),
  'cablefly': Rig([Pose(-82, -82, 150, 135, 90, 90, 0), Pose(-82, -82, 15, 5, 90, 90, 0)]),
  'treadmill': Rig([Pose(-80, -80, 40, -60, 45, 95, 0, th2: 115, sh2: 160, ft2: 30), Pose(-80, -80, 130, 30, 115, 160, 30, th2: 45, sh2: 95, ft2: 0)], anchorHip: true),
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
  final List<(String, Offset, double, bool)> parts; // الاسم، الموضع، الزاوية، رجل بعيدة؟
  final Offset ankle, wrist;
  final double hand, ground, ax;
  final Rect bounds; // نسبةً لنقطة الارتكاز والأرض
  _Geo(this.parts, this.ankle, this.wrist, this.hand, this.ground, this.ax, this.bounds);
}

_Geo _geo(Pose p, Rig r) {
  double L(String k) => _len(k) * _s;
  const hip = Offset.zero;
  final neck = hip + _dir(p.torso, L('torso')), sho = hip + _dir(p.torso, L('torso') * .83);
  final knee = hip + _dir(p.th, L('thigh')), ankle = knee + _dir(p.sh, L('shin'));
  final knee2 = hip + _dir(p.th2, L('thigh')), ankle2 = knee2 + _dir(p.sh2, L('shin'));
  final elbow = sho + _dir(p.ua, L('uarm')), wrist = elbow + _dir(p.fa, L('farm'));
  final hand = p.hd ?? r.handAbs ?? p.fa;
  final parts = <(String, Offset, double, bool)>[
    ('foot', ankle2, p.ft2, true), ('shin', knee2, p.sh2, true), ('thigh', hip, p.th2, true),
    ('foot', ankle, p.ft, false), ('shin', knee, p.sh, false), ('thigh', hip, p.th, false), ('torso', hip, p.torso, false),
    ('head', neck, p.head, false), ('hand', wrist, hand, false), ('farm', elbow, p.fa, false), ('uarm', sho, p.ua, false),
  ];
  final all = [for (final x in parts) ..._corners(x.$1, x.$2, x.$3)];
  final contact = [
    ..._corners('foot', ankle, p.ft), ..._corners('foot', ankle2, p.ft2), ..._corners('hand', wrist, hand),
    hip + const Offset(0, 13), neck + const Offset(0, 13), knee + const Offset(0, 9), knee2 + const Offset(0, 9), elbow + const Offset(0, 7),
  ];
  final ground = contact.map((o) => o.dy).reduce(m.max);
  final ax = r.anchorHip ? 0.0 : ankle.dx;
  final b = all.fold<Rect?>(null, (a, o) => a == null ? Rect.fromLTWH(o.dx, o.dy, 0, 0) : a.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0)))!;
  return _Geo(parts, ankle, wrist, hand, ground, ax, b.shift(Offset(-ax, -ground)));
}

Pose _at(Rig r, double tri) {
  final n = r.frames.length - 1;
  final x = tri * n;
  final i = x.floor().clamp(0, n - 1).toInt();
  return Pose.lerp(r.frames[i], r.frames[i + 1], Curves.easeInOut.transform(x - i));
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
                  return CustomPaint(painter: _P(widget.rig, tri, _img!));
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
    final g = _geo(_at(r, t), r);
    final u = r.frames.map((f) => _geo(f, r).bounds).reduce((a, b) => a.expandToInclude(b)).inflate(6); // إطار ثابت للحركة كلها
    final k = m.min(sz.width / u.width, sz.height / u.height);
    cv.save();
    cv.translate(sz.width / 2 - k * u.center.dx, sz.height / 2 - k * u.center.dy);
    cv.scale(k);
    cv.translate(-g.ax, -g.ground);
    cv.drawLine(Offset(g.ax + u.left, g.ground), Offset(g.ax + u.right, g.ground), Paint()..color = Colors.grey.withValues(alpha: .5)..strokeWidth = 2);
    if (r.seat) cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-4, 20), width: 60, height: 10), const Radius.circular(4)), Paint()..color = const Color(0xFF546E7A));
    if (r.bench) cv.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-90, 15, 130, 6), const Radius.circular(3)), Paint()..color = const Color(0xFF546E7A));
    final near = Paint()..filterQuality = FilterQuality.high..isAntiAlias = true;
    final far = Paint()..filterQuality = FilterQuality.high..isAntiAlias = true..colorFilter = const ColorFilter.mode(Color(0x55000000), BlendMode.srcATop);
    for (final (name, pos, theta, isFar) in g.parts) {
      final p = partMeta[name]!;
      cv.save();
      cv.translate(pos.dx, pos.dy);
      cv.rotate(_rad(_rot(name, theta)));
      cv.scale(_s);
      cv.drawImage(img[name]!, Offset(-p[2], -p[3]), isFar ? far : near);
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
