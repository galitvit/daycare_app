import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

class DaycareApp extends StatelessWidget {
  const DaycareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daycare App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const AuthRouter(),
    );
  }
}

// --- THE ROUTER ---
class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!authSnapshot.hasData || authSnapshot.data == null) return const AuthScreen();

        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: Text('Checking permissions...')));
            if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Scaffold(body: Center(child: ElevatedButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Sign Out'))));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'] ?? 'parent';

            if (role == 'admin') return const AdminDashboard();
            if (role == 'teacher') return const TeacherDashboard();
            return const ParentDashboard();
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
      throw FirebaseAuthException(code: 'missing-email', message: 'This account does not have a valid email address.');
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Google sign-in failed')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in is not available on this device.')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isLogin && (email.isEmpty || password.isEmpty || phone.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are mandatory!')));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 80, color: Colors.teal),
            const SizedBox(height: 32),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            if (!_isLogin) ...[ // Only show phone field on Sign Up
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number (with country code, e.g. 15551234567)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), 
              obscureText: true,
              onSubmitted: (_) => _submitAuth(),
            ),
            const SizedBox(height: 24),
            _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submitAuth, child: Text(_isLogin ? 'Login' : 'Sign Up'))),
            const SizedBox(height: 12),
            _isLoading
                ? const SizedBox.shrink()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                    ),
                  ),
            TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? 'Create an account' : 'I already have an account'))
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
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite Teacher to $daycareName'),
        content: TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Teacher Email', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
            child: const Text('Send Invite'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.purple, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('New Daycare'),
            content: TextField(controller: _daycareNameController, decoration: const InputDecoration(labelText: 'Daycare Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: _addDaycare, child: const Text('Create')),
            ],
          ),
        ),
        label: const Text('Add Daycare', style: TextStyle(color: Colors.white)),
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
                              const Text('Teachers', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextButton.icon(icon: const Icon(Icons.person_add_alt_1, size: 18), label: const Text('Invite'), onPressed: () => _showInviteTeacherDialog(daycare.id, daycare['name'])),
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
    final nameController = TextEditingController(text: currentName);
    // Grab the first phone if it exists
    final initialPhone = (currentPhones != null && currentPhones.isNotEmpty) ? currentPhones.first.toString() : "";
    final phoneController = TextEditingController(text: initialPhone);
    final initialEmail = (currentEmails != null && currentEmails.isNotEmpty) ? currentEmails.first.toString() : "";
    final emailController = TextEditingController(text: initialEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${currentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Child Name')),
            const SizedBox(height: 16),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Parent Phone (e.g. 15551234567)')),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Parent Email (e.g. parent@example.com)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
            child: const Text('Save Changes'),
          )
        ],
      ),
    );
  }

  // --- 3. LOGGING HELPERS ---
  Future<void> _saveLogToDatabase(String childId, String type, String details) async {
    await FirebaseFirestore.instance.collection('activity_logs').add({
      'child_id': childId,
      'type': type,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showIncidentDialog(BuildContext context, String childId, String childName) {
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incident: $childName'),
        content: TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(hintText: 'What happened?', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (descController.text.isNotEmpty) {
              await _saveLogToDatabase(childId, 'Incident', descController.text.trim());
              if (context.mounted) Navigator.pop(context);
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  // --- 4. REPORT GENERATOR ---
  void _generateEndDayReport(BuildContext context, String childId, String childName, List<dynamic>? parentPhones) async {
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final end = start.add(const Duration(days: 1));
    final logsQuery = await FirebaseFirestore.instance.collection('activity_logs').where('child_id', isEqualTo: childId).get();
    final todayLogs = logsQuery.docs.where((doc) {
      final ts = (doc['timestamp'] as Timestamp?)?.toDate();
      return ts != null && ts.isAfter(start) && ts.isBefore(end);
    }).toList();

    String summary = "Summary for $childName's day:\n\n";
    for (var log in todayLogs) {
      final time = (log['timestamp'] as Timestamp).toDate();
      summary += "• ${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${log['type']}: ${log['details']}\n";
    }

    final reportController = TextEditingController(text: summary);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daily Report: $childName'),
        content: TextField(controller: reportController, maxLines: 8, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          if (parentPhones != null && parentPhones.isNotEmpty && parentPhones.first.toString().trim().isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.message, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _launchWhatsApp(parentPhones.first.toString(), reportController.text),
            ),
          ElevatedButton(
            onPressed: () async {
              await _saveLogToDatabase(childId, 'Daily Summary', reportController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save to App'),
          ),
        ],
      ),
    );
  }

  // --- 5. BOTTOM SHEET MENU ---
  void _showLoggingModal(BuildContext context, String childId, String childName, bool isNapping, List<dynamic>? parentPhones) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Log for $childName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.summarize, color: Colors.teal),
                title: const Text('Generate Daily Report'),
                onTap: () { Navigator.pop(context); _generateEndDayReport(context, childId, childName, parentPhones); },
              ),
              ListTile(
                leading: Icon(isNapping ? Icons.wb_sunny : Icons.bedtime, color: isNapping ? Colors.amber : Colors.indigo),
                title: Text(isNapping ? 'End Nap' : 'Start Nap'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance.collection('children').doc(childId).update({'is_napping': !isNapping});
                  await _saveLogToDatabase(childId, 'Nap', isNapping ? 'Woke up' : 'Sleeping');
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: const Text('Log Meal'),
                onTap: () async { Navigator.pop(context); await _saveLogToDatabase(childId, 'Meal', 'Ate meal'); },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Incident Report'),
                onTap: () { Navigator.pop(context); _showIncidentDialog(context, childId, childName); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context, String daycareId) {
    final nameController = TextEditingController();
    final pEmail = TextEditingController();
    final pPhone = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Child'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *')),
          TextField(controller: pEmail, decoration: const InputDecoration(labelText: 'Parent Email *')),
          TextField(controller: pPhone, decoration: const InputDecoration(labelText: 'Parent Phone')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          }, child: const Text('Save'))
        ],
      )
    );
  }

  // --- 6. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final daycareId = userSnap.data!['daycare_id'];
        return Scaffold(
          appBar: AppBar(title: const Text('Teacher Dashboard'), backgroundColor: Colors.teal, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())]),
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
                      title: Text(childData['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Parents: ${(childData['parent_emails'] as List<dynamic>?)?.join(', ') ?? 'None'}'),
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
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
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
                child: Text('No children linked to ${user.email}. Please ask the teacher to add your email to your child\'s profile.', textAlign: TextAlign.center),
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

              return Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.child_care, color: Colors.white)),
                  title: Text(childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text('Tap to view today\'s activity'),
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

  @override
  Widget build(BuildContext context) {
    // These define the window for the calendar selection
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
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
      body: StreamBuilder<QuerySnapshot>(
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

          if (logs.isEmpty) return const Center(child: Text('No activities for this day.'));

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final logData = logs[index].data() as Map<String, dynamic>;
              final type = logData['type'] ?? 'Update';
              final details = logData['details'] ?? '';
              
              final timestamp = (logData['timestamp'] as Timestamp?)?.toDate();
              final timeStr = timestamp != null 
                  ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}" 
                  : "";

              // --- UI LOGIC: Collapsible Summary ---
              if (type == 'Daily Summary') {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.indigo.withOpacity(0.05),
                  child: ExpansionTile(
                    leading: const Icon(Icons.summarize, color: Colors.indigo),
                    title: const Text('Daily Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Posted at $timeStr'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(details, style: const TextStyle(fontSize: 16, height: 1.5)),
                      ),
                    ],
                  ),
                );
              }

              // --- UI LOGIC: Standard Activity ---
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.indigo),
                title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(details),
                trailing: Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              );
            },
          );
        },
      ),
    );
  }
}