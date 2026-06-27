// ==========================================
// integration_test/app_test.dart
// ==========================================
// ວິທີ Run: flutter test integration_test/app_test.dart
// ຕ້ອງໃສ່ pubspec.yaml:
//   dev_dependencies:
//     integration_test:
//       sdk: flutter
//     flutter_test:
//       sdk: flutter

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phanukngan/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PHANUKNGAN Integration Tests', () {

    // ==========================================
    // TEST 1: Splash Screen
    // ==========================================
    testWidgets('Splash — Logo ແລະ Animation ປາກົດ', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ກວດ Logo text
      expect(find.text('PHANUKNGAN'), findsWidgets);
      expect(find.text('ພະນັກງານ'),   findsWidgets);

      // ລໍຖ້າ Splash ຜ່ານ (3 ວິ)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    // ==========================================
    // TEST 2: Login Screen
    // ==========================================
    testWidgets('Login — Form Validation ພາສາລາວ', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // ເຂົ້າ Login Screen
      expect(find.text('ເຂົ້າສູ່ລະບົບ'), findsWidgets);

      // ກົດ Submit ໂດຍບໍ່ໃສ່ຫຍັງ → ຕ້ອງ Error
      final loginBtn = find.text('ເຂົ້າສູ່ລະບົບ').last;
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // ກວດ Error Message ລາວ
      expect(find.text('ໃສ່ Email ກ່ອນ'), findsOneWidget);
    });

    testWidgets('Login — Email Format Validation', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // ໃສ່ Email ຜິດຮູບແບບ
      await tester.enterText(find.byType(TextField).first, 'notanemail');
      await tester.tap(find.text('ເຂົ້າສູ່ລະບົບ').last);
      await tester.pumpAndSettle();

      expect(find.text('Email ບໍ່ຖືກຮູບແບບ'), findsOneWidget);
    });

    // ==========================================
    // TEST 3: Home Dashboard
    // ==========================================
    testWidgets('Home — Stats Cards ປາກົດ', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ໃສ່ Credentials ທົດສອບ (ຕ້ອງສ້າງ test account ໃນ Supabase)
      await tester.enterText(find.byType(TextField).first,  'test@phanukngan.la');
      await tester.enterText(find.byType(TextField).last,   'test123456');
      await tester.tap(find.text('ເຂົ້າສູ່ລະບົບ').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ກວດ Dashboard
      expect(find.text('ວຽກທັງໝົດ'), findsWidgets);
      expect(find.text('ສ້າງວຽກໃໝ່'), findsWidgets);
      expect(find.text('ວຽກລ່າສຸດ'),  findsWidgets);
    });

    // ==========================================
    // TEST 4: Navigation
    // ==========================================
    testWidgets('Navigation — Bottom Nav ທຳງານ', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // ກົດ Chat Tab
      await tester.tap(find.text('ສົນທະນາ'));
      await tester.pumpAndSettle();
      expect(find.text('PHANUKNGAN AI'), findsWidgets);

      // ກົດ ທີມງານ Tab
      await tester.tap(find.text('ທີມງານ'));
      await tester.pumpAndSettle();
      expect(find.text('ທີມງານ 100 ຄົນ'), findsWidgets);
    });

    // ==========================================
    // TEST 5: Lao Text
    // ==========================================
    testWidgets('ພາສາລາວ — ຕົວໜັງສືຖືກຕ້ອງທຸກໜ້າ', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // ກວດຄຳສຳຄັນລາວ
      final laoWords = [
        'ໜ້າຫຼັກ', 'ສົນທະນາ', 'ຜົນງານ', 'ທີມງານ',
      ];
      for (final word in laoWords) {
        expect(find.text(word), findsWidgets,
          reason: 'ຄຳລາວ "$word" ຕ້ອງປາກົດ');
      }
    });
  });
}
