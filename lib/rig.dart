import 'dart:math' as m;
import 'package:flutter/material.dart';

/// وضعية الجسم: كل زاوية بالدرجات في اتجاه الشاشة (0=يمين، 90=أسفل، -90=أعلى)، والشخصية تنظر لليمين.
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
  final Pose a, b; // البداية والنهاية (الحركة ذهابًا وإيابًا)
  final bool dumbbell;
  const Rig(this.a, this.b, {this.dumbbell = false});
}

// عدّل الزوايا هنا لضبط أي تمرين بدقة.
const rigs = <String, Rig>{
  'pushup': Rig(Pose(-26, -26, 90, 90, 154, 154, 60), Pose(-10, -10, 170, 40, 170, 170, 60)),
  'squat': Rig(Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-60, -60, 0, 0, 10, 100, 0)),
  'dbcurl': Rig(Pose(-90, -90, 90, 90, 90, 90, 0), Pose(-90, -90, 90, -50, 90, 90, 0), dumbbell: true),
  'dbpress': Rig(Pose(-90, -90, 90, -90, 90, 90, 0), Pose(-90, -90, -90, -90, 90, 90, 0), dumbbell: true),
  'situp': Rig(Pose(0, 0, 0, 0, -125, 110, 170), Pose(-65, -65, 0, 0, -125, 110, 170)),
  'glute': Rig(Pose(0, 0, 0, 0, -125, 110, 170), Pose(15, 15, 15, 15, -160, 130, 170)),
};

class RigView extends StatefulWidget {
  final Rig rig;
  final double size;
  const RigView(this.rig, {super.key, this.size = 64});
  @override
  State<RigView> createState() => _RigViewState();
}

class _RigViewState extends State<RigView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size, height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final tri = _c.value < .5 ? _c.value * 2 : (1 - _c.value) * 2;
            final p = Pose.lerp(widget.rig.a, widget.rig.b, Curves.easeInOut.transform(tri));
            return CustomPaint(painter: _RigPainter(p, widget.rig.dumbbell, Theme.of(context).colorScheme.primary));
          },
        ),
      );
}

class _RigPainter extends CustomPainter {
  final Pose p;
  final bool db;
  final Color shirt;
  _RigPainter(this.p, this.db, this.shirt);
  Offset _d(double deg, double len) => Offset(len * m.cos(deg * m.pi / 180), len * m.sin(deg * m.pi / 180));

  @override
  void paint(Canvas cv, Size s) {
    const hip = Offset.zero;
    final neck = hip + _d(p.torso, 60), head = neck + _d(p.head, 20);
    final elbow = neck + _d(p.ua, 32), wrist = elbow + _d(p.fa, 30);
    final knee = hip + _d(p.th, 42), ankle = knee + _d(p.sh, 40), toe = ankle + _d(p.ft, 14);
    final ground = [hip, neck, elbow, wrist, knee, ankle, toe].map((o) => o.dy).reduce(m.max);
    cv.save();
    cv.translate(s.width / 2, s.height * .86);
    cv.scale(s.height / 200);
    cv.translate(-ankle.dx, -ground); // القدم ثابتة والأرض ثابتة
    void line(Offset a, Offset b, double w, Color c) =>
        cv.drawLine(a, b, Paint()..color = c..strokeWidth = w..strokeCap = StrokeCap.round);
    line(Offset(ankle.dx - 150, ground + 6), Offset(ankle.dx + 150, ground + 6), 3, Colors.grey);
    const skin = Color(0xFFE8B98A), pants = Color(0xFF455A64);
    line(hip, knee, 12, pants);
    line(knee, ankle, 10, pants);
    line(ankle, toe, 9, Colors.white70);
    line(hip, neck, 16, shirt);
    line(neck, elbow, 9, skin);
    line(elbow, wrist, 8, skin);
    if (db) cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: wrist, width: 24, height: 9), const Radius.circular(3)), Paint()..color = Colors.blueGrey);
    cv.drawCircle(head, 13, Paint()..color = skin); // وجه مطموس
    cv.restore();
  }

  @override
  bool shouldRepaint(_RigPainter o) => o.p != p;
}
