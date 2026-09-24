import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phone = TextEditingController();
  final code = TextEditingController();
  bool sent = false, busy = false;
  String? error;

  @override
  void dispose() { phone.dispose(); code.dispose(); super.dispose(); }

  String _errorMessage(Object e) {
    if (e is FormatException) return e.message.toString();
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
    }
    return 'ارتباط با سرور برقرار نشد. دوباره تلاش کن.';
  }

  Future<void> submit() async {
    if (busy) return;
    FocusScope.of(context).unfocus();
    setState(() { busy = true; error = null; });
    try {
      final repo = ref.read(authRepositoryProvider);
      if (!sent) {
        await repo.sendOtp(phone.text.trim());
        if (!mounted) return;
        setState(() => sent = true);
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        final r = await repo.verifyOtp(phone.text.trim(), code.text.trim());
        final rawUser = r['user'];
        if (rawUser is! Map) throw const FormatException('اطلاعات کاربر در پاسخ ورود نامعتبر است');
        await ref.read(authControllerProvider.notifier).setUser(Map<String, dynamic>.from(rawUser));
        if (!mounted) return;
        final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
        context.go(redirect != null && redirect.startsWith('/') ? redirect : '/');
      }
    } catch (e) {
      if (mounted) setState(() => error = _errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void editPhone() {
    if (busy) return;
    code.clear();
    setState(() { sent = false; error = null; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ورود به کی‌داره')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('با شماره موبایل وارد شوید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      TextField(controller: phone, enabled: !sent && !busy, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'شماره موبایل', hintText: '09123456789')),
      if (sent) ...[
        const SizedBox(height: 12),
        TextField(controller: code, enabled: !busy, autofocus: true, keyboardType: TextInputType.number, textInputAction: TextInputAction.done, maxLength: 5, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'کد تأیید', hintText: 'کد ۵ رقمی'),),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: busy ? null : editPhone, child: const Text('ویرایش شماره'))),
      ],
      if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 16),
      FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'در حال پردازش...' : sent ? 'ورود' : 'دریافت کد تأیید')),
    ]),
  );
}