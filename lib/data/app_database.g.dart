// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SeasonsTable extends Seasons with TableInfo<$SeasonsTable, Season> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SeasonStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SeasonStatus>($SeasonsTable.$converterstatus);
  static const VerificationMeta _reflectionMadeMeta = const VerificationMeta(
    'reflectionMade',
  );
  @override
  late final GeneratedColumn<String> reflectionMade = GeneratedColumn<String>(
    'reflection_made',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reflectionLearnedMeta = const VerificationMeta(
    'reflectionLearned',
  );
  @override
  late final GeneratedColumn<String> reflectionLearned =
      GeneratedColumn<String>(
        'reflection_learned',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reflectionReturnSomedayMeta =
      const VerificationMeta('reflectionReturnSomeday');
  @override
  late final GeneratedColumn<String> reflectionReturnSomeday =
      GeneratedColumn<String>(
        'reflection_return_someday',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    startDate,
    durationWeeks,
    status,
    reflectionMade,
    reflectionLearned,
    reflectionReturnSomeday,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Season> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationWeeksMeta);
    }
    if (data.containsKey('reflection_made')) {
      context.handle(
        _reflectionMadeMeta,
        reflectionMade.isAcceptableOrUnknown(
          data['reflection_made']!,
          _reflectionMadeMeta,
        ),
      );
    }
    if (data.containsKey('reflection_learned')) {
      context.handle(
        _reflectionLearnedMeta,
        reflectionLearned.isAcceptableOrUnknown(
          data['reflection_learned']!,
          _reflectionLearnedMeta,
        ),
      );
    }
    if (data.containsKey('reflection_return_someday')) {
      context.handle(
        _reflectionReturnSomedayMeta,
        reflectionReturnSomeday.isAcceptableOrUnknown(
          data['reflection_return_someday']!,
          _reflectionReturnSomedayMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Season map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Season(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      )!,
      status: $SeasonsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      reflectionMade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_made'],
      ),
      reflectionLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_learned'],
      ),
      reflectionReturnSomeday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_return_someday'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SeasonsTable createAlias(String alias) {
    return $SeasonsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SeasonStatus, String, String> $converterstatus =
      const EnumNameConverter<SeasonStatus>(SeasonStatus.values);
}

class Season extends DataClass implements Insertable<Season> {
  final int id;
  final String title;
  final String? description;
  final DateTime startDate;
  final int durationWeeks;
  final SeasonStatus status;
  final String? reflectionMade;
  final String? reflectionLearned;
  final String? reflectionReturnSomeday;
  final DateTime createdAt;
  const Season({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.durationWeeks,
    required this.status,
    this.reflectionMade,
    this.reflectionLearned,
    this.reflectionReturnSomeday,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['duration_weeks'] = Variable<int>(durationWeeks);
    {
      map['status'] = Variable<String>(
        $SeasonsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || reflectionMade != null) {
      map['reflection_made'] = Variable<String>(reflectionMade);
    }
    if (!nullToAbsent || reflectionLearned != null) {
      map['reflection_learned'] = Variable<String>(reflectionLearned);
    }
    if (!nullToAbsent || reflectionReturnSomeday != null) {
      map['reflection_return_someday'] = Variable<String>(
        reflectionReturnSomeday,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SeasonsCompanion toCompanion(bool nullToAbsent) {
    return SeasonsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      durationWeeks: Value(durationWeeks),
      status: Value(status),
      reflectionMade: reflectionMade == null && nullToAbsent
          ? const Value.absent()
          : Value(reflectionMade),
      reflectionLearned: reflectionLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(reflectionLearned),
      reflectionReturnSomeday: reflectionReturnSomeday == null && nullToAbsent
          ? const Value.absent()
          : Value(reflectionReturnSomeday),
      createdAt: Value(createdAt),
    );
  }

  factory Season.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Season(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      durationWeeks: serializer.fromJson<int>(json['durationWeeks']),
      status: $SeasonsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      reflectionMade: serializer.fromJson<String?>(json['reflectionMade']),
      reflectionLearned: serializer.fromJson<String?>(
        json['reflectionLearned'],
      ),
      reflectionReturnSomeday: serializer.fromJson<String?>(
        json['reflectionReturnSomeday'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime>(startDate),
      'durationWeeks': serializer.toJson<int>(durationWeeks),
      'status': serializer.toJson<String>(
        $SeasonsTable.$converterstatus.toJson(status),
      ),
      'reflectionMade': serializer.toJson<String?>(reflectionMade),
      'reflectionLearned': serializer.toJson<String?>(reflectionLearned),
      'reflectionReturnSomeday': serializer.toJson<String?>(
        reflectionReturnSomeday,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Season copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? startDate,
    int? durationWeeks,
    SeasonStatus? status,
    Value<String?> reflectionMade = const Value.absent(),
    Value<String?> reflectionLearned = const Value.absent(),
    Value<String?> reflectionReturnSomeday = const Value.absent(),
    DateTime? createdAt,
  }) => Season(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    startDate: startDate ?? this.startDate,
    durationWeeks: durationWeeks ?? this.durationWeeks,
    status: status ?? this.status,
    reflectionMade: reflectionMade.present
        ? reflectionMade.value
        : this.reflectionMade,
    reflectionLearned: reflectionLearned.present
        ? reflectionLearned.value
        : this.reflectionLearned,
    reflectionReturnSomeday: reflectionReturnSomeday.present
        ? reflectionReturnSomeday.value
        : this.reflectionReturnSomeday,
    createdAt: createdAt ?? this.createdAt,
  );
  Season copyWithCompanion(SeasonsCompanion data) {
    return Season(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      durationWeeks: data.durationWeeks.present
          ? data.durationWeeks.value
          : this.durationWeeks,
      status: data.status.present ? data.status.value : this.status,
      reflectionMade: data.reflectionMade.present
          ? data.reflectionMade.value
          : this.reflectionMade,
      reflectionLearned: data.reflectionLearned.present
          ? data.reflectionLearned.value
          : this.reflectionLearned,
      reflectionReturnSomeday: data.reflectionReturnSomeday.present
          ? data.reflectionReturnSomeday.value
          : this.reflectionReturnSomeday,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Season(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('status: $status, ')
          ..write('reflectionMade: $reflectionMade, ')
          ..write('reflectionLearned: $reflectionLearned, ')
          ..write('reflectionReturnSomeday: $reflectionReturnSomeday, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    startDate,
    durationWeeks,
    status,
    reflectionMade,
    reflectionLearned,
    reflectionReturnSomeday,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Season &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.durationWeeks == this.durationWeeks &&
          other.status == this.status &&
          other.reflectionMade == this.reflectionMade &&
          other.reflectionLearned == this.reflectionLearned &&
          other.reflectionReturnSomeday == this.reflectionReturnSomeday &&
          other.createdAt == this.createdAt);
}

class SeasonsCompanion extends UpdateCompanion<Season> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> startDate;
  final Value<int> durationWeeks;
  final Value<SeasonStatus> status;
  final Value<String?> reflectionMade;
  final Value<String?> reflectionLearned;
  final Value<String?> reflectionReturnSomeday;
  final Value<DateTime> createdAt;
  const SeasonsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.status = const Value.absent(),
    this.reflectionMade = const Value.absent(),
    this.reflectionLearned = const Value.absent(),
    this.reflectionReturnSomeday = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SeasonsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime startDate,
    required int durationWeeks,
    required SeasonStatus status,
    this.reflectionMade = const Value.absent(),
    this.reflectionLearned = const Value.absent(),
    this.reflectionReturnSomeday = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       startDate = Value(startDate),
       durationWeeks = Value(durationWeeks),
       status = Value(status);
  static Insertable<Season> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<int>? durationWeeks,
    Expression<String>? status,
    Expression<String>? reflectionMade,
    Expression<String>? reflectionLearned,
    Expression<String>? reflectionReturnSomeday,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (status != null) 'status': status,
      if (reflectionMade != null) 'reflection_made': reflectionMade,
      if (reflectionLearned != null) 'reflection_learned': reflectionLearned,
      if (reflectionReturnSomeday != null)
        'reflection_return_someday': reflectionReturnSomeday,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SeasonsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? startDate,
    Value<int>? durationWeeks,
    Value<SeasonStatus>? status,
    Value<String?>? reflectionMade,
    Value<String?>? reflectionLearned,
    Value<String?>? reflectionReturnSomeday,
    Value<DateTime>? createdAt,
  }) {
    return SeasonsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      status: status ?? this.status,
      reflectionMade: reflectionMade ?? this.reflectionMade,
      reflectionLearned: reflectionLearned ?? this.reflectionLearned,
      reflectionReturnSomeday:
          reflectionReturnSomeday ?? this.reflectionReturnSomeday,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SeasonsTable.$converterstatus.toSql(status.value),
      );
    }
    if (reflectionMade.present) {
      map['reflection_made'] = Variable<String>(reflectionMade.value);
    }
    if (reflectionLearned.present) {
      map['reflection_learned'] = Variable<String>(reflectionLearned.value);
    }
    if (reflectionReturnSomeday.present) {
      map['reflection_return_someday'] = Variable<String>(
        reflectionReturnSomeday.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeasonsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('status: $status, ')
          ..write('reflectionMade: $reflectionMade, ')
          ..write('reflectionLearned: $reflectionLearned, ')
          ..write('reflectionReturnSomeday: $reflectionReturnSomeday, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SeasonsTable seasons = $SeasonsTable(this);
  late final Index seasonsStartDate = Index(
    'seasons_start_date',
    'CREATE INDEX seasons_start_date ON seasons (start_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    seasons,
    seasonsStartDate,
  ];
}

typedef $$SeasonsTableCreateCompanionBuilder = SeasonsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required DateTime startDate,
  required int durationWeeks,
  required SeasonStatus status,
  Value<String?> reflectionMade,
  Value<String?> reflectionLearned,
  Value<String?> reflectionReturnSomeday,
  Value<DateTime> createdAt,
});
typedef $$SeasonsTableUpdateCompanionBuilder = SeasonsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> startDate,
  Value<int> durationWeeks,
  Value<SeasonStatus> status,
  Value<String?> reflectionMade,
  Value<String?> reflectionLearned,
  Value<String?> reflectionReturnSomeday,
  Value<DateTime> createdAt,
});

class $$SeasonsTableFilterComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SeasonStatus, SeasonStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reflectionMade => $composableBuilder(
    column: $table.reflectionMade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionLearned => $composableBuilder(
    column: $table.reflectionLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionReturnSomeday => $composableBuilder(
    column: $table.reflectionReturnSomeday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeasonsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionMade => $composableBuilder(
    column: $table.reflectionMade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionLearned => $composableBuilder(
    column: $table.reflectionLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionReturnSomeday => $composableBuilder(
    column: $table.reflectionReturnSomeday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeasonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SeasonStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reflectionMade => $composableBuilder(
    column: $table.reflectionMade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflectionLearned => $composableBuilder(
    column: $table.reflectionLearned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflectionReturnSomeday => $composableBuilder(
    column: $table.reflectionReturnSomeday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SeasonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeasonsTable,
          Season,
          $$SeasonsTableFilterComposer,
          $$SeasonsTableOrderingComposer,
          $$SeasonsTableAnnotationComposer,
          $$SeasonsTableCreateCompanionBuilder,
          $$SeasonsTableUpdateCompanionBuilder,
          (Season, BaseReferences<_$AppDatabase, $SeasonsTable, Season>),
          Season,
          PrefetchHooks Function()
        > {
  $$SeasonsTableTableManager(_$AppDatabase db, $SeasonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> durationWeeks = const Value.absent(),
                Value<SeasonStatus> status = const Value.absent(),
                Value<String?> reflectionMade = const Value.absent(),
                Value<String?> reflectionLearned = const Value.absent(),
                Value<String?> reflectionReturnSomeday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SeasonsCompanion(
                id: id,
                title: title,
                description: description,
                startDate: startDate,
                durationWeeks: durationWeeks,
                status: status,
                reflectionMade: reflectionMade,
                reflectionLearned: reflectionLearned,
                reflectionReturnSomeday: reflectionReturnSomeday,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime startDate,
                required int durationWeeks,
                required SeasonStatus status,
                Value<String?> reflectionMade = const Value.absent(),
                Value<String?> reflectionLearned = const Value.absent(),
                Value<String?> reflectionReturnSomeday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SeasonsCompanion.insert(
                id: id,
                title: title,
                description: description,
                startDate: startDate,
                durationWeeks: durationWeeks,
                status: status,
                reflectionMade: reflectionMade,
                reflectionLearned: reflectionLearned,
                reflectionReturnSomeday: reflectionReturnSomeday,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeasonsTable, Season>(table),
                  BaseReferences<_$AppDatabase, $SeasonsTable, Season>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeasonsTable,
      Season,
      $$SeasonsTableFilterComposer,
      $$SeasonsTableOrderingComposer,
      $$SeasonsTableAnnotationComposer,
      $$SeasonsTableCreateCompanionBuilder,
      $$SeasonsTableUpdateCompanionBuilder,
      (Season, BaseReferences<_$AppDatabase, $SeasonsTable, Season>),
      Season,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SeasonsTableTableManager get seasons =>
      $$SeasonsTableTableManager(_db, _db.seasons);
}
