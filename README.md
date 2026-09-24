# Kidareh Flutter

همراه سبک موبایل برای سایت [کی‌داره](https://github.com/Tahmoures54/kidareh).

وب منبع حقیقت است. این اپ نقشه، چت، AI، پرداخت و سیستم معرفی را کپی نمی‌کند.

## داخل اپ

- ورود OTP موبایل (Bearer token)
- جستجوی کالا و جزئیات کالا/فروشگاه
- تماس و مسیریابی با اپ سیستم
- مدیریت ساده کالای فروشنده
- پروفایل و خروج

## بیرون اپ (فقط سایت)

نقشه، چت، دستیار هوشمند، پرداخت، تیکت، ادمین، پروموشن و **رفرال/کیف پول**

https://kidareh.com

## معماری

- Flutter + Material 3 + RTL
- Riverpod + GoRouter + Dio
- Flutter Secure Storage
- بک‌اند مشترک با وب

UI → Controller/Notifier → Repository → API Client → Backend

## اجرا

```bash
flutter pub get
flutter run --dart-define=KIDAREH_API_URL=https://kidareh.com/api --dart-define=KIDAREH_WEB_URL=https://kidareh.com
```

اگر پوشه‌های پلتفرم نیست:

```bash
flutter create . --project-name kidareh_flutter
```
