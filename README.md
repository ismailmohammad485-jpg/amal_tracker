# আমল ট্র্যাকার (Amal Tracker)

দৈনিক নামাজ, কুরআন তিলাওয়াত ও জিকির ট্র্যাক করার একটি সম্পূর্ণ Flutter অ্যাপ। সব ডেটা মোবাইলে (SharedPreferences দিয়ে) লোকালি সেভ হয়, ইন্টারনেট লাগে না।

এই প্রজেক্টে ইচ্ছাকৃতভাবে `android/` ফোল্ডার নেই — `codemagic.yaml` বিল্ডের শুরুতেই `flutter create . --platforms=android` চালিয়ে Codemagic-এ ইনস্টল থাকা Flutter ভার্সনের সাথে ম্যাচ করা সঠিক Android ফোল্ডার নিজে থেকে বানিয়ে নেয়। এতে ভার্সন-মিসম্যাচ সমস্যা হয় না।

## ⚠️ DartPad নিয়ে নোট
এই অ্যাপ DartPad-এ রান করা যাবে না — এতে shared_preferences, share_plus, screenshot এর মতো native plugin আছে যেগুলো শুধু আসল ডিভাইস/এমুলেটরে কাজ করে।

---

## Codemagic দিয়ে Android APK বিল্ড (শুধু Android, iOS বাদ)

1. **GitHub-এ রিপোজিটরি বানান** (github.com এ ফ্রি অ্যাকাউন্ট লাগবে)। "New repository" → নাম দিন `amal_tracker` → Create।
2. রিপোর পেজে **Add file → Upload files** চাপুন, তারপর এই পুরো ফোল্ডারের সবকিছু (lib/, pubspec.yaml, codemagic.yaml, .gitignore, analysis_options.yaml, README.md) ড্র্যাগ করে ছেড়ে দিন। **Commit changes** চাপুন।
3. **codemagic.io**-এ গিয়ে GitHub দিয়ে সাইন আপ/লগইন করুন।
4. Dashboard-এ **Add application** → Git provider হিসেবে GitHub বাছুন → অনুমতি দিন → আপনার `amal_tracker` রিপো সিলেক্ট করুন।
5. Codemagic রিপোতে `codemagic.yaml` পাবে এবং সেটা থেকে **`android-workflow`** নামে একটা ওয়ার্কফ্লো দেখাবে/অটো-সিলেক্ট করবে। সেটা বেছে নিন।
6. উপরে ডানে **Start new build** চাপুন। বিল্ড শুরু হলে এই ৩টা ধাপ চলবে:
   - `rm -rf android && flutter create . --platforms=android` (নতুন Android ফোল্ডার বানানো)
   - `flutter pub get`
   - `flutter build apk --release`
7. বিল্ড সবুজ (successful) হলে **Artifacts** ট্যাবে গিয়ে `.apk` ফাইলটা ডাউনলোড করুন।
8. এই .apk ফাইলটা সরাসরি WhatsApp/Telegram/Google Drive দিয়ে বন্ধুদের পাঠান। যিনি ইনস্টল করবেন, তাকে ফোনে "Install from Unknown Sources" অনুমতি দিতে হবে।

**ফ্রি লিমিট**: Codemagic-এ প্রতি মাসে ৫০০ মিনিট ফ্রি বিল্ড সময় থাকে — এই ছোট অ্যাপের জন্য যথেষ্ট।

---

## অ্যাপের কাঠামো
```
codemagic.yaml             # Codemagic বিল্ড কনফিগারেশন (Android-only)
lib/
  main.dart                 # অ্যাপ এন্ট্রি পয়েন্ট, থিম ও লোকালাইজেশন সেটআপ
  constants.dart            # সব বাংলা লেবেল ও অপশন এক জায়গায়
  models/day_amal_data.dart # একদিনের সব আমলের ডেটা মডেল
  services/storage_service.dart # SharedPreferences দিয়ে সেভ/লোড
  widgets/app_drawer.dart   # নেভিগেশন ড্রয়ার
  screens/
    welcome_screen.dart     # স্বাগতম পেইজ
    prayer_screen.dart      # Page 1: নামাজ আদায়
    quran_screen.dart       # Page 2: তিলাওয়াত
    zikr_screen.dart        # Page 3: জিকির
    report_screen.dart      # Page 4: দৈনিক ও মাসিক রিপোর্ট + শেয়ার
```

## ফিচার সারসংক্ষেপ
- স্বাগতম পেইজ থেকে বাটনে ক্লিক করে নামাজ পেইজে প্রবেশ
- তারিখ পিকার দিয়ে যেকোনো দিনের এন্ট্রি দেখা/এডিট করা যায়
- ৫ ওয়াক্ত নামাজের জন্য জামাতে/একাকী/কাজা আদায় রেডিও অপশন
- তিলাওয়াত ও জিকিরের (সকাল/সন্ধ্যা + ডাইনামিক জিকির লিস্ট) এন্ট্রি
- প্রতিটি পেইজে Previous/Submit বাটন দিয়ে নেভিগেশন
- রিপোর্ট পেইজে দৈনিক ও মাসিক ট্যাব, রঙিন ড্যাশবোর্ড কার্ড
- স্ক্রিনশট নিয়ে সোশ্যাল মিডিয়ায় শেয়ার করার বাটন
- ন্যাভিগেশন ড্রয়ার দিয়ে যেকোনো পেইজ থেকে সরাসরি রিপোর্টে যাওয়া যায়
- সব ডেটা তারিখ অনুযায়ী ফোনের মেমরিতে (লোকালি) সেভ থাকে, পুনরায় এডিট করলে রিপোর্টে সাথে সাথে আপডেট হয়
