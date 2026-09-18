import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const teal = Color(0xFF0FA3B1);
const darkTeal = Color(0xFF087F8C);
const navy = Color(0xFF14213D);
const canvas = Color(0xFFF6FAFC);
const border = Color(0xFFDDE8EF);
const muted = Color(0xFF64748B);
const success = Color(0xFF22B573);
const warning = Color(0xFFF4B942);

enum UserRole { receptionist, doctor, patient, admin, waiting }
enum QueueStatus { consulting, next, waiting, completed, called }

class Patient {
  Patient({required this.id, required this.name, this.phone = '', this.age = 0, this.gender = 'Not set'});
  final String id;
  String name;
  String phone;
  int age;
  String gender;
}

class Doctor {
  Doctor({required this.id, required this.name, required this.specialization, required this.room, this.averageMinutes = 15});
  final String id;
  String name;
  String specialization;
  String room;
  int averageMinutes;
}

class QueueEntry {
  QueueEntry({required this.token, required this.patientId, required this.doctorId, required this.problem, required this.time, required this.status});
  final String token;
  final String patientId;
  final String doctorId;
  final String problem;
  final String time;
  QueueStatus status;
}

class ClinicState extends ChangeNotifier {
  bool tamil = false;
  final clinicName = 'Sri Devi Clinic';
  int _nextToken = 29;
  final patients = <Patient>[
    Patient(id: 'p1', name: 'Ravi Kumar', age: 42, gender: 'Male'),
    Patient(id: 'p2', name: 'Priya Nair', age: 31, gender: 'Female'),
    Patient(id: 'p3', name: 'Suresh Babu', age: 56, gender: 'Male'),
    Patient(id: 'p4', name: 'Meena Krishnan', age: 28, gender: 'Female'),
    Patient(id: 'p5', name: 'Anitha Raj', age: 38, gender: 'Female'),
  ];
  final doctors = <Doctor>[
    Doctor(id: 'd1', name: 'Dr. Arun Kumar', specialization: 'General Medicine', room: 'Room 1'),
    Doctor(id: 'd2', name: 'Dr. Priya', specialization: 'Dental', room: 'Room 2', averageMinutes: 20),
    Doctor(id: 'd3', name: 'Dr. Meena', specialization: 'General Medicine', room: 'Room 3'),
  ];
  final queue = <QueueEntry>[
    QueueEntry(token: 'G-024', patientId: 'p1', doctorId: 'd1', problem: 'Fever', time: '10:10 AM', status: QueueStatus.consulting),
    QueueEntry(token: 'G-025', patientId: 'p2', doctorId: 'd1', problem: 'Cough', time: '10:20 AM', status: QueueStatus.next),
    QueueEntry(token: 'G-026', patientId: 'p3', doctorId: 'd1', problem: 'Headache', time: '10:25 AM', status: QueueStatus.waiting),
    QueueEntry(token: 'G-027', patientId: 'p4', doctorId: 'd1', problem: 'Fever', time: '10:30 AM', status: QueueStatus.waiting),
    QueueEntry(token: 'G-028', patientId: 'p5', doctorId: 'd1', problem: 'Tooth pain', time: '10:40 AM', status: QueueStatus.waiting),
  ];

  Patient patientFor(QueueEntry entry) => patients.firstWhere((p) => p.id == entry.patientId);
  Doctor doctorFor(QueueEntry entry) => doctors.firstWhere((d) => d.id == entry.doctorId);
  QueueEntry get patientEntry => queue.firstWhere((e) => e.patientId == 'p4');
  String text(String key) => tamil ? (translations['ta']![key] ?? key) : (translations['en']![key] ?? key);
  void toggleLanguage() { tamil = !tamil; notifyListeners(); }

  void callNext() {
    final current = queue.where((e) => e.status == QueueStatus.consulting).toList();
    if (current.isNotEmpty) current.first.status = QueueStatus.completed;
    final next = queue.where((e) => e.status == QueueStatus.next).toList();
    if (next.isNotEmpty) next.first.status = QueueStatus.consulting;
    final waiting = queue.where((e) => e.status == QueueStatus.waiting).toList();
    if (waiting.isNotEmpty) waiting.first.status = QueueStatus.next;
    notifyListeners();
  }

  String addPatient({required String name, required String doctorId, required String problem, required String time, String phone = '', int age = 0, String gender = 'Not set'}) {
    final id = 'p${patients.length + 1}';
    patients.add(Patient(id: id, name: name, phone: phone, age: age, gender: gender));
    final token = 'G-${_nextToken++}';
    queue.add(QueueEntry(token: token, patientId: id, doctorId: doctorId, problem: problem, time: time, status: QueueStatus.waiting));
    notifyListeners();
    return token;
  }

  void updatePatient(Patient patient, {required String name, String? phone, int? age, String? gender}) {
    patient.name = name;
    if (phone != null) patient.phone = phone;
    if (age != null) patient.age = age;
    if (gender != null) patient.gender = gender;
    notifyListeners();
  }

  void deletePatient(Patient patient) {
    queue.removeWhere((entry) => entry.patientId == patient.id);
    patients.removeWhere((item) => item.id == patient.id);
    notifyListeners();
  }

  void removeQueueEntry(QueueEntry entry) {
    queue.remove(entry);
    notifyListeners();
  }

  Doctor addDoctor({required String name, required String specialization, required String room, int averageMinutes = 15}) {
    final doctor = Doctor(id: 'd${doctors.length + 1}', name: name, specialization: specialization, room: room, averageMinutes: averageMinutes);
    doctors.add(doctor);
    notifyListeners();
    return doctor;
  }

  void updateDoctor(Doctor doctor, {required String name, required String specialization, required String room}) {
    doctor.name = name;
    doctor.specialization = specialization;
    doctor.room = room;
    notifyListeners();
  }

  void deleteDoctor(Doctor doctor) {
    doctors.remove(doctor);
    queue.removeWhere((entry) => entry.doctorId == doctor.id);
    notifyListeners();
  }
}

final clinicProvider = ChangeNotifierProvider<ClinicState>((ref) => ClinicState());
const translations = {
  'en': {'dashboard': 'Dashboard', 'queue': 'Live Queue', 'goodMorning': 'Good morning, Reception!', 'today': "Here's what's happening at your clinic today.", 'yourToken': 'Your Token', 'peopleAhead': 'People ahead', 'estimated': 'Estimated wait', 'doctorConsulting': 'Doctor is consulting'},
  'ta': {'dashboard': 'டாஷ்போர்டு', 'queue': 'நேரடி வரிசை', 'goodMorning': 'காலை வணக்கம், வரவேற்பு!', 'today': 'இன்று உங்கள் கிளினிக்கில் நடப்பது.', 'yourToken': 'உங்கள் டோக்கன்', 'peopleAhead': 'உங்களுக்கு முன்னால்', 'estimated': 'எதிர்பார்க்கப்படும் காத்திருப்பு நேரம்', 'doctorConsulting': 'மருத்துவர் ஆலோசனையில் உள்ளார்'},
};

void main() => runApp(const ProviderScope(child: ClinixApp()));

class ClinixApp extends StatelessWidget {
  const ClinixApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(initialLocation: '/', routes: [GoRoute(path: '/', builder: (_, __) => const RolePicker()), GoRoute(path: '/role/:role', builder: (_, state) => RoleHome(role: parseRole(state.pathParameters['role']!))) ]);
    return MaterialApp.router(title: 'Clinix App', debugShowCheckedModeBanner: false, routerConfig: router, theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: canvas, colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal), fontFamily: 'Arial', textTheme: const TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.w700, color: navy), bodyMedium: TextStyle(color: muted, height: 1.4))));
  }
}

UserRole parseRole(String value) => UserRole.values.firstWhere((role) => role.name == value, orElse: () => UserRole.receptionist);

class RolePicker extends StatelessWidget {
  const RolePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final roles = <(UserRole, IconData, String, String)>[
      (UserRole.patient, Icons.person_outline, 'Patient', 'Track your token and appointment'),
      (UserRole.receptionist, Icons.dashboard_outlined, 'Receptionist', 'Register patients and manage flow'),
      (UserRole.doctor, Icons.medical_services_outlined, 'Doctor', 'Call the next patient'),
      (UserRole.admin, Icons.insights_outlined, 'Admin', 'Clinic performance overview'),
      (UserRole.waiting, Icons.tv_outlined, 'Waiting Room Display', 'Public queue screen'),
    ];
    return Scaffold(body: SingleChildScrollView(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 980), child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ClinixLogo(large: true), const SizedBox(height: 12), const Text('Care Today. Healthier Tomorrow.', style: TextStyle(color: muted, fontSize: 18)), const SizedBox(height: 48), const Text('Choose demo role', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 20),
      Wrap(spacing: 16, runSpacing: 16, children: [for (final role in roles) roleButton(context, role.$1, role.$2, role.$3, role.$4)]),
    ]))))));
  }
  Widget roleButton(BuildContext context, UserRole role, IconData icon, String title, String subtitle) {
    return SizedBox(width: 290, child: Card(child: InkWell(
      onTap: () => context.go('/role/${role.name}'),
      borderRadius: BorderRadius.circular(14),
      child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        CircleAvatar(backgroundColor: teal.withOpacity(.12), foregroundColor: darkTeal, child: Icon(icon)), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: navy)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, color: muted))])),
      ])),
    )));
  }
}

class ClinixLogo extends StatelessWidget { const ClinixLogo({super.key, this.large = false}); final bool large; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: large ? 48 : 38, height: large ? 48 : 38, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.add, color: Colors.white, size: 30)), const SizedBox(width: 10), Text('Clinix', style: TextStyle(fontSize: large ? 28 : 21, fontWeight: FontWeight.w800, color: navy))]); }

class RoleHome extends StatelessWidget { const RoleHome({super.key, required this.role}); final UserRole role; @override Widget build(BuildContext context) { if (role == UserRole.patient) return const PatientView(); if (role == UserRole.waiting) return const WaitingView(); return DashboardShell(role: role); } }

class DashboardShell extends StatelessWidget { const DashboardShell({super.key, required this.role}); final UserRole role; @override Widget build(BuildContext context) => Scaffold(body: LayoutBuilder(builder: (context, constraints) { final desktop = constraints.maxWidth > 900; return Row(children: [if (desktop) SideNav(role: role), Expanded(child: Column(children: [TopBar(role: role), Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(desktop ? 32 : 18), child: role == UserRole.doctor ? const DoctorView() : role == UserRole.admin ? const AdminView() : const ReceptionControlView()))]))]); })); }

class SideNav extends StatelessWidget { const SideNav({super.key, required this.role}); final UserRole role; @override Widget build(BuildContext context) => Container(width: 242, color: Colors.white, padding: const EdgeInsets.fromLTRB(18, 26, 18, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const ClinixLogo(), const SizedBox(height: 42), nav(Icons.grid_view_rounded, 'Dashboard', true), nav(Icons.people_outline, 'Patients', false), nav(Icons.calendar_month_outlined, 'Appointments', false), nav(Icons.queue_play_next_outlined, 'Live Queue', false), nav(Icons.auto_awesome_outlined, 'Clinical Insights', false), nav(Icons.bar_chart_outlined, 'Reports & Analytics', false), const Spacer(), const Divider(color: border), const Text('Need help?', style: TextStyle(fontWeight: FontWeight.w700, color: navy)), const SizedBox(height: 8), const Text('Contact support', style: TextStyle(color: muted, fontSize: 12)), const SizedBox(height: 18), const Text('Clinix App v1.0.0', style: TextStyle(color: muted, fontSize: 11))])); Widget nav(IconData icon, String label, bool active) => Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: active ? teal.withOpacity(.1) : Colors.transparent, borderRadius: BorderRadius.circular(9)), child: ListTile(dense: true, leading: Icon(icon, size: 19, color: active ? darkTeal : muted), title: Text(label, style: TextStyle(color: active ? darkTeal : muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500, fontSize: 13)), onTap: () {})); }

class TopBar extends ConsumerWidget { const TopBar({super.key, required this.role}); final UserRole role; @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); return Container(height: 76, padding: const EdgeInsets.symmetric(horizontal: 28), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: border))), child: Row(children: [if (MediaQuery.sizeOf(context).width <= 900) const ClinixLogo(), const Spacer(), TextButton.icon(onPressed: state.toggleLanguage, icon: const Icon(Icons.language, size: 18), label: Text(state.tamil ? 'தமிழ்' : 'EN')), const SizedBox(width: 14), const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE1F4F5), child: Icon(Icons.person_outline, color: darkTeal)), const SizedBox(width: 10), Text(role == UserRole.doctor ? 'Dr. Arun Kumar' : 'Reception Team', style: const TextStyle(fontWeight: FontWeight.w700, color: navy))])); } }

class ReceptionView extends ConsumerWidget { const ReceptionView({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.text('goodMorning'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 6), Text(state.text('today'), style: const TextStyle(color: muted))])), FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const AddPatientDialog()), icon: const Icon(Icons.add), label: const Text('Add New Patient'))]), const SizedBox(height: 28), Wrap(spacing: 14, runSpacing: 14, children: [stat('32', 'Appointments', Icons.calendar_today_outlined, teal), stat('24', 'Checked in', Icons.how_to_reg_outlined, success), stat('${state.queue.where((e) => e.status == QueueStatus.waiting || e.status == QueueStatus.next).length}', 'Waiting', Icons.hourglass_empty, warning), stat('${state.queue.where((e) => e.status == QueueStatus.consulting).length}', 'Consulting', Icons.medical_services_outlined, darkTeal), stat('${state.queue.where((e) => e.status == QueueStatus.completed).length + 18}', 'Completed', Icons.check_circle_outline, success)]), const SizedBox(height: 34), sectionHeader('Live patient flow', 'See and manage today\'s queue'), const SizedBox(height: 14), queueTable(context, state)]); } Widget stat(String value, String label, IconData icon, Color color) => SizedBox(width: 170, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 16), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: navy)), Text(label, style: const TextStyle(fontSize: 12, color: muted))])))); }

Widget sectionHeader(String title, String subtitle) => Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: muted, fontSize: 12))])), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 16), label: const Text('Filter'))]);

Widget queueTable(BuildContext context, ClinicState state) {
  final rows = state.queue.map((entry) {
    final patient = state.patientFor(entry);
    final doctor = state.doctorFor(entry);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: border))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(entry.token, style: const TextStyle(fontWeight: FontWeight.w800, color: darkTeal))),
        Expanded(flex: 3, child: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w700, color: navy))),
        Expanded(flex: 3, child: Text('${doctor.name}\n${entry.problem}', style: const TextStyle(color: muted, fontSize: 12))),
        Expanded(child: StatusBadge(entry.status)),
        SizedBox(width: 120, child: Row(mainAxisSize: MainAxisSize.min, children: [if (entry.status == QueueStatus.next) FilledButton(onPressed: state.callNext, child: const Text('CALL')), IconButton(tooltip: 'Remove from queue', onPressed: () => state.removeQueueEntry(entry), icon: const Icon(Icons.delete_outline, size: 19, color: Colors.redAccent))])),
      ]),
    );
  }).toList();
  return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
    const Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [Expanded(flex: 2, child: Text('TOKEN', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w700))), Expanded(flex: 3, child: Text('PATIENT', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w700))), Expanded(flex: 3, child: Text('DOCTOR / REASON', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w700))), Expanded(child: Text('STATUS', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w700))), SizedBox(width: 120)])),
    ...rows,
  ])));
}

class StatusBadge extends StatelessWidget { const StatusBadge(this.status, {super.key}); final QueueStatus status; @override Widget build(BuildContext context) { final labels = {QueueStatus.consulting: 'Consulting', QueueStatus.next: 'Next', QueueStatus.waiting: 'Waiting', QueueStatus.completed: 'Completed', QueueStatus.called: 'Called'}; final colors = {QueueStatus.consulting: teal, QueueStatus.next: warning, QueueStatus.waiting: muted, QueueStatus.completed: success, QueueStatus.called: darkTeal}; return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: colors[status]!.withOpacity(.11), borderRadius: BorderRadius.circular(20)), child: Text(labels[status]!, style: TextStyle(color: colors[status], fontSize: 11, fontWeight: FontWeight.w700))); } }

class AddPatientDialog extends ConsumerStatefulWidget {
  const AddPatientDialog({super.key});
  @override ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final age = TextEditingController();
  final problem = TextEditingController();
  final time = TextEditingController(text: '10:45 AM');
  String? doctorId;
  String token = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.read(clinicProvider);
    return AlertDialog(
      title: const Text('Register new patient', style: TextStyle(color: navy, fontWeight: FontWeight.w800)),
      content: SizedBox(width: 520, child: token.isNotEmpty ? successPanel(state) : Form(key: form, child: SingleChildScrollView(child: Column(children: [
        field(name, 'Patient name *', 'Enter patient name'), field(phone, 'Phone number', 'Enter phone number'), field(age, 'Age', 'Enter age'),
        DropdownButtonFormField<String>(initialValue: doctorId, decoration: const InputDecoration(labelText: 'Doctor *', border: OutlineInputBorder()), items: state.doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(), onChanged: (v) => setState(() => doctorId = v), validator: (v) => v == null ? 'Select a doctor' : null),
        const SizedBox(height: 14), field(problem, 'Problem / reason *', 'e.g. Fever, headache...', maxLines: 2), field(time, 'Appointment time', '10:30 AM'),
      ])))),
      actions: token.isNotEmpty ? [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))] : [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: submit, child: const Text('Add patient'))],
    );
  }

  Widget field(TextEditingController controller, String label, String hint, {int maxLines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 14), child: TextFormField(controller: controller, maxLines: maxLines, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null));
  Widget successPanel(ClinicState state) { final entry = state.queue.firstWhere((e) => e.token == token); return Column(children: [const Icon(Icons.check_circle, color: success, size: 54), const SizedBox(height: 10), const Text('Patient added successfully', style: TextStyle(fontWeight: FontWeight.w700, color: navy)), const SizedBox(height: 22), const Text('YOUR TOKEN', style: TextStyle(color: muted, letterSpacing: 1.5, fontWeight: FontWeight.w700)), Text(token, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: darkTeal)), Text(state.patientFor(entry).name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: navy)), const SizedBox(height: 8), Text('${state.doctorFor(entry).name}  ·  ${entry.time}', style: const TextStyle(color: muted)), const SizedBox(height: 18), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: canvas, borderRadius: BorderRadius.circular(10)), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [Text('4', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: navy)), Text('People ahead', style: TextStyle(fontSize: 11, color: muted))]), Column(children: [Text('30–40 min', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: navy)), Text('Estimated wait', style: TextStyle(fontSize: 11, color: muted))])]))]); }
  void submit() { if (!form.currentState!.validate() || doctorId == null) return; final newToken = ref.read(clinicProvider).addPatient(name: name.text.trim(), doctorId: doctorId!, problem: problem.text.trim(), time: time.text.trim(), phone: phone.text.trim(), age: int.tryParse(age.text.trim()) ?? 0); setState(() => token = newToken); }
}

class DoctorView extends ConsumerWidget { const DoctorView({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); final current = state.queue.where((e) => e.status == QueueStatus.consulting).firstOrNull; final next = state.queue.where((e) => e.status == QueueStatus.next).firstOrNull; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Good morning, Dr. Arun', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 6), const Text('General Medicine  ·  Room 1', style: TextStyle(color: muted)), const SizedBox(height: 28), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: panel('CURRENT PATIENT', current == null ? const EmptyState(label: 'No active consultation') : patientCard(state, current, true))), const SizedBox(width: 18), Expanded(child: panel('NEXT PATIENT', next == null ? const EmptyState(label: 'Queue is clear') : patientCard(state, next, false)))])]); }
  Widget panel(String title, Widget child) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: muted)), const SizedBox(height: 18), child])));
  Widget patientCard(ClinicState state, QueueEntry entry, bool active) { final p = state.patientFor(entry); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.token, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: darkTeal)), Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 14), Text('Problem: ${entry.problem}', style: const TextStyle(color: muted)), Text('Appointment: ${entry.time}', style: const TextStyle(color: muted)), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton(onPressed: active ? () {} : state.callNext, child: Text(active ? 'Complete consultation' : 'CALL NEXT')))]); }
}

class PatientView extends ConsumerWidget {
  const PatientView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clinicProvider);
    final entry = state.patientEntry;
    final ahead = state.queue.where((e) => e.status != QueueStatus.completed).toList().indexOf(entry);
    final doctor = state.doctorFor(entry);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: const ClinixLogo(), actions: [TextButton(onPressed: state.toggleLanguage, child: Text(state.tamil ? 'தமிழ்' : 'EN'))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 18), Text(state.tamil ? 'காலை வணக்கம், மீனா' : 'Good morning, Meena', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 6), const Text("Here's your appointment for today.", style: TextStyle(color: muted)), const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const CircleAvatar(backgroundColor: Color(0xFFE1F4F5), child: Icon(Icons.medical_services_outlined, color: darkTeal)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w800, color: navy)), Text('${doctor.specialization}  ·  ${entry.time}', style: const TextStyle(color: muted, fontSize: 12))])]), const SizedBox(height: 24),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24), decoration: BoxDecoration(color: teal.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(state.text('yourToken').toUpperCase(), style: const TextStyle(letterSpacing: 1.5, color: muted, fontWeight: FontWeight.w700)), Text(entry.token, style: const TextStyle(fontSize: 62, fontWeight: FontWeight.w900, color: darkTeal)), Text(state.text('doctorConsulting'), style: const TextStyle(color: darkTeal, fontWeight: FontWeight.w700))])), const SizedBox(height: 22), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [metric('${ahead < 0 ? 0 : ahead}', state.text('peopleAhead')), metric('30–40 min', state.text('estimated'))]), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => showModalBottomSheet(context: context, builder: (_) => QueueSheet(state: state)), icon: const Icon(Icons.queue_play_next), label: Text(state.text('queue')))),
        ]))), const SizedBox(height: 20), const Text('Appointment journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 12), const Timeline(),
      ])))));
  }
  Widget metric(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 18)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: muted, fontSize: 12))]);
}

class QueueSheet extends StatelessWidget { const QueueSheet({super.key, required this.state}); final ClinicState state; @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.text('queue'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 18), ...state.queue.where((e) => e.status != QueueStatus.completed).map((e) => ListTile(contentPadding: EdgeInsets.zero, leading: Text(e.token, style: const TextStyle(fontWeight: FontWeight.w800, color: darkTeal)), title: Text(e.patientId == 'p4' ? 'YOUR TOKEN' : state.patientFor(e).name, style: const TextStyle(fontWeight: FontWeight.w700, color: navy)), trailing: StatusBadge(e.status))) ]))); }

class Timeline extends StatelessWidget { const Timeline({super.key}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: ['Appointment booked', 'Checked in', 'Token generated', 'Waiting', 'Approaching', 'Called', 'Completed'].asMap().entries.map((item) => Row(children: [Icon(item.key < 4 ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: item.key < 4 ? success : border), const SizedBox(width: 12), Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(item.value, style: TextStyle(color: item.key < 4 ? navy : muted, fontWeight: item.key < 4 ? FontWeight.w700 : FontWeight.w400)))] )).toList()))); }

class WaitingView extends ConsumerWidget { const WaitingView({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); final current = state.queue.where((e) => e.status == QueueStatus.consulting).firstOrNull; final next = state.queue.where((e) => e.status == QueueStatus.next).firstOrNull; return Scaffold(backgroundColor: navy, body: SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(28), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add, color: Colors.white, size: 26)), const SizedBox(width: 10), const Text('Clinix App', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), const Spacer(), Text(state.clinicName, style: const TextStyle(color: Colors.white70, fontSize: 18))])), const Spacer(), const Text('NOW SERVING', style: TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 14), Text(current?.token ?? '--', style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.w900)), Text(current == null ? 'Please wait' : state.patientFor(current).name.toUpperCase(), style: const TextStyle(color: teal, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1)), const SizedBox(height: 8), const Text('Consultation Room 1', style: TextStyle(color: Colors.white70, fontSize: 18)), const SizedBox(height: 42), Container(width: 360, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Text('NEXT', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(next?.token ?? '--', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)), Text(next == null ? 'Queue is clear' : state.patientFor(next).name, style: const TextStyle(color: Colors.white, fontSize: 17))])), const Spacer(), const Text('Please be ready when your token is called.', style: TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(height: 28)]))); }
}

class AdminView extends ConsumerWidget { const AdminView({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Clinic overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 6), Text('${state.clinicName}  ·  Today, 18 September 2026', style: const TextStyle(color: muted)), const SizedBox(height: 28), Wrap(spacing: 14, runSpacing: 14, children: [adminStat('Total patients', '${state.patients.length + 126}', Icons.people_outline, teal), adminStat('Appointments', '32', Icons.calendar_today_outlined, darkTeal), adminStat('Completed visits', '18', Icons.check_circle_outline, success), adminStat('Avg. wait time', '18 min', Icons.timer_outlined, warning)]), const SizedBox(height: 26), Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Patient flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 20), Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [bar('Mon', .55), bar('Tue', .75), bar('Wed', .45), bar('Thu', .9), bar('Fri', .68), bar('Sat', .5)])]))), const SizedBox(height: 20), const Card(child: ListTile(leading: Icon(Icons.auto_awesome, color: teal), title: Text('Clinical Insights — Prototype', style: TextStyle(fontWeight: FontWeight.w700, color: navy)), subtitle: Text('Demo analytics only. These values do not diagnose patients.')))]); } Widget adminStat(String title, String value, IconData icon, Color color) => SizedBox(width: 190, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 15), Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: navy)), Text(title, style: const TextStyle(color: muted, fontSize: 12))])))); Widget bar(String day, double height) => Column(children: [Container(width: 36, height: 130 * height, decoration: BoxDecoration(color: teal.withOpacity(.78), borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))), const SizedBox(height: 8), Text(day, style: const TextStyle(color: muted, fontSize: 12))]); }

class EmptyState extends StatelessWidget { const EmptyState({super.key, required this.label}); final String label; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text(label, style: const TextStyle(color: muted)))); }

Widget metric(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 18)), Text(label, style: const TextStyle(color: muted, fontSize: 12))]);

class ReceptionControlView extends ConsumerWidget {
  const ReceptionControlView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clinicProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.text('goodMorning'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)), const SizedBox(height: 6), Text(state.text('today'), style: const TextStyle(color: muted))])), Wrap(spacing: 8, children: [OutlinedButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const PatientDirectoryDialog()), icon: const Icon(Icons.people_outline), label: const Text('Manage patients')), OutlinedButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const DoctorManagementDialog()), icon: const Icon(Icons.medical_services_outlined), label: const Text('Manage doctors')), FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const AddPatientDialog()), icon: const Icon(Icons.add), label: const Text('Add patient'))])]),
      const SizedBox(height: 28),
      Wrap(spacing: 14, runSpacing: 14, children: [simpleStat('${state.patients.length}', 'Patients', Icons.people_outline, teal), simpleStat('${state.doctors.length}', 'Doctors', Icons.medical_services_outlined, darkTeal), simpleStat('${state.queue.length}', 'Queue entries', Icons.queue_play_next_outlined, warning)]),
      const SizedBox(height: 28), sectionHeader('Live patient flow', 'Edit, remove, or call patients from the queue'), const SizedBox(height: 14), queueTable(context, state),
    ]);
  }
}

Widget simpleStat(String value, String label, IconData icon, Color color) => SizedBox(width: 170, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: navy)), Text(label, style: const TextStyle(fontSize: 12, color: muted))]))));

class PatientDirectoryDialog extends ConsumerWidget {
  const PatientDirectoryDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clinicProvider);
    final rows = state.patients.map<Widget>((patient) => ListTile(
      leading: CircleAvatar(backgroundColor: teal.withOpacity(.12), foregroundColor: darkTeal, child: Text(patient.name.substring(0, 1))),
      title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${patient.phone.isEmpty ? 'No phone' : patient.phone}  ·  Age ${patient.age}  ·  ${patient.gender}'),
      trailing: Wrap(spacing: 4, children: [IconButton(tooltip: 'Edit patient', onPressed: () => showDialog(context: context, builder: (_) => PatientEditDialog(patient: patient)), icon: const Icon(Icons.edit_outlined, color: darkTeal)), IconButton(tooltip: 'Delete patient', onPressed: () => ref.read(clinicProvider).deletePatient(patient), icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]),
    )).toList();
    return AlertDialog(title: const Text('Patient directory', style: TextStyle(color: navy, fontWeight: FontWeight.w800)), content: SizedBox(width: 620, child: ListView(shrinkWrap: true, children: rows),), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), FilledButton.icon(onPressed: () { Navigator.pop(context); showDialog(context: context, builder: (_) => const AddPatientDialog()); }, icon: const Icon(Icons.add), label: const Text('Register patient'))]);
  }
}

class PatientEditDialog extends ConsumerStatefulWidget {
  const PatientEditDialog({super.key, required this.patient});
  final Patient patient;
  @override ConsumerState<PatientEditDialog> createState() => _PatientEditDialogState();
}
class _PatientEditDialogState extends ConsumerState<PatientEditDialog> {
  late final name = TextEditingController(text: widget.patient.name);
  late final phone = TextEditingController(text: widget.patient.phone);
  late final age = TextEditingController(text: widget.patient.age == 0 ? '' : '${widget.patient.age}');
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('Edit patient', style: TextStyle(color: navy, fontWeight: FontWeight.w800)), content: Column(mainAxisSize: MainAxisSize.min, children: [editField(name, 'Patient name'), editField(phone, 'Phone number'), editField(age, 'Age')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { ref.read(clinicProvider).updatePatient(widget.patient, name: name.text.trim(), phone: phone.text.trim(), age: int.tryParse(age.text) ?? 0); Navigator.pop(context); }, child: const Text('Save changes'))]);
  Widget editField(TextEditingController controller, String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
}

class DoctorManagementDialog extends ConsumerWidget {
  const DoctorManagementDialog({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) { final state = ref.watch(clinicProvider); final rows = state.doctors.map<Widget>((doctor) => ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFE1F4F5), child: Icon(Icons.medical_services_outlined, color: darkTeal)), title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${doctor.specialization}  ·  ${doctor.room}  ·  ${doctor.averageMinutes} min'), trailing: Wrap(children: [IconButton(tooltip: 'Edit doctor', onPressed: () => showDialog(context: context, builder: (_) => DoctorEditDialog(doctor: doctor)), icon: const Icon(Icons.edit_outlined, color: darkTeal)), IconButton(tooltip: 'Delete doctor', onPressed: () => ref.read(clinicProvider).deleteDoctor(doctor), icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]))).toList(); return AlertDialog(title: const Text('Doctor management', style: TextStyle(color: navy, fontWeight: FontWeight.w800)), content: SizedBox(width: 560, child: ListView(shrinkWrap: true, children: rows)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const AddDoctorDialog()), icon: const Icon(Icons.add), label: const Text('Add doctor'))]); }
}

class AddDoctorDialog extends ConsumerStatefulWidget { const AddDoctorDialog({super.key}); @override ConsumerState<AddDoctorDialog> createState() => _AddDoctorDialogState(); }
class _AddDoctorDialogState extends ConsumerState<AddDoctorDialog> { final name = TextEditingController(); final specialization = TextEditingController(); final room = TextEditingController(text: 'Room 1'); @override Widget build(BuildContext context) => AlertDialog(title: const Text('Add doctor', style: TextStyle(color: navy, fontWeight: FontWeight.w800)), content: Column(mainAxisSize: MainAxisSize.min, children: [field(name, 'Doctor name *'), field(specialization, 'Specialization'), field(room, 'Consultation room')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { if (name.text.trim().isEmpty) return; ref.read(clinicProvider).addDoctor(name: name.text.trim(), specialization: specialization.text.trim(), room: room.text.trim()); Navigator.pop(context); }, child: const Text('Save doctor'))]); Widget field(TextEditingController controller, String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()))); }

class DoctorEditDialog extends ConsumerStatefulWidget { const DoctorEditDialog({super.key, required this.doctor}); final Doctor doctor; @override ConsumerState<DoctorEditDialog> createState() => _DoctorEditDialogState(); }
class _DoctorEditDialogState extends ConsumerState<DoctorEditDialog> { late final name = TextEditingController(text: widget.doctor.name); late final specialization = TextEditingController(text: widget.doctor.specialization); late final room = TextEditingController(text: widget.doctor.room); @override Widget build(BuildContext context) => AlertDialog(title: const Text('Edit doctor', style: TextStyle(color: navy, fontWeight: FontWeight.w800)), content: Column(mainAxisSize: MainAxisSize.min, children: [field(name, 'Doctor name'), field(specialization, 'Specialization'), field(room, 'Consultation room')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { ref.read(clinicProvider).updateDoctor(widget.doctor, name: name.text.trim(), specialization: specialization.text.trim(), room: room.text.trim()); Navigator.pop(context); }, child: const Text('Save changes'))]); Widget field(TextEditingController controller, String label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()))); }