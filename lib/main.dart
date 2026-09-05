import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';

void main() {
  runApp(const PragyaHamaliApp());
}

class PragyaHamaliApp extends StatelessWidget {
  const PragyaHamaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pragya Products',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A2540),
          primary: const Color(0xFF0A2540),
          secondary: const Color(0xFF00D4B2),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= BRAND LOGO =================
class PragyaBrandLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const PragyaBrandLogo({super.key, this.size = 60, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F3959), const Color(0xFF0A2540)]
              : [const Color(0xFF00E5FF), const Color(0xFF00D4B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF00D4B2) : const Color(0xFF0A2540)).withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF00D4B2).withOpacity(0.5) : Colors.white,
          width: size * 0.04,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.18,
              child: Icon(
                Icons.precision_manufacturing_rounded,
                size: size * 0.55,
                color: isDark ? Colors.white : const Color(0xFF0A2540),
              ),
            ),
            Text(
              'P',
              style: TextStyle(
                fontSize: size * 0.52,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFF00D4B2) : const Color(0xFF0A2540),
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationShell()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081C30),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const PragyaBrandLogo(size: 110, isDark: true),
              ),
              const SizedBox(height: 28),
              const Text(
                'PRAGYA PRODUCTS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'INDUSTRIAL HAMALI AUTOMATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF88A3BD),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4B2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF00D4B2).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.code_rounded, size: 16, color: Color(0xFF00D4B2)),
                    SizedBox(width: 8),
                    Text(
                      'Made by Harshit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4B2),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DATA MODEL =================
class HamaliEntry {
  int sNo;
  final String date;
  final String detail;
  final int bags;
  final String weightPerBag;
  final double pricePerBag;
  final double total;
  final String description;
  final String timeStamp;

  HamaliEntry({
    required this.sNo,
    required this.date,
    required this.detail,
    required this.bags,
    required this.weightPerBag,
    required this.pricePerBag,
    required this.total,
    required this.description,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() => {
        'sNo': sNo,
        'date': date,
        'detail': detail,
        'bags': bags,
        'weightPerBag': weightPerBag,
        'pricePerBag': pricePerBag,
        'total': total,
        'description': description,
        'timeStamp': timeStamp,
      };

  factory HamaliEntry.fromMap(Map<String, dynamic> map) => HamaliEntry(
        sNo: map['sNo'],
        date: map['date'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now()),
        detail: map['detail'],
        bags: map['bags'],
        weightPerBag: map['weightPerBag'],
        pricePerBag: map['pricePerBag'],
        total: map['total'],
        description: map['description'] ?? '',
        timeStamp: map['timeStamp'] ?? '',
      );
}

// ================= NAVIGATION SHELL (BOTTOM BAR) =================
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final List<HamaliEntry> _allEntries = [];
  bool _isLocked = false;
  final String _adminPin = "1234";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('daily_entries');
    final bool? lockedStatus = prefs.getBool('is_locked');
    if (rawData != null) {
      final List decoded = jsonDecode(rawData);
      setState(() {
        _allEntries.clear();
        _allEntries.addAll(decoded.map((e) => HamaliEntry.fromMap(e)).toList());
      });
    }
    if (lockedStatus != null) {
      setState(() => _isLocked = lockedStatus);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_allEntries.map((e) => e.toMap()).toList());
    await prefs.setString('daily_entries', encoded);
    await prefs.setBool('is_locked', _isLocked);
  }

  void _toggleLock() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLocked ? 'Enter PIN to Unlock' : 'Enter PIN to Lock'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(hintText: '4-digit PIN (Default: 1234)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == _adminPin) {
                setState(() => _isLocked = !_isLocked);
                _saveData();
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN!')));
              }
            },
            child: const Text('Verify'),
          )
        ],
      ),
    );
  }

  static Future<void> exportDatePdf(BuildContext context, String reportDate, List<HamaliEntry> entries) async {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No entries to export for this date!')));
      return;
    }

    final pdf = pw.Document();
    final dayTotal = entries.fold<double>(0, (prev, el) => prev + el.total);
    final dayBags = entries.fold<int>(0, (prev, el) => prev + el.bags);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 38,
                        height: 38,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.blueGrey900,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text('P', style: pw.TextStyle(color: PdfColors.cyan, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('PRAGYA PRODUCTS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.Text('Daily Hamali Distribution Report', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Report Date', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(reportDate, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.TableHelper.fromTextArray(
                headers: ['S.No', 'Detail', 'Bags', 'Weight', 'Rate (Rs)', 'Total (Rs)', 'Notes'],
                data: entries.map((e) => [
                  e.sNo.toString(),
                  e.detail,
                  e.bags.toString(),
                  e.weightPerBag,
                  e.pricePerBag.toStringAsFixed(2),
                  e.total.toStringAsFixed(2),
                  e.description,
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 15),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Bags: $dayBags Bags', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.Text('Grand Total: Rs. ${dayTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Generated via Pragya Hamali App • Built by Harshit', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081C30),
        title: Row(
          children: [
            const PragyaBrandLogo(size: 34, isDark: true),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Pragya Products', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 17)),
                Text('Made by Harshit', style: TextStyle(color: Color(0xFF00D4B2), fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLocked ? Icons.lock_rounded : Icons.lock_open_rounded, color: _isLocked ? Colors.redAccent : const Color(0xFF00D4B2)),
            onPressed: _toggleLock,
            tooltip: _isLocked ? 'Unlock Sheet' : 'Lock Sheet',
          ),
        ],
      ),
      body: _currentIndex == 0
          ? HomeScreenTab(
              allEntries: _allEntries,
              isLocked: _isLocked,
              onDataChanged: _saveData,
            )
          : SavedReportsTab(
              allEntries: _allEntries,
              onExportPdf: (date, entries) => exportDatePdf(context, date, entries),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: const Color(0xFF00D4B2).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_rounded),
            selectedIcon: Icon(Icons.edit_note_rounded, color: Color(0xFF0A2540)),
            label: 'Daily Entries',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: Color(0xFF0A2540)),
            label: 'Saved Reports',
          ),
        ],
      ),
    );
  }
}

// ================= TAB 1: DAILY ENTRIES =================
class HomeScreenTab extends StatefulWidget {
  final List<HamaliEntry> allEntries;
  final bool isLocked;
  final VoidCallback onDataChanged;

  const HomeScreenTab({
    super.key,
    required this.allEntries,
    required this.isLocked,
    required this.onDataChanged,
  });

  @override
  State<HomeScreenTab> createState() => _HomeScreenTabState();
}

class _HomeScreenTabState extends State<HomeScreenTab> {
  DateTime _selectedDate = DateTime.now();
  String _selectedWork = 'Truck Load';
  String _selectedWeight = '50 Kg';
  final TextEditingController _customWorkController = TextEditingController();
  final TextEditingController _customWeightController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> _workOptions = ['Truck Load', 'Truck Unload', 'Load from Stack', 'Fill & Stack', 'Custom (Manual)'];
  final List<String> _weightOptions = ['30 Kg', '40 Kg', '50 Kg', 'Custom (Manual)'];

  List<HamaliEntry> get _filteredEntries {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return widget.allEntries.where((e) => e.date == formattedDate).toList();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addEntry() {
    if (widget.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet Locked hai! Pehle unlock karein.')));
      return;
    }

    final int? bags = int.tryParse(_bagsController.text);
    final double? price = double.tryParse(_priceController.text);

    if (bags == null || price == null || bags <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid Bags & Rate enter karein')));
      return;
    }

    final String finalWork = _selectedWork == 'Custom (Manual)' ? _customWorkController.text.trim() : _selectedWork;
    final String finalWeight = _selectedWeight == 'Custom (Manual)' ? _customWeightController.text.trim() : _selectedWeight;

    if (finalWork.isEmpty || finalWeight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work Detail & Weight specify karein')));
      return;
    }

    final String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final currentDayCount = _filteredEntries.length;

    final newEntry = HamaliEntry(
      sNo: currentDayCount + 1,
      date: formattedDate,
      detail: finalWork,
      bags: bags,
      weightPerBag: finalWeight,
      pricePerBag: price,
      total: bags * price,
      description: _descController.text.trim(),
      timeStamp: DateFormat('hh:mm a').format(DateTime.now()),
    );

    setState(() {
      widget.allEntries.add(newEntry);
      _bagsController.clear();
      _priceController.clear();
      _descController.clear();
      _customWorkController.clear();
      _customWeightController.clear();
    });

    widget.onDataChanged();
  }

  void _deleteEntry(HamaliEntry entryToDelete) {
    if (widget.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet Locked hai! Unlock karein.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('S.No #${entryToDelete.sNo} entry delete karni hai?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                widget.allEntries.remove(entryToDelete);
                final dayEntries = widget.allEntries.where((e) => e.date == entryToDelete.date).toList();
                for (int i = 0; i < dayEntries.length; i++) {
                  dayEntries[i].sNo = i + 1;
                }
              });
              widget.onDataChanged();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;
    final dayTotal = filtered.fold<double>(0, (prev, el) => prev + el.total);
    final dayBags = filtered.fold<int>(0, (prev, el) => prev + el.bags);
    final dateString = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF3FB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF0A2540).withOpacity(0.15)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF0A2540)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Date: $dateString (Tap to Change)',
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0A2540)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: filtered.isEmpty ? null : () => _MainNavigationShellState.exportDatePdf(context, dateString, filtered),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                          tooltip: 'Export Current Day PDF',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedWork,
                            decoration: InputDecoration(
                              labelText: 'Work Type',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _workOptions.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) => setState(() => _selectedWork = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedWeight,
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _weightOptions.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) => setState(() => _selectedWeight = val!),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedWork == 'Custom (Manual)' || _selectedWeight == 'Custom (Manual)') const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_selectedWork == 'Custom (Manual)')
                          Expanded(
                            child: TextField(
                              controller: _customWorkController,
                              decoration: InputDecoration(
                                labelText: 'Custom Work Detail',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        if (_selectedWork == 'Custom (Manual)' && _selectedWeight == 'Custom (Manual)') const SizedBox(width: 8),
                        if (_selectedWeight == 'Custom (Manual)')
                          Expanded(
                            child: TextField(
                              controller: _customWeightController,
                              decoration: InputDecoration(
                                labelText: 'Custom Weight',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bagsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Bags Count',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Rate / Bag (₹)',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle No / Notes (Optional)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF081C30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00D4B2)),
                        label: const Text('ADD ENTRY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Entries for $dateString', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A2540))),
                  Text('${filtered.length} entries', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '$dateString ki koi entry nahi hai.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final item = filtered[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          elevation: 0.8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF081C30),
                              foregroundColor: const Color(0xFF00D4B2),
                              child: Text('${item.sNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text('${item.bags} Bags — ${item.detail} (${item.weightPerBag})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('Rate: ₹${item.pricePerBag} | Time: ${item.timeStamp}\n${item.description.isNotEmpty ? "Note: " + item.description : ""}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF00897B))),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => _deleteEntry(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Day Bags: $dayBags', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                      Text(widget.isLocked ? '🔒 Locked' : '🔓 Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.isLocked ? Colors.red : Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total ($dateString)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('₹ ${dayTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A2540))),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= TAB 2: SAVED REPORTS ARCHIVE =================
class SavedReportsTab extends StatelessWidget {
  final List<HamaliEntry> allEntries;
  final Function(String date, List<HamaliEntry> entries) onExportPdf;

  const SavedReportsTab({
    super.key,
    required this.allEntries,
    required this.onExportPdf,
  });

  Map<String, List<HamaliEntry>> get _groupedReports {
    final Map<String, List<HamaliEntry>> map = {};
    for (var entry in allEntries) {
      if (!map.containsKey(entry.date)) {
        map[entry.date] = [];
      }
      map[entry.date]!.add(entry);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedReports;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Day-wise Saved Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0A2540)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2540).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${dates.length} Days Recorded',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: dates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Abhi tak koi entry save nahi hui hai.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dates.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      itemBuilder: (ctx, idx) {
                        final date = dates[idx];
                        final dayEntries = grouped[date]!;
                        final totalBags = dayEntries.fold<int>(0, (prev, el) => prev + el.bags);
                        final grandTotal = dayEntries.fold<double>(0, (prev, el) => prev + el.total);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              _showDateBreakdownSheet(context, date, dayEntries, totalBags, grandTotal);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A2540),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF00D4B2), size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date: $date',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0A2540)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bags: $totalBags | Entries: ${dayEntries.length}',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹ ${grandTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF00897B)),
                                      ),
                                      const SizedBox(height: 6),
                                      IconButton.filledTonal(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => onExportPdf(date, dayEntries),
                                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                        tooltip: 'Print / Export PDF',
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateBreakdownSheet(BuildContext context, String date, List<HamaliEntry> entries, int totalBags, double grandTotal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Report: $date', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text('Total Bags: $totalBags | Grand Total: ₹ ${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onExportPdf(date, entries);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2540),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('PDF'),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: entries.length,
                itemBuilder: (c, i) {
                  final item = entries[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0A2540),
                      foregroundColor: const Color(0xFF00D4B2),
                      child: Text('${item.sNo}'),
                    ),
                    title: Text('${item.bags} Bags — ${item.detail} (${item.weightPerBag})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Rate: ₹${item.pricePerBag} | ${item.timeStamp}\n${item.description.isNotEmpty ? item.description : ""}'),
                    trailing: Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF00897B))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
