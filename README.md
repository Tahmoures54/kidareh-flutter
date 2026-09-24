# Kidareh Flutter

همراه سبک موبایل برای سایت [کی‌داره](https://github.com/Tahmoures54/kidareh).

وب منبع حقیقت است. این اپ نقشه، چت زنده، AI و پرداخت را کپی نمی‌کند. فقط کارهای پرتکرار روی گوشی را بدون مرورگر تمام می‌کند و بقیه را به سایت می‌سپارد.

## چه داخل اپ است

- ورود OTP موبایل (توکن Bearer، جدا از کوکی وب)
- جستجوی کالا، جزئیات کالا و فروشگاه
- تماس و مسیریابی با اپ سیستم
- مدیریت ساده کالای فروشنده
- نمایش کد معرفی و موجودی کیف پول

## چه داخل اپ نیست

نقشه، چت Socket.IO، دستیار Gemini، پرداخت، تیکت، پنل ادمین و پروموشن فقط در سایت:

https://kidareh.com

## معماری

- Flutter + Material 3 + RTL
- Riverpod + GoRouter + Dio
- Flutter Secure Storage برای توکن موبایل
- ساختار feature-first
- بک‌اند مشترک با وب

جریان طبقات: UI → Controller/Notifier → Repository → API Client → Backend

## اجرا

```bash
flutter pub get
flutter run --dart-define=KIDAREH_API_URL=https://kidareh.com/api --dart-define=KIDAREH_WEB_URL=https://kidareh.com
```

اگر پوشه‌های `android/` یا `ios/` در کلون نیست:

```bash
flutter create . --project-name kidareh_flutter
```

## احراز هویت

وب با HttpOnly cookie کار می‌کند. موبایل باید همیشه هدر `X-Kidareh-Client: mobile` و Bearer token را از بک‌اند بگیرد.
