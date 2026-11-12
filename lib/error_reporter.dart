import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class AppErrorReport {
  final Object error;
  final StackTrace stackTrace;
  final String source;
  final DateTime occurredAt;

  AppErrorReport({
    required this.error,
    required this.stackTrace,
    required this.source,
  }) : occurredAt = DateTime.now();

  String get details => [
        'Muslim-Fit-pro error report',
        'Time: ${occurredAt.toIso8601String()}',
        'Source: $source',
        '',
        error.toString(),
        '',
        'Stack trace:',
        stackTrace.toString(),
      ].join('\n');
}

final globalErrorReport = ValueNotifier<AppErrorReport?>(null);

void reportAppError(Object error, StackTrace stackTrace, {required String source}) {
  if (globalErrorReport.value != null) return;
  globalErrorReport.value = AppErrorReport(error: error, stackTrace: stackTrace, source: source);
}

void reportAppErrorAfterFrame(Object error, {required String source}) {
  final stackTrace = StackTrace.current;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    reportAppError(error, stackTrace, source: source);
  });
}

class ErrorReportScreen extends StatefulWidget {
  final AppErrorReport report;

  const ErrorReportScreen({super.key, required this.report});

  @override
  State<ErrorReportScreen> createState() => _ErrorReportScreenState();
}

class _ErrorReportScreenState extends State<ErrorReportScreen> {
  String? _feedback;

  Future<void> _copyReport() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.report.details));
      if (mounted) setState(() => _feedback = 'تم نسخ تقرير الخطأ');
    } on PlatformException catch (error) {
      if (mounted) setState(() => _feedback = 'تعذر النسخ (${error.code})');
    } on MissingPluginException {
      if (mounted) setState(() => _feedback = 'ميزة النسخ غير متاحة على هذا الجهاز');
    }
  }

  Future<void> _shareReport() async {
    try {
      await Share.share(widget.report.details, subject: 'Muslim-Fit-pro error report');
    } on PlatformException catch (error) {
      if (mounted) setState(() => _feedback = 'تعذرت المشاركة (${error.code})');
    } on MissingPluginException {
      if (mounted) setState(() => _feedback = 'ميزة المشاركة غير متاحة على هذا الجهاز');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('حدث خطأ في التطبيق')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.error_outline, size: 52, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    'تعذر على التطبيق متابعة هذه العملية. انسخ التقرير أو شاركه للمساعدة في تشخيص المشكلة.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('المصدر: ${widget.report.source}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(widget.report.details),
                      ),
                    ),
                  ),
                  if (_feedback != null) ...[
                    const SizedBox(height: 8),
                    Text(_feedback!, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _copyReport,
                        icon: const Icon(Icons.copy),
                        label: const Text('نسخ التقرير'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _shareReport,
                        icon: const Icon(Icons.share),
                        label: const Text('مشاركة التقرير'),
                      ),
                      TextButton(
                        onPressed: () => globalErrorReport.value = null,
                        child: const Text('العودة إلى التطبيق'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
