// কেন্দ্রীয় লেবেল ও কনস্ট্যান্ট সমূহ

const List<String> prayerKeys = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];

const Map<String, String> prayerLabels = {
  'fajr': 'ফজর',
  'zuhr': 'যুহর',
  'asr': 'আসর',
  'maghrib': 'মাগরিব',
  'isha': 'এশা',
};

// ১ = জামাতে, ২ = একাকী, ৩ = কাজা আদায়
const Map<int, String> prayerOptionLabels = {
  1: 'জামাতে',
  2: 'একাকী',
  3: 'কাজা আদায়',
};

// ১ = টার্গেট তিলাওয়াত হয়েছে, ২ = আংশিক তিলাওয়াত হয়েছে, ৩ = হয় নাই
const Map<int, String> quranOptionLabels = {
  1: 'টার্গেট তিলাওয়াত হয়েছে',
  2: 'আংশিক তিলাওয়াত হয়েছে',
  3: 'হয় নাই',
};

// ১ = করা হয়েছে, ২ = করা হয়নি
const Map<int, String> zikrOptionLabels = {
  1: 'করা হয়েছে',
  2: 'করা হয়নি',
};

const List<String> banglaMonths = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];
