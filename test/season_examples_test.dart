import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/domain/season_examples.dart';

void main() {
  test('there are 40 examples to rotate through', () {
    expect(seasonExamples, hasLength(40));
  });

  test('every example has a unique, non-empty title and description', () {
    final titles = <String>{};
    for (final example in seasonExamples) {
      expect(example.title.trim(), isNotEmpty);
      expect(example.description.trim(), isNotEmpty);
      expect(
        titles.add(example.title),
        isTrue,
        reason: 'Duplicate example title: "${example.title}".',
      );
    }
  });

  test('principle 3: example copy has no scoring, quota, or guilt language',
      () {
    // Word-boundary matching: "explore" must not trip the "xp" rule.
    final forbidden = RegExp(
      r'\b(score|xp|streak|points|levels?|rank|progress|efficiency|'
      r'master(y|ed)?|fluent|perfect|discipline|habits?|daily|weekly|'
      r'goals?|targets?|deadline|behind|fail(ed|ure)?)\b',
      caseSensitive: false,
    );
    for (final example in seasonExamples) {
      for (final text in [example.title, example.description]) {
        expect(
          forbidden.hasMatch(text),
          isFalse,
          reason: 'Example copy "$text" sounds scored or pressuring.',
        );
      }
    }
  });

  test('randomSeasonExample returns members of the list', () {
    final picked = randomSeasonExample(Random(7));
    expect(seasonExamples, contains(picked));
  });

  test('back-to-back picks never repeat', () {
    // True by construction, whatever the random source does.
    final first = randomSeasonExample(Random(1));
    final second = randomSeasonExample(Random(1));
    expect(second, isNot(same(first)));
  });
}
