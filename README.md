# 🕌💪 Muslim-Fit-pro

تطبيق تمارين مجاني بالكامل، واجهة عربية، يعمل على **أندرويد** و**ويندوز** من كود واحد (Flutter).
شخصيات التمارين مرسومة بوجه مطموس وتتحرك برمجيًا بالزوايا (Rigging) — لا حاجة لملفات GIF.

## المميزات
- 31 تمرينًا (بدون أدوات / دمبل / جيم) بخطوات الأداء والنصائح، مع بحث وفلترة
- حركة شخصية سلسة لكل تمرين له Rig (حاليًا 6 تمارين، والباقي قيد الإضافة)
- 3 خطط جاهزة، مجموعات تمارين خاصة أو عامة، مؤقت راحة
- تسجيل المجموعات (عدّات/وزن) وصفحة تقدّم لآخر 7 أيام
- وضع فاتح/داكن • مجاني بلا إعلانات

## 📥 التحميل
من صفحة **Releases**: `Muslim-Fit-pro-Android.apk` و`Muslim-Fit-pro-Windows.zip`.

## ▶️ الروتين التلقائي
من تبويب «الروتين»: اختر (تمارين الصباح/المساء/البطن/الذراع/الأرجل/الظهر) وضع الهاتف أمامك؛ كل تمرين له عدّات ووقت، وينتقل تلقائيًا للتالي مع زر تخطّي/السابق/إيقاف مؤقت، والشاشة تبقى مضاءة. تقدر تنشئ روتينك الخاص من «مجموعاتي».

## 🏷️ قبل النشر
عدّل `lib/app_info.dart` (حساب GitHub، البريد، رابط المتجر والشبكة) لتظهر الروابط في شاشة «عن التطبيق».

## ⚙️ الإعداد
1. Firebase: فعّل **Firestore** و**Authentication ← Anonymous**، والصق `firestore.rules` في Rules.
2. GitHub ← *Settings → Secrets → Actions*: `FB_API_KEY`, `FB_APP_ID`, `FB_SENDER_ID`, `FB_PROJECT_ID`.
3. إصدار: `git tag v1.0.1 && git push origin v1.0.1` (أو شغّل Workflow يدويًا من Actions).

> مفاتيح Firebase للعميل ليست أسرارًا مطلقة؛ الحماية الحقيقية هي قواعد Firestore. قيّد الـ API key من Google Cloud Console على تطبيقك.

## 🚀 النشر على Google Play
1. أنشئ مفتاح التوقيع **مرة واحدة** واحتفظ به في مكان آمن (لا ترفعه للمستودع):
```bash
keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
2. حوّله إلى base64: Linux/Mac `base64 -w0 upload.jks` — PowerShell `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload.jks"))`
3. أضف Secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` (= upload).
4. ارفع tag جديد → سيظهر `Muslim-Fit-pro-PlayStore.aab` في Releases. ارفعه في Play Console (فعّل Play App Signing).
5. المطلوب في المتجر: سياسة الخصوصية (`PRIVACY.md` — انشرها عبر GitHub Pages أو رابط Raw)، نموذج Data safety، تصنيف المحتوى، لقطات شاشة، أيقونة 512، وصورة مميزة 1024×500.

> ⚠️ معرّف التطبيق الحالي `com.muslimfit.muslim_fit_pro` **لا يتغير بعد النشر**. غيّره قبل أول رفع إن أردت (`--org` في `build.yml`).

## 🎬 تحريك الشخصية
- الأجزاء في `assets/rig/` ومحاورها في `lib/parts_data.dart`.
- زوايا كل تمرين في `rigs` داخل `lib/rig.dart` (0=يمين، 90=أسفل، -90=أعلى). عدّلها لضبط الحركة.

## 🧪 تشغيل محلي
```bash
flutter create . --platforms=android,windows --org com.muslimfit
flutter run --dart-define=FB_API_KEY=... --dart-define=FB_APP_ID=... --dart-define=FB_SENDER_ID=... --dart-define=FB_PROJECT_ID=...
```
