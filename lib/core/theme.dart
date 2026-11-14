import 'package:flutter/material.dart';

import 'models.dart';

/// ألوان كاشف الروابط | Link Scanner: Graphite داكن + Indigo كهربائي.
/// الأخضر للأمان/النجاح فقط، والأحمر والبرتقالي والأصفر لمستويات الخطر.
class C {
  C._();

  // هوية Graphite / Indigo: أسطح محايدة داكنة مع أزرق كهربائي واضح.
  static const Color bg = Color(0xFF080B13);
  static const Color surface = Color(0xFF111725);
  static const Color surface2 = Color(0xFF192337);
  static const Color line = Color(0xFF2B3852);

  /// لون الهوية الأساسي (أزرق نيلي فاتح).
  static const Color accent = Color(0xFF829BFF);

  /// لون بداية التدرجات والأزرار (نيلي أعمق).
  static const Color accentDeep = Color(0xFF586BE8);

  /// لون ثانوي مساعد للهوية، وليس بديلًا عن ألوان مستويات الخطورة.
  static const Color secondary = Color(0xFF58D6C8);

  /// الأخضر: "لا مؤشرات" / نجاح فقط.
  static const Color green = Color(0xFF42D6A0);
  static const Color amber = Color(0xFFFFC857);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color red = Color(0xFFFF5A6A);
  static const Color text = Color(0xFFF1F4FF);
  static const Color muted = Color(0xFF9BAAC7);

  /// لون النص فوق الأزرار الفاتحة.
  static const Color onAccent = Color(0xFF04122B);
}

/// لون بشفافية (بدون withOpacity لتفادي اختلاف نسخ Flutter)
Color alpha(Color c, double o) => c.withAlpha((o * 255).round());

/// توهج خفيف حوالين العناصر المهمة فقط (الشدة بتتقلّل تلقائيًا عشان الشكل يفضل هادي).
List<BoxShadow> glow(
  Color c, {
  double opacity = 0.25,
  double blur = 24,
  double spread = 0,
}) {
  return <BoxShadow>[
    BoxShadow(
      color: alpha(c, opacity * 0.6),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];
}

/// خلفية بطاقة: أسطح Graphite متدرجة وحدود Indigo هادئة.
BoxDecoration glassDecoration({
  Color? border,
  double radius = 20,
  bool glowing = false,
}) {
  final edge = border ?? C.line;
  return BoxDecoration(
    color: C.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: edge),
    boxShadow: glowing ? glow(border ?? C.accent, opacity: 0.10, blur: 18) : null,
  );
}

Color levelColor(RiskLevel l) {
  switch (l) {
    case RiskLevel.low:
      return C.green;
    case RiskLevel.medium:
      return C.amber;
    case RiskLevel.high:
      return C.orange;
    case RiskLevel.critical:
      return C.red;
  }
}

Color severityColor(Severity s) {
  switch (s) {
    case Severity.good:
      return C.green;
    case Severity.info:
      return C.muted;
    case Severity.warn:
      return C.amber;
    case Severity.danger:
      return C.red;
  }
}

IconData severityIcon(Severity s) {
  switch (s) {
    case Severity.good:
      return Icons.check_circle_rounded;
    case Severity.info:
      return Icons.info_rounded;
    case Severity.warn:
      return Icons.warning_amber_rounded;
    case Severity.danger:
      return Icons.dangerous_rounded;
  }
}

String fmtTime(DateTime t) {
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${t.day}/${t.month}  ${two(t.hour)}:${two(t.minute)}';
}

ThemeData buildTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: C.accent,
    brightness: Brightness.dark,
  );
  final scheme = base.copyWith(
    primary: C.accent,
    onPrimary: C.onAccent,
    secondary: C.secondary,
    surface: C.surface,
    onSurface: C.text,
    error: C.red,
    // أسطح Material 3 (الحوارات والقوائم والحقول) بنفس الزجاج الداكن بدل التدرّج المولّد من اللون.
    surfaceContainerLowest: C.bg,
    surfaceContainerLow: C.surface,
    surfaceContainer: C.surface,
    surfaceContainerHigh: C.surface2,
    surfaceContainerHighest: C.surface2,
    outline: C.line,
    outlineVariant: C.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      foregroundColor: C.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.bg,
      indicatorColor: alpha(C.accent, 0.16),
      surfaceTintColor: Colors.transparent,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(color: on ? C.accent : C.muted, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          color: on ? C.accent : C.muted,
          fontSize: 12,
          fontWeight: on ? FontWeight.w800 : FontWeight.w500,
        );
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.selected) ? C.onAccent : C.muted;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.selected) ? C.accent : C.surface2;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.selected) ? C.accent : C.line;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: C.accent,
      inactiveTrackColor: C.line,
      thumbColor: C.accent,
      overlayColor: alpha(C.accent, 0.16),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: C.accent,
      linearTrackColor: C.surface2,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: C.accent,
      selectionHandleColor: C.accent,
      selectionColor: alpha(C.accent, 0.3),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: C.accent),
    ),
    dividerTheme: const DividerThemeData(color: C.line, space: 1),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.surface2,
      contentTextStyle: TextStyle(color: C.text),
    ),
  );
}
