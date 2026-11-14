import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/settings_store.dart';
import '../services/strings.dart';
import '../widgets/common.dart';
import '../widgets/intel_settings.dart';
import '../widgets/app_header.dart';
import '../widgets/sub_page.dart';
import '../widgets/tools.dart';
import '../widgets/tools_extra.dart';
import 'learn_screen.dart';
import 'train_screen.dart';

/// نص بحسب لغة الواجهة الحالية (عربي/إنجليزي) لهذه الشاشة فقط.
String _t(String ar, String en) => SettingsStore.instance.english ? en : ar;

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

void openTrain(BuildContext context) {
  _push(context, const BackPage(child: TrainScreen()));
}

void openLearn(BuildContext context) {
  _push(context, const LearnPage());
}

void openSettings(BuildContext context) {
  _push(
    context,
    ToolPage(
      title: _t('الإعدادات', 'Settings'),
      subtitle: _t('اللغة والتنبيهات ومصادر الفحص المتقدم',
          'Language, alerts and advanced scan sources'),
      icon: Icons.settings_rounded,
      children: const <Widget>[
        SettingsPanel(),
        SizedBox(height: 14),
        IntelSettingsPanel(),
      ],
    ),
  );
}

/// فحص المرسل (من القائمة الجانبية ومن تبويب المزيد).
void openSenderTool(BuildContext context) {
  _openTool(
    context,
    _t('فحص المرسل', 'Check a sender'),
    _t('تحقق من هوية المرسل', 'Verify who sent it'),
    Icons.alternate_email_rounded,
    const SenderTool(),
  );
}

/// الفحص المجمّع للروابط (من القائمة الجانبية ومن تبويب المزيد).
void openBatchTool(BuildContext context) {
  _openTool(
    context,
    _t('فحص مجمّع', 'Batch scan'),
    _t('الصق عدة روابط وافحصها دفعة واحدة',
        'Paste several links and scan them together'),
    Icons.playlist_add_check_rounded,
    const BatchTool(),
  );
}

void _openTool(
  BuildContext context,
  String title,
  String subtitle,
  IconData icon,
  Widget tool,
) {
  _push(
    context,
    ToolPage(
      title: title,
      subtitle: subtitle,
      icon: icon,
      children: <Widget>[tool],
    ),
  );
}

/// تبويب الأدوات: مجموعات مرئية بدل قائمة طويلة متشابهة.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.onQr, required this.onImage});

  final VoidCallback onQr;
  final VoidCallback onImage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppHeader(
          title: tr(S.moreTitle),
          subtitle: tr(S.moreSubtitle),
          icon: Icons.grid_view_rounded,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle(_t('الفحوصات الإضافية', 'ADDITIONAL SCANS')),
              const SizedBox(height: 9),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.28,
                children: [
                  _MoreToolCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: _t('فحص QR', 'QR scan'),
                    subtitle: _t('افحص الرابط داخل الرمز', 'Inspect an encoded link'),
                    onTap: onQr,
                    tint: C.green,
                  ),
                  _MoreToolCard(
                    icon: Icons.image_search_rounded,
                    title: _t('فحص صورة', 'Image scan'),
                    subtitle: _t('حلّل لقطة شاشة', 'Analyze a screenshot'),
                    onTap: onImage,
                    tint: C.amber,
                  ),
                  _MoreToolCard(
                    icon: Icons.alternate_email_rounded,
                    title: _t('فحص المرسل', 'Sender check'),
                    subtitle: _t('تحقق من هوية المرسل', 'Inspect sender identity'),
                    onTap: () => openSenderTool(context),
                    tint: C.orange,
                  ),
                  _MoreToolCard(
                    icon: Icons.playlist_add_check_rounded,
                    title: _t('فحص مجمّع', 'Batch scan'),
                    subtitle: _t('افحص عدة روابط معًا', 'Scan multiple links'),
                    onTap: () => openBatchTool(context),
                    tint: C.accent,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SectionTitle(_t('التعلّم والتدريب', 'LEARN & TRAIN')),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _MoreToolCard(
                      icon: Icons.sports_esports_rounded,
                      title: _t('تدرّب على الكشف', 'Training'),
                      subtitle: _t('تحديات بمستويات مختلفة', 'Progressive challenges'),
                      onTap: () => openTrain(context),
                      tint: C.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MoreToolCard(
                      icon: Icons.school_rounded,
                      title: _t('دروس الحماية', 'Protection lessons'),
                      subtitle: _t('تعلم علامات الاحتيال', 'Learn scam signals'),
                      onTap: () => openLearn(context),
                      tint: C.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SectionTitle(_t('أدوات الروابط وكلمات السر', 'LINK & PASSWORD TOOLS')),
              const SizedBox(height: 9),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.28,
                children: [
                  _MoreToolCard(
                    icon: Icons.password_rounded,
                    title: _t('قوة كلمة السر', 'Password strength'),
                    subtitle: _t('قيّم قوة كلمة السر', 'Evaluate a password'),
                    onTap: () => _openTool(
                      context,
                      _t('قوة كلمة السر', 'Password strength'),
                      _t('التحليل بيتم على جهازك فقط', 'Analyzed on your device only'),
                      Icons.password_rounded,
                      const StrengthTool(),
                    ),
                    tint: C.secondary,
                  ),
                  _MoreToolCard(
                    icon: Icons.casino_rounded,
                    title: _t('مولّد كلمات السر', 'Password generator'),
                    subtitle: _t('أنشئ كلمات قوية عشوائية', 'Generate strong passwords'),
                    onTap: () => _openTool(
                      context,
                      _t('مولّد كلمات السر', 'Password generator'),
                      _t('كلمات سر عشوائية قوية', 'Strong random passwords'),
                      Icons.casino_rounded,
                      const GeneratorTool(),
                    ),
                    tint: C.green,
                  ),
                  _MoreToolCard(
                    icon: Icons.cleaning_services_rounded,
                    title: _t('منظّف الروابط', 'Link cleaner'),
                    subtitle: _t('أزل معاملات التتبع', 'Remove tracking parameters'),
                    onTap: () => _openTool(
                      context,
                      _t('منظّف الروابط', 'Link cleaner'),
                      _t('شيل التتبّع من الرابط', 'Remove tracking from a link'),
                      Icons.cleaning_services_rounded,
                      const CleanerTool(),
                    ),
                    tint: C.amber,
                  ),
                  _MoreToolCard(
                    icon: Icons.tag_rounded,
                    title: _t('حساب الهاش', 'Hash generator'),
                    subtitle: _t('احسب بصمة النص', 'Compute a text hash'),
                    onTap: () => _openTool(
                      context,
                      _t('هاش', 'Hash'),
                      _t('بصمة النص على جهازك', 'Text fingerprint on your device'),
                      Icons.tag_rounded,
                      const HashTool(),
                    ),
                    tint: C.orange,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SectionTitle(_t('إعداد التطبيق', 'APP SETTINGS')),
              const SizedBox(height: 9),
              _MoreItem(
                icon: Icons.settings_rounded,
                title: _t('الإعدادات ومصادر الفحص', 'Settings and scan sources'),
                subtitle: _t('اللغة، مراقبة الحافظة، ومفاتيح الفحص المتقدم', 'Language, clipboard watch and advanced scan keys'),
                onTap: () => openSettings(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreToolCard extends StatelessWidget {
  const _MoreToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tint = C.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: alpha(tint, 0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: tint, size: 21),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_outward_rounded, color: C.muted, size: 15),
                ],
              ),
              const SizedBox(height: 11),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.muted, fontSize: 10.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: alpha(C.accent, 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: C.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 13.5)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: C.muted, fontSize: 11, height: 1.35)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: C.muted),
            ],
          ),
        ),
      ),
    );
  }
}
