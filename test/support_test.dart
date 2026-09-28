import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/support_repository.dart';

import 'test_database.dart';

void main() {
  test('the support footer is off by default', () async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = SupportRepository(db);

    expect((await repo.get()).showFooter, isFalse);
  });

  test('the support footer preference can be toggled and read back', () async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = SupportRepository(db);

    await repo.setShowFooter(true);
    expect((await repo.get()).showFooter, isTrue);

    await repo.setShowFooter(false);
    expect((await repo.get()).showFooter, isFalse);
  });

  test('the coffee link points at the expected https URL', () {
    expect(SupportRepository.coffeeUrl, 'https://buymeacoffee.com/mihastele');
    expect(Uri.parse(SupportRepository.coffeeUrl).scheme, 'https');
  });
}
