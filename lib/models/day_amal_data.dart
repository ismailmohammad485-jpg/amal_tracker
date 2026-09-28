// একটি নির্দিষ্ট তারিখের সমস্ত আমলের তথ্য ধরে রাখার মডেল

class ZikrItem {
  String name;
  int count;

  ZikrItem({required this.name, required this.count});

  factory ZikrItem.fromJson(Map<String, dynamic> json) {
    return ZikrItem(
      name: json['name'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
      };
}

class DayAmalData {
  final String date; // yyyy-MM-dd ফরম্যাটে
  Map<String, int?> prayers; // key: fajr/zuhr/asr/maghrib/isha, value: 1/2/3
  int? quranStatus; // 1/2/3
  int? sokalZikr; // 1/2
  int? sondhyaZikr; // 1/2
  List<ZikrItem> zikrList;

  DayAmalData({
    required this.date,
    Map<String, int?>? prayers,
    this.quranStatus,
    this.sokalZikr,
    this.sondhyaZikr,
    List<ZikrItem>? zikrList,
  })  : prayers = prayers ??
            {
              'fajr': null,
              'zuhr': null,
              'asr': null,
              'maghrib': null,
              'isha': null,
            },
        zikrList = zikrList ?? [];

  factory DayAmalData.empty(String date) => DayAmalData(date: date);

  factory DayAmalData.fromJson(String date, Map<String, dynamic> json) {
    final rawPrayers = json['prayers'] as Map<String, dynamic>? ?? {};
    final prayers = <String, int?>{
      'fajr': (rawPrayers['fajr'] as num?)?.toInt(),
      'zuhr': (rawPrayers['zuhr'] as num?)?.toInt(),
      'asr': (rawPrayers['asr'] as num?)?.toInt(),
      'maghrib': (rawPrayers['maghrib'] as num?)?.toInt(),
      'isha': (rawPrayers['isha'] as num?)?.toInt(),
    };
    final rawZikrList = json['zikrList'] as List? ?? [];
    return DayAmalData(
      date: date,
      prayers: prayers,
      quranStatus: (json['quranStatus'] as num?)?.toInt(),
      sokalZikr: (json['sokalZikr'] as num?)?.toInt(),
      sondhyaZikr: (json['sondhyaZikr'] as num?)?.toInt(),
      zikrList: rawZikrList
          .map((e) => ZikrItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'prayers': prayers,
        'quranStatus': quranStatus,
        'sokalZikr': sokalZikr,
        'sondhyaZikr': sondhyaZikr,
        'zikrList': zikrList.map((e) => e.toJson()).toList(),
      };
}
