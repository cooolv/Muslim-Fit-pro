import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'main.dart';

String get _uid => FirebaseAuth.instance.currentUser!.uid;

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
  Widget build(BuildContext c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدّات'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'وزن كجم'))),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final r = int.tryParse(reps.text), w = double.tryParse(kg.text) ?? 0;
                if (r == null || r <= 0 || r > 1000 || w < 0 || w > 1000) return;
                await FirebaseFirestore.instance.collection('logs').add({
                  'owner': _uid, 'ex': widget.e.id, 'reps': r, 'kg': w, 'at': FieldValue.serverTimestamp(),
                });
                reps.clear();
                if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('تم التسجيل ✅')));
              },
              child: const Text('سجّل'),
            ),
          ]),
        ),
      );
}

/// صفحة التقدم
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext c) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('logs').where('owner', isEqualTo: _uid).snapshots(),
        builder: (_, s) {
          if (s.hasError) return Center(child: Text('تعذر التحميل: ${s.error}'));
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final logs = s.data!.docs.map((d) => d.data() as Map<String, dynamic>).where((m) => m['at'] != null).toList()
            ..sort((a, b) => (b['at'] as Timestamp).compareTo(a['at'] as Timestamp));
          if (logs.isEmpty) return const Center(child: Text('سجّل أول مجموعة من صفحة أي تمرين'));
          final vol = logs.fold<double>(0, (p, m) => p + (m['reps'] as num) * ((m['kg'] as num) == 0 ? 1 : m['kg'] as num));
          final now = DateTime.now();
          final days = List.generate(7, (i) {
            final d = now.subtract(Duration(days: 6 - i));
            return logs.where((m) {
              final t = (m['at'] as Timestamp).toDate();
              return t.year == d.year && t.month == d.month && t.day == d.day;
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
            for (final m in logs.take(15))
              ListTile(
                dense: true,
                title: Text(exercises.where((e) => e.id == m['ex']).map((e) => e.name).firstOrNull ?? '${m['ex']}'),
                trailing: Text('${m['reps']} × ${m['kg']} كجم'),
              ),
          ]);
        },
      );
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
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('sets').add({
                          'name': '${p.name} • ${d.key}', 'ids': d.value, 'public': false, 'owner': _uid,
                          'at': FieldValue.serverTimestamp(),
                        });
                        if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('أُضيفت إلى مجموعاتي ✅')));
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
