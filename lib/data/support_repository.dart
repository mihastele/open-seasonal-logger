import 'package:drift/drift.dart';
import 'package:seasonal/data/app_database.dart';

/// The optional "buy me a coffee" support link.
///
/// This is not a shop, a subscription, or a nudge. It is a single, quiet link
/// at the foot of the home screen, off by default, that the user can hide
/// again at any time.
class SupportRepository {
  static const String coffeeUrl = 'https://buymeacoffee.com/mihastele';

  final AppDatabase db;
  SupportRepository(this.db);

  Stream<SupportSetting> watch() {
    return (db.select(db.supportSettings)..limit(1)).watchSingle();
  }

  Future<SupportSetting> get() {
    return (db.select(db.supportSettings)..limit(1)).getSingle();
  }

  Future<void> setShowFooter(bool show) {
    return (db.update(db.supportSettings)).write(
      SupportSettingsCompanion(showFooter: Value(show)),
    );
  }
}
