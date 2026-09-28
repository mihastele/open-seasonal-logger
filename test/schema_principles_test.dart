import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// Guards the product principles that are about what the data model must NOT
/// contain. These tests fail if someone adds a scored/quantified field.
void main() {
  test('principle 3: the schema has no scoring, streak, or XP fields',
      () async {
    final db = newTestDatabase();
    addTearDown(db.close);

    final columnNames =
        db.seasons.$columns.map((c) => c.name).toList(growable: false);

    const forbidden = [
      'score',
      'xp',
      'streak',
      'points',
      'level',
      'rank',
      'progress',
      'efficiency',
    ];
    for (final name in columnNames) {
      for (final word in forbidden) {
        expect(
          name.toLowerCase().contains(word),
          isFalse,
          reason: 'Column "$name" looks like a scoring/quantified field.',
        );
      }
    }
  });

  test('principle 4: the season table has exactly three reflection fields',
      () async {
    final db = newTestDatabase();
    addTearDown(db.close);

    final reflectionFields = db.seasons.$columns
        .map((c) => c.name)
        .where((name) => name.startsWith('reflection'))
        .toList();

    expect(reflectionFields, hasLength(3));
    expect(
      reflectionFields.toSet(),
      {
        'reflection_made',
        'reflection_learned',
        'reflection_return_someday',
      },
    );
  });
}
