# 💪 فيت برو (FitPro)

تطبيق تمارين مجاني بالكامل، واجهة عربية، يعمل على **أندرويد** و**ويندوز** من كود واحد (Flutter).

## المميزات
- تمارين بدون أدوات / دمبل / جيم مع خطوات الأداء ونصائح
- فلترة، انتقالات وأنيميشن سلس (Hero + Fade)
- مجموعات تمارين خاصة بك: **خاصة** أو **عامة** للجميع (Firestore)
- مؤقت راحة، تسجيل المجموعات (عدّات/وزن)، وصفحة تقدّم برسم بياني لآخر 7 أيام
- بحث بالاسم أو العضلة، و3 خطط جاهزة (جسم كامل / دمبل / PPL) تُحفظ بضغطة في مجموعاتك
- 31 تمرينًا قابلة للتوسعة، ووضع فاتح/داكن بزر في الشريط العلوي
- صور GIF لكل تمرين (تضيفها بنفسك، انظر أدناه)

## 📥 التحميل
من صفحة **Releases** في المستودع:
- `FitPro-Android.apk` — ثبّته على الهاتف (اسمح بالتثبيت من مصدر غير معروف)
- `FitPro-Windows.zip` — فك الضغط وشغّل `fitpro.exe`

## ⚙️ التجهيز (مرة واحدة)
1. أنشئ مشروعًا في [Firebase Console](https://console.firebase.google.com) (الخطة المجانية Spark).
2. فعّل **Firestore Database** و **Authentication ← Anonymous**.
3. الصق محتوى `firestore.rules` في تبويب Rules.
4. أضف **Web app** للمشروع وانسخ قيمه.
5. في GitHub: *Settings → Secrets and variables → Actions* وأضف:

| Secret | القيمة |
|---|---|
| `FB_API_KEY` | apiKey |
| `FB_APP_ID` | appId |
| `FB_SENDER_ID` | messagingSenderId |
| `FB_PROJECT_ID` | projectId |

> المفاتيح لا تُكتب في الكود أبدًا؛ تُحقن وقت البناء. ملاحظة: مفاتيح Firebase للعملاء ليست أسرارًا مطلقة،
> والحماية الحقيقية هي **قواعد Firestore** الموجودة في المشروع.

## 🚀 إصدار نسخة
```bash
git tag v1.0.0 && git push origin v1.0.0
```
سيبني GitHub Actions النسختين ويرفعهما في Releases تلقائيًا. (أو شغّل Workflow يدويًا من تبويب Actions.)

## 🖼️ إضافة صور GIF
ضع ملف `assets/gifs/<id>.gif` لكل تمرين (مثال: `pushup.gif`)، والـ id موجود في `lib/data.dart`.
يُفضَّل رسوم كرتونية بوجه مطموس من مصدر **تملك ترخيصه** أو ترسمه بنفسك.

## ➕ إضافة تمارين
أضف عنصرًا جديدًا في قائمة `exercises` داخل `lib/data.dart`.

## 🧪 تشغيل محلي
```bash
flutter create . --platforms=android,windows
flutter run --dart-define=FB_API_KEY=... --dart-define=FB_APP_ID=... \
  --dart-define=FB_SENDER_ID=... --dart-define=FB_PROJECT_ID=...
```
