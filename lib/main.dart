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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const HomeScreen(),
    );
  }
}

class HamaliEntry {
  final int sNo;
  final String detail;
  final int bags;
  final String weightPerBag;
  final double pricePerBag;
  final double total;
  final String description;
  final String timeStamp;

  HamaliEntry({
    required this.sNo,
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
        detail: map['detail'],
        bags: map['bags'],
        weightPerBag: map['weightPerBag'],
        pricePerBag: map['pricePerBag'],
        total: map['total'],
        description: map['description'] ?? '',
        timeStamp: map['timeStamp'] ?? '',
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<HamaliEntry> _entries = [];
  bool _isLocked = false;
  final String _adminPin = "1234";

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
        _entries.clear();
        _entries.addAll(decoded.map((e) => HamaliEntry.fromMap(e)).toList());
      });
    }
    if (lockedStatus != null) {
      setState(() => _isLocked = lockedStatus);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString('daily_entries', encoded);
    await prefs.setBool('is_locked', _isLocked);
  }

  void _addEntry() {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet is Locked! Unlock with PIN to add.')));
      return;
    }

    final int? bags = int.tryParse(_bagsController.text);
    final double? price = double.tryParse(_priceController.text);

    if (bags == null || price == null || bags <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid Bags and Price')));
      return;
    }

    final String finalWork = _selectedWork == 'Custom (Manual)' ? _customWorkController.text.trim() : _selectedWork;
    final String finalWeight = _selectedWeight == 'Custom (Manual)' ? _customWeightController.text.trim() : _selectedWeight;

    if (finalWork.isEmpty || finalWeight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please specify Work and Weight')));
      return;
    }

    final newEntry = HamaliEntry(
      sNo: _entries.length + 1,
      detail: finalWork,
      bags: bags,
      weightPerBag: finalWeight,
      pricePerBag: price,
      total: bags * price,
      description: _descController.text.trim(),
      timeStamp: DateFormat('hh:mm a').format(DateTime.now()),
    );

    setState(() {
      _entries.add(newEntry);
      _bagsController.clear();
      _priceController.clear();
      _descController.clear();
      _customWorkController.clear();
      _customWeightController.clear();
    });

    _saveData();
  }

  void _toggleLock() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLocked ? 'Enter PIN to Unlock' : 'Set/Enter PIN to Lock'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter 4-digit PIN (Default: 1234)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == _adminPin) {
                setState(() => _isLocked = !_isLocked);
                _saveData();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isLocked ? 'Sheet Locked Successfully!' : 'Sheet Unlocked!')),
                );
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
    final pdf = pw.Document();
    final grandTotal = _entries.fold<double>(0, (prev, el) => prev + el.total);
    final totalBags = _entries.fold<int>(0, (prev, el) => prev + el.bags);
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Pragya Products', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Daily Hamali Distribution Report', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Date: $currentDate', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 15),
              pw.TableHelper.fromTextArray(
                headers: ['S.No', 'Detail', 'Bags', 'Weight', 'Rate', 'Total', 'Notes'],
                data: _entries.map((e) => [
                  e.sNo.toString(),
                  e.detail,
                  e.bags.toString(),
                  e.weightPerBag,
                  e.pricePerBag.toStringAsFixed(2),
                  e.total.toStringAsFixed(2),
                  e.description,
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 15),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Bags: $totalBags Bags', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Grand Total: Rs. ${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = _entries.fold<double>(0, (prev, el) => prev + el.total);
    final totalBags = _entries.fold<int>(0, (prev, el) => prev + el.bags);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pragya Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F4C81),
        actions: [
          IconButton(
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
            onPressed: _toggleLock,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _entries.isEmpty ? null : _exportPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedWork,
                          decoration: const InputDecoration(labelText: 'Detail / Work', border: OutlineInputBorder()),
                          items: _workOptions.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) => setState(() => _selectedWork = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedWeight,
                          decoration: const InputDecoration(labelText: 'Weight', border: OutlineInputBorder()),
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
                            decoration: const InputDecoration(labelText: 'Custom Work Detail', border: OutlineInputBorder()),
                          ),
                        ),
                      if (_selectedWork == 'Custom (Manual)' && _selectedWeight == 'Custom (Manual)') const SizedBox(width: 8),
                      if (_selectedWeight == 'Custom (Manual)')
                        Expanded(
                          child: TextField(
                            controller: _customWeightController,
                            decoration: const InputDecoration(labelText: 'Custom Weight (e.g. 25 Kg)', border: OutlineInputBorder()),
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
                          decoration: const InputDecoration(labelText: 'Bags Count', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Rate / Bag (₹)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description / Remarks (Optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('ADD ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('Aaj ki koi entry nahi hai. Nayi entry add karein.'))
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (ctx, idx) {
                      final item = _entries[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0F4C81),
                            foregroundColor: Colors.white,
                            child: Text('${item.sNo}'),
                          ),
                          title: Text('${item.bags} Bags - ${item.detail} (${item.weightPerBag})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Rate: ₹${item.pricePerBag} | Notes: ${item.description.isEmpty ? "None" : item.description}'),
                          trailing: Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Bags: $totalBags', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(_isLocked ? '🔒 Sheet Locked' : '🔓 Active Mode', style: TextStyle(fontSize: 12, color: _isLocked ? Colors.red : Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Grand Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('₹ ${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
