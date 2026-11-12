import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'cloud_access.dart';
import 'data.dart';
import 'extras.dart';
import 'rig.dart';
import 'splash.dart';
import 'about.dart';
import 'player.dart';
import 'nutrition.dart';
import 'error_reporter.dart';

// المفاتيح تُمرَّر وقت البناء (--dart-define) من GitHub Secrets، ولا تُكتب في الكود.
const fbOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FB_API_KEY'),
  appId: String.fromEnvironment('FB_APP_ID'),
  messagingSenderId: String.fromEnvironment('FB_SENDER_ID'),
  projectId: String.fromEnvironment('FB_PROJECT_ID'),
);

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      reportAppError(
        details.exception,
        details.stack ?? StackTrace.current,
        source: details.library ?? 'Flutter framework',
      );
    };
    ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
      reportAppError(error, stackTrace, source: 'Platform dispatcher');
      return true;
    };
    runApp(const FitPro());
  }, (error, stackTrace) {
    reportAppError(error, stackTrace, source: 'Dart zone');
  });
}

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

class FitPro extends StatelessWidget {
  const FitPro({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (c, m, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Muslim-Fit-pro',
        builder: (c, w) => ValueListenableBuilder<AppErrorReport?>(
          valueListenable: globalErrorReport,
          builder: (context, report, _) => Directionality(
            textDirection: TextDirection.rtl,
            child: report == null ? w ?? const SizedBox.shrink() : ErrorReportScreen(report: report),
          ),
        ),
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0B6B4D)),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0B6B4D), brightness: Brightness.dark),
        themeMode: m,
        home: const Boot(),
      ));
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Muslim-Fit-pro'), actions: [
          IconButton(tooltip: 'عن التطبيق', icon: const Icon(Icons.info_outline), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const AboutPage()))),
          IconButton(
            tooltip: 'الوضع الفاتح/الداكن',
            icon: Icon(Theme.of(c).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeMode.value = Theme.of(c).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ]),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: [
            const ExList(key: ValueKey(0)),
            const PlansPage(key: ValueKey(1)),
            const SetsPage(key: ValueKey(2)),
            const ProgressPage(key: ValueKey(3)),
            const NutritionPage(key: ValueKey(4)),
          ][i],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.fitness_center), label: 'التمارين'),
            NavigationDestination(icon: Icon(Icons.play_circle), label: 'الروتين'),
            NavigationDestination(icon: Icon(Icons.collections_bookmark), label: 'مجموعاتي'),
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'تقدّمي'),
            NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'التغذية'),
          ],
        ),
      );
}

Widget gifOf(Ex e, {double size = 64}) {
  final rig = rigs[e.id] ?? rigs[exerciseRigAliases[e.id]];
  return rig != null
      ? RigView(rig, size: size)
      : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(e.gif, width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: size, height: size, color: Colors.white10,
                  child: Icon(Icons.accessibility_new, size: size * .6))),
        );
}

class ExList extends StatefulWidget {
  const ExList({super.key});
  @override
  State<ExList> createState() => _ExListState();
}

class _ExListState extends State<ExList> {
  String f = 'all', q = '';
  @override
  Widget build(BuildContext c) {
    final list = exercises.where((e) => (f == 'all' || e.equip == f) && (q.isEmpty || e.name.contains(q) || e.muscle.contains(q))).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: TextField(
          onChanged: (v) => setState(() => q = v.trim()),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث باسم التمرين أو العضلة', border: OutlineInputBorder()),
        ),
      ),
      SizedBox(
        height: 56,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
          for (final k in ['all', ...equipLabels.keys])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                  label: Text(k == 'all' ? 'الكل' : equipLabels[k]!),
                  selected: f == k,
                  onSelected: (_) => setState(() => f = k)),
            ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, n) {
            final e = list[n];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Hero(tag: e.id, child: gifOf(e)),
                title: Text(e.name),
                subtitle: Text('${e.muscle} • ${equipLabels[e.equip]} • ${e.level}'),
                onTap: () => Navigator.push(c, PageRouteBuilder(
                    transitionsBuilder: (_, a, __, w) => FadeTransition(opacity: a, child: w),
                    pageBuilder: (_, __, ___) => Detail(e))),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class Detail extends StatelessWidget {
  final Ex e;
  const Detail(this.e, {super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(e.name)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: Hero(tag: e.id, child: gifOf(e, size: 240))),
          const SizedBox(height: 16),
          const Text('الحركة المعروضة توضيحية؛ اقرأ خطوات الأداء واختر مدى مريحًا لك.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('العضلة: ${e.muscle} • المستوى: ${e.level}'),
          const SizedBox(height: 12),
          Text('طريقة الأداء', style: Theme.of(c).textTheme.titleMedium),
          for (var i = 0; i < e.steps.length; i++)
            ListTile(dense: true, leading: CircleAvatar(radius: 12, child: Text('${i + 1}')), title: Text(e.steps[i])),
          Card(child: ListTile(leading: const Icon(Icons.lightbulb), title: Text(e.tip))),
          LogSet(e),
          const RestTimer(),
        ]),
      );
}

class SetsPage extends StatelessWidget {
  const SetsPage({super.key});
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            reportAppErrorAfterFrame(snapshot.error!, source: 'Checking workout-set access');
            return const SizedBox.shrink();
          }
          return snapshot.data == null
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () => showDialog(context: c, builder: (_) => const NewSet()),
                  icon: const Icon(Icons.add),
                  label: const Text('مجموعة جديدة'),
                );
        },
      ),
      body: CloudAccessGate(
        builder: (user) {
          final q = FirebaseFirestore.instance.collection('sets').where(Filter.or(
              Filter('public', isEqualTo: true), Filter('owner', isEqualTo: user.uid)));
          return StreamBuilder<QuerySnapshot>(
            stream: q.snapshots(),
            builder: (_, s) {
              if (s.hasError) {
                reportAppErrorAfterFrame(s.error!, source: 'Loading workout sets');
                return Center(child: Text('تعذر التحميل: ${s.error}'));
              }
              if (!s.hasData) return const Center(child: CircularProgressIndicator());
              final docs = s.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('لا توجد مجموعات بعد'));
              return ListView(children: [
                for (final d in docs)
                  Builder(builder: (context) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = data['name'] is String ? data['name'] as String : 'مجموعة';
                    final isPublic = data['public'] == true;
                    final ids = exerciseIdsOf(data['ids']);
                    final steps = stepsOf(data);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        leading: Icon(isPublic ? Icons.public : Icons.lock),
                        title: Text(name),
                        subtitle: Text(isPublic ? 'عامة' : 'خاصة'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            tooltip: 'ابدأ',
                            icon: const Icon(Icons.play_circle_fill),
                            onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => Player(title: name, steps: steps))),
                          ),
                          if (data['owner'] == user.uid)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final messenger = ScaffoldMessenger.of(c);
                                d.reference.delete().then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {
                                  reportAppError(error, stackTrace, source: 'Deleting workout set');
                                  if (c.mounted) messenger.showSnackBar(SnackBar(content: Text('تعذر حذف المجموعة: $error')));
                                });
                              },
                            ),
                        ]),
                        children: [
                          for (final id in ids)
                            ListTile(title: Text(exercises.firstWhere((e) => e.id == id).name)),
                        ],
                      ),
                    );
                  }),
              ]);
            },
          );
        },
      ),
    );
  }
}

class NewSet extends StatefulWidget {
  const NewSet({super.key});
  @override
  State<NewSet> createState() => _NewSetState();
}

class _NewSetState extends State<NewSet> {
  final name = TextEditingController(), reps = TextEditingController(text: '12'), secs = TextEditingController(text: '40');
  final sel = <String>{};

  @override
  void dispose() {
    name.dispose();
    reps.dispose();
    secs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => AlertDialog(
        title: const Text('مجموعة جديدة'),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
            Row(children: [
              Expanded(child: TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدّات لكل تمرين'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: secs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ثواني لكل تمرين'))),
            ]),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final e in exercises)
                  CheckboxListTile(
                      title: Text(e.name), value: sel.contains(e.id),
                      onChanged: (v) {
                        if (v == null) return;
                        if (v && sel.length >= 50) {
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(content: Text('يمكن إضافة 50 تمرينًا كحد أقصى للمجموعة')),
                          );
                          return;
                        }
                        setState(() => v ? sel.add(e.id) : sel.remove(e.id));
                      }),
              ]),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final nav = Navigator.of(c), msg = ScaffoldMessenger.of(c);
              final setName = name.text.trim();
              if (setName.isEmpty) {
                msg.showSnackBar(const SnackBar(content: Text('اكتب اسم المجموعة')));
                return;
              }
              if (utf8.encode(setName).length >= 60) {
                msg.showSnackBar(const SnackBar(content: Text('اسم المجموعة طويل جدًا')));
                return;
              }
              if (sel.isEmpty) {
                msg.showSnackBar(const SnackBar(content: Text('اختر تمرينًا واحدًا على الأقل')));
                return;
              }
              final parsedReps = int.tryParse(reps.text.trim());
              if (parsedReps == null || parsedReps < 0 || parsedReps > 100) {
                msg.showSnackBar(const SnackBar(content: Text('أدخل عدّات صحيحة من 0 إلى 100')));
                return;
              }
              final parsedSecs = int.tryParse(secs.text.trim());
              if (parsedSecs == null || parsedSecs < 10 || parsedSecs > 600) {
                msg.showSnackBar(const SnackBar(content: Text('أدخل مدة صحيحة من 10 إلى 600 ثانية')));
                return;
              }
              final r = parsedReps, t = parsedSecs;
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                msg.showSnackBar(const SnackBar(content: Text('اتصل بالخدمات السحابية قبل إنشاء مجموعة')));
                return;
              }
              // لا ننتظر ردّ الخادم: الكتابة تُحفظ محليًا فورًا ثم تُزامَن، فيُغلق الديالوج مباشرة
              FirebaseFirestore.instance.collection('sets').add({
                'name': setName,
                'ids': sel.toList(),
                'steps': [for (final id in sel) {'id': id, 'reps': r, 'secs': t}],
                'public': false, // المشاركة العامة معطّلة في الإصدار الأول (سياسة المحتوى الذي ينشئه المستخدمون)
                'owner': user.uid,
                'at': FieldValue.serverTimestamp(),
              }).then<void>((_) {}, onError: (Object error, StackTrace stackTrace) {
                reportAppError(error, stackTrace, source: 'Saving workout set');
                msg.showSnackBar(SnackBar(content: Text('تعذر الحفظ: $error')));
              });
              nav.pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      );
}
