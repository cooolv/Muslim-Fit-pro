import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cloud_access.dart';
import 'data.dart';
import 'error_reporter.dart';
import 'main.dart';
import 'player.dart';

/// مؤقت راحة بين المجموعات
class RestTimer extends StatefulWidget {
  const RestTimer({super.key});
  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  Timer? _t;
  int total = 60, left = 0;
  void start(int s) {
    _t?.cancel();
    setState(() => total = left = s);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (left <= 1) t.cancel();
      setState(() => left--);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text('وقت الراحة', style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              width: 90, height: 90,
              child: Stack(alignment: Alignment.center, children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: left <= 0 ? 0 : left / total),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, __) => SizedBox.expand(child: CircularProgressIndicator(value: v, strokeWidth: 8)),
                ),
                Text(left > 0 ? '$left' : '✓', style: const TextStyle(fontSize: 26)),
              ]),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final s in [30, 60, 90, 120]) OutlinedButton(onPressed: () => start(s), child: Text('$s ث')),
            ]),
          ]),
        ),
      );
}

/// تسجيل مجموعة (عدّات + وزن)
class LogSet extends StatefulWidget {
  final Ex e;
  const LogSet(this.e, {super.key});
  @override
  State<LogSet> createState() => _LogSetState();
}

class _LogSetState extends State<LogSet> {
  final reps = TextEditingController(), kg = TextEditingController();

  @override
  void dispose() {
    reps.dispose();
    kg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CloudAccessGate(
      builder: (user) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدّات'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'وزن كجم'))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final msg = ScaffoldMessenger.of(c);
                final r = int.tryParse(reps.text.trim());
                if (r == null || r <= 0 || r > 1000) {
                  msg.showSnackBar(const SnackBar(content: Text('أدخل عدد عدّات من 1 إلى 1000')));
                  return;
                }
                final weightText = kg.text.trim();
                final w = weightText.isEmpty ? 0.0 : double.tryParse(weightText);
                if (w == null || !w.isFinite || w < 0 || w > 1000) {
                  msg.showSnackBar(const SnackBar(content: Text('أدخل وزنًا صحيحًا من 0 إلى 1000 كجم')));
                  return;
                }
                FirebaseFirestore.instance.collection('logs').add({
                  'owner': user.uid, 'ex': widget.e.id, 'reps': r, 'kg': w, 'at': FieldValue.serverTimestamp(),
                }).then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {
                  reportAppError(error, stackTrace, source: 'Saving workout log');
                  if (c.mounted) msg.showSnackBar(SnackBar(content: Text('تعذر حفظ السجل: $error')));
                });
                reps.clear();
                kg.clear();
                msg.showSnackBar(const SnackBar(content: Text('حُفظ السجل محليًا وستتم مزامنته عند توفر الإنترنت')));
              },
              child: const Text('سجّل'),
            ),
          ]),
        ),
      ));
}

/// صفحة التقدم
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext c) => CloudAccessGate(
      builder: (user) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('logs')
            .where('owner', isEqualTo: user.uid)
            .snapshots(),
        builder: (_, s) {
          if (s.hasError) {
            reportAppErrorAfterFrame(s.error!, source: 'Loading workout progress');
            return Center(child: Text('تعذر التحميل: ${s.error}'));
          }
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final logs = <_WorkoutLog>[];
          for (final doc in s.data!.docs) {
            final log = _WorkoutLog.tryParse(doc.data());
            if (log != null) logs.add(log);
          }
          logs.sort((a, b) => b.at.compareTo(a.at));
          if (logs.isEmpty) return const Center(child: Text('سجّل أول مجموعة من صفحة أي تمرين'));
          final vol = logs.fold<double>(0, (p, log) {
            return p + log.reps * (log.kg == 0 ? 1.0 : log.kg);
          });
          final now = DateTime.now();
          final days = List.generate(7, (i) {
            final d = now.subtract(Duration(days: 6 - i));
            return logs.where((log) {
              return log.at.year == d.year && log.at.month == d.month && log.at.day == d.day;
            }).length;
          });
          final mx = days.reduce((a, b) => a > b ? a : b).clamp(1, 9999);
          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(child: _Stat('المجموعات', '${logs.length}')),
              Expanded(child: _Stat('الحجم الكلي', vol.toStringAsFixed(0))),
            ]),
            const SizedBox(height: 16),
            Text('آخر 7 أيام', style: Theme.of(c).textTheme.titleMedium),
            SizedBox(
              height: 120,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final n in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: n / mx * 100 + 4),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, h, __) => Container(
                            height: h, decoration: BoxDecoration(color: Theme.of(c).colorScheme.primary, borderRadius: BorderRadius.circular(6))),
                      ),
                    ),
                  ),
              ]),
            ),
            const Divider(),
            for (final log in logs.take(15))
              ListTile(
                dense: true,
                title: Text(exercises.where((e) => e.id == log.exerciseId).map((e) => e.name).firstOrNull ?? log.exerciseId),
                trailing: Text('${log.reps} × ${log.kg} كجم'),
              ),
          ]);
        },
      ));
}

class _WorkoutLog {
  final String exerciseId;
  final double reps, kg;
  final DateTime at;

  const _WorkoutLog({
    required this.exerciseId,
    required this.reps,
    required this.kg,
    required this.at,
  });

  static _WorkoutLog? tryParse(Map<String, dynamic> data) {
    final exerciseId = data['ex'];
    final reps = data['reps'];
    final kg = data['kg'];
    final timestamp = data['at'];
    if (exerciseId is! String ||
        exerciseId.isEmpty ||
        reps is! num ||
        kg is! num ||
        !reps.isFinite ||
        !kg.isFinite ||
        reps < 0 ||
        reps > 1000 ||
        kg < 0 ||
        kg > 1000 ||
        timestamp is! Timestamp) {
      return null;
    }

    return _WorkoutLog(
      exerciseId: exerciseId,
      reps: reps.toDouble(),
      kg: kg.toDouble(),
      at: timestamp.toDate(),
    );
  }
}

class _Stat extends StatelessWidget {
  final String t, v;
  const _Stat(this.t, this.v);
  @override
  Widget build(BuildContext c) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text(v, style: Theme.of(c).textTheme.headlineMedium), Text(t)])));
}

/// خطط تمرين جاهزة
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});
  @override
  Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(12), children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 8), child: Text('ابدأ الآن', style: Theme.of(c).textTheme.titleLarge)),
        for (final r in routines)
          Card(
            child: ListTile(
              leading: Text(r.emoji, style: const TextStyle(fontSize: 28)),
              title: Text(r.name),
              subtitle: Text('${r.steps.length} تمارين • ${r.minutes} دقيقة'),
              trailing: FilledButton.icon(icon: const Icon(Icons.play_arrow), label: const Text('ابدأ'), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => Player(title: r.name, steps: r.steps)))),
              onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => Player(title: r.name, steps: r.steps))),
            ),
          ),
        Padding(padding: const EdgeInsets.fromLTRB(8, 16, 8, 8), child: Text('خطط أسبوعية', style: Theme.of(c).textTheme.titleLarge)),
        for (final p in plans)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.event_note),
              title: Text(p.name),
              subtitle: Text(p.desc),
              children: [
                for (final d in p.days.entries) ...[
                  ListTile(
                    title: Text(d.key, style: Theme.of(c).textTheme.titleSmall),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.bookmark_add, size: 18),
                      label: const Text('احفظ'),
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(content: Text('اتصل بالخدمات السحابية من تبويب مجموعاتي أولًا')),
                          );
                          return;
                        }
                        final msg = ScaffoldMessenger.of(c);
                        FirebaseFirestore.instance.collection('sets').add({
                          'name': '${p.name} • ${d.key}', 'ids': d.value, 'public': false, 'owner': user.uid,
                          'at': FieldValue.serverTimestamp(),
                        }).then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {
                          reportAppError(error, stackTrace, source: 'Saving a training-plan set');
                          if (c.mounted) msg.showSnackBar(SnackBar(content: Text('تعذر الحفظ: $error')));
                        });
                        msg.showSnackBar(const SnackBar(content: Text('حُفظت محليًا وستتم المزامنة عند توفر الإنترنت')));
                      },
                    ),
                  ),
                  for (final id in d.value)
                    Builder(builder: (_) {
                      final e = exercises.firstWhere((x) => x.id == id);
                      return ListTile(
                        dense: true,
                        leading: gifOf(e, size: 40),
                        title: Text(e.name),
                        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => Detail(e))),
                      );
                    }),
                ],
              ],
            ),
          ),
      ]);
}
