import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'data.dart';
import 'error_reporter.dart';
import 'main.dart' show gifOf;

/// يحوّل وثيقة مجموعة من Firestore إلى خطوات (يدعم المجموعات القديمة التي تحتوي ids فقط)
List<RStep> stepsOf(Map<String, dynamic> m) {
  final rawSteps = m['steps'];
  if (rawSteps is List && rawSteps.isNotEmpty) {
    final parsed = <RStep>[];
    for (final raw in rawSteps) {
      if (raw is! Map) continue;
      final id = raw['id'], reps = raw['reps'], secs = raw['secs'];
      if (id is! String ||
          !_exerciseIds.contains(id) ||
          reps is! num ||
          secs is! num ||
          !reps.isFinite ||
          !secs.isFinite ||
          reps < 0 ||
          reps > 1000 ||
          secs < 1 ||
          secs > 3600) {
        continue;
      }
      parsed.add(RStep(id, reps.toInt(), secs.toInt()));
    }
    if (parsed.isNotEmpty) return parsed;
  }
  return [for (final id in exerciseIdsOf(m['ids'])) RStep(id, 12, 40)];
}

final _exerciseIds = exercises.map((e) => e.id).toSet();

List<String> exerciseIdsOf(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().where(_exerciseIds.contains).toList();
}

/// مشغّل التمارين: يعدّ الوقت وينتقل تلقائيًا للتالي، مع تخطي/رجوع/إيقاف مؤقت
class Player extends StatefulWidget {
  final String title;
  final List<RStep> steps;
  const Player({super.key, required this.title, required this.steps});
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  static const prep = 5;
  int i = -1; // -1 = وقت الاستعداد
  int left = prep;
  bool paused = false, done = false;
  Timer? t;

  bool get _supportsMobileFeatures =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Ex ex(int n) => exercises.firstWhere((e) => e.id == widget.steps[n].id);

  @override
  void initState() {
    super.initState();
    if (widget.steps.isEmpty) return;
    if (_supportsMobileFeatures) unawaited(WakelockPlus.enable());
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (paused || done || !mounted) return;
      setState(() {
        if (left > 1) {
          left--;
        } else {
          if (i >= 0) _log(widget.steps[i]);
          if (_supportsMobileFeatures) {
            unawaited(HapticFeedback.heavyImpact());
            unawaited(SystemSound.play(SystemSoundType.alert));
          }
          _go(i + 1);
        }
      });
    });
  }

  void _go(int n) {
    if (n >= widget.steps.length) {
      done = true;
      return;
    }
    i = n < 0 ? 0 : n;
    left = widget.steps[i].secs;
  }

  void _log(RStep s) {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    FirebaseFirestore.instance.collection('logs').add({
      'owner': u.uid, 'ex': s.id, 'reps': s.reps > 0 ? s.reps : 1, 'kg': 0, 'at': FieldValue.serverTimestamp(),
    }).then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {
      reportAppError(error, stackTrace, source: 'Automatic workout log');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر حفظ سجل التمرين: $error')),
        );
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    if (_supportsMobileFeatures) unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    if (widget.steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('لا توجد تمارين صالحة في هذه المجموعة')),
      );
    }
    if (done) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            Text('أحسنت! أتممت ${widget.title}', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('تقبّل الله طاعتك وزادك قوة'),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(c), child: const Text('رجوع')),
          ]),
        ),
      );
    }
    final inPrep = i < 0;
    final cur = inPrep ? 0 : i;
    final e = ex(cur), s = widget.steps[cur];
    final total = inPrep ? prep : s.secs;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            LinearProgressIndicator(value: (cur + (inPrep ? 0 : 1 - left / total)) / widget.steps.length, minHeight: 6, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 4),
            Text('تمرين ${cur + 1} من ${widget.steps.length}'),
            Expanded(
              child: LayoutBuilder(
                builder: (_, k) => Center(child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: KeyedSubtree(key: ValueKey('$inPrep$cur'), child: gifOf(e, size: k.biggest.shortestSide.clamp(120, 420).toDouble())),
                )),
              ),
            ),
            Text(inPrep ? 'استعد: ${e.name}' : e.name, style: Theme.of(c).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(inPrep ? 'سيبدأ التمرين خلال لحظات' : (s.reps > 0 ? '× ${s.reps} عدّة' : 'ثبّت الوضع حتى انتهاء الوقت'),
                style: Theme.of(c).textTheme.titleMedium?.copyWith(color: cs.primary)),
            const SizedBox(height: 12),
            SizedBox(
              width: 96, height: 96,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(child: CircularProgressIndicator(value: left / total, strokeWidth: 8)),
                Text('$left', style: Theme.of(c).textTheme.headlineMedium),
              ]),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(onPressed: () => setState(() => _go(inPrep ? 0 : (i - 1).clamp(0, widget.steps.length - 1).toInt())), child: const Text('السابق')),
              const SizedBox(width: 16),
              IconButton.filled(iconSize: 40, onPressed: () => setState(() => paused = !paused), icon: Icon(paused ? Icons.play_arrow : Icons.pause)),
              const SizedBox(width: 16),
              FilledButton.tonal(onPressed: () => setState(() => _go(i + 1)), child: const Text('تخطّي ⏭')),
            ]),
            if (cur + 1 < widget.steps.length)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text('التالي: ${ex(cur + 1).name}', style: const TextStyle(color: Colors.grey))),
          ]),
        ),
      ),
    );
  }
}
