import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      _locale = _locale.languageCode == 'en' ? const Locale('he') : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(_locale);
    return MaterialApp(
      title: l10n.tr('daycareApp'),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
    var value = (_values[locale.languageCode] ?? _values['en']!) [key] ?? _values['en']![key] ?? key;
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
      'googleSignInUnavailable': 'Google sign-in is not available on this device.',
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
      'noChildrenLinked': 'No children linked to {email}. Please ask the teacher to add your email to your child\'s profile.',
      'tapToViewActivity': 'Tap to view today\'s activity',
      'tapToViewActivityAtDaycare': 'Tap to view today\'s activity at {daycareName}',
      'noActivitiesForDay': 'No activities for this day.',
      'dailySummary': 'Daily Summary',
      'postedAt': 'Posted at {time}',
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
      'update': 'Update',
      'wokeUp': 'Woke up',
      'sleeping': 'Sleeping',
      'ateMeal': 'Ate meal',
      'languageToggle': 'עב',
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
      'noChildrenLinked': 'אין ילדים שמקושרים ל־{email}. בקש מהמורה להוסיף את האימייל שלך לפרופיל הילד.',
      'tapToViewActivity': 'הקש לצפייה בפעילות של היום',
      'tapToViewActivityAtDaycare': 'הקש לצפייה בפעילות של היום ב־{daycareName}',
      'noActivitiesForDay': 'אין פעילויות ליום זה.',
      'dailySummary': 'סיכום יומי',
      'postedAt': 'פורסם ב־{time}',
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
      'update': 'עדכון',
      'wokeUp': 'התעורר',
      'sleeping': 'ישן',
      'ateMeal': 'אכל ארוחה',
      'languageToggle': 'EN',
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

String _formatLogDetails(AppLocalizations l10n, Map<String, dynamic> logData) {
  final type = logData['type'];
  if (type == 'Nap') {
    final napStart = logData['nap_start'];
    final napEnd = logData['nap_end'];
    final napDurationMinutes = logData['nap_duration_minutes'];

    if (napStart is Timestamp && napEnd is Timestamp && napDurationMinutes is int) {
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

  final details = logData['details']?.toString() ?? '';
  return l10n.activityDetails(details);
}

IconData _activityIconForType(String type) {
  switch (type.trim().toLowerCase()) {
    case 'meal':
      return Icons.restaurant;
    case 'nap':
      return Icons.bedtime;
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
        if (authSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!authSnapshot.hasData || authSnapshot.data == null) return const AuthScreen();

        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: Text(l10n.tr('checkingPermissions'))));
            }
            if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
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
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // NEW
  bool _isLogin = true; 
  bool _isLoading = false;

  Future<void> _upsertUserProfile(User user, {String? phone}) async {
    final email = (user.email ?? '').trim().toLowerCase();
    if (email.isEmpty) {
      throw FirebaseAuthException(code: 'missing-email');
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final updates = <String, dynamic>{'email': email};
      if (phone != null && phone.isNotEmpty) {
        updates['phone'] = phone;
      }
      await userRef.set(updates, SetOptions(merge: true));
      return;
    }

    final inviteDoc = await FirebaseFirestore.instance.collection('teacher_invites').doc(email).get();
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
        userCredential = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          return;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        await _upsertUserProfile(user);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authErrorMessage(e, l10n, fallbackKey: 'googleSignInFailed'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('googleSignInUnavailable'))));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('allFieldsMandatory'))));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await _upsertUserProfile(userCredential.user!, phone: phone);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authErrorMessage(e, l10n, fallbackKey: 'genericError'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authErrorMessage(FirebaseAuthException error, AppLocalizations l10n, {required String fallbackKey}) {
    switch (error.code) {
      case 'missing-email':
        return l10n.tr('missingEmail');
      default:
        return error.message ?? l10n.tr(fallbackKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isLogin ? l10n.tr('login') : l10n.tr('signUp')),
        actions: [languageToggleAction(context)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 80, color: Colors.teal),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: l10n.tr('email'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            if (!_isLogin) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: l10n.tr('phoneNumber'), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _passwordController, 
              decoration: InputDecoration(labelText: l10n.tr('password'), border: const OutlineInputBorder()), 
              obscureText: true,
              onSubmitted: (_) => _submitAuth(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitAuth,
                      child: Text(_isLogin ? l10n.tr('login') : l10n.tr('signUp')),
                    ),
                  ),
            const SizedBox(height: 12),
            _isLoading
                ? const SizedBox.shrink()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromRGBO(0, 0, 0, 0.9),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: _signInWithGoogle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
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
                            _isLogin ? l10n.tr('loginWithGoogle') : l10n.tr('signUpWithGoogle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin), 
              child: Text(_isLogin ? l10n.tr('createAccount') : l10n.tr('alreadyHaveAccount'))
            )
          ],
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
          decoration: InputDecoration(labelText: l10n.tr('teacherEmail'), border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim().toLowerCase();
              if (email.isNotEmpty) {
                await FirebaseFirestore.instance.collection('teacher_invites').doc(email).set({
                  'daycare_id': daycareId,
                  'daycare_name': daycareName,
                  'invited_at': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('sendInvite')),
          )
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
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [languageToggleAction(context, color: Colors.white), IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.tr('newDaycare')),
            content: TextField(controller: _daycareNameController, decoration: InputDecoration(labelText: l10n.tr('daycareName'))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
              ElevatedButton(onPressed: _addDaycare, child: Text(l10n.tr('create'))),
            ],
          ),
        ),
        label: Text(l10n.tr('addDaycare'), style: const TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_business, color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('daycares').where('admin_uid', isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final daycares = snapshot.data!.docs;
          return ListView.builder(
            itemCount: daycares.length,
            itemBuilder: (context, index) {
              final daycare = daycares[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  leading: const Icon(Icons.business, color: Colors.purple),
                  title: Text(daycare['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.tr('teachers'), style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextButton.icon(icon: const Icon(Icons.person_add_alt_1, size: 18), label: Text(l10n.tr('invite')), onPressed: () => _showInviteTeacherDialog(daycare.id, daycare['name'])),
                            ],
                          ),
                          // Logic to show active and pending teachers
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').where('daycare_id', isEqualTo: daycare.id).where('role', isEqualTo: 'teacher').snapshots(),
                            builder: (context, teacherSnap) {
                              final teachers = teacherSnap.data?.docs ?? [];
                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('teacher_invites').where('daycare_id', isEqualTo: daycare.id).snapshots(),
                                builder: (context, inviteSnap) {
                                  final invites = inviteSnap.data?.docs ?? [];
                                  return Column(
                                    children: [
                                      ...teachers.map((t) => ListTile(dense: true, leading: const Icon(Icons.verified, color: Colors.green), title: Text(t['email']))),
                                      ...invites.map((i) => ListTile(dense: true, leading: const Icon(Icons.mail_outline, color: Colors.orange), title: Text(i.id))),
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
  Future<void> _launchWhatsApp(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return;
    final url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // --- 2. EDIT CHILD DIALOG (New Feature) ---
  void _showEditChildDialog(BuildContext context, String childId, String currentName, List<dynamic>? currentPhones, List<dynamic>? currentEmails) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: currentName);
    // Grab the first phone if it exists
    final initialPhone = (currentPhones != null && currentPhones.isNotEmpty) ? currentPhones.first.toString() : "";
    final phoneController = TextEditingController(text: initialPhone);
    final initialEmail = (currentEmails != null && currentEmails.isNotEmpty) ? currentEmails.first.toString() : "";
    final emailController = TextEditingController(text: initialEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('editChild', {'name': currentName})),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.tr('childName'))),
            const SizedBox(height: 16),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: l10n.tr('parentPhoneExample'))),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: InputDecoration(labelText: l10n.tr('parentEmailExample'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('children').doc(childId).update({
                  'name': nameController.text.trim(),
                  'parent_phones': phoneController.text.isEmpty ? [] : [phoneController.text.trim()],
                  'parent_emails': emailController.text.isEmpty ? [] : [emailController.text.trim()],
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.tr('saveChanges')),
          )
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
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp) : FieldValue.serverTimestamp(),
    };

    if (extra != null && extra.isNotEmpty) {
      data.addAll(extra);
    }

    await FirebaseFirestore.instance.collection('activity_logs').add(data);
  }

  Future<void> _showUpdateNapDialog(BuildContext parentContext, String childId, String childName) async {
    final l10n = AppLocalizations.of(parentContext);

    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          String timeStr(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
                    final picked = await showTimePicker(context: dialogContext, initialTime: startTime);
                    if (picked != null) setState(() => startTime = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('napEndTime')),
                  trailing: Text(timeStr(endTime)),
                  onTap: () async {
                    final picked = await showTimePicker(context: dialogContext, initialTime: endTime);
                    if (picked != null) setState(() => endTime = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.tr('cancel'))),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final startDt = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                  final endDt = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

                  if (!endDt.isAfter(startDt)) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text(l10n.tr('invalidNapTimes'))));
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

  void _showIncidentDialog(BuildContext context, String childId, String childName) {
    final l10n = AppLocalizations.of(context);
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('incidentTitle', {'childName': childName})),
        content: TextField(controller: descController, maxLines: 3, decoration: InputDecoration(hintText: l10n.tr('whatHappened'), border: const OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          ElevatedButton(onPressed: () async {
            if (descController.text.isNotEmpty) {
              await _saveLogToDatabase(childId, 'Daily Note', descController.text.trim());
              if (context.mounted) Navigator.pop(context);
            }
          }, child: Text(l10n.tr('save'))),
        ],
      ),
    );
  }

  // --- 4. REPORT GENERATOR ---
  void _generateEndDayReport(BuildContext context, String childId, String childName, List<dynamic>? parentPhones) async {
    final l10n = AppLocalizations.of(context);
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final end = start.add(const Duration(days: 1));
    final logsQuery = await FirebaseFirestore.instance.collection('activity_logs').where('child_id', isEqualTo: childId).get();
    final todayLogs = logsQuery.docs.where((doc) {
      final logData = doc.data() as Map<String, dynamic>;
      final ts = (logData['timestamp'] as Timestamp?)?.toDate();
      final type = (logData['type']?.toString() ?? '').trim().toLowerCase();
      return ts != null && !ts.isBefore(start) && ts.isBefore(end) && type != 'daily summary';
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
      summary += "• ${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${l10n.activityType(type)}: ${_formatLogDetails(l10n, logData)}\n";
    }

    final reportController = TextEditingController(text: summary);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('dailyReportTitle', {'childName': childName})),
        content: TextField(controller: reportController, maxLines: 8, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          if (parentPhones != null && parentPhones.isNotEmpty && parentPhones.first.toString().trim().isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.message, size: 18),
              label: Text(l10n.tr('whatsApp')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _launchWhatsApp(parentPhones.first.toString(), reportController.text),
            ),
          ElevatedButton(
            onPressed: () async {
              await _saveLogToDatabase(childId, 'Daily Summary', reportController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.tr('saveToApp')),
          ),
        ],
      ),
    );
  }

  // --- 5. BOTTOM SHEET MENU ---
  void _showLoggingModal(BuildContext parentContext, String childId, String childName, bool isNapping, List<dynamic>? parentPhones) {
    final l10n = AppLocalizations.of(parentContext);
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20, top: 20, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(l10n.tr('logForChild', {'childName': childName}), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.summarize, color: Colors.teal),
                title: Text(l10n.tr('generateDailyReport')),
                onTap: () { Navigator.pop(sheetContext); _generateEndDayReport(parentContext, childId, childName, parentPhones); },
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
                onTap: () async { Navigator.pop(sheetContext); await _saveLogToDatabase(childId, 'Meal', 'Ate meal'); },
              ),
              ListTile(
                leading: const Icon(Icons.sticky_note_2, color: Colors.teal),
                title: Text(l10n.tr('incidentReport')),
                onTap: () { Navigator.pop(sheetContext); _showIncidentDialog(parentContext, childId, childName); },
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.tr('nameRequired'))),
          TextField(controller: pEmail, decoration: InputDecoration(labelText: l10n.tr('parentEmailRequired'))),
          TextField(controller: pPhone, decoration: InputDecoration(labelText: l10n.tr('parentPhone'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          ElevatedButton(onPressed: () async {
            if (nameController.text.isNotEmpty && pEmail.text.isNotEmpty) {
              await FirebaseFirestore.instance.collection('children').add({
                'name': nameController.text.trim(),
                'daycare_id': daycareId,
                'parent_emails': [pEmail.text.toLowerCase().trim()],
                'parent_phones': pPhone.text.isEmpty ? [] : [pPhone.text.trim()],
                'is_napping': false,
                'allergies': 'None'
              });
              if (context.mounted) Navigator.pop(context);
            }
          }, child: Text(l10n.tr('save')))
        ],
      )
    );
  }

  // --- 6. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final daycareId = userSnap.data!['daycare_id'];
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tr('teacherDashboard')),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [languageToggleAction(context, color: Colors.white), IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
          ),
          floatingActionButton: FloatingActionButton(onPressed: () => _showAddChildDialog(context, daycareId), child: const Icon(Icons.add, color: Colors.white), backgroundColor: Colors.teal),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('children').where('daycare_id', isEqualTo: daycareId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final children = snapshot.data!.docs;
              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  final childData = child.data() as Map<String, dynamic>;
                  final parentPhones = childData.containsKey('parent_phones') ? List<dynamic>.from(childData['parent_phones']) : null;

                  return Card(
                    child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                        onPressed: () => _showEditChildDialog(context, child.id, childData['name'], parentPhones, childData['parent_emails']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildTimelineScreen(
                              childId: child.id,
                              childName: childData['name'] ?? l10n.tr('unknown'),
                            ),
                          ),
                        );
                      },
                      title: Text(childData['name'] ?? l10n.tr('unknown'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        l10n.tr('parents', {'parents': (childData['parent_emails'] as List<dynamic>?)?.join(', ') ?? l10n.tr('none')}),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.teal), 
                        onPressed: () => _showLoggingModal(context, child.id, childData['name'], childData['is_napping'] ?? false, parentPhones)
                      ),
                    ),
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [languageToggleAction(context, color: Colors.white), IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
      ),
      // LOGIC: Find any child where the current user's email is in the parent_emails list
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('children')
            .where('parent_emails', arrayContains: user.email!.toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(l10n.tr('noChildrenLinked', {'email': user.email ?? ''}), textAlign: TextAlign.center),
              ),
            );
          }

          final children = snapshot.data!.docs;

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final childData = children[index].data() as Map<String, dynamic>;
              final childName = childData['name'];
              final childId = children[index].id;
              final childDaycareId = childData['daycare_id']?.toString();

              return Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.child_care, color: Colors.white)),
                  title: Text(childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: childDaycareId == null || childDaycareId.isEmpty
                      ? Text(l10n.tr('tapToViewActivity'))
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('daycares').doc(childDaycareId).snapshots(),
                          builder: (context, daycareSnapshot) {
                            final daycareData = daycareSnapshot.data?.data() as Map<String, dynamic>?;
                            final daycareName = daycareData?['name']?.toString();
                            if (daycareName == null || daycareName.isEmpty) {
                              return Text(l10n.tr('tapToViewActivity'));
                            }
                            return Text(l10n.tr('tapToViewActivityAtDaycare', {'daycareName': daycareName}));
                          },
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChildTimelineScreen(childId: childId, childName: childName)),
                    );
                  },
                ),
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
  const ChildTimelineScreen({super.key, required this.childId, required this.childName});

  @override
  State<ChildTimelineScreen> createState() => _ChildTimelineScreenState();
}

class _ChildTimelineScreenState extends State<ChildTimelineScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _deleteDailyReport(BuildContext context, QueryDocumentSnapshot logDoc) async {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('dailyReportDeleted'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('deleteFailed'))));
      }
    }
  }

  Future<void> _deleteActivityLog(BuildContext context, QueryDocumentSnapshot logDoc) async {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('activityDeleted'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('deleteFailed'))));
      }
    }
  }

  Future<void> _showEditActivityDialog(BuildContext context, QueryDocumentSnapshot logDoc) async {
    final l10n = AppLocalizations.of(context);
    final data = logDoc.data() as Map<String, dynamic>;
    final type = data['type']?.toString() ?? '';
    final normalizedType = type.trim().toLowerCase();

    if (normalizedType == 'nap') {
      final now = DateTime.now();
      final ts = (data['timestamp'] as Timestamp?)?.toDate();
      final fallbackStart = ts ?? now;
      final napStartTs = data['nap_start'];
      final napEndTs = data['nap_end'];

      DateTime startDt = napStartTs is Timestamp ? napStartTs.toDate() : fallbackStart;
      DateTime endDt = napEndTs is Timestamp ? napEndTs.toDate() : startDt.add(const Duration(hours: 1));

      TimeOfDay startTime = TimeOfDay.fromDateTime(startDt);
      TimeOfDay endTime = TimeOfDay.fromDateTime(endDt);

      await showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setState) {
            String timeStr(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
                      final picked = await showTimePicker(context: dialogContext, initialTime: startTime);
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tr('napEndTime')),
                    trailing: Text(timeStr(endTime)),
                    onTap: () async {
                      final picked = await showTimePicker(context: dialogContext, initialTime: endTime);
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.tr('cancel'))),
                ElevatedButton(
                  onPressed: () async {
                    final base = startDt;
                    final updatedStart = DateTime(base.year, base.month, base.day, startTime.hour, startTime.minute);
                    final updatedEnd = DateTime(base.year, base.month, base.day, endTime.hour, endTime.minute);

                    if (!updatedEnd.isAfter(updatedStart)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('invalidNapTimes'))));
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('activityUpdated'))));
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('updateFailed'))));
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

    if (normalizedType == 'meal' || normalizedType == 'incident' || normalizedType == 'daily note') {
      final controller = TextEditingController(text: data['details']?.toString() ?? '');
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
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.tr('cancel'))),
            ElevatedButton(
              onPressed: () async {
                final updatedDetails = controller.text.trim();
                if (updatedDetails.isEmpty) return;

                try {
                  await logDoc.reference.update({'details': updatedDetails});
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('activityUpdated'))));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('updateFailed'))));
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
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
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
                lastDate: DateTime.now()
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          final role = (userData?['role']?.toString() ?? 'parent').trim().toLowerCase();
          final canDeleteDailyReport = role == 'admin' || role == 'teacher';
          final canEditActivities = role == 'admin' || role == 'teacher';
          final canDeleteActivities = role == 'admin' || role == 'teacher';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activity_logs')
                .where('child_id', isEqualTo: widget.childId) // Fixed: Added widget.
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              // Local filtering for the selected calendar date
              final logs = snapshot.data!.docs.where((doc) {
                final ts = (doc['timestamp'] as Timestamp?)?.toDate();
                return ts != null && ts.isAfter(start) && ts.isBefore(end);
              }).toList();

              // Sort logs so newest are at the top
              logs.sort((a, b) {
                final aTs = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                final bTs = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                return bTs.compareTo(aTs);
              });

              if (logs.isEmpty) return Center(child: Text(l10n.tr('noActivitiesForDay')));

              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final logDoc = logs[index];
                  final logData = logDoc.data() as Map<String, dynamic>;
                  final type = logData['type']?.toString() ?? 'Update';
                  final normalizedType = type.trim().toLowerCase();
                  final isDailySummary = normalizedType == 'daily summary';
                    final canEditThisLog = canEditActivities &&
                        (normalizedType == 'meal' || normalizedType == 'nap' || normalizedType == 'incident' || normalizedType == 'daily note');
                    final canDeleteThisLog = canDeleteActivities &&
                        (normalizedType == 'meal' || normalizedType == 'nap' || normalizedType == 'incident' || normalizedType == 'daily note');
                  final details = logData['details']?.toString() ?? '';
                  final detailsText = _formatLogDetails(l10n, logData);

                  final timestamp = (logData['timestamp'] as Timestamp?)?.toDate();
                  final timeStr = timestamp != null
                      ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                      : "";

                  // --- UI LOGIC: Collapsible Summary ---
                  if (isDailySummary) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.indigo.withOpacity(0.05),
                      child: ExpansionTile(
                        leading: const Icon(Icons.summarize, color: Colors.indigo),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.tr('dailySummary'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (canDeleteDailyReport)
                              IconButton(
                                onPressed: () => _deleteDailyReport(context, logDoc),
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: l10n.tr('deleteDailyReport'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        subtitle: Text(l10n.tr('postedAt', {'time': timeStr})),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(details, style: const TextStyle(fontSize: 16, height: 1.5)),
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
                    title: Text(l10n.activityType(type), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(detailsText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        if (canEditThisLog)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                            tooltip: l10n.tr('editActivity'),
                            onPressed: () => _showEditActivityDialog(context, logDoc),
                          ),
                        if (canDeleteThisLog)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            tooltip: l10n.tr('deleteActivity'),
                            onPressed: () => _deleteActivityLog(context, logDoc),
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
