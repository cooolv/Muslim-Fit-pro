import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'extras.dart';
import 'rig.dart';

// المفاتيح تُمرَّر وقت البناء (--dart-define) من GitHub Secrets، ولا تُكتب في الكود.
const _opts = FirebaseOptions(
  apiKey: String.fromEnvironment('FB_API_KEY'),
  appId: String.fromEnvironment('FB_APP_ID'),
  messagingSenderId: String.fromEnvironment('FB_SENDER_ID'),
  projectId: String.fromEnvironment('FB_PROJECT_ID'),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: _opts);
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const FitPro());
}

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

class FitPro extends StatelessWidget {
  const FitPro({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (c, m, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'فيت برو',
        builder: (c, w) => Directionality(textDirection: TextDirection.rtl, child: w!),
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFFFF6B35)),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFFFF6B35), brightness: Brightness.dark),
        themeMode: m,
        home: const Home(),
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
        appBar: AppBar(title: const Text('فيت برو 💪'), actions: [
          IconButton(
            tooltip: 'الوضع الفاتح/الداكن',
            icon: Icon(Theme.of(c).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeMode.value = Theme.of(c).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ]),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: [const ExList(key: ValueKey(0)), const PlansPage(key: ValueKey(1)), const SetsPage(key: ValueKey(2)), const ProgressPage(key: ValueKey(3))][i],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.fitness_center), label: 'التمارين'),
            NavigationDestination(icon: Icon(Icons.event_note), label: 'الخطط'),
            NavigationDestination(icon: Icon(Icons.collections_bookmark), label: 'مجموعاتي'),
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'تقدّمي'),
          ],
        ),
      );
}

Widget gifOf(Ex e, {double size = 64}) => rigs.containsKey(e.id)
    ? RigView(rigs[e.id]!, size: size)
    : ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(e.gif, width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: size, height: size, color: Colors.white10,
              child: Icon(Icons.accessibility_new, size: size * .6))),
    );

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
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final q = FirebaseFirestore.instance.collection('sets').where(Filter.or(
        Filter('public', isEqualTo: true), Filter('owner', isEqualTo: uid)));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(context: c, builder: (_) => const NewSet()),
          icon: const Icon(Icons.add), label: const Text('مجموعة جديدة')),
      body: StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (_, s) {
          if (s.hasError) return Center(child: Text('تعذر التحميل: ${s.error}'));
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد مجموعات بعد'));
          return ListView(children: [
            for (final d in docs)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  leading: Icon(d['public'] == true ? Icons.public : Icons.lock),
                  title: Text(d['name']),
                  subtitle: Text(d['public'] == true ? 'عامة' : 'خاصة'),
                  trailing: d['owner'] == uid
                      ? IconButton(icon: const Icon(Icons.delete), onPressed: () => d.reference.delete())
                      : null,
                  children: [
                    for (final id in List<String>.from(d['ids']))
                      if (exercises.any((e) => e.id == id))
                        ListTile(title: Text(exercises.firstWhere((e) => e.id == id).name)),
                  ],
                ),
              ),
          ]);
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
  final name = TextEditingController();
  final sel = <String>{};
  bool pub = false;
  @override
  Widget build(BuildContext c) => AlertDialog(
        title: const Text('مجموعة جديدة'),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
            SwitchListTile(title: const Text('عامة للجميع'), value: pub, onChanged: (v) => setState(() => pub = v)),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final e in exercises)
                  CheckboxListTile(
                      title: Text(e.name), value: sel.contains(e.id),
                      onChanged: (v) => setState(() => v! ? sel.add(e.id) : sel.remove(e.id))),
              ]),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty || sel.isEmpty) return;
              await FirebaseFirestore.instance.collection('sets').add({
                'name': name.text.trim(),
                'ids': sel.toList(),
                'public': pub,
                'owner': FirebaseAuth.instance.currentUser!.uid,
                'at': FieldValue.serverTimestamp(),
              });
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text('حفظ'),
          ),
        ],
      );
}
