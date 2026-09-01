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
        scaffoldBackgroundColor: const Color(0xFFF6F9FC),
      ),
      home: const SplashScreen(),
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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
      backgroundColor: const Color(0xFF0A2540),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.factory_outlined, size: 75, color: Color(0xFF00D4B2)),
              ),
              const SizedBox(height: 24),
              const Text(
                'PRAGYA PRODUCTS',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hamali & Labor Distribution System',
                style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 0.5),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4B2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.pad(BorderSide(color: const Color(0xFF00D4B2).withOpacity(0.4))),
                ),
                child: const Text(
                  'Made by Harshit',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00D4B2), letterSpacing: 1.2),
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

// ================= MAIN SCREEN =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<HamaliEntry> _allEntries = [];
  bool _isLocked = false;
  final String _adminPin = "1234";

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

  List<HamaliEntry> get _filteredEntries {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return _allEntries.where((e) => e.date == formattedDate).toList();
  }

  void _addEntry() {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet is Locked! Unlock with PIN first.')));
      return;
    }

    final int? bags = int.tryParse(_bagsController.text);
    final double? price = double.tryParse(_priceController.text);

    if (bags == null || price == null || bags <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid Bags & Price enter karein')));
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
      _allEntries.add(newEntry);
      _bagsController.clear();
      _priceController.clear();
      _descController.clear();
      _customWorkController.clear();
      _customWeightController.clear();
    });

    _saveData();
  }

  void _deleteEntry(HamaliEntry entryToDelete) {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sheet Locked hai! Unlock karein.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Kya aap S.No #${entryToDelete.sNo} entry delete karna chahte hain?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _allEntries.remove(entryToDelete);
                final dayEntries = _allEntries.where((e) => e.date == entryToDelete.date).toList();
                for (int i = 0; i < dayEntries.length; i++) {
                  dayEntries[i].sNo = i + 1;
                }
              });
              _saveData();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  Future<void> _exportPdf() async {
    final filtered = _filteredEntries;
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected date me koi entry nahi hai!')),
      );
      return;
    }

    final pdf = pw.Document();
    final dayTotal = filtered.fold<double>(0, (prev, el) => prev + el.total);
    final dayBags = filtered.fold<int>(0, (prev, el) => prev + el.bags);
    final reportDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

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
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PRAGYA PRODUCTS', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Daily Hamali Distribution Report', style: const pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                  pw.Text('Date: $reportDate', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.TableHelper.fromTextArray(
                headers: ['S.No', 'Detail', 'Bags', 'Weight', 'Rate (Rs)', 'Total (Rs)', 'Notes'],
                data: filtered.map((e) => [
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
                child: pw.Text('Generated via Pragya Hamali App • Made by Harshit', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
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
    final filtered = _filteredEntries;
    final dayTotal = filtered.fold<double>(0, (prev, el) => prev + el.total);
    final dayBags = filtered.fold<int>(0, (prev, el) => prev + el.bags);
    final dateString = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A2540),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Pragya Products', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
            Text('Made by Harshit', style: TextStyle(color: Color(0xFF00D4B2), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open, color: _isLocked ? Colors.redAccent : const Color(0xFF00D4B2)),
            onPressed: _toggleLock,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            onPressed: filtered.isEmpty ? null : _exportPdf,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 2,
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
                                    const Icon(Icons.calendar_month, size: 18, color: Color(0xFF0A2540)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date: $dateString',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0A2540)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                            backgroundColor: const Color(0xFF0A2540),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00D4B2)),
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
                    Text('Entries: $dateString', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A2540))),
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
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF0A2540),
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
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
                        Text('Total Bags: $dayBags', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                        Text(_isLocked ? '🔒 Locked' : '🔓 Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isLocked ? Colors.red : Colors.green)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Day Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('₹ ${dayTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A2540))),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
