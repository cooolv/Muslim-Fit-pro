// ✏️ عدّل هذه القيم قبل النشر. الروابط الفارغة تُخفى تلقائيًا من شاشة «عن التطبيق».
const kAppName = 'Muslim-Fit-pro';
const kVersion = '1.1.0';
const kDeveloper = 'أحمد السيد محمود';
const kGithubUser = ''; // اسم حسابك على GitHub
const kRepo = 'Muslim-Fit-pro';
const kContactEmail = ''; // بريد التواصل (مطلوب في Google Play)
const kStoreUrl = ''; // رابط «متجر تطبيقات المسلم»
const kNetworkUrl = ''; // رابط «شبكة العلم نور الناس»

String get kRepoUrl => kGithubUser.isEmpty ? '' : 'https://github.com/$kGithubUser/$kRepo';
String get kReleasesUrl => kRepoUrl.isEmpty ? '' : '$kRepoUrl/releases';
String get kPrivacyUrl => kRepoUrl.isEmpty ? '' : '$kRepoUrl/blob/main/PRIVACY.md';
