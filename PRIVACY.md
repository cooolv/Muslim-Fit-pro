<div dir="rtl" markdown="1">

# سياسة الخصوصية — Muslim-Fit-pro

**آخر تحديث: 12 نوفمبر 2026**

## البيانات والخدمات

- لا يطلب التطبيق اسمًا أو بريدًا إلكترونيًا أو موقعًا جغرافيًا. تسجيل الدخول السحابي اختياري ومجهول عبر Firebase Authentication، وينشئ معرّف مستخدم Firebase.
- عند استخدام الميزات السحابية، تُحفظ سجلات التمارين (معرّف التمرين، العدّات، الوزن، والتاريخ) والمجموعات التي تنشئها في Cloud Firestore، مرتبطة بمعرّف المستخدم.
- يستخدم التطبيق Firebase لتشغيل تسجيل الدخول وقاعدة البيانات. قد تعالج Google/Firebase بيانات تقنية لازمة لتقديم هذه الخدمات. لا يتضمن المشروع تكاملًا متعمدًا للإعلانات أو التحليلات.
- تبقى التمارين والروتينات وخطط التغذية المضمّنة على الجهاز. اختيارات قسم التغذية وعلامات الإنجاز وعدّاد الماء حالة مؤقتة داخل واجهة التطبيق، ولا تُرسل أو تُحفظ في قاعدة البيانات.

## التخزين والمشاركة

- يتصل التطبيق بخدمات Firebase عند استخدامها، ويُفعّل التخزين المحلي لـFirestore لدعم القراءة من البيانات المخزنة مؤقتًا ومزامنة الكتابات المعلّقة عند عودة الاتصال. قد يؤدي حذف بيانات التطبيق أو إزالته إلى فقدان البيانات المحلية أو تعذّر استعادة هوية مجهولة سابقة.
- السجلات والمجموعات الخاصة متاحة لمالكها وفق قواعد Firestore. تسمح القواعد بقراءة المجموعات التي تحمل `public: true` للمستخدمين المسجلين؛ الواجهة الحالية تنشئ مجموعات خاصة.
- تُحمى حركة البيانات إلى Firebase أثناء النقل. تعتمد حماية البيانات وصلاحياتها على إعدادات Firebase وقواعد [`firestore.rules`](./firestore.rules).
- لا يبيع التطبيق بياناتك. تستخدم Google/Firebase بوصفها مزوّدًا للخدمات اللازمة لتشغيل الميزات السحابية.
- تُنشأ تقارير الأخطاء على الجهاز ولا تُرسل تلقائيًا. قد يحتوي التقرير على نص الاستثناء ومسار التتبع ومعلومات تقنية؛ لا يُنسخ أو يُشارك إلا عند اختيارك ذلك من شاشة الخطأ.

## الروابط الخارجية وحذف البيانات

- روابط مراجع التغذية اختيارية وتُفتح في المتصفح الخارجي. عند فتحها، تسري سياسة الخصوصية الخاصة بالموقع الذي تزوره.
- لطلب حذف البيانات السحابية، راسلنا على **aemworkacc@gmail.com**. اذكر أن الطلب يخص Muslim-Fit-pro وأي تفاصيل تساعد على تحديد البيانات المراد حذفها.

## تنبيه صحي والأطفال

محتوى التمارين والتغذية للتثقيف العام وليس تشخيصًا أو علاجًا طبيًا. استشر مختصًا بشأن الأمراض والأدوية والصيام والحمل والأطفال، ولا تغيّر علاجًا أو تبدأ مكملًا بناءً على محتوى التطبيق وحده. التطبيق غير موجّه للأطفال دون 13 عامًا.

**التواصل:** aemworkacc@gmail.com

</div>

---

<div dir="ltr" markdown="1">

# Privacy Policy — Muslim-Fit-pro

**Last updated: November 12, 2026**

## Data and services

- The app does not ask for your name, email address, or location. Optional cloud sign-in is anonymous through Firebase Authentication and creates a Firebase user ID.
- When you use cloud features, workout logs (exercise ID, repetitions, weight, and date) and sets you create are stored in Cloud Firestore and associated with that user ID.
- The app uses Firebase for authentication and database services. Google/Firebase may process technical data needed to provide these services. The project does not intentionally integrate advertising or analytics.
- Bundled exercises, routines, and nutrition plans remain on the device. Nutrition selections, completion checkboxes, and the water counter are temporary app UI state; they are not sent to or stored in the database.

## Storage and sharing

- The app connects to Firebase when cloud features are used and enables Firestore local persistence to support cached reads and synchronization of pending writes when connectivity returns. Clearing app data or uninstalling may remove local data or make a previous anonymous identity unrecoverable.
- Workout logs and private sets are available to their owner under the Firestore rules. The rules allow signed-in users to read sets with `public: true`; the current UI creates private sets.
- Data sent to Firebase is protected in transit. Data access is governed by Firebase configuration and [`firestore.rules`](./firestore.rules).
- The app does not sell your data. Google/Firebase is used as the service provider needed to operate cloud features.
- Error reports are assembled locally and are not sent automatically. They may contain exception text, stack traces, and technical details; they are copied or shared only when you choose an action on the error screen.

## External links and data deletion

- Nutrition reference links are optional and open in your external browser. The destination website's privacy policy applies when you visit it.
- To request deletion of cloud data, email **aemworkacc@gmail.com**. Mention Muslim-Fit-pro and include any details that can help identify the data to be deleted.

## Health notice and children

Exercise and nutrition content is general education, not diagnosis or treatment. Consult a qualified professional about medical conditions, medication, fasting, pregnancy, and children. Do not change treatment or start supplements based only on app content. The app is not directed to children under 13.

**Contact:** aemworkacc@gmail.com

</div>
