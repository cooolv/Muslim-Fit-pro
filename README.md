<div dir="rtl" align="right">

# Muslim-Fit-pro

**تطبيق لياقة عربي للمنزل والجيم** مبني بـFlutter.

للقراءة بالإنجليزية: [README.en.md](./README.en.md).

## نظرة سريعة

- **100 تمرين** بوزن الجسم والدمبل وأجهزة الجيم، مع العضلات المستهدفة ومستوى الصعوبة وخطوات الأداء.
- رسوم حركة توضيحية مبنية بنظام Rig ثنائي الأبعاد؛ قد تستخدم التمارين المتقاربة حركة توضيحية مشتركة.
- ستة روتينات جاهزة ومشغّل بفترة استعداد ومؤقت وانتقال تلقائي، إضافة إلى ثلاث خطط تدريب.
- إنشاء مجموعات شخصية من التمارين، ومؤقت راحة، وتسجيل المجموعات وعرض التقدم.
- قسم تغذية تفاعلي بخطط مرنة لأهداف متعددة، بما فيها الرياضة والصيام؛ مع مصادر وتنبيهات صحية.
- واجهة عربية من اليمين إلى اليسار، ووضع فاتح/داكن.

## المنصات والتقنيات

| المجال | التقنية |
| --- | --- |
| التطبيق | Flutter / Dart |
| المنصات التي يبنيها الإصدار الحالي | Android وWindows |
| تسجيل الدخول السحابي | Firebase Anonymous Authentication |
| البيانات السحابية | Cloud Firestore |
| الحركة ومنع إطفاء الشاشة | رسوم Rig محلية و`wakelock_plus` |
| الروابط الخارجية | `url_launcher` |

بيانات التمارين والخطط والتغذية مضمنة محليًا. لا يحتاج تصفحها أو تشغيل الروتينات الجاهزة إلى اتصال بالإنترنت، لكن يحتاج التطبيق إلى إعداد Firebase عند البناء والتهيئة. تسجيل الدخول المجهول والبيانات السحابية يحتاجان اتصالًا عند استخدامهما أول مرة؛ وبعد تسجيل الدخول، يخزن Firestore التغييرات محليًا لمزامنتها عند عودة الاتصال.

## ابدأ محليًا

### المتطلبات

- Flutter على قناة stable وDart المتوافق مع القيد في [`pubspec.yaml`](./pubspec.yaml).
- Android Studio أو Visual Studio حسب المنصة المستهدفة.
- مشروع Firebase مع تفعيل **Anonymous Authentication** و**Cloud Firestore** إذا أردت اختبار ميزات السحابة.

### الإعداد والتشغيل

1. استنسخ المستودع ثم ادخل مجلده.
2. أنشئ ملفات المنصات المحلية؛ فهي غير محفوظة في المستودع:

   ```bash
   flutter create . --platforms=android,windows --org com.muslimfit
   flutter pub get
   ```

3. مرّر إعدادات Firebase إلى Flutter عبر `--dart-define`. عيّن القيم محليًا في متغيرات البيئة قبل تنفيذ الأمر، ولا تضع أسرارًا أو مفاتيح توقيع في Git:

   ```bash
   flutter run \
     --dart-define=FB_API_KEY="$FB_API_KEY" \
     --dart-define=FB_APP_ID="$FB_APP_ID" \
     --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
     --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
   ```

   أسماء القيم مطابقة للثوابت في [`lib/main.dart`](./lib/main.dart). يلزم إعداد Firebase لتهيئة التطبيق حتى عند استخدام ميزاته المحلية دون اتصال.

4. فعّل **Anonymous** و**Firestore** في Firebase Console، ثم انشر قواعد [`firestore.rules`](./firestore.rules). لا تجعل قواعد Firestore مفتوحة للعامة.

### فحوصات وبناء محلي

```bash
flutter analyze
flutter build apk --release \
  --dart-define=FB_API_KEY="$FB_API_KEY" \
  --dart-define=FB_APP_ID="$FB_APP_ID" \
  --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
  --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
flutter build windows --release \
  --dart-define=FB_API_KEY="$FB_API_KEY" \
  --dart-define=FB_APP_ID="$FB_APP_ID" \
  --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
  --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
```

لا يحتوي المستودع حاليًا على مجلد اختبارات `test/`. أضف اختبارات مركزة عند إضافة منطق جديد، وشغّل `flutter test` بعد إضافتها.

## خريطة المشروع

| المسار | المسؤولية |
| --- | --- |
| [`lib/main.dart`](./lib/main.dart) | نقطة الدخول، الثيم والتنقل، قائمة التمارين وتفاصيلها، مجموعات المستخدم، وعرض الحركة |
| [`lib/data.dart`](./lib/data.dart) | تعريف التمرين `Ex` والـ100 تمرين والروتينات والخطط وخطوات المشغّل |
| [`lib/player.dart`](./lib/player.dart) | مؤقت التمرين، الاستعداد، الإيقاف والتخطي والانتقال التلقائي |
| [`lib/extras.dart`](./lib/extras.dart) | مؤقت الراحة، سجل التمارين، صفحة التقدم والخطط |
| [`lib/nutrition.dart`](./lib/nutrition.dart) | محتوى التغذية المحلي التفاعلي ومصادره |
| [`lib/rig.dart`](./lib/rig.dart) و[`lib/parts_data.dart`](./lib/parts_data.dart) | رسوم الشخصيات، إطارات الحركة ومحاور الأجزاء |
| [`lib/splash.dart`](./lib/splash.dart) | شاشة البداية وتهيئة Firebase وتفعيل التخزين المحلي لـFirestore |
| [`lib/cloud_access.dart`](./lib/cloud_access.dart) | بوابة تسجيل الدخول عند فتح ميزات السحابة |
| [`firestore.rules`](./firestore.rules) | صلاحيات القراءة والكتابة لمجموعات Firestore |
| [`.github/workflows/build.yml`](./.github/workflows/build.yml) | بناء Android وWindows وإرفاق المخرجات بالإصدار |
| [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) | تدفق التطبيق ونموذج البيانات |

لشرح ملفات الرسم ومواصفات الأجزاء، راجع [`docs/AI_CHARACTER_PROMPT.md`](./docs/AI_CHARACTER_PROMPT.md). لمعايير المساهمة راجع [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## إضافة تمرين

1. أضف `Ex` جديدًا إلى `exercises` في [`lib/data.dart`](./lib/data.dart)، مع **معرّف فريد ومستقر** واسم عربي وعضلة ومعدة (`none` أو `dumbbell` أو `gym`) ومستوى وخطوات ونصيحة.
2. أضف Rig خاصًا في [`lib/rig.dart`](./lib/rig.dart)، أو اربط التمرين بحركة توضيحية مناسبة عبر `exerciseRigAliases`. الحركات المشتركة توضيحية وليست بديلًا عن قراءة خطوات الأداء.
3. استخدم المعرّف نفسه في `RStep` إذا أضفت التمرين إلى روتين جاهز. المجموعات المخصصة تستعرض `exercises` تلقائيًا.
4. تحقّق من عدم تكرار المعرّف، ومن ظهور التمرين في البحث والتفاصيل والمشغّل.

**لا تغيّر معرّف تمرين منشور دون ترحيل البيانات:** المجموعات والسجلات المخزنة في Firestore تشير إلى `Ex.id`.

## Firebase والبيانات

- `logs`: `owner`, `ex`, `reps`, `kg`, `at`.
- `sets`: `name`, `ids`, `steps` (اختياري للمجموعات القديمة), `public`, `owner`, `at`.
- تسجيل الدخول مجهول، ولا يتطلب اسمًا أو بريدًا. يحتفظ Firebase بهوية المستخدم على الجهاز؛ إزالة بيانات التطبيق قد تمنع استعادة هوية مجهولة سابقة.
- القواعد الحالية تقيد السجلات والمجموعات الخاصة بمالكها، وتسمح بقراءة المجموعة العامة للمستخدم المسجل. راجع القواعد قبل أي تغيير في نموذج المشاركة.
- مفاتيح Firebase المضمّنة في التطبيق ليست أسرارًا بحد ذاتها؛ الحماية تعتمد على قواعد Firestore وتقييد مفاتيح API. **لا ترفع مطلقًا keystore أو كلمات المرور أو ملفات أسرار Firebase.**

راجع [سياسة الخصوصية](./PRIVACY.md) لمعرفة البيانات والخدمات المستخدمة.

## الإصدارات

سير العمل في [`.github/workflows/build.yml`](./.github/workflows/build.yml) يعمل عند دفع tag يبدأ بـ`v` أو عند تشغيله يدويًا:

1. يجهز ملفات Android وWindows ويستعيد الحزم.
2. يبني APK وملف Windows ZIP.
3. يبني Android App Bundle إذا كانت أسرار التوقيع التالية موجودة: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.
4. يرفع المخرجات إلى GitHub Release.

لإنشاء إصدار، حدّث رقم الإصدار في [`pubspec.yaml`](./pubspec.yaml) و[`lib/app_info.dart`](./lib/app_info.dart)، ثم ادفع tag مثل `v1.3.0`. معرّف Android الحالي `com.muslimfit.muslim_fit_pro`؛ لا تغيّره بعد النشر إلى المتجر.

## تنبيهات

- محتوى التمارين والتغذية تثقيفي عام، وليس تشخيصًا أو علاجًا طبيًا. راجع طبيبًا أو اختصاصي تغذية للحالات الصحية والأدوية والحمل والأطفال.
- المحتوى الغذائي لا يوصي بتغيير علاج السكري أو تناول مكملات الحديد دون مختص.
- التطبيق مرخص بموجب [MIT](./LICENSE).

</div>
