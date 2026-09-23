# Kidareh Flutter

اپلیکیشن یکپارچه موبایل کی‌داره برای خریدار، فروشنده و معرف.

## معماری
- Flutter + Material 3
- Riverpod برای مدیریت state
- GoRouter برای navigation
- Dio برای API
- Flutter Secure Storage برای credentialهای حساس
- Backend مشترک با وب‌سایت کی‌داره
- UI فارسی و RTL
- ساختار feature-first

## نقش‌ها
یک حساب می‌تواند هم‌زمان خریدار، فروشنده و معرف باشد؛ معماری اپ بر مبنای سه اپ جدا نیست.

خریدار: جستجو، موقعیت، فروشگاه نزدیک، موجودی/قیمت، درخواست کالا، چت و خرید.
فروشنده: فروشگاه، کالا، قیمت، موجودی، درخواست مشتری و گزارش.
معرف: کد معرفی، معرفی‌ها، پورسانت، دفتر تراکنش، کیف پول و برداشت.

محاسبه و ثبت پورسانت فقط در backend انجام می‌شود.

## Backend
مسیرهای اصلی backend فعلی:
- /api/auth/send-otp
- /api/auth/verify-otp
- /api/auth/me
- /api/products
- /api/stores
- /api/messages
- /api/referral/stats
- /api/referral/transactions
- /api/referral/withdraw
- /api/referral/apply

احراز هویت وب‌سایت فعلاً HttpOnly cookie است. برای موبایل باید قرارداد session/token مخصوص mobile در backend نهایی شود.

## اجرا
flutter pub get
flutter run --dart-define=KIDAREH_API_URL=https://YOUR-DOMAIN/api

## اصل توسعه
UI → Controller/Notifier → Repository → API Client → Backend
