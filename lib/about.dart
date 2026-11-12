import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_info.dart';
import 'error_reporter.dart';

Future<void> _open(BuildContext context, String url) async {
  try {
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      reportAppError(StateError('url_launcher returned false for $url'), StackTrace.current, source: 'Opening external link');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  } on PlatformException catch (error) {
    reportAppError(error, StackTrace.current, source: 'Opening external link');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح الرابط (${error.code})')),
      );
    }
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  Widget _link(BuildContext c, IconData i, String t, String url) =>
      url.isEmpty ? const SizedBox.shrink() : ListTile(leading: Icon(i), title: Text(t), trailing: const Icon(Icons.open_in_new, size: 18), onTap: () => _open(c, url));

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('عن التطبيق')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/icon/logo.png', width: 110, height: 110))),
          const SizedBox(height: 12),
          Center(child: Text(kAppName, style: Theme.of(c).textTheme.headlineSmall)),
          const Center(child: Text('الإصدار $kVersion')),
          const SizedBox(height: 8),
          const Center(child: Text('تطبيق تمارين رياضية مجاني بالكامل، بلا إعلانات، للبيت والجيم.', textAlign: TextAlign.center)),
          const Divider(height: 32),
          const ListTile(leading: Icon(Icons.code), title: Text('المطوّر'), subtitle: Text(kDeveloper)),
          const ListTile(leading: Icon(Icons.storefront), title: Text('متجر تطبيقات المسلم')),
          _link(c, Icons.link, 'رابط متجر تطبيقات المسلم', kStoreUrl),
          const ListTile(leading: Icon(Icons.school), title: Text('شبكة العلم نور الناس')),
          _link(c, Icons.link, 'رابط شبكة العلم نور الناس', kNetworkUrl),
          const Divider(height: 32),
          _link(c, Icons.folder_open, 'المستودع على GitHub (مفتوح المصدر)', kRepoUrl),
          _link(c, Icons.download, 'تحميل أحدث إصدار', kReleasesUrl),
          _link(c, Icons.privacy_tip, 'سياسة الخصوصية', kPrivacyUrl),
          _link(c, Icons.mail, 'تواصل معنا', kContactEmail.isEmpty ? '' : 'mailto:$kContactEmail'),
          ListTile(leading: const Icon(Icons.description), title: const Text('تراخيص المكتبات'), onTap: () => showLicensePage(context: c, applicationName: kAppName, applicationVersion: kVersion)),
          const Divider(height: 32),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('تنبيه صحي: التمارين في هذا التطبيق للتوعية واللياقة العامة وليست بديلًا عن استشارة الطبيب. '
                  'استشر طبيبك قبل البدء، وتوقف فورًا عند الشعور بألم أو دوخة. يُحفظ معرّف مجهول وسجلات تمارينك على Firebase، ولا نجمع أي بيانات شخصية.'),
            ),
          ),
        ]),
      );
}
