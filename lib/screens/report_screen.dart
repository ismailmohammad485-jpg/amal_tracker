import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../constants.dart';
import '../models/day_amal_data.dart';
import '../services/storage_service.dart';

// Page 4: রিপোর্ট পেইজ (দৈনিক + মাসিক)
class ReportScreen extends StatefulWidget {
  final DateTime initialDate;
  const ReportScreen({super.key, required this.initialDate});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _dailyDate;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  DayAmalData? _dayData;
  bool _loadingDay = true;

  List<DayAmalData> _monthData = [];
  bool _loadingMonth = true;

  final ScreenshotController _dailyShotController = ScreenshotController();
  final ScreenshotController _monthlyShotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _dailyDate = widget.initialDate;
    _tabController = TabController(length: 2, vsync: this);
    _loadDaily();
    _loadMonthly();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDaily() async {
    setState(() => _loadingDay = true);
    final data = await StorageService.loadDay(_dailyDate);
    if (!mounted) return;
    setState(() {
      _dayData = data;
      _loadingDay = false;
    });
  }

  Future<void> _loadMonthly() async {
    setState(() => _loadingMonth = true);
    final data = await StorageService.loadMonth(_year, _month);
    if (!mounted) return;
    setState(() {
      _monthData = data;
      _loadingMonth = false;
    });
  }

  Future<void> _pickDailyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dailyDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dailyDate = picked);
      _loadDaily();
    }
  }

  Future<void> _share(ScreenshotController controller, String label) async {
    try {
      final bytes = await controller.capture(pixelRatio: 2.0);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/amal_report_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: label);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('শেয়ার করতে সমস্যা হয়েছে: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('রিপোর্ট পেইজ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'দৈনিক আমল রিপোর্ট'),
            Tab(text: 'মাসিক রিপোর্ট'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildMonthlyTab(),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    if (_loadingDay || _dayData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final dateLabel = DateFormat('dd MMMM yyyy', 'bn').format(_dailyDate);
    final data = _dayData!;

    int jamaat = 0, alone = 0, qaza = 0, notDone = 0;
    for (final k in prayerKeys) {
      final v = data.prayers[k];
      if (v == 1) {
        jamaat++;
      } else if (v == 2) {
        alone++;
      } else if (v == 3) {
        qaza++;
      } else {
        notDone++;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDailyDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dateLabel),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _share(
                  _dailyShotController,
                  'আমার আজকের আমল রিপোর্ট ($dateLabel)',
                ),
                icon: const Icon(Icons.share),
                label: const Text('শেয়ার'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Screenshot(
            controller: _dailyShotController,
            child: Container(
              color: const Color(0xFFF4F8F6),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'তারিখ: $dateLabel',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    'নামাজ',
                    Icons.mosque,
                    Colors.green,
                    [
                      'জামাতে: $jamaat',
                      'একাকী: $alone',
                      'কাজা আদায়: $qaza',
                      'আদায় হয়নি: $notDone',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    'কুরআন তিলাওয়াত',
                    Icons.menu_book,
                    Colors.teal,
                    [
                      data.quranStatus != null
                          ? quranOptionLabels[data.quranStatus]!
                          : 'এন্ট্রি করা হয়নি',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    'জিকির',
                    Icons.favorite,
                    Colors.purple,
                    [
                      'সকালের আজকার: ${data.sokalZikr != null ? zikrOptionLabels[data.sokalZikr]! : 'এন্ট্রি করা হয়নি'}',
                      'সন্ধ্যার আজকার: ${data.sondhyaZikr != null ? zikrOptionLabels[data.sondhyaZikr]! : 'এন্ট্রি করা হয়নি'}',
                      if (data.zikrList.isEmpty) 'কোনো জিকির যোগ করা হয়নি',
                      ...data.zikrList.map((z) => '${z.name}: ${z.count} বার'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTab() {
    int jamaat = 0, alone = 0, qaza = 0;
    int quranTarget = 0, quranPartial = 0, quranNone = 0;
    int sokalDone = 0, sondhyaDone = 0, totalZikrCount = 0;

    for (final day in _monthData) {
      for (final k in prayerKeys) {
        final v = day.prayers[k];
        if (v == 1) {
          jamaat++;
        } else if (v == 2) {
          alone++;
        } else if (v == 3) {
          qaza++;
        }
      }
      if (day.quranStatus == 1) {
        quranTarget++;
      } else if (day.quranStatus == 2) {
        quranPartial++;
      } else if (day.quranStatus == 3) {
        quranNone++;
      }

      if (day.sokalZikr == 1) sokalDone++;
      if (day.sondhyaZikr == 1) sondhyaDone++;
      for (final z in day.zikrList) {
        totalZikrCount += z.count;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _month,
                  decoration: const InputDecoration(
                    labelText: 'মাস',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(banglaMonths[m - 1]),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _month = v);
                    _loadMonthly();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _year,
                  decoration: const InputDecoration(
                    labelText: 'বছর',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: List.generate(6, (i) => DateTime.now().year - 3 + i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _year = v);
                    _loadMonthly();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _share(
                  _monthlyShotController,
                  '${banglaMonths[_month - 1]} $_year এর আমল রিপোর্ট',
                ),
                icon: const Icon(Icons.share),
                label: const Text('শেয়ার'),
              ),
            ],
          ),
        ),
        if (_loadingMonth)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: Screenshot(
              controller: _monthlyShotController,
              child: Container(
                color: const Color(0xFFF4F8F6),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${banglaMonths[_month - 1]} $_year — এন্ট্রি করা দিন: ${_monthData.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _statCard('নামাজ (মাসিক)', Icons.mosque, Colors.green, [
                      'জামাতে: $jamaat বার',
                      'একাকী: $alone বার',
                      'কাজা আদায়: $qaza বার',
                    ]),
                    const SizedBox(height: 12),
                    _statCard('কুরআন তিলাওয়াত (মাসিক)', Icons.menu_book, Colors.teal, [
                      'টার্গেট পূর্ণ হয়েছে: $quranTarget দিন',
                      'আংশিক তিলাওয়াত: $quranPartial দিন',
                      'তিলাওয়াত হয়নি: $quranNone দিন',
                    ]),
                    const SizedBox(height: 12),
                    _statCard('জিকির (মাসিক)', Icons.favorite, Colors.purple, [
                      'সকালের আজকার সম্পন্ন: $sokalDone দিন',
                      'সন্ধ্যার আজকার সম্পন্ন: $sondhyaDone দিন',
                      'মোট জিকির সংখ্যা: $totalZikrCount',
                    ]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String title, IconData icon, Color color, List<String> lines) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...lines.map((l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(l, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }
}
