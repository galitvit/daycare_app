import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DaycareApp());
}

class DaycareApp extends StatefulWidget {
  const DaycareApp({super.key});

  static _DaycareAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_DaycareAppState>();
    assert(state != null, 'DaycareApp state not found in context');
    return state!;
  }

  @override
  State<DaycareApp> createState() => _DaycareAppState();
}

class _DaycareAppState extends State<DaycareApp> {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('he')
          : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(_locale);
    return MaterialApp(
      title: l10n.tr('daycareApp'),
      // --- MASSIVE UI UPGRADE HERE ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        // 1. Soft Pastel Background for the whole app
        scaffoldBackgroundColor: Colors.transparent,

        // 2. Playful, rounded AppBars
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal.shade400,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),

        // 3. Floating, soft-shadow Cards
        cardTheme: CardThemeData(
          // <-- Added 'Data' here
          elevation: 8,
          shadowColor: Colors.teal.shade900.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // 4. Friendly, rounded Dialogs
        dialogTheme: DialogThemeData(
          // <-- Added 'Data' here
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
        ),

        // 5. Chunky, tappable Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.teal.shade500,
            foregroundColor: Colors.white,
          ),
        ),

        // 6. Playful Floating Action Buttons
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 6,
        ),

        // 7. Soft Text Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.teal.shade50.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.teal.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // -------------------------------
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade100,
                Colors.blue.shade50,
                Colors.orange.shade100,
              ],
            ),
          ),
          child: child,
        );
      },
      home: AuthRouter(),
    );
  }
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  bool get isHebrew => locale.languageCode == 'he';

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(DaycareApp.of(context).locale);
  }

  String tr(String key, [Map<String, String>? params]) {
    var value =
        (_values[locale.languageCode] ?? _values['en']!)[key] ??
        _values['en']![key] ??
        key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }

  String activityType(String type) {
    const knownTypes = {
      'Incident': 'incident',
      'Daily Note': 'dailyNote',
      'Nap': 'nap',
      'Meal': 'meal',
      'Absence': 'absence',
      'Daily Summary': 'dailySummary',
      'Update': 'update',
    };
    final key = knownTypes[type];
    return key == null ? type : tr(key);
  }

  String activityDetails(String details) {
    const knownDetails = {
      'Woke up': 'wokeUp',
      'Sleeping': 'sleeping',
      'Ate meal': 'ateMeal',
      'Absent': 'Child not in attendance',
      'Planned absence': 'plannedAbsence',
    };
    final key = knownDetails[details];
    return key == null ? details : tr(key);
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'daycareApp': 'Daycare App',
      'checkingPermissions': 'Checking permissions...',
      'signOut': 'Sign Out',
      'missingEmail': 'This account does not have a valid email address.',
      'googleSignInFailed': 'Google sign-in failed',
      'googleSignInUnavailable':
          'Google sign-in is not available on this device.',
      'allFieldsMandatory': 'All fields are mandatory!',
      'genericError': 'Error',
      'login': 'Login',
      'signUp': 'Sign Up',
      'email': 'Email',
      'phoneNumber': 'Phone Number (with country code, e.g. 15551234567)',
      'password': 'Password',
      'loginWithGoogle': 'Login with Google',
      'signUpWithGoogle': 'Sign Up with Google',
      'createAccount': 'Create an account',
      'alreadyHaveAccount': 'I already have an account',
      'inviteTeacherTo': 'Invite Teacher to {daycareName}',
      'teacherEmail': 'Teacher Email',
      'cancel': 'Cancel',
      'sendInvite': 'Send Invite',
      'adminDashboard': 'Admin Dashboard',
      'newDaycare': 'New Daycare',
      'daycareName': 'Daycare Name',
      'create': 'Create',
      'addDaycare': 'Add Daycare',
      'teachers': 'Teachers',
      'invite': 'Invite',
      'editChild': 'Edit {name}',
      'childName': 'Child Name',
      'parentPhoneExample': 'Parent Phone (e.g. 15551234567)',
      'parentEmailExample': 'Parent Email (e.g. parent@example.com)',
      'saveChanges': 'Save Changes',
      'incidentTitle': 'Daily Note: {childName}',
      'whatHappened': 'What would you like to share?',
      'save': 'Save',
      'dailyReportTitle': 'Daily Report: {childName}',
      'whatsApp': 'WhatsApp',
      'saveToApp': 'Save to App',
      'logForChild': 'Log for {childName}',
      'generateDailyReport': 'Generate Daily Report',
      'updateNap': 'Update Nap',
      'napStartTime': 'Nap start time',
      'napEndTime': 'Nap end time',
      'saveNap': 'Save Nap',
      'invalidNapTimes': 'End time must be after start time.',
      'napDetails': 'Start: {start}, End: {end} (Duration: {duration})',
      'logMeal': 'Log Meal',
      'incidentReport': 'Daily Note',
      'addChild': 'Add Child',
      'nameRequired': 'Name *',
      'parentEmailRequired': 'Parent Email *',
      'parentPhone': 'Parent Phone',
      'teacherDashboard': 'Teacher Dashboard',
      'unknown': 'Unknown',
      'parents': 'Parents: {parents}',
      'none': 'None',
      'myChildren': 'My Children',
      'noChildrenLinked':
          'No children linked to {email}. Please ask the teacher to add your email to your child\'s profile.',
      'tapToViewActivity': 'Tap to view today\'s activity',
      'tapToViewActivityAtDaycare':
          'Tap to view today\'s activity at {daycareName}',
      'noActivitiesForDay': 'No activities for this day.',
      'dailySummary': 'Daily Summary',
      'postedAt': 'Posted at {time}',
      'whatsAppSentAt': 'WhatsApp message sent at {time}',
      'markAsSeen': 'Mark as Seen',
      'seen': 'Seen',
      'seenAt': 'Seen at {time}',
      'notSeenYet': 'Not seen yet',
      'seenMarked': 'Marked as seen.',
      'editActivity': 'Edit Activity',
      'deleteActivity': 'Delete Activity',
      'deleteActivityConfirm': 'Are you sure you want to delete this activity?',
      'updateMeal': 'Update Meal',
      'updateIncident': 'Update Daily Note',
      'mealDetailsHint': 'Meal details',
      'saveUpdate': 'Save Update',
      'activityUpdated': 'Activity updated.',
      'activityDeleted': 'Activity deleted.',
      'updateFailed': 'Update failed.',
      'deleteDailyReport': 'Delete Daily Report',
      'deleteDailyReportConfirm': 'Delete this daily report?',
      'delete': 'Delete',
      'dailyReportDeleted': 'Daily report deleted.',
      'deleteFailed': 'Delete failed.',
      'summaryForDay': 'Summary for {childName}\'s day:\n\n',
      'mealAte': 'Ate meal',
      'napSleeping': 'Sleeping',
      'napWokeUp': 'Woke up',
      'incident': 'Daily Note',
      'dailyNote': 'Daily Note',
      'nap': 'Nap',
      'meal': 'Meal',
      'absence': 'Absence',
      'update': 'Update',
      'wokeUp': 'Woke up',
      'sleeping': 'Sleeping',
      'ateMeal': 'Ate meal',
      'absent': 'Child not in attendance',
      'plannedAbsence': 'Planned Absence',
      'reportAbsence': 'Report Absence',
      'editAbsence': 'Edit Absence',
      'absenceType': 'Type',
      'absenceDate': 'Date',
      'absenceFrom': 'From',
      'absenceTo': 'To',
      'absenceNote': 'Note (optional)',
      'saveAbsence': 'Save Absence',
      'absenceReports': 'Absence reports',
      'absenceMarkedToday': 'Marked absent for today.',
      'absenceAlreadyMarkedToday': 'Absence already marked for today.',
      'reportedByParent': 'Reported by parent',
      'reportedByTeacher': 'Reported by teacher',
      'parentManaged': 'Parent managed',
      'parentReportedAbsence': 'Parent reported absence',
      'languageToggle': 'עב',
      'noticesBoard': 'Holidays & Vacations',
      'addNotice': 'Add Notice',
      'noticeTitleHint': 'Title (e.g. Passover Holiday)',
      'noticeFrom': 'From',
      'noticeTo': 'To',
      'noticeNote': 'Note (optional)',
      'noNotices': 'No notices posted yet.',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'deleteNotice': 'Delete Notice',
      'deleteNoticeConfirm': 'Delete this notice?',
      'noticeDeleted': 'Notice deleted.',
      'editNotice': 'Edit Notice',
      'saveNotice': 'Save',
      'noticeTitleRequired': 'Title is required.',
      'viewNoticesBoard': 'Holidays & Vacations',
      'todayNoticeBanner': 'Today',
      'weeklyMealPlan': 'Weekly Meal Plan',
      'viewWeeklyMealPlan': 'Weekly Meal Plan',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'afterLunchTreat': 'After Lunch Treat',
      'saveMealPlan': 'Save Meal Plan',
      'mealPlanSaved': 'Meal plan saved.',
      'weekOf': 'Week of {date}',
      'noMealPlanYet': 'No meal plan posted for this week.',
      'sunday': 'Sunday',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'importantDocuments': 'Important Documents',
      'viewDocuments': 'Important Documents',
      'uploadDocument': 'Upload Document',
      'downloadDocument': 'Download',
      'noDocumentsAvailable': 'No documents uploaded yet.',
      'documentUploaded': 'Document uploaded successfully.',
      'uploadFailed': 'Upload failed.',
      'selectFile': 'Select File',
      'deleteDocument': 'Delete Document',
      'deleteDocumentConfirm': 'Delete this document?',
      'documentDeleted': 'Document deleted.',
    },
    'he': {
      'daycareApp': 'אפליקציית מעון',
      'checkingPermissions': 'בודק הרשאות...',
      'signOut': 'התנתק',
      'missingEmail': 'לחשבון הזה אין כתובת אימייל תקינה.',
      'googleSignInFailed': 'ההתחברות עם גוגל נכשלה',
      'googleSignInUnavailable': 'ההתחברות עם גוגל אינה זמינה במכשיר הזה.',
      'allFieldsMandatory': 'כל השדות הם חובה!',
      'genericError': 'שגיאה',
      'login': 'התחברות',
      'signUp': 'הרשמה',
      'email': 'אימייל',
      'phoneNumber': 'מספר טלפון (עם קידומת מדינה, לדוגמה 15551234567)',
      'password': 'סיסמה',
      'loginWithGoogle': 'התחברות עם גוגל',
      'signUpWithGoogle': 'הרשמה עם גוגל',
      'createAccount': 'צור חשבון',
      'alreadyHaveAccount': 'כבר יש לי חשבון',
      'inviteTeacherTo': 'הזמן מורה ל־{daycareName}',
      'teacherEmail': 'אימייל המורה',
      'cancel': 'ביטול',
      'sendInvite': 'שלח הזמנה',
      'adminDashboard': 'לוח ניהול',
      'newDaycare': 'מעון חדש',
      'daycareName': 'שם המעון',
      'create': 'צור',
      'addDaycare': 'הוסף מעון',
      'teachers': 'מורים',
      'invite': 'הזמן',
      'editChild': 'ערוך את {name}',
      'childName': 'שם הילד',
      'parentPhoneExample': 'טלפון הורה (לדוגמה 15551234567)',
      'parentEmailExample': 'אימייל הורה (לדוגמה parent@example.com)',
      'saveChanges': 'שמור שינויים',
      'incidentTitle': 'הערה יומית: {childName}',
      'whatHappened': 'מה תרצה לעדכן?',
      'save': 'שמור',
      'dailyReportTitle': 'דוח יומי: {childName}',
      'whatsApp': 'וואטסאפ',
      'saveToApp': 'שמור באפליקציה',
      'logForChild': 'רישום עבור {childName}',
      'generateDailyReport': 'צור דוח יומי',
      'updateNap': 'עדכון שינה',
      'napStartTime': 'שעת תחילת שינה',
      'napEndTime': 'שעת סיום שינה',
      'saveNap': 'שמור שינה',
      'invalidNapTimes': 'שעת הסיום חייבת להיות אחרי שעת ההתחלה.',
      'napDetails': 'התחלה: {start}, סיום: {end} (משך: {duration})',
      'logMeal': 'רשום ארוחה',
      'incidentReport': 'הערה יומית',
      'addChild': 'הוסף ילד',
      'nameRequired': 'שם *',
      'parentEmailRequired': 'אימייל הורה *',
      'parentPhone': 'טלפון הורה',
      'teacherDashboard': 'לוח מורה',
      'unknown': 'לא ידוע',
      'parents': 'הורים: {parents}',
      'none': 'אין',
      'myChildren': 'הילדים שלי',
      'noChildrenLinked':
          'אין ילדים שמקושרים ל־{email}. בקש מהמורה להוסיף את האימייל שלך לפרופיל הילד.',
      'tapToViewActivity': 'הקש לצפייה בפעילות של היום',
      'tapToViewActivityAtDaycare':
          'הקש לצפייה בפעילות של היום ב־{daycareName}',
      'noActivitiesForDay': 'אין פעילויות ליום זה.',
      'dailySummary': 'סיכום יומי',
      'postedAt': 'פורסם ב־{time}',
      'whatsAppSentAt': 'הודעת וואטסאפ נשלחה ב־{time}',
      'markAsSeen': 'סמן כנצפה',
      'seen': 'נצפה',
      'seenAt': 'נצפה ב־{time}',
      'notSeenYet': 'טרם נצפה',
      'seenMarked': 'סומן כנצפה.',
      'editActivity': 'ערוך פעילות',
      'deleteActivity': 'מחק פעילות',
      'deleteActivityConfirm': 'האם אתה בטוח שברצונך למחוק את הפעילות הזו?',
      'updateMeal': 'עדכן ארוחה',
      'updateIncident': 'עדכן הערה יומית',
      'mealDetailsHint': 'פרטי ארוחה',
      'saveUpdate': 'שמור עדכון',
      'activityUpdated': 'הפעילות עודכנה.',
      'activityDeleted': 'הפעילות נמחקה.',
      'updateFailed': 'העדכון נכשל.',
      'deleteDailyReport': 'מחק דוח יומי',
      'deleteDailyReportConfirm': 'למחוק את הדוח היומי הזה?',
      'delete': 'מחק',
      'dailyReportDeleted': 'הדוח היומי נמחק.',
      'deleteFailed': 'מחיקה נכשלה.',
      'summaryForDay': 'סיכום היום של {childName}:\n\n',
      'mealAte': 'אכל ארוחה',
      'napSleeping': 'ישן',
      'napWokeUp': 'התעורר',
      'incident': 'הערה יומית',
      'dailyNote': 'הערה יומית',
      'nap': 'שינה',
      'meal': 'ארוחה',
      'absence': 'היעדרות',
      'update': 'עדכון',
      'wokeUp': 'התעורר',
      'sleeping': 'ישן',
      'ateMeal': 'אכל ארוחה',
      'absent': 'לא נוכח',
      'plannedAbsence': 'היעדרות מתוכננת',
      'reportAbsence': 'דיווח היעדרות',
      'editAbsence': 'עריכת היעדרות',
      'absenceType': 'סוג',
      'absenceDate': 'תאריך',
      'absenceFrom': 'מתאריך',
      'absenceTo': 'עד תאריך',
      'absenceNote': 'הערה (אופציונלי)',
      'saveAbsence': 'שמור היעדרות',
      'absenceReports': 'דיווחי היעדרות',
      'absenceMarkedToday': 'הילד סומן כלא נוכח להיום.',
      'absenceAlreadyMarkedToday': 'כבר קיים דיווח היעדרות להיום.',
      'reportedByParent': 'דווח על ידי הורה',
      'reportedByTeacher': 'דווח על ידי הצוות',
      'parentManaged': 'מנוהל על ידי הורה',
      'parentReportedAbsence': 'דווחה היעדרות על ידי הורה',
      'languageToggle': 'EN',
      'noticesBoard': 'חגים וחופשות',
      'addNotice': 'הוסף הודעה',
      'noticeTitleHint': 'כותרת (לדוגמה: חג פסח)',
      'noticeFrom': 'מתאריך',
      'noticeTo': 'עד תאריך',
      'noticeNote': 'הערה (אופציונלי)',
      'noNotices': 'אין הודעות עדיין.',
      'upcoming': 'קרוב',
      'past': 'עבר',
      'deleteNotice': 'מחק הודעה',
      'deleteNoticeConfirm': 'למחוק את ההודעה הזו?',
      'noticeDeleted': 'ההודעה נמחקה.',
      'editNotice': 'ערוך הודעה',
      'saveNotice': 'שמור',
      'noticeTitleRequired': 'כותרת היא שדה חובה.',
      'viewNoticesBoard': 'חגים וחופשות',
      'todayNoticeBanner': 'היום',
      'weeklyMealPlan': 'תפריט שבועי',
      'viewWeeklyMealPlan': 'תפריט שבועי',
      'breakfast': 'ארוחת בוקר',
      'lunch': 'ארוחת צהריים',
      'afterLunchTreat': 'קינוח',
      'saveMealPlan': 'שמור תפריט',
      'mealPlanSaved': 'התפריט נשמר.',
      'weekOf': 'שבוע של {date}',
      'noMealPlanYet': 'לא נמצא תפריט לשבוע זה.',
      'sunday': 'יום ראשון',
      'monday': 'יום שני',
      'tuesday': 'יום שלישי',
      'wednesday': 'יום רביעי',
      'thursday': 'יום חמישי',
      'friday': 'יום שישי',
      'saturday': 'יום שבת',
      'importantDocuments': 'מסמכים חשובים',
      'viewDocuments': 'מסמכים חשובים',
      'uploadDocument': 'העלה מסמך',
      'downloadDocument': 'הורד',
      'noDocumentsAvailable': 'לא הועלו מסמכים עדיין.',
      'documentUploaded': 'מסמך הועלה בהצלחה.',
      'uploadFailed': 'ההעלאה נכשלה.',
      'selectFile': 'בחר קובץ',
      'deleteDocument': 'מחק מסמך',
      'deleteDocumentConfirm': 'למחוק את המסמך הזה?',
      'documentDeleted': 'המסמך נמחק.',
    },
  };
}

String _formatTimeHHmm(DateTime dateTime) {
  final hh = dateTime.hour.toString().padLeft(2, '0');
  final mm = dateTime.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDurationHHmm(Duration duration) {
  final totalMinutes = duration.inMinutes;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '${hours}:${minutes.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

String _formatAbsenceDateRange(Map<String, dynamic> logData) {
  final from = (logData['absence_from'] as Timestamp?)?.toDate();
  final to = (logData['absence_to'] as Timestamp?)?.toDate();
  if (from == null || to == null) {
    final timestamp = (logData['timestamp'] as Timestamp?)?.toDate();
    return timestamp == null ? '' : _formatDate(timestamp);
  }

  final fromLabel = _formatDate(from);
  final toLabel = _formatDate(to);
  return fromLabel == toLabel ? fromLabel : '$fromLabel - $toLabel';
}

String _formatLogDetails(AppLocalizations l10n, Map<String, dynamic> logData) {
  final type = logData['type'];
  if (type == 'Nap') {
    final napStart = logData['nap_start'];
    final napEnd = logData['nap_end'];
    final napDurationMinutes = logData['nap_duration_minutes'];

    if (napStart is Timestamp &&
        napEnd is Timestamp &&
        napDurationMinutes is int) {
      final startDt = napStart.toDate();
      final endDt = napEnd.toDate();
      final duration = Duration(minutes: napDurationMinutes);

      return l10n.tr('napDetails', {
        'start': _formatTimeHHmm(startDt),
        'end': _formatTimeHHmm(endDt),
        'duration': _formatDurationHHmm(duration),
      });
    }
  }

  if (type == 'Absence') {
    final absenceKind = logData['absence_kind']?.toString();
    final absenceNote = logData['absence_note']?.toString().trim() ?? '';
    final recordedByRole = logData['recorded_by_role']?.toString();
    final baseLabel = absenceKind == 'planned'
        ? l10n.tr('plannedAbsence')
        : l10n.tr('absent');
    final dateLabel = _formatAbsenceDateRange(logData);
    final lines = [
      baseLabel,
      if (dateLabel.isNotEmpty) dateLabel,
      if (recordedByRole == 'teacher') l10n.tr('reportedByTeacher'),
      if (recordedByRole == 'parent') l10n.tr('reportedByParent'),
      if (absenceNote.isNotEmpty) absenceNote,
    ];
    return lines.join('\n');
  }

  final details = logData['details']?.toString() ?? '';
  return l10n.activityDetails(details);
}

Future<void> _showAbsenceDialog(
  BuildContext context, {
  required String childId,
  String? recordedByRole,
  QueryDocumentSnapshot? existing,
}) async {
  final l10n = AppLocalizations.of(context);
  final data = existing?.data() as Map<String, dynamic>?;
  final details = data?['details']?.toString() ?? '';
  final existingRecordedByRole = data?['recorded_by_role']?.toString();
  String absenceKind =
      data?['absence_kind']?.toString() ??
      (details.toLowerCase().contains('planned') ? 'planned' : 'unplanned');
  final noteController = TextEditingController(
    text: data?['absence_note']?.toString() ?? '',
  );
  final existingFrom =
      (data?['absence_from'] as Timestamp?)?.toDate() ??
      (data?['timestamp'] as Timestamp?)?.toDate();
  final existingTo =
      (data?['absence_to'] as Timestamp?)?.toDate() ?? existingFrom;
  DateTime fromDate = existingFrom == null
      ? DateTime.now()
      : DateTime(existingFrom.year, existingFrom.month, existingFrom.day);
  DateTime toDate = existingTo == null
      ? fromDate
      : DateTime(existingTo.year, existingTo.month, existingTo.day);

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(
          existing == null ? l10n.tr('reportAbsence') : l10n.tr('editAbsence'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: absenceKind,
                decoration: InputDecoration(
                  labelText: l10n.tr('absenceType'),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'unplanned',
                    child: Text(l10n.tr('absence')),
                  ),
                  DropdownMenuItem(
                    value: 'planned',
                    child: Text(l10n.tr('plannedAbsence')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => absenceKind = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tr('absenceFrom')),
                trailing: Text(
                  _formatDate(fromDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: fromDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      fromDate = picked;
                      if (toDate.isBefore(fromDate)) {
                        toDate = fromDate;
                      }
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tr('absenceTo')),
                trailing: Text(
                  _formatDate(toDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: toDate.isBefore(fromDate) ? fromDate : toDate,
                    firstDate: fromDate,
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => toDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.tr('absenceNote'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final normalizedFrom = DateTime(
                fromDate.year,
                fromDate.month,
                fromDate.day,
                12,
              );
              final finalTo = toDate.isBefore(fromDate) ? fromDate : toDate;
              final normalizedTo = DateTime(
                finalTo.year,
                finalTo.month,
                finalTo.day,
                12,
              );
              final payload = <String, dynamic>{
                'child_id': childId,
                'type': 'Absence',
                'details': absenceKind == 'planned'
                    ? 'Planned absence'
                    : 'Absent',
                'timestamp': Timestamp.fromDate(normalizedFrom),
                'absence_from': Timestamp.fromDate(normalizedFrom),
                'absence_to': Timestamp.fromDate(normalizedTo),
                'absence_kind': absenceKind,
                'absence_note': noteController.text.trim(),
                'recorded_by_role':
                    existingRecordedByRole ?? recordedByRole ?? 'parent',
              };

              if (existing == null) {
                await FirebaseFirestore.instance
                    .collection('activity_logs')
                    .add(payload);
              } else {
                await existing.reference.update(payload);
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(
              l10n.tr(existing == null ? 'saveAbsence' : 'saveUpdate'),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _markTeacherAbsenceForToday(
  BuildContext context, {
  required String childId,
}) async {
  final l10n = AppLocalizations.of(context);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 12);
  final todayOnly = DateTime(now.year, now.month, now.day);

  final existingLogs = await FirebaseFirestore.instance
      .collection('activity_logs')
      .where('child_id', isEqualTo: childId)
      .where('type', isEqualTo: 'Absence')
      .get();

  final alreadyMarked = existingLogs.docs.any((doc) {
    final data = doc.data();
    if (data['recorded_by_role']?.toString() != 'teacher') {
      return false;
    }
    final from = (data['absence_from'] as Timestamp?)?.toDate();
    final to = (data['absence_to'] as Timestamp?)?.toDate();
    if (from == null || to == null) {
      return false;
    }
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return !todayOnly.isBefore(fromDate) && !todayOnly.isAfter(toDate);
  });

  if (alreadyMarked) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('absenceAlreadyMarkedToday'))),
      );
    }
    return;
  }

  await FirebaseFirestore.instance.collection('activity_logs').add({
    'child_id': childId,
    'type': 'Absence',
    'details': 'Absent',
    'timestamp': Timestamp.fromDate(today),
    'absence_from': Timestamp.fromDate(today),
    'absence_to': Timestamp.fromDate(today),
    'absence_kind': 'unplanned',
    'absence_note': '',
    'recorded_by_role': 'teacher',
  });

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('absenceMarkedToday'))));
  }
}

Future<void> _deleteAbsenceReport(
  BuildContext context, {
  required QueryDocumentSnapshot absenceDoc,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.tr('deleteActivity')),
      content: Text(l10n.tr('deleteActivityConfirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(l10n.tr('delete')),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await absenceDoc.reference.delete();
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('activityDeleted'))));
  }
}

String _buildDailyReportText(
  AppLocalizations l10n,
  String reportText, {
  DateTime? whatsAppSentAt,
}) {
  final trimmedReport = reportText.trimRight();
  if (whatsAppSentAt == null) {
    return trimmedReport;
  }

  final sentLine = l10n.tr('whatsAppSentAt', {
    'time': _formatTimeHHmm(whatsAppSentAt),
  });
  return '$trimmedReport\n$sentLine';
}

String _sanitizeDailySummaryText(String details) {
  return details
      .split('\n')
      .where((line) {
        final trimmedStart = line.trimLeft();
        return !trimmedStart.startsWith('• WhatsApp message sent at') &&
            !trimmedStart.startsWith('WhatsApp message sent at') &&
            !trimmedStart.startsWith('• הודעת וואטסאפ נשלחה ב־') &&
            !trimmedStart.startsWith('הודעת וואטסאפ נשלחה ב־');
      })
      .join('\n');
}

String? _extractWhatsAppSentLabel(
  AppLocalizations l10n,
  Map<String, dynamic> logData,
) {
  final whatsAppSentAt = logData['whatsapp_sent_at'];
  if (whatsAppSentAt is Timestamp) {
    return l10n.tr('whatsAppSentAt', {
      'time': _formatTimeHHmm(whatsAppSentAt.toDate()),
    });
  }

  final details = logData['details']?.toString() ?? '';
  for (final line in details.split('\n').reversed) {
    final trimmed = line.trim();
    if (trimmed.contains('WhatsApp message sent at') ||
        trimmed.contains('הודעת וואטסאפ נשלחה ב־')) {
      return trimmed.startsWith('• ') ? trimmed.substring(2) : trimmed;
    }
  }

  return null;
}

IconData _activityIconForType(String type) {
  switch (type.trim().toLowerCase()) {
    case 'meal':
      return Icons.restaurant;
    case 'nap':
      return Icons.bedtime;
    case 'absence':
      return Icons.event_busy;
    case 'incident':
    case 'daily note':
      return Icons.sticky_note_2;
    case 'daily summary':
      return Icons.summarize;
    default:
      return Icons.check_circle;
  }
}

Color _activityIconColorForType(String type) {
  switch (type.trim().toLowerCase()) {
    case 'meal':
      return Colors.orange;
    case 'nap':
      return Colors.indigo;
    case 'absence':
      return Colors.redAccent;
    case 'incident':
    case 'daily note':
      return Colors.teal;
    case 'daily summary':
      return Colors.indigo;
    default:
      return Colors.indigo;
  }
}

Widget languageToggleAction(BuildContext context, {Color? color}) {
  final appState = DaycareApp.of(context);
  final l10n = AppLocalizations.of(context);
  return TextButton(
    onPressed: appState.toggleLanguage,
    style: TextButton.styleFrom(
      foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
    child: Text(l10n.tr('languageToggle')),
  );
}

// --- THE ROUTER ---
class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (!authSnapshot.hasData || authSnapshot.data == null)
          return const AuthScreen();

        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: Text(l10n.tr('checkingPermissions'))),
              );
            }
            if (userSnapshot.hasError ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text(l10n.tr('signOut')),
                  ),
                ),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'] ?? 'parent';

            if (role == 'admin') return AdminDashboard();
            if (role == 'teacher') return TeacherDashboard();
            return ParentDashboard();
          },
        );
      },
    );
  }
}

// --- AUTH SCREEN ---
// --- AUTH SCREEN ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _upsertUserProfile(User user, {String? phone}) async {
    final email = (user.email ?? '').trim().toLowerCase();
    if (email.isEmpty) {
      throw FirebaseAuthException(code: 'missing-email');
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final updates = <String, dynamic>{'email': email};
      if (phone != null && phone.isNotEmpty) {
        updates['phone'] = phone;
      }
      await userRef.set(updates, SetOptions(merge: true));
      return;
    }

    final inviteDoc = await FirebaseFirestore.instance
        .collection('teacher_invites')
        .doc(email)
        .get();
    String assignedRole = 'parent';
    String? assignedDaycareId;

    if (inviteDoc.exists) {
      assignedRole = 'teacher';
      assignedDaycareId = inviteDoc.data()?['daycare_id'];
      await inviteDoc.reference.delete();
    }

    await userRef.set({
      'email': email,
      'phone': phone,
      'role': assignedRole,
      'daycare_id': assignedDaycareId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      final user = userCredential.user;
      if (user != null) {
        await _upsertUserProfile(user);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _authErrorMessage(e, l10n, fallbackKey: 'googleSignInFailed'),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('googleSignInUnavailable'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAuth() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isLogin && (email.isEmpty || password.isEmpty || phone.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('allFieldsMandatory'))));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await _upsertUserProfile(userCredential.user!, phone: phone);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _authErrorMessage(e, l10n, fallbackKey: 'genericError'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authErrorMessage(
    FirebaseAuthException error,
    AppLocalizations l10n, {
    required String fallbackKey,
  }) {
    switch (error.code) {
      case 'missing-email':
        return l10n.tr('missingEmail');
      default:
        return error.message ?? l10n.tr(fallbackKey);
    }
  }

  // Helper widget for playful text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade300),
        filled: true,
        fillColor: Colors.teal.shade50.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.teal.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // We remove the AppBar entirely for a cleaner, full-screen look
      body: Container(
        // Soft, playful gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade100,
              Colors.blue.shade50,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Language toggle positioned playfully at the top corner
              Positioned(
                top: 8,
                right: l10n.isHebrew ? null : 16,
                left: l10n.isHebrew ? 16 : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: languageToggleAction(
                    context,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Playful Header Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          size: 70,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // App Title
                      Text(
                        l10n.tr('daycareApp'),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // The White "Card" holding the form
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.shade900.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isLogin ? l10n.tr('login') : l10n.tr('signUp'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildTextField(
                              controller: _emailController,
                              label: l10n.tr('email'),
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),

                            if (!_isLogin) ...[
                              _buildTextField(
                                controller: _phoneController,
                                label: l10n.tr('phoneNumber'),
                                icon: Icons.phone_android_rounded,
                              ),
                              const SizedBox(height: 16),
                            ],

                            _buildTextField(
                              controller: _passwordController,
                              label: l10n.tr('password'),
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              onSubmitted: _submitAuth,
                            ),
                            const SizedBox(height: 32),

                            _isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    height: 56, // Chunky, tappable button
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade500,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: _submitAuth,
                                      child: Text(
                                        _isLogin
                                            ? l10n.tr('login')
                                            : l10n.tr('signUp'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 16),

                            _isLoading
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: _signInWithGoogle,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Image(
                                              image: AssetImage(
                                                'assets/logos/google_light.png',
                                                package: 'sign_in_button',
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _isLogin
                                                ? l10n.tr('loginWithGoogle')
                                                : l10n.tr('signUpWithGoogle'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 16),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.teal.shade700,
                              ),
                              onPressed: () =>
                                  setState(() => _isLogin = !_isLogin),
                              child: Text(
                                _isLogin
                                    ? l10n.tr('createAccount')
                                    : l10n.tr('alreadyHaveAccount'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ADMIN DASHBOARD (Consolidated & Fixed) ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _daycareNameController = TextEditingController();

  Future<void> _addDaycare() async {
    final user = FirebaseAuth.instance.currentUser!;
    if (_daycareNameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('daycares').add({
        'name': _daycareNameController.text.trim(),
        'admin_uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });
      _daycareNameController.clear();
      if (mounted) Navigator.pop(context);
    }
  }

  void _showInviteTeacherDialog(String daycareId, String daycareName) {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('inviteTeacherTo', {'daycareName': daycareName})),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: l10n.tr('teacherEmail'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim().toLowerCase();
              if (email.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('teacher_invites')
                    .doc(email)
                    .set({
                      'daycare_id': daycareId,
                      'daycare_name': daycareName,
                      'invited_at': FieldValue.serverTimestamp(),
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('sendInvite')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('adminDashboard')),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        actions: [
          languageToggleAction(context, color: Colors.white),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.tr('newDaycare')),
            content: TextField(
              controller: _daycareNameController,
              decoration: InputDecoration(labelText: l10n.tr('daycareName')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: _addDaycare,
                child: Text(l10n.tr('create')),
              ),
            ],
          ),
        ),
        label: Text(
          l10n.tr('addDaycare'),
          style: const TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add_business, color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('daycares')
            .where('admin_uid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final daycares = snapshot.data!.docs;
          return ListView.builder(
            itemCount: daycares.length,
            itemBuilder: (context, index) {
              final daycare = daycares[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  leading: const Icon(Icons.business, color: Colors.purple),
                  title: Text(
                    daycare['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.tr('teachers'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 18,
                                ),
                                label: Text(l10n.tr('invite')),
                                onPressed: () => _showInviteTeacherDialog(
                                  daycare.id,
                                  daycare['name'],
                                ),
                              ),
                            ],
                          ),
                          // Logic to show active and pending teachers
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('daycare_id', isEqualTo: daycare.id)
                                .where('role', isEqualTo: 'teacher')
                                .snapshots(),
                            builder: (context, teacherSnap) {
                              final teachers = teacherSnap.data?.docs ?? [];
                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('teacher_invites')
                                    .where('daycare_id', isEqualTo: daycare.id)
                                    .snapshots(),
                                builder: (context, inviteSnap) {
                                  final invites = inviteSnap.data?.docs ?? [];
                                  return Column(
                                    children: [
                                      ...teachers.map(
                                        (t) => ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                          ),
                                          title: Text(t['email']),
                                        ),
                                      ),
                                      ...invites.map(
                                        (i) => ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.mail_outline,
                                            color: Colors.orange,
                                          ),
                                          title: Text(i.id),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ----- TEACHER DASHBOARD
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  // --- 1. WHATSAPP LOGIC ---
  Future<bool> _launchWhatsApp(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return false;
    final url =
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  // --- 2. EDIT CHILD DIALOG (New Feature) ---
  void _showEditChildDialog(
    BuildContext context,
    String childId,
    String currentName,
    List<dynamic>? currentPhones,
    List<dynamic>? currentEmails,
  ) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: currentName);
    // Grab the first phone if it exists
    final initialPhone = (currentPhones != null && currentPhones.isNotEmpty)
        ? currentPhones.first.toString()
        : "";
    final phoneController = TextEditingController(text: initialPhone);
    final initialEmail = (currentEmails != null && currentEmails.isNotEmpty)
        ? currentEmails.first.toString()
        : "";
    final emailController = TextEditingController(text: initialEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('editChild', {'name': currentName})),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.tr('childName')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.tr('parentPhoneExample'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: l10n.tr('parentEmailExample'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('children')
                    .doc(childId)
                    .update({
                      'name': nameController.text.trim(),
                      'parent_phones': phoneController.text.isEmpty
                          ? []
                          : [phoneController.text.trim()],
                      'parent_emails': emailController.text.isEmpty
                          ? []
                          : [emailController.text.trim()],
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('saveChanges')),
          ),
        ],
      ),
    );
  }

  // --- 3. LOGGING HELPERS ---
  Future<void> _saveLogToDatabase(
    String childId,
    String type,
    String details, {
    DateTime? timestamp,
    Map<String, dynamic>? extra,
  }) async {
    final data = <String, dynamic>{
      'child_id': childId,
      'type': type,
      'details': details,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp)
          : FieldValue.serverTimestamp(),
    };

    if (extra != null && extra.isNotEmpty) {
      data.addAll(extra);
    }

    await FirebaseFirestore.instance.collection('activity_logs').add(data);
  }

  Future<void> _showUpdateNapDialog(
    BuildContext parentContext,
    String childId,
    String childName,
  ) async {
    final l10n = AppLocalizations.of(parentContext);

    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(hours: 1)),
    );

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          String timeStr(TimeOfDay t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

          return AlertDialog(
            title: Text('${l10n.tr('updateNap')} - $childName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('napStartTime')),
                  trailing: Text(timeStr(startTime)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: dialogContext,
                      initialTime: startTime,
                    );
                    if (picked != null) setState(() => startTime = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('napEndTime')),
                  trailing: Text(timeStr(endTime)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: dialogContext,
                      initialTime: endTime,
                    );
                    if (picked != null) setState(() => endTime = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final startDt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    startTime.hour,
                    startTime.minute,
                  );
                  final endDt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    endTime.hour,
                    endTime.minute,
                  );

                  if (!endDt.isAfter(startDt)) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(content: Text(l10n.tr('invalidNapTimes'))),
                    );
                    return;
                  }

                  final duration = endDt.difference(startDt);

                  await _saveLogToDatabase(
                    childId,
                    'Nap',
                    'Nap',
                    timestamp: startDt,
                    extra: {
                      'nap_start': Timestamp.fromDate(startDt),
                      'nap_end': Timestamp.fromDate(endDt),
                      'nap_duration_minutes': duration.inMinutes,
                    },
                  );

                  if (parentContext.mounted) Navigator.pop(dialogContext);
                },
                child: Text(l10n.tr('saveNap')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showIncidentDialog(
    BuildContext context,
    String childId,
    String childName,
  ) {
    final l10n = AppLocalizations.of(context);
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('incidentTitle', {'childName': childName})),
        content: TextField(
          controller: descController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.tr('whatHappened'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descController.text.isNotEmpty) {
                await _saveLogToDatabase(
                  childId,
                  'Daily Note',
                  descController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('save')),
          ),
        ],
      ),
    );
  }

  // --- 4. REPORT GENERATOR ---
  void _generateEndDayReport(
    BuildContext context,
    String childId,
    String childName,
    List<dynamic>? parentPhones,
  ) async {
    final l10n = AppLocalizations.of(context);
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final end = start.add(const Duration(days: 1));
    final logsQuery = await FirebaseFirestore.instance
        .collection('activity_logs')
        .where('child_id', isEqualTo: childId)
        .get();
    final todayLogs = logsQuery.docs.where((doc) {
      final logData = doc.data() as Map<String, dynamic>;
      final ts = (logData['timestamp'] as Timestamp?)?.toDate();
      final type = (logData['type']?.toString() ?? '').trim().toLowerCase();
      return ts != null &&
          !ts.isBefore(start) &&
          ts.isBefore(end) &&
          type != 'daily summary';
    }).toList();

    todayLogs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTs = (aData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bTs = (bData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      return aTs.compareTo(bTs);
    });

    String summary = l10n.tr('summaryForDay', {'childName': childName});
    for (var log in todayLogs) {
      final logData = log.data() as Map<String, dynamic>;
      final time = (logData['timestamp'] as Timestamp).toDate();
      final type = logData['type']?.toString() ?? 'Update';
      summary +=
          "• ${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${l10n.activityType(type)}: ${_formatLogDetails(l10n, logData)}\n";
    }

    final reportController = TextEditingController(text: summary);
    DateTime? whatsAppSentAt;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l10n.tr('dailyReportTitle', {'childName': childName})),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reportController,
                maxLines: 8,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              if (whatsAppSentAt != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.tr('whatsAppSentAt', {
                      'time': _formatTimeHHmm(whatsAppSentAt!),
                    }),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.tr('cancel')),
            ),
            if (parentPhones != null &&
                parentPhones.isNotEmpty &&
                parentPhones.first.toString().trim().isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.message, size: 18),
                label: Text(l10n.tr('whatsApp')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final sent = await _launchWhatsApp(
                    parentPhones.first.toString(),
                    reportController.text,
                  );
                  if (!sent) return;
                  setState(() => whatsAppSentAt = DateTime.now());
                },
              ),
            ElevatedButton(
              onPressed: () async {
                final reportToSave = _buildDailyReportText(
                  l10n,
                  reportController.text,
                  whatsAppSentAt: whatsAppSentAt,
                );
                await _saveLogToDatabase(
                  childId,
                  'Daily Summary',
                  reportToSave,
                  extra: whatsAppSentAt == null
                      ? null
                      : {
                          'whatsapp_sent_at': Timestamp.fromDate(
                            whatsAppSentAt!,
                          ),
                        },
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(l10n.tr('saveToApp')),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. BOTTOM SHEET MENU ---
  void _showLoggingModal(
    BuildContext parentContext,
    String childId,
    String childName,
    bool isNapping,
    List<dynamic>? parentPhones,
  ) {
    final l10n = AppLocalizations.of(parentContext);
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tr('logForChild', {'childName': childName}),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.summarize, color: Colors.teal),
                title: Text(l10n.tr('generateDailyReport')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _generateEndDayReport(
                    parentContext,
                    childId,
                    childName,
                    parentPhones,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime, color: Colors.indigo),
                title: Text(l10n.tr('updateNap')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showUpdateNapDialog(parentContext, childId, childName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: Text(l10n.tr('logMeal')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _saveLogToDatabase(childId, 'Meal', 'Ate meal');
                },
              ),
              ListTile(
                leading: const Icon(Icons.sticky_note_2, color: Colors.teal),
                title: Text(l10n.tr('incidentReport')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showIncidentDialog(parentContext, childId, childName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context, String daycareId) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final pEmail = TextEditingController();
    final pPhone = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('addChild')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.tr('nameRequired')),
            ),
            TextField(
              controller: pEmail,
              decoration: InputDecoration(
                labelText: l10n.tr('parentEmailRequired'),
              ),
            ),
            TextField(
              controller: pPhone,
              decoration: InputDecoration(labelText: l10n.tr('parentPhone')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && pEmail.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('children').add({
                  'name': nameController.text.trim(),
                  'daycare_id': daycareId,
                  'parent_emails': [pEmail.text.toLowerCase().trim()],
                  'parent_phones': pPhone.text.isEmpty
                      ? []
                      : [pPhone.text.trim()],
                  'is_napping': false,
                  'allergies': 'None',
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('save')),
          ),
        ],
      ),
    );
  }

  // --- 6. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final daycareId = userSnap.data!['daycare_id'];
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tr('teacherDashboard')),
            backgroundColor: Colors.teal.shade400,
            foregroundColor: Colors.white,
            actions: [
              languageToggleAction(context, color: Colors.white),
              IconButton(
                icon: const Icon(Icons.event_note),
                tooltip: l10n.tr('noticesBoard'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NoticesBoardScreen(daycareId: daycareId, canEdit: true),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restaurant_menu),
                tooltip: l10n.tr('weeklyMealPlan'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyMealPlanScreen(
                      daycareId: daycareId,
                      canEdit: true,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.description),
                tooltip: l10n.tr('importantDocuments'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DocumentsScreen(daycareId: daycareId, canEdit: true),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddChildDialog(context, daycareId),
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.teal,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('children')
                .where('daycare_id', isEqualTo: daycareId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final children = snapshot.data!.docs;
              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  final childData = child.data() as Map<String, dynamic>;
                  final parentPhones = childData.containsKey('parent_phones')
                      ? List<dynamic>.from(childData['parent_phones'])
                      : null;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activity_logs')
                        .where('child_id', isEqualTo: child.id)
                        .snapshots(),
                    builder: (context, absenceSnapshot) {
                      final absences =
                          absenceSnapshot.data?.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return (data['type']?.toString() ?? '')
                                    .trim()
                                    .toLowerCase() ==
                                'absence';
                          }).toList() ??
                          <QueryDocumentSnapshot>[];

                      absences.sort((a, b) {
                        final aFrom =
                            ((a.data() as Map<String, dynamic>)['absence_from']
                                    as Timestamp?)
                                ?.toDate() ??
                            DateTime(0);
                        final bFrom =
                            ((b.data() as Map<String, dynamic>)['absence_from']
                                    as Timestamp?)
                                ?.toDate() ??
                            DateTime(0);
                        return bFrom.compareTo(aFrom);
                      });

                      final today = DateTime.now();
                      final todayDate = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      );
                      final hasActiveParentReportedAbsence = absences.any((
                        doc,
                      ) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (data['recorded_by_role']?.toString() != 'parent') {
                          return false;
                        }
                        final from = (data['absence_from'] as Timestamp?)
                            ?.toDate();
                        final to = (data['absence_to'] as Timestamp?)?.toDate();
                        if (from == null || to == null) {
                          return false;
                        }
                        final fromDate = DateTime(
                          from.year,
                          from.month,
                          from.day,
                        );
                        final toDate = DateTime(to.year, to.month, to.day);
                        return !todayDate.isBefore(fromDate) &&
                            !todayDate.isAfter(toDate);
                      });
                      final openEditChildDialog = () => _showEditChildDialog(
                        context,
                        child.id,
                        childData['name'],
                        parentPhones,
                        childData['parent_emails'],
                      );

                      return Card(
                        color: hasActiveParentReportedAbsence
                            ? const Color(0xFFFFF7E6)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: hasActiveParentReportedAbsence
                                ? const Color(0xFFF59E0B)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: hasActiveParentReportedAbsence
                                      ? const Color(0xFFF59E0B)
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    hasActiveParentReportedAbsence
                                        ? Icons.assignment_late
                                        : Icons.edit,
                                    size: 20,
                                    color: hasActiveParentReportedAbsence
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                  tooltip: hasActiveParentReportedAbsence
                                      ? l10n.tr('editChild', {
                                          'name':
                                              childData['name']?.toString() ??
                                              l10n.tr('unknown'),
                                        })
                                      : l10n.tr('editChild', {
                                          'name':
                                              childData['name']?.toString() ??
                                              l10n.tr('unknown'),
                                        }),
                                  onPressed: openEditChildDialog,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildTimelineScreen(
                                      childId: child.id,
                                      childName:
                                          childData['name'] ??
                                          l10n.tr('unknown'),
                                    ),
                                  ),
                                );
                              },
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      childData['name'] ?? l10n.tr('unknown'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: hasActiveParentReportedAbsence
                                            ? const Color(0xFF9A6700)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.tr('parents', {
                                      'parents':
                                          (childData['parent_emails']
                                                  as List<dynamic>?)
                                              ?.join(', ') ??
                                          l10n.tr('none'),
                                    }),
                                  ),
                                  if (hasActiveParentReportedAbsence)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDE7C3),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.event_busy,
                                                size: 14,
                                                color: Color(0xFF9A6700),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.tr(
                                                  'parentReportedAbsence',
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF9A6700),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      hasActiveParentReportedAbsence
                                          ? Icons.event_available
                                          : Icons.event_busy,
                                      color: hasActiveParentReportedAbsence
                                          ? const Color(0xFF9A6700)
                                          : Colors.redAccent,
                                    ),
                                    tooltip: l10n.tr('reportAbsence'),
                                    onPressed: () =>
                                        _markTeacherAbsenceForToday(
                                          context,
                                          childId: child.id,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      hasActiveParentReportedAbsence
                                          ? Icons.playlist_add_circle
                                          : Icons.add_circle_outline,
                                      color: hasActiveParentReportedAbsence
                                          ? const Color(0xFF9A6700)
                                          : Colors.teal,
                                    ),
                                    tooltip: l10n.tr('update'),
                                    onPressed: () => _showLoggingModal(
                                      context,
                                      child.id,
                                      childData['name'],
                                      childData['is_napping'] ?? false,
                                      parentPhones,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (absences.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  children: [
                                    Divider(
                                      height: 1,
                                      color: hasActiveParentReportedAbsence
                                          ? const Color(0xFFF2C57C)
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    ...absences.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final canManageAbsence =
                                          data['recorded_by_role']
                                              ?.toString() !=
                                          'parent';
                                      final isParentManaged =
                                          data['recorded_by_role']
                                              ?.toString() ==
                                          'parent';
                                      final detailsText = _formatLogDetails(
                                        l10n,
                                        data,
                                      );
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isParentManaged
                                              ? const Color(0xFFFFF7ED)
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: isParentManaged
                                              ? Border.all(
                                                  color: const Color(
                                                    0xFFF2C57C,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                          leading: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: isParentManaged
                                                ? const Color(0xFFFDE7C3)
                                                : Colors.red.withOpacity(0.12),
                                            child: Icon(
                                              isParentManaged
                                                  ? Icons.lock_person_outlined
                                                  : _activityIconForType(
                                                      'absence',
                                                    ),
                                              color: isParentManaged
                                                  ? const Color(0xFF9A6700)
                                                  : _activityIconColorForType(
                                                      'absence',
                                                    ),
                                              size: 16,
                                            ),
                                          ),
                                          title: Text(
                                            detailsText,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isParentManaged
                                                  ? const Color(0xFF7C5A10)
                                                  : null,
                                            ),
                                          ),
                                          trailing: canManageAbsence
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.indigo,
                                                      ),
                                                      tooltip: l10n.tr(
                                                        'editAbsence',
                                                      ),
                                                      onPressed: () =>
                                                          _showAbsenceDialog(
                                                            context,
                                                            childId: child.id,
                                                            existing: doc,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      tooltip: l10n.tr(
                                                        'deleteActivity',
                                                      ),
                                                      onPressed: () =>
                                                          _deleteAbsenceReport(
                                                            context,
                                                            absenceDoc: doc,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.lock_outline,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      l10n.tr('parentManaged'),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF7C5A10,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('myChildren')),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        actions: [
          languageToggleAction(context, color: Colors.white),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      // LOGIC: Find any child where the current user's email is in the parent_emails list
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('children')
            .where('parent_emails', arrayContains: user.email!.toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.tr('noChildrenLinked', {'email': user.email ?? ''}),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final children = snapshot.data!.docs;
          final firstDaycareId =
              (children.first.data() as Map<String, dynamic>)['daycare_id']
                  ?.toString() ??
              '';

          final listView = ListView.builder(
            itemCount: children.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (firstDaycareId.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      color: Colors.teal.withOpacity(0.08),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_note,
                          color: Colors.teal,
                        ),
                        title: Text(
                          l10n.tr('viewNoticesBoard'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoticesBoardScreen(
                              daycareId: firstDaycareId,
                              canEdit: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      color: Colors.orange.withOpacity(0.08),
                      child: ListTile(
                        leading: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.orange,
                        ),
                        title: Text(
                          l10n.tr('viewWeeklyMealPlan'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeeklyMealPlanScreen(
                              daycareId: firstDaycareId,
                              canEdit: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      color: Colors.purple.withOpacity(0.08),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.purple,
                        ),
                        title: Text(
                          l10n.tr('viewDocuments'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentsScreen(
                              daycareId: firstDaycareId,
                              canEdit: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              final childData =
                  children[index - 1].data() as Map<String, dynamic>;
              final childName = childData['name'];
              final childId = children[index - 1].id;
              final childDaycareId = childData['daycare_id']?.toString();

              return Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        childName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: childDaycareId == null || childDaycareId.isEmpty
                          ? Text(l10n.tr('tapToViewActivity'))
                          : StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('daycares')
                                  .doc(childDaycareId)
                                  .snapshots(),
                              builder: (context, daycareSnapshot) {
                                final daycareData =
                                    daycareSnapshot.data?.data()
                                        as Map<String, dynamic>?;
                                final daycareName = daycareData?['name']
                                    ?.toString();
                                if (daycareName == null ||
                                    daycareName.isEmpty) {
                                  return Text(l10n.tr('tapToViewActivity'));
                                }
                                return Text(
                                  l10n.tr('tapToViewActivityAtDaycare', {
                                    'daycareName': daycareName,
                                  }),
                                );
                              },
                            ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.event_busy,
                          color: Colors.redAccent,
                        ),
                        tooltip: l10n.tr('reportAbsence'),
                        onPressed: () => _showAbsenceDialog(
                          context,
                          childId: childId,
                          recordedByRole: 'parent',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 170,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 140,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ChildTimelineScreen(
                                      childId: childId,
                                      childName: childName,
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  final curved = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  );
                                  return FadeTransition(
                                    opacity: curved,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('activity_logs')
                          .where('child_id', isEqualTo: childId)
                          .snapshots(),
                      builder: (context, absenceSnapshot) {
                        if (!absenceSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final parentAbsences =
                            absenceSnapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return (data['type']?.toString() ?? '')
                                          .trim()
                                          .toLowerCase() ==
                                      'absence' &&
                                  data['recorded_by_role']?.toString() ==
                                      'parent';
                            }).toList()..sort((a, b) {
                              final aFrom =
                                  ((a.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['absence_from']
                                          as Timestamp?)
                                      ?.toDate() ??
                                  DateTime(0);
                              final bFrom =
                                  ((b.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['absence_from']
                                          as Timestamp?)
                                      ?.toDate() ??
                                  DateTime(0);
                              return bFrom.compareTo(aFrom);
                            });

                        if (parentAbsences.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              const Divider(height: 1),
                              Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  key: PageStorageKey(
                                    'parent_absences_$childId',
                                  ),
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  childrenPadding: const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  title: Text(
                                    '${l10n.tr('absenceReports')} (${parentAbsences.length})',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  children: parentAbsences.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final detailsText = _formatLogDetails(
                                      l10n,
                                      data,
                                    );
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                      leading: Icon(
                                        _activityIconForType('absence'),
                                        color: _activityIconColorForType(
                                          'absence',
                                        ),
                                        size: 20,
                                      ),
                                      title: Text(
                                        detailsText,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Colors.indigo,
                                            ),
                                            tooltip: l10n.tr('editAbsence'),
                                            onPressed: () => _showAbsenceDialog(
                                              context,
                                              childId: childId,
                                              existing: doc,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            tooltip: l10n.tr('deleteActivity'),
                                            onPressed: () =>
                                                _deleteAbsenceReport(
                                                  context,
                                                  absenceDoc: doc,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (firstDaycareId.isEmpty) return listView;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notices')
                .where('daycare_id', isEqualTo: firstDaycareId)
                .snapshots(),
            builder: (context, noticesSnapshot) {
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              final todayNotices = noticesSnapshot.hasData
                  ? noticesSnapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final from = (data['date_from'] as Timestamp?)?.toDate();
                      final to = (data['date_to'] as Timestamp?)?.toDate();
                      if (from == null || to == null) return false;
                      final fromDate = DateTime(
                        from.year,
                        from.month,
                        from.day,
                      );
                      final toDate = DateTime(to.year, to.month, to.day);
                      return !todayDate.isBefore(fromDate) &&
                          !todayDate.isAfter(toDate);
                    }).toList()
                  : <QueryDocumentSnapshot>[];

              if (todayNotices.isEmpty) return listView;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.event_available,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.tr('todayNoticeBanner'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ...todayNotices.map((doc) {
                                final title =
                                    (doc.data()
                                            as Map<String, dynamic>)['title']
                                        ?.toString() ??
                                    '';
                                return Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: listView),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// --- CHILD TIMELINE (WITH TIME TRAVEL) ---
class ChildTimelineScreen extends StatefulWidget {
  final String childId;
  final String childName;
  const ChildTimelineScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildTimelineScreen> createState() => _ChildTimelineScreenState();
}

class _ChildTimelineScreenState extends State<ChildTimelineScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _markLogAsSeen(
    BuildContext context,
    QueryDocumentSnapshot logDoc,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await logDoc.reference.update({
        'seen_by_parent_at': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('seenMarked'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('updateFailed'))));
      }
    }
  }

  Future<void> _deleteDailyReport(
    BuildContext context,
    QueryDocumentSnapshot logDoc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tr('deleteDailyReport')),
        content: Text(l10n.tr('deleteDailyReportConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.tr('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await logDoc.reference.delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('dailyReportDeleted'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('deleteFailed'))));
      }
    }
  }

  Future<void> _deleteActivityLog(
    BuildContext context,
    QueryDocumentSnapshot logDoc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tr('deleteActivity')),
        content: Text(l10n.tr('deleteActivityConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.tr('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await logDoc.reference.delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('activityDeleted'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('deleteFailed'))));
      }
    }
  }

  Future<void> _showEditActivityDialog(
    BuildContext context,
    QueryDocumentSnapshot logDoc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final data = logDoc.data() as Map<String, dynamic>;
    final type = data['type']?.toString() ?? '';
    final normalizedType = type.trim().toLowerCase();

    if (normalizedType == 'absence') {
      await _showAbsenceDialog(
        context,
        childId: widget.childId,
        existing: logDoc,
      );
      return;
    }

    if (normalizedType == 'nap') {
      final now = DateTime.now();
      final ts = (data['timestamp'] as Timestamp?)?.toDate();
      final fallbackStart = ts ?? now;
      final napStartTs = data['nap_start'];
      final napEndTs = data['nap_end'];

      DateTime startDt = napStartTs is Timestamp
          ? napStartTs.toDate()
          : fallbackStart;
      DateTime endDt = napEndTs is Timestamp
          ? napEndTs.toDate()
          : startDt.add(const Duration(hours: 1));

      TimeOfDay startTime = TimeOfDay.fromDateTime(startDt);
      TimeOfDay endTime = TimeOfDay.fromDateTime(endDt);

      await showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setState) {
            String timeStr(TimeOfDay t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

            return AlertDialog(
              title: Text('${l10n.tr('updateNap')} - ${widget.childName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tr('napStartTime')),
                    trailing: Text(timeStr(startTime)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: startTime,
                      );
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tr('napEndTime')),
                    trailing: Text(timeStr(endTime)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: endTime,
                      );
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.tr('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final base = startDt;
                    final updatedStart = DateTime(
                      base.year,
                      base.month,
                      base.day,
                      startTime.hour,
                      startTime.minute,
                    );
                    final updatedEnd = DateTime(
                      base.year,
                      base.month,
                      base.day,
                      endTime.hour,
                      endTime.minute,
                    );

                    if (!updatedEnd.isAfter(updatedStart)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.tr('invalidNapTimes'))),
                      );
                      return;
                    }

                    final duration = updatedEnd.difference(updatedStart);
                    try {
                      await logDoc.reference.update({
                        'type': 'Nap',
                        'details': 'Nap',
                        'timestamp': Timestamp.fromDate(updatedStart),
                        'nap_start': Timestamp.fromDate(updatedStart),
                        'nap_end': Timestamp.fromDate(updatedEnd),
                        'nap_duration_minutes': duration.inMinutes,
                      });
                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tr('activityUpdated'))),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tr('updateFailed'))),
                        );
                      }
                    }
                  },
                  child: Text(l10n.tr('saveUpdate')),
                ),
              ],
            );
          },
        ),
      );
      return;
    }

    if (normalizedType == 'meal' ||
        normalizedType == 'incident' ||
        normalizedType == 'daily note') {
      final controller = TextEditingController(
        text: data['details']?.toString() ?? '',
      );
      final isMeal = normalizedType == 'meal';
      final titleKey = isMeal ? 'updateMeal' : 'updateIncident';
      final hintKey = isMeal ? 'mealDetailsHint' : 'whatHappened';

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.tr(titleKey)),
          content: TextField(
            controller: controller,
            maxLines: isMeal ? 1 : 3,
            decoration: InputDecoration(
              hintText: l10n.tr(hintKey),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedDetails = controller.text.trim();
                if (updatedDetails.isEmpty) return;

                try {
                  await logDoc.reference.update({'details': updatedDetails});
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tr('activityUpdated'))),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tr('updateFailed'))),
                    );
                  }
                }
              },
              child: Text(l10n.tr('saveUpdate')),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;
    // These define the window for the calendar selection
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          languageToggleAction(context, color: Colors.white),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          final role = (userData?['role']?.toString() ?? 'parent')
              .trim()
              .toLowerCase();
          final isParent = role == 'parent';
          final isStaff = role == 'admin' || role == 'teacher';
          final canDeleteDailyReport = isStaff;
          final canEditActivities = isStaff;
          final canDeleteActivities = isStaff;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activity_logs')
                .where(
                  'child_id',
                  isEqualTo: widget.childId,
                ) // Fixed: Added widget.
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              // Local filtering for the selected calendar date
              final logs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final type = data['type']?.toString().trim().toLowerCase();
                if (type == 'absence') {
                  final absenceFrom = (data['absence_from'] as Timestamp?)
                      ?.toDate();
                  final absenceTo = (data['absence_to'] as Timestamp?)
                      ?.toDate();
                  if (absenceFrom != null && absenceTo != null) {
                    final fromDate = DateTime(
                      absenceFrom.year,
                      absenceFrom.month,
                      absenceFrom.day,
                    );
                    final toDate = DateTime(
                      absenceTo.year,
                      absenceTo.month,
                      absenceTo.day,
                    );
                    return !start.isBefore(fromDate) && !start.isAfter(toDate);
                  }
                }

                final ts = (data['timestamp'] as Timestamp?)?.toDate();
                return ts != null && ts.isAfter(start) && ts.isBefore(end);
              }).toList();

              // Sort logs so newest are at the top
              logs.sort((a, b) {
                final aTs =
                    (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                final bTs =
                    (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                return bTs.compareTo(aTs);
              });

              if (logs.isEmpty)
                return Center(child: Text(l10n.tr('noActivitiesForDay')));

              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final logDoc = logs[index];
                  final logData = logDoc.data() as Map<String, dynamic>;
                  final type = logData['type']?.toString() ?? 'Update';
                  final normalizedType = type.trim().toLowerCase();
                  final isDailySummary = normalizedType == 'daily summary';
                  final isAbsence = normalizedType == 'absence';
                  final absenceReportedByParent =
                      logData['recorded_by_role']?.toString() == 'parent';
                  final canEditThisLog =
                      (canEditActivities &&
                          (normalizedType == 'meal' ||
                              normalizedType == 'nap' ||
                              normalizedType == 'incident' ||
                              normalizedType == 'daily note' ||
                              (isAbsence && !absenceReportedByParent))) ||
                      (isParent && isAbsence);
                  final canDeleteThisLog =
                      (canDeleteActivities &&
                          (normalizedType == 'meal' ||
                              normalizedType == 'nap' ||
                              normalizedType == 'incident' ||
                              normalizedType == 'daily note' ||
                              (isAbsence && !absenceReportedByParent))) ||
                      (isParent && isAbsence);
                  final seenAt = (logData['seen_by_parent_at'] as Timestamp?)
                      ?.toDate();
                  final seenAtText = seenAt == null
                      ? l10n.tr('notSeenYet')
                      : l10n.tr('seenAt', {'time': _formatTimeHHmm(seenAt)});
                  final whatsAppSentLabel = _extractWhatsAppSentLabel(
                    l10n,
                    logData,
                  );
                  final details = logData['details']?.toString() ?? '';
                  final detailsText = _formatLogDetails(l10n, logData);

                  final timestamp = (logData['timestamp'] as Timestamp?)
                      ?.toDate();
                  final timeStr = isAbsence
                      ? ''
                      : timestamp != null
                      ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                      : "";

                  // --- UI LOGIC: Collapsible Summary ---
                  if (isDailySummary) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.indigo.withOpacity(0.05),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.summarize,
                          color: Colors.indigo,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.tr('dailySummary'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (canDeleteDailyReport)
                              IconButton(
                                onPressed: () =>
                                    _deleteDailyReport(context, logDoc),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: l10n.tr('deleteDailyReport'),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (isParent)
                              IconButton(
                                onPressed: seenAt == null
                                    ? () => _markLogAsSeen(context, logDoc)
                                    : null,
                                icon: Icon(
                                  seenAt == null
                                      ? Icons.visibility_outlined
                                      : Icons.visibility,
                                  color: seenAt == null
                                      ? Colors.indigo
                                      : Colors.green,
                                ),
                                tooltip: seenAt == null
                                    ? l10n.tr('markAsSeen')
                                    : l10n.tr('seen'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.tr('postedAt', {'time': timeStr})),
                            if (whatsAppSentLabel != null)
                              Text(
                                whatsAppSentLabel,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sanitizeDailySummaryText(details),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  seenAtText,
                                  style: TextStyle(
                                    color: seenAt == null
                                        ? Colors.grey[700]
                                        : Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // --- UI LOGIC: Standard Activity ---
                  return ListTile(
                    leading: Icon(
                      _activityIconForType(type),
                      color: _activityIconColorForType(type),
                    ),
                    title: Text(
                      l10n.activityType(type),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$detailsText\n$seenAtText'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (isParent)
                          IconButton(
                            icon: Icon(
                              seenAt == null
                                  ? Icons.visibility_outlined
                                  : Icons.visibility,
                              size: 20,
                              color: seenAt == null
                                  ? Colors.indigo
                                  : Colors.green,
                            ),
                            tooltip: seenAt == null
                                ? l10n.tr('markAsSeen')
                                : l10n.tr('seen'),
                            onPressed: seenAt == null
                                ? () => _markLogAsSeen(context, logDoc)
                                : null,
                          ),
                        if (isStaff)
                          Icon(
                            seenAt == null
                                ? Icons.visibility_off_outlined
                                : Icons.visibility,
                            size: 18,
                            color: seenAt == null
                                ? Colors.orange
                                : Colors.green,
                          ),
                        if (canEditThisLog)
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.indigo,
                            ),
                            tooltip: l10n.tr('editActivity'),
                            onPressed: () =>
                                _showEditActivityDialog(context, logDoc),
                          ),
                        if (canDeleteThisLog)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            tooltip: l10n.tr('deleteActivity'),
                            onPressed: () =>
                                _deleteActivityLog(context, logDoc),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- NOTICES BOARD ---
class NoticesBoardScreen extends StatelessWidget {
  final String daycareId;
  final bool canEdit;
  const NoticesBoardScreen({
    super.key,
    required this.daycareId,
    required this.canEdit,
  });

  void _showAddOrEditNoticeDialog(
    BuildContext context, {
    QueryDocumentSnapshot? existing,
  }) {
    final l10n = AppLocalizations.of(context);
    final data = existing?.data() as Map<String, dynamic>?;
    final titleController = TextEditingController(
      text: data?['title']?.toString() ?? '',
    );
    final noteController = TextEditingController(
      text: data?['note']?.toString() ?? '',
    );
    final now = DateTime.now();
    DateTime fromDate = data != null && data['date_from'] is Timestamp
        ? (data['date_from'] as Timestamp).toDate()
        : now;
    DateTime toDate = data != null && data['date_to'] is Timestamp
        ? (data['date_to'] as Timestamp).toDate()
        : now;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(
            existing == null ? l10n.tr('addNotice') : l10n.tr('editNotice'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.tr('noticeTitleHint'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('noticeFrom')),
                  trailing: Text(
                    _formatDate(fromDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: fromDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => fromDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('noticeTo')),
                  trailing: Text(
                    _formatDate(toDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: toDate.isBefore(fromDate)
                          ? fromDate
                          : toDate,
                      firstDate: fromDate,
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => toDate = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.tr('noticeNote'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.tr('noticeTitleRequired'))),
                  );
                  return;
                }
                final finalTo = toDate.isBefore(fromDate) ? fromDate : toDate;
                final payload = <String, dynamic>{
                  'daycare_id': daycareId,
                  'title': title,
                  'date_from': Timestamp.fromDate(
                    DateTime(fromDate.year, fromDate.month, fromDate.day),
                  ),
                  'date_to': Timestamp.fromDate(
                    DateTime(finalTo.year, finalTo.month, finalTo.day),
                  ),
                  'note': noteController.text.trim(),
                };
                if (existing == null) {
                  payload['created_at'] = FieldValue.serverTimestamp();
                  await FirebaseFirestore.instance
                      .collection('notices')
                      .add(payload);
                } else {
                  await existing.reference.update(payload);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(l10n.tr('saveNotice')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNotice(
    BuildContext context,
    QueryDocumentSnapshot doc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tr('deleteNotice')),
        content: Text(l10n.tr('deleteNoticeConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.tr('delete')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await doc.reference.delete();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('noticeDeleted'))));
    }
  }

  Widget _buildNoticeCard(
    BuildContext context,
    AppLocalizations l10n,
    QueryDocumentSnapshot doc,
    bool isUpcoming,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title']?.toString() ?? '';
    final note = data['note']?.toString() ?? '';
    final fromDt = (data['date_from'] as Timestamp).toDate();
    final toDt = (data['date_to'] as Timestamp).toDate();
    final isSingleDay =
        fromDt.year == toDt.year &&
        fromDt.month == toDt.month &&
        fromDt.day == toDt.day;
    final dateLabel = isSingleDay
        ? _formatDate(fromDt)
        : '${_formatDate(fromDt)} – ${_formatDate(toDt)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isUpcoming ? Colors.teal.withOpacity(0.05) : null,
      child: ListTile(
        leading: Icon(
          Icons.event,
          color: isUpcoming ? Colors.teal : Colors.grey,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel),
            if (note.isNotEmpty)
              Text(note, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
        isThreeLine: note.isNotEmpty,
        trailing: canEdit
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.indigo,
                    ),
                    onPressed: () =>
                        _showAddOrEditNoticeDialog(context, existing: doc),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _deleteNotice(context, doc),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('noticesBoard')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [languageToggleAction(context, color: Colors.white)],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showAddOrEditNoticeDialog(context),
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .where('daycare_id', isEqualTo: daycareId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aFrom = (a['date_from'] as Timestamp).toDate();
              final bFrom = (b['date_from'] as Timestamp).toDate();
              return aFrom.compareTo(bFrom);
            });

          if (docs.isEmpty) return Center(child: Text(l10n.tr('noNotices')));

          final upcoming = docs.where((d) {
            final to = (d['date_to'] as Timestamp).toDate();
            return !DateTime(to.year, to.month, to.day).isBefore(todayDate);
          }).toList();
          final past = docs.where((d) {
            final to = (d['date_to'] as Timestamp).toDate();
            return DateTime(to.year, to.month, to.day).isBefore(todayDate);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    l10n.tr('upcoming'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                ...upcoming.map(
                  (doc) => _buildNoticeCard(context, l10n, doc, true),
                ),
                const SizedBox(height: 12),
              ],
              if (past.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    l10n.tr('past'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ...past.map(
                  (doc) => _buildNoticeCard(context, l10n, doc, false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEEKLY MEAL PLAN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class WeeklyMealPlanScreen extends StatefulWidget {
  final String daycareId;
  final bool canEdit;

  const WeeklyMealPlanScreen({
    super.key,
    required this.daycareId,
    required this.canEdit,
  });

  @override
  State<WeeklyMealPlanScreen> createState() => _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends State<WeeklyMealPlanScreen> {
  static const _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  static const _mealTypes = ['breakfast', 'lunch', 'treat'];

  late DateTime _weekStart;
  final Map<String, TextEditingController> _controllers = {};
  String? _lastLoadedDocId;
  bool _isSaving = false;

  static DateTime _sundayOf(DateTime date) {
    final offset = date.weekday % 7; // Mon=1…Sun=0
    return DateTime(date.year, date.month, date.day - offset);
  }

  String get _docId =>
      '${widget.daycareId}_${_weekStart.toIso8601String().substring(0, 10)}';

  @override
  void initState() {
    super.initState();
    _weekStart = _sundayOf(DateTime.now());
    for (final day in _days) {
      for (final meal in _mealTypes) {
        _controllers['${day}_$meal'] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic>? data) {
    final days = data?['days'] as Map<String, dynamic>? ?? {};
    for (final day in _days) {
      final dayData = days[day] as Map<String, dynamic>? ?? {};
      for (final meal in _mealTypes) {
        _controllers['${day}_$meal']?.text = dayData[meal]?.toString() ?? '';
      }
    }
    _lastLoadedDocId = _docId;
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      final days = <String, dynamic>{
        for (final day in _days)
          day: {
            for (final meal in _mealTypes)
              meal: _controllers['${day}_$meal']?.text.trim() ?? '',
          },
      };
      await FirebaseFirestore.instance
          .collection('meal_plans')
          .doc(_docId)
          .set({
            'daycare_id': widget.daycareId,
            'week_start': Timestamp.fromDate(_weekStart),
            'days': days,
          });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('mealPlanSaved'))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('weeklyMealPlan')),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        actions: [
          languageToggleAction(context, color: Colors.white),
          if (widget.canEdit)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: l10n.tr('saveMealPlan'),
                    onPressed: () => _save(context),
                  ),
        ],
      ),
      body: Column(
        children: [
          // ── Week navigation ──────────────────────────────────────────
          Container(
            color: Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _weekStart = _weekStart.subtract(const Duration(days: 7));
                    _lastLoadedDocId = null;
                  }),
                ),
                Text(
                  l10n.tr('weekOf', {'date': _formatDate(_weekStart)}),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _weekStart = _weekStart.add(const Duration(days: 7));
                    _lastLoadedDocId = null;
                  }),
                ),
              ],
            ),
          ),
          // ── Day cards ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('meal_plans')
                  .doc(_docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data =
                    snapshot.hasData && (snapshot.data?.exists ?? false)
                    ? snapshot.data!.data() as Map<String, dynamic>?
                    : null;

                if (widget.canEdit && _lastLoadedDocId != _docId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _populateControllers(data);
                  });
                }

                if (!widget.canEdit && data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.tr('noMealPlanYet'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                final savedDays = data?['days'] as Map<String, dynamic>? ?? {};
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _days.length,
                  itemBuilder: (context, i) {
                    final day = _days[i];
                    final dayDate = _weekStart.add(Duration(days: i));
                    final savedDay =
                        savedDays[day] as Map<String, dynamic>? ?? {};
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.tr(day.toLowerCase())}  •  ${_formatDate(dayDate)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Divider(height: 18),
                            _mealRow(
                              l10n,
                              day,
                              'breakfast',
                              savedDay,
                              Icons.free_breakfast_outlined,
                              Colors.orange.shade600,
                            ),
                            const SizedBox(height: 10),
                            _mealRow(
                              l10n,
                              day,
                              'lunch',
                              savedDay,
                              Icons.lunch_dining,
                              Colors.teal.shade600,
                            ),
                            const SizedBox(height: 10),
                            _mealRow(
                              l10n,
                              day,
                              'treat',
                              savedDay,
                              Icons.cake_outlined,
                              Colors.pink.shade400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealRow(
    AppLocalizations l10n,
    String day,
    String meal,
    Map<String, dynamic> savedDay,
    IconData icon,
    Color color,
  ) {
    final labelKey = meal == 'treat' ? 'afterLunchTreat' : meal;
    if (widget.canEdit) {
      return Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controllers['${day}_$meal'],
              decoration: InputDecoration(
                labelText: l10n.tr(labelKey),
                isDense: true,
              ),
            ),
          ),
        ],
      );
    }
    // Read-only view
    final value = savedDay[meal]?.toString() ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr(labelKey),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value.isEmpty ? '–' : value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// DocumentsScreen: Teacher uploads & manages documents; Parents view & download
class DocumentsScreen extends StatefulWidget {
  final String daycareId;
  final bool canEdit;

  const DocumentsScreen({
    required this.daycareId,
    required this.canEdit,
    super.key,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String? _selectedFileName;
  bool _uploading = false;

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final fileName = result.files.single.name;
        setState(() => _selectedFileName = fileName);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.tr('uploadFailed')}: $e')),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedFileName == null || _selectedFileName!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('selectFile'))));
      return;
    }

    setState(() => _uploading = true);

    try {
      await FirebaseFirestore.instance.collection('documents').add({
        'daycare_id': widget.daycareId,
        'file_name': _selectedFileName,
        'uploaded_by': FirebaseAuth.instance.currentUser!.email,
        'uploaded_at': Timestamp.now(),
        'file_url': 'https://example.com/document.pdf', // Mock URL
      });

      setState(() => _selectedFileName = null);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('documentUploaded'))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('uploadFailed'))));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteDocument(String docId) async {
    final l10n = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('deleteDocument')),
        content: Text(l10n.tr('deleteDocumentConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.tr('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tr('documentDeleted'))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting document')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('importantDocuments')),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.canEdit)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Colors.purple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.tr('selectFile'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _selectedFileName ?? 'No file selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _selectedFileName == null
                              ? null
                              : () => setState(() => _selectedFileName = null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectFile,
                      icon: const Icon(Icons.browse_gallery),
                      label: Text(l10n.tr('selectFile')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploading || _selectedFileName == null
                          ? null
                          : _uploadDocument,
                      icon: _uploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(l10n.tr('uploadDocument')),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('daycare_id', isEqualTo: widget.daycareId)
                  .orderBy('uploaded_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(l10n.tr('noDocumentsAvailable')),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final fileName = data['file_name'] ?? 'Unknown';
                    final uploadedAt = data['uploaded_at'] as Timestamp?;
                    final uploadedBy = data['uploaded_by'] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.purple,
                        ),
                        title: Text(fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploaded by: $uploadedBy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (uploadedAt != null)
                              Text(
                                'Date: ${_formatDate(uploadedAt.toDate())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!widget.canEdit)
                              IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.blue,
                                ),
                                tooltip: l10n.tr('downloadDocument'),
                                onPressed: () {
                                  // In a real app, this would download the file
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Download: $fileName'),
                                    ),
                                  );
                                },
                              ),
                            if (widget.canEdit)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: l10n.tr('deleteDocument'),
                                onPressed: () => _deleteDocument(doc.id),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
