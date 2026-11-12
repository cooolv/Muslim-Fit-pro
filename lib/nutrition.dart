import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'error_reporter.dart';

class _MealIdea {
  final String time, name;
  final List<String> options;

  const _MealIdea(this.time, this.name, this.options);
}

class _NutritionTrack {
  final String title, summary;
  final IconData icon;
  final List<_MealIdea> meals;
  final List<String> tips;
  final String? caution;

  const _NutritionTrack({
    required this.title,
    required this.summary,
    required this.icon,
    required this.meals,
    required this.tips,
    this.caution,
  });
}

const _tracks = <_NutritionTrack>[
  _NutritionTrack(
    title: 'صحة وتوازن',
    summary: 'أفكار يومية مرنة من أطعمة مألوفة؛ نوّع ولا تحتاج إلى أطعمة خاصة.',
    icon: Icons.spa_outlined,
    meals: [
      _MealIdea('الفطور', 'بداية مشبعة', ['شوفان بالحليب أو اللبن مع فاكهة ومكسرات', 'بيض مع خبز كامل الحبة وخضار']),
      _MealIdea('الغداء', 'وجبة متوازنة', ['دجاج أو سمك مع أرز/برغل وسلطة', 'عدس أو حمص مع خبز كامل الحبة وخضار']),
      _MealIdea('وجبة خفيفة', 'حسب الجوع', ['فاكهة مع لبن أو زبادي', 'خضار مقطّعة مع حمص']),
      _MealIdea('العشاء', 'خفيف ومتنوع', ['شوربة عدس وسلطة', 'ساندويتش تونة أو فاصوليا مع خضار']),
    ],
    tips: [
      'اجمع بين الخضار أو الفاكهة، ومصدر بروتين، وحبوب أو نشويات في وجباتك.',
      'اختر الماء غالبًا، وقلّل المشروبات المحلاة والأطعمة شديدة التصنيع.',
      'استخدم الأطعمة المتاحة والمناسبة لثقافتك وميزانيتك؛ لا يوجد طبق واحد إلزامي.',
    ],
  ),
  _NutritionTrack(
    title: 'خفض الوزن تدريجيًا',
    summary: 'تغييرات صغيرة قابلة للاستمرار، من دون تجويع أو قوائم ممنوعة.',
    icon: Icons.trending_down,
    meals: [
      _MealIdea('الفطور', 'بروتين وألياف', ['بيض وخضار مع خبز كامل الحبة', 'زبادي غير محلى مع شوفان وفاكهة']),
      _MealIdea('الغداء', 'وجبة مشبعة', ['دجاج مشوي أو فاصوليا مع خضار وحبوب كاملة', 'سمك مع سلطة وبطاطا أو أرز']),
      _MealIdea('وجبة خفيفة', 'إذا شعرت بالجوع', ['فاكهة كاملة', 'زبادي غير محلى أو حفنة صغيرة من المكسرات']),
      _MealIdea('العشاء', 'وجبة بسيطة', ['شوربة خضار وعدس', 'سلطة كبيرة مع بيض أو تونة وخبز']),
    ],
    tips: [
      'ابدأ بتبديل واحد واقعي مثل الماء بدل المشروب المحلى أو إضافة الخضار.',
      'كُل ببطء وتوقف عند الشبع المريح؛ لا يلزم حذف وجبات أو مجموعات غذائية.',
      'اربط التغذية بالمشي أو تمارين القوة والنوم الجيد، وتابع العادات لا الوزن وحده.',
    ],
  ),
  _NutritionTrack(
    title: 'زيادة الوزن بأطعمة مغذية',
    summary: 'أضف وجبات أو مكونات مغذية تدريجيًا بدل الاعتماد على الحلويات والمقليات.',
    icon: Icons.trending_up,
    meals: [
      _MealIdea('الفطور', 'طاقة ومغذيات', ['شوفان بالحليب والموز وزبدة المكسرات', 'بيض وجبن أو لبنة مع خبز وخضار']),
      _MealIdea('وجبة خفيفة', 'إضافة سهلة', ['زبادي مع فاكهة ومكسرات', 'تمر مع طحينة أو مكسرات']),
      _MealIdea('الغداء', 'وجبة رئيسية', ['أرز مع دجاج أو حمص وخضار وزيت زيتون', 'مكرونة مع لحم أو عدس وصلصة طماطم']),
      _MealIdea('وجبة خفيفة', 'بين الوجبات', ['سموذي حليب أو لبن مع موز وشوفان', 'ساندويتش زبدة مكسرات أو حمص']),
      _MealIdea('العشاء', 'وجبة كاملة', ['بطاطا أو خبز مع بيض وخضار', 'سمك أو فاصوليا مع حبوب وسلطة']),
    ],
    tips: [
      'زد حجم الوجبة أو أضف وجبة خفيفة تدريجيًا، واختر أطعمة كثيفة المغذيات.',
      'تمارين القوة تساعد على بناء العضلات؛ الزيادة السريعة ليست هدفًا صحيًا بحد ذاتها.',
      'استشر مختصًا إذا كان فقدان الوزن غير مقصود أو كانت الشهية ضعيفة باستمرار.',
    ],
  ),
  _NutritionTrack(
    title: 'رياضة وبناء عضلات',
    summary: 'غذاء كافٍ وتمارين مقاومة متدرجة ونوم جيد؛ لا حاجة لمكملات خاصة لمعظم الناس.',
    icon: Icons.fitness_center,
    meals: [
      _MealIdea('الفطور', 'ابدأ يومك', ['بيض أو لبن مع خبز وشوفان أو فاكهة', 'فول أو حمص مع خبز وخضار']),
      _MealIdea('قبل التمرين', 'وجبة معتادة إن احتجت', ['موزة ولبن أو زبادي', 'خبز مع جبن أو حمص']),
      _MealIdea('بعد التمرين', 'وجبة خلال يومك', ['دجاج أو عدس مع أرز وخضار', 'بيض أو تونة مع بطاطا وخضار']),
      _MealIdea('وجبة خفيفة', 'لدعم الاحتياج اليومي', ['حليب أو لبن مع فاكهة', 'ساندويتش جبن أو زبدة مكسرات']),
    ],
    tips: [
      'وزّع مصادر البروتين على وجباتك: بقول، بيض، ألبان، سمك أو لحوم حسب اختيارك.',
      'الكربوهيدرات مثل الشوفان والأرز والخبز والفاكهة تمدّك بالطاقة للتمرين.',
      'لا يلزم تناول الطعام فور انتهاء آخر تكرار؛ اجعل الوجبة التالية مناسبة ومتوازنة.',
      'زد أحمال تمارين القوة تدريجيًا، وخذ أيام راحة ونم جيدًا.',
    ],
  ),
  _NutritionTrack(
    title: 'تثقيف غذائي للسكري',
    summary: 'أفكار عامة لا تستبدل خطة الطبيب أو اختصاصي التغذية ولا تعدّل جرعات الدواء.',
    icon: Icons.favorite_outline,
    meals: [
      _MealIdea('الفطور', 'اختر ما يناسب خطتك', ['بيض وخضار مع خبز كامل الحبة', 'زبادي غير محلى مع شوفان ومكسرات']),
      _MealIdea('الغداء', 'ألياف ومصدر بروتين', ['سمك أو دجاج مع خضار وأرز أو برغل', 'عدس أو فاصوليا مع سلطة وخبز']),
      _MealIdea('وجبة خفيفة', 'وفق خطة العلاج', ['مكسرات غير مملحة بكمية مناسبة', 'فاكهة كاملة مع لبن غير محلى']),
      _MealIdea('العشاء', 'توازن واعتدال', ['شوربة بقول وسلطة', 'بيض أو تونة مع خضار وخبز كامل']),
    ],
    tips: [
      'اجعل المشروبات قليلة أو خالية من السكر المضاف، واختر أطعمة غنية بالألياف غالبًا.',
      'تختلف كمية الكربوهيدرات وتوقيت الوجبات حسب العلاج وقراءات السكر؛ اتبع خطتك الفردية.',
      'لا توقف أو تغيّر الإنسولين أو أي دواء بسبب تغيير الطعام أو الصيام دون الطبيب.',
    ],
    caution: 'السكري يحتاج خطة تناسب حالتك من فريقك الصحي، خصوصًا مع الإنسولين أو أدوية قد تخفّض السكر. ناقش الصيام والرياضة معهم.',
  ),
  _NutritionTrack(
    title: 'الحديد والأنيميا',
    summary: 'التغذية قد تساعد، لكن الأنيميا لها أسباب متعددة ولا تُشخّص من الطعام أو الأعراض وحدها.',
    icon: Icons.bloodtype_outlined,
    meals: [
      _MealIdea('الفطور', 'مصدر حديد نباتي', ['حبوب إفطار مدعمة بالحديد مع فاكهة', 'فول أو حمص مع طماطم وخبز']),
      _MealIdea('الغداء', 'مصدر حديد مع فيتامين C', ['لحم أو دجاج مع فلفل أو سلطة طماطم', 'عدس أو فاصوليا مع ليمون أو فاكهة حمضية']),
      _MealIdea('وجبة خفيفة', 'خيارات متنوعة', ['مشمش مجفف مع مكسرات', 'فاكهة مع بذور أو مكسرات']),
      _MealIdea('العشاء', 'بقول أو بروتين', ['شوربة عدس مع سلطة', 'سمك أو بيض مع خضار وحبوب كاملة']),
    ],
    tips: [
      'مصادر الحديد تشمل اللحوم وبعض المأكولات البحرية، والبقول، والمكسرات، وبعض الحبوب المدعمة.',
      'تناول الخضار أو الفاكهة الغنية بفيتامين C مع الوجبة النباتية قد يساعد امتصاص الحديد.',
      'الشاي والقهوة مع الوجبة قد يقللان امتصاص الحديد من الطعام؛ اسأل مختصك عن الأنسب لك.',
    ],
    caution: 'اشتباه الأنيميا يحتاج تقييمًا وفحوصات لتحديد السبب. لا تبدأ حبوب الحديد أو جرعات علاجية من نفسك؛ اتبع وصف الطبيب.',
  ),
  _NutritionTrack(
    title: 'الصيام الإسلامي',
    summary: 'أفكار للسحور والإفطار في رمضان أو الصيام التطوعي؛ هذا تخطيط غذائي وليس فتوى.',
    icon: Icons.nights_stay_outlined,
    meals: [
      _MealIdea('السحور', 'وجبة مشبعة', ['شوفان بالحليب أو اللبن مع فاكهة', 'خبز كامل مع بيض أو لبنة وخضار']),
      _MealIdea('الإفطار', 'ابدأ بهدوء', ['ماء ثم شوربة أو سلطة ووجبة متوازنة', 'ماء ووجبة منزلية فيها بروتين وخضار ونشويات']),
      _MealIdea('بين الإفطار والسحور', 'حسب حاجتك', ['فاكهة مع زبادي', 'مكسرات أو ساندويتش صغير']),
      _MealIdea('الحركة', 'اختر الوقت المناسب', ['مشي هادئ بعد الإفطار', 'تمرين مقاومة بعد وجبة خفيفة وراحة']),
    ],
    tips: [
      'اختر للسحور أطعمة مشبعة مثل الحبوب الكاملة والبقول والبيض أو الألبان.',
      'وزّع شرب الماء بين الإفطار والسحور، وقلّل الإفراط في الأطعمة شديدة الملوحة أو السكر.',
      'خفّف شدة التدريب أثناء الصيام، وتوقف عند الدوار أو الضعف أو أي عرض مقلق.',
      'لأحكام الرخص الشرعية اسأل أهل العلم، وللملاءمة الصحية اسأل طبيبك.',
    ],
    caution: 'الحمل والرضاعة والأمراض المزمنة وبعض الأدوية قد تجعل الصيام غير آمن. المصاب بالسكري لا يصمّم خطة صيام أو دواء بنفسه؛ يستشير فريقه الطبي مسبقًا.',
  ),
];

class _NutritionSource {
  final String title, url;

  const _NutritionSource(this.title, this.url);
}

const _sources = <_NutritionSource>[
  _NutritionSource('منظمة الصحة العالمية — الغذاء الصحي', 'https://www.who.int/news-room/fact-sheets/detail/healthy-diet'),
  _NutritionSource('Harvard — طبق الغذاء الصحي', 'https://nutritionsource.hsph.harvard.edu/healthy-eating-plate/'),
  _NutritionSource('NHS — نصائح لإدارة الوزن', 'https://www.nhs.uk/live-well/healthy-weight/managing-your-weight/tips-to-help-you-lose-weight/'),
  _NutritionSource('NIDDK — التعايش الصحي مع السكري', 'https://www.niddk.nih.gov/health-information/diabetes/overview/healthy-living-with-diabetes'),
  _NutritionSource('NHS — أنيميا نقص الحديد', 'https://www.nhs.uk/conditions/iron-deficiency-anaemia/'),
  _NutritionSource('Diabetes UK — السكري ورمضان', 'https://www.diabetes.org.uk/about-diabetes/looking-after-diabetes/ramadan'),
  _NutritionSource('المعهد الأسترالي للرياضة — التغذية', 'https://www.ausport.gov.au/ais/nutrition'),
];

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  int _trackIndex = 0;
  int _cups = 0;
  final Set<int> _completedMeals = {};
  final Map<int, int> _mealOptions = {};

  _NutritionTrack get _track => _tracks[_trackIndex];

  void _selectTrack(int index) {
    setState(() {
      _trackIndex = index;
      _cups = 0;
      _completedMeals.clear();
      _mealOptions.clear();
    });
  }

  Future<void> _openSource(String url) async {
    try {
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        reportAppError(StateError('url_launcher returned false for $url'), StackTrace.current, source: 'Opening nutrition reference');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح المصدر')));
      }
    } on PlatformException catch (error) {
      reportAppError(error, StackTrace.current, source: 'Opening nutrition reference');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح المصدر (${error.code})')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _completedMeals.length / _track.meals.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [theme.colorScheme.primary.withValues(alpha: .92), theme.colorScheme.primary.withValues(alpha: .55)],
                    ),
                        ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 42, color: Colors.white),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('غذاؤك.. عافية وقوة', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('خطط مرنة، أكل مألوف، وخطوة صحية كل يوم.', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('اختر هدفك', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < _tracks.length; index++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            avatar: Icon(_tracks[index].icon, size: 18),
                            label: Text(_tracks[index].title),
                            selected: _trackIndex == index,
                            onSelected: (_) => _selectTrack(index),
                          ),
                        ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_track.icon, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_track.title, style: theme.textTheme.titleLarge)),
                            Text('${_completedMeals.length}/${_track.meals.length}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_track.summary),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 6),
                        Text('متابعة وجبات اليوم — علّم ما أنجزته، ويمكنك تبديل الاقتراحات.', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('قالب مرن للوجبة الرئيسية', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text('دليل بصري تقريبي للبالغين الأصحاء، وليس مقاسًا إلزاميًا:'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _PlatePart(icon: Icons.eco_outlined, label: '½ خضار وفاكهة'),
                            ),
                            Expanded(
                              child: _PlatePart(icon: Icons.restaurant, label: '¼ بروتين'),
                            ),
                            Expanded(
                              child: _PlatePart(icon: Icons.grain, label: '¼ حبوب أو نشويات'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('عدّل الاختيارات والكميات حسب احتياجك وتوجيه المختص، خصوصًا مع الأمراض المزمنة.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                for (var index = 0; index < _track.meals.length; index++)
                  _MealCard(
                    meal: _track.meals[index],
                    selectedOption: _mealOptions[index] ?? 0,
                    completed: _completedMeals.contains(index),
                    onToggle: () => setState(() {
                      if (!_completedMeals.add(index)) _completedMeals.remove(index);
                    }),
                    onChangeOption: () => setState(() {
                      _mealOptions[index] = ((_mealOptions[index] ?? 0) + 1) % _track.meals[index].options.length;
                    }),
                  ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.water_drop_outlined),
                    title: const Text('تذكير بالماء'),
                    subtitle: Text('سجّلت $_cups ${_cups == 1 ? 'كوبًا' : 'أكواب'} اليوم — عدّل العداد حسب حاجتك.'),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(tooltip: 'إنقاص', onPressed: _cups == 0 ? null : () => setState(() => _cups--), icon: const Icon(Icons.remove_circle_outline)),
                        IconButton(tooltip: 'تسجيل كوب', onPressed: () => setState(() => _cups++), icon: const Icon(Icons.add_circle_outline)),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 12),
                  child: Text('احتياج السوائل يختلف باختلاف الجو والنشاط والحالة الصحية؛ هذا عدّاد تذكيري وليس هدفًا طبيًا.', style: TextStyle(color: Colors.grey)),
                ),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: const Text('مبادئ تساعدك على الاستمرار'),
                    children: [
                      for (final tip in _track.tips)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline, size: 20),
                          title: Text(tip),
                        ),
                    ],
                  ),
                ),
                if (_track.caution != null)
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(Icons.health_and_safety_outlined, color: theme.colorScheme.onErrorContainer),
                      title: Text(_track.caution!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                    ),
                  ),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('تنبيه صحي مهم'),
                    children: const [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text(
                          'هذه أمثلة تثقيفية عامة للبالغين وليست تشخيصًا أو علاجًا أو خطة سعرات شخصية. '
                          'استشر طبيبًا أو اختصاصي تغذية للحمل، والأطفال، والأمراض المزمنة، والحساسية، '
                          'أو اضطرابات الأكل. لا توقف دواءً ولا تبدأ مكملًا علاجيًا اعتمادًا على التطبيق.',
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.fact_check_outlined),
                    title: const Text('المصادر الطبية'),
                    subtitle: const Text('افتح المرجع للاطلاع على التفاصيل'),
                    children: [
                      for (final source in _sources)
                        ListTile(
                          title: Text(source.title),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => _openSource(source.url),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final _MealIdea meal;
  final int selectedOption;
  final bool completed;
  final VoidCallback onToggle, onChangeOption;

  const _MealCard({
    required this.meal,
    required this.selectedOption,
    required this.completed,
    required this.onToggle,
    required this.onChangeOption,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Checkbox(value: completed, onChanged: (_) => onToggle()),
          title: Text(meal.time),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(meal.options[selectedOption]),
              TextButton.icon(
                onPressed: onChangeOption,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('بدّل الاقتراح'),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      );
}

class _PlatePart extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlatePart({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, size: 22),
                const SizedBox(height: 4),
                Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      );
}
