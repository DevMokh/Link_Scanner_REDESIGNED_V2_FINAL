import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/history_store.dart';
import '../services/settings_store.dart';
import '../services/threat_feed.dart';
import '../widgets/brand_logo.dart';
import '../widgets/common.dart';
import '../widgets/stats_card.dart';

const List<String> _tips = <String>[
  'لو رسالة بتهدّدك بإيقاف حسابك خلال ساعات، دي علامة نصب كلاسيكية. البنوك الحقيقية مش بتستعجلك كده.',
  'محدش رسمي (بنك، محفظة، شركة اتصالات) هيطلب منك كود التحقق أو الـ CVV في مكالمة أو رسالة. اقفل الخط.',
  'اقرأ اسم الدومين من اليمين لليسار قبل الـ.com أو .eg. الجزء الأهم هو أقرب حاجة لنوع الامتداد.',
  'لو حد قالك "رقمي اتغير" وطلب فلوس، اتصل بالرقم القديم أو اسأله سؤال يعرفه هو بس قبل ما تحول.',
  'رمز QR ممكن يتلصق فوق رمز حقيقي في محل أو عداد ركن. راجع اسم الموقع بعد ما تفحصه قبل الدفع.',
  'لا تثبت تطبيق تحكم عن بعد بناءً على طلب حد اتصل بيك وقال إنه دعم فني.',
  'وظيفة بتطلب فلوس تسجيل مقدمًا هي نصب في الأغلب، مهما كان المرتب المعروض مغري.',
  'لو الرسالة فيها رابط ومعاه استعجال أو تهديد، افتراض إنه نصب أأمن ليك من فتحه.',
  'غيّر كلمة السر فورًا لو ضغطت على رابط مشبوه وكتبت بياناتك، وفعّل التحقق بخطوتين لو متاح.',
  'الجهات الحكومية (تموين، تأمينات، كهرباء) مش بترسل روابط دفع أو تهديد بقطع خدمة برسالة SMS.',
];

String _tipOfDay() {
  final day = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
  return _tips[day % _tips.length];
}

String _t(String ar, String en) => SettingsStore.instance.english ? en : ar;

int countThreats(List<HistoryItem> items) {
  var n = 0;
  for (final it in items) {
    if (it.level == RiskLevel.high || it.level == RiskLevel.critical) n++;
  }
  return n;
}

int countUrlScans(List<HistoryItem> items) {
  var n = 0;
  for (final it in items) {
    if (it.kind == ScanKind.url) n++;
  }
  return n;
}

String agoText(DateTime t, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inMinutes < 1) return _t('الآن', 'just now');
  if (d.inMinutes < 60) return _t('منذ ${d.inMinutes} دقيقة', '${d.inMinutes} min ago');
  if (d.inHours < 24) return _t('منذ ${d.inHours} ساعة', '${d.inHours} h ago');
  return _t('منذ ${d.inDays} يوم', '${d.inDays} d ago');
}

/// Main command center. All counters are derived from the real on-device history.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.onTab,
    required this.onQr,
    required this.onImage,
    required this.onSender,
    required this.onBatch,
    required this.onTrain,
    required this.onLearn,
    required this.onSettings,
    required this.onMenu,
  });

  final void Function(int tabIndex) onTab;
  final VoidCallback onQr;
  final VoidCallback onImage;
  final VoidCallback onSender;
  final VoidCallback onBatch;
  final VoidCallback onTrain;
  final VoidCallback onLearn;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  Widget _topBar(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, top + 12, 18, 18),
      child: Row(
        children: [
          const LinkScannerLogo(size: 44, glowing: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(kAppNameAr,
                    style: TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w900)),
                Text(kAppNameEn,
                    style: TextStyle(color: C.accent.withAlpha(220), fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
              ],
            ),
          ),
          Material(
            color: C.surface2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: C.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: onMenu,
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.tune_rounded, color: C.text, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero({required bool ready, required String detail}) {
    final status = ready ? C.green : C.amber;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[Color(0xFF1D315C), Color(0xFF111C35), Color(0xFF101725)],
        ),
        border: Border.all(color: alpha(C.accent, 0.30)),
        boxShadow: glow(C.accent, opacity: 0.16, blur: 28),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -44,
            top: -56,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: alpha(C.accent, 0.12), width: 26),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: alpha(status, 0.13),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: alpha(status, 0.35)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: status, shape: BoxShape.circle)),
                        const SizedBox(width: 7),
                        Text(ready ? _t('مصادر التهديدات محدثة', 'SOURCES UP TO DATE') : _t('تحديث المصادر مطلوب', 'UPDATE SOURCES'),
                            style: TextStyle(color: status, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
                      ]),
                    ),
                    const Spacer(),
                    const Icon(Icons.shield_moon_rounded, color: C.accent, size: 24),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  _t('اعرف الرابط قبل ما تضغط', 'Know the link before you tap'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 23, height: 1.25),
                ),
                const SizedBox(height: 8),
                Text(detail, style: const TextStyle(color: Color(0xFFCAD5EC), fontSize: 12.5, height: 1.55)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => onTab(1),
                    style: FilledButton.styleFrom(
                      backgroundColor: C.accent,
                      foregroundColor: C.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 22),
                    label: Text(_t('ابدأ فحص رابط', 'SCAN A LINK')),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _t('الفحص الأساسي محلي على جهازك • لا تفتح الرابط أثناء التحليل', 'Core analysis runs on-device • Do not open the link during analysis'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9EACCA), fontSize: 10.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 7),
            Text(value, style: const TextStyle(color: C.text, fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, maxLines: 2,
                style: const TextStyle(color: C.muted, fontSize: 10.5, height: 1.25)),
          ],
        ),
      ),
    );
  }

  Widget _toolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color tint = C.accent,
    bool featured = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: featured ? alpha(tint, 0.10) : C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: featured ? alpha(tint, 0.42) : C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: alpha(tint, 0.14), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: tint, size: 21),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, color: alpha(C.muted, 0.8), size: 16),
              ]),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: C.text, fontSize: 13.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.muted, fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quick(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: C.surface,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: C.line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: C.accent, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recent(HistoryItem it) {
    final c = levelColor(it.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: C.line)),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: alpha(c, 0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: alpha(c, 0.30))),
          child: Center(child: Text('${it.score}', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13))),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Directionality(
            textDirection: it.kind == ScanKind.url ? TextDirection.ltr : TextDirection.rtl,
            child: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: C.text, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Text('${it.level.label}  •  ${agoText(it.time)}', style: TextStyle(color: c, fontSize: 10.5)),
        ])),
        Icon(it.kind == ScanKind.url ? Icons.link_rounded : Icons.mark_email_unread_rounded, color: C.muted, size: 19),
      ]),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alpha(C.amber, 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alpha(C.amber, 0.24)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: alpha(C.amber, 0.14), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.lightbulb_outline_rounded, color: C.amber, size: 21)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('معلومة أمان اليوم', 'SECURITY TIP'), style: const TextStyle(color: C.amber, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text(_tipOfDay(), style: const TextStyle(color: C.text, fontSize: 12.5, height: 1.55)),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[HistoryStore.instance, ThreatFeed.instance]),
      builder: (context, _) {
        final items = HistoryStore.instance.items;
        final feed = ThreatFeed.instance;
        final stale = feed.updated == null || DateTime.now().difference(feed.updated!) > const Duration(days: 14);
        final detail = stale
            ? _t(
                'الفحص الأساسي متاح على جهازك، لكن قاعدة مصادر التهديدات تحتاج إلى تحميل أو تحديث.',
                'On-device scanning is available, but the threat-source database needs to be downloaded or updated.',
              )
            : items.isEmpty
                ? _t(
                    'افحص الروابط والرسائل المشبوهة قبل فتحها. أدوات الحماية الأساسية كلها في مكان واحد.',
                    'Check suspicious links and messages before opening them. Your security tools are in one place.',
                  )
                : '${_t('آخر فحص', 'Last scan')}: ${agoText(items.first.time)}. ${_t('الفحص بيبدأ لما تطلبه فقط.', 'Scanning only starts when you request it.')}';

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _topBar(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _hero(ready: !stale, detail: detail),
                const SizedBox(height: 17),
                Row(children: [
                  _stat(Icons.link_rounded, '${countUrlScans(items)}', _t('روابط مفحوصة', 'Links scanned'), C.accent),
                  const SizedBox(width: 9),
                  _stat(Icons.warning_amber_rounded, '${countThreats(items)}', _t('تهديدات', 'Threats'), C.red),
                  const SizedBox(width: 9),
                  _stat(Icons.manage_search_rounded, '${items.length}', _t('إجمالي الفحوص', 'Total scans'), C.secondary),
                ]),
                const SizedBox(height: 8),
                Text(
                  items.length >= HistoryStore.maxItems
                      ? _t('إحصائيات من سجل الجهاز — يتم الاحتفاظ بآخر ${HistoryStore.maxItems} فحص.', 'On-device history — the latest ${HistoryStore.maxItems} scans are kept.')
                      : _t('الإحصائيات محسوبة من سجل الفحوصات المحفوظ على جهازك.', 'Statistics are calculated from your on-device scan history.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 10.5),
                ),
                const SizedBox(height: 22),
                SectionTitle(_t('مركز الأدوات', 'SECURITY TOOLKIT')),
                Text(_t('اختار نوع الفحص أو الأداة المناسبة.', 'Choose the scan type or tool you need.'),
                    style: const TextStyle(color: C.muted, fontSize: 11.5)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.30,
                  children: [
                    _toolTile(icon: Icons.link_rounded, title: _t('فحص رابط', 'Link scanner'), subtitle: _t('تحليل عنوان الموقع', 'URL risk analysis'), onTap: () => onTab(1), featured: true),
                    _toolTile(icon: Icons.mark_email_unread_rounded, title: _t('فحص رسالة', 'Message scan'), subtitle: _t('استخراج الروابط والإشارات', 'Links and warning signs'), onTap: () => onTab(2), tint: C.secondary),
                    _toolTile(icon: Icons.qr_code_scanner_rounded, title: _t('فحص QR', 'QR scanner'), subtitle: _t('قراءة الرمز وفحصه', 'Read and inspect a code'), onTap: onQr, tint: C.green),
                    _toolTile(icon: Icons.image_search_rounded, title: _t('فحص صورة', 'Image scan'), subtitle: _t('استخراج النصوص والروابط', 'Extract text and links'), onTap: onImage, tint: C.amber),
                    _toolTile(icon: Icons.alternate_email_rounded, title: _t('فحص المرسل', 'Sender check'), subtitle: _t('تحليل بيانات المرسل', 'Inspect sender details'), onTap: onSender, tint: C.orange),
                    _toolTile(icon: Icons.playlist_add_check_rounded, title: _t('فحص مجمّع', 'Batch scan'), subtitle: _t('فحص أكثر من رابط', 'Scan multiple URLs'), onTap: onBatch, tint: C.accent),
                  ],
                ),
                const SizedBox(height: 20),
                SectionTitle(_t('تعلم وطوّر حمايتك', 'LEARN & IMPROVE')),
                Row(children: [
                  Expanded(child: _toolTile(icon: Icons.sports_esports_rounded, title: _t('تدرّب', 'Training'), subtitle: _t('اختبر قدرتك على كشف الاحتيال', 'Practice spotting scams'), onTap: onTrain, tint: C.secondary)),
                  const SizedBox(width: 10),
                  Expanded(child: _toolTile(icon: Icons.school_rounded, title: _t('دروس الحماية', 'Learn'), subtitle: _t('إرشادات عملية', 'Practical guidance'), onTap: onLearn, tint: C.accent)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _quick(Icons.grid_view_rounded, _t('كل الأدوات', 'All tools'), () => onTab(4)),
                  const SizedBox(width: 10),
                  _quick(Icons.settings_rounded, _t('الإعدادات', 'Settings'), onSettings),
                ]),
                if (stale) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: alpha(C.amber, 0.07), borderRadius: BorderRadius.circular(18), border: Border.all(color: alpha(C.amber, 0.3))),
                    child: Row(children: [
                      const Icon(Icons.sync_problem_rounded, color: C.amber, size: 23),
                      const SizedBox(width: 11),
                      Expanded(child: Text(
                        feed.updated == null
                            ? _t('قاعدة مصادر التهديدات لم تُحمّل بعد. يمكنك إعدادها من الإعدادات.', 'Threat sources have not been downloaded yet. Configure them in Settings.')
                            : _t('قاعدة مصادر التهديدات قديمة. حدّثها للحصول على أحدث بيانات الكشف.', 'Threat sources are outdated. Update them for the latest detection data.'),
                        style: const TextStyle(color: C.muted, fontSize: 11.5, height: 1.45),
                      )),
                      TextButton(onPressed: onSettings, child: Text(_t('تحديث', 'Update'))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                if (items.isNotEmpty) ...[
                  SectionTitle(_t('آخر عمليات الفحص', 'RECENT SCANS'), trailing: TextButton(onPressed: () => onTab(3), child: Text(_t('عرض الكل', 'View all')))),
                  for (final it in items.take(3)) _recent(it),
                  const SizedBox(height: 4),
                  StatsCard(items: items),
                  const SizedBox(height: 18),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
                    child: Row(children: [
                      const Icon(Icons.history_toggle_off_rounded, color: C.muted, size: 30),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_t('لسه مفيش فحوصات محفوظة. أول فحص هتعمله هيظهر هنا.', 'No saved scans yet. Your first scan will appear here.'), style: const TextStyle(color: C.muted, fontSize: 12.5, height: 1.5))),
                    ]),
                  ),
                  const SizedBox(height: 18),
                ],
                _tipCard(),
              ]),
            ),
          ],
        );
      },
    );
  }
}
