import 'dart:math';

/// Utility to generate passwords.
///
/// Default uses `Random.secure()` for better entropy. For tests pass a
/// deterministic `Random(seed)` instance.
class PasswordGenerator {
  PasswordGenerator._();

  static String generate({
    required int length,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    Random? random,
  }) {
    final rnd = random ?? Random.secure();

    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const nums = '0123456789';
    const syms = '!@#\u0024%^&*()-_=+[]{}|;:\'",.<>?/~';

    final buffers = <String>[];
    if (includeUppercase) buffers.add(upper);
    if (includeLowercase) buffers.add(lower);
    if (includeNumbers) buffers.add(nums);
    if (includeSymbols) buffers.add(syms);

    if (buffers.isEmpty) return '';

    final all = buffers.join();
    final result = StringBuffer();
    for (var i = 0; i < length; i++) {
      result.write(all[rnd.nextInt(all.length)]);
    }
    return result.toString();
  }
}
