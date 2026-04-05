// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ObligationsTable extends Obligations
    with TableInfo<$ObligationsTable, Obligation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObligationsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ObligationType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ObligationType>($ObligationsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emiDurationMonthsMeta = const VerificationMeta(
    'emiDurationMonths',
  );
  @override
  late final GeneratedColumn<int> emiDurationMonths = GeneratedColumn<int>(
    'emi_duration_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gracePeriodDaysMeta = const VerificationMeta(
    'gracePeriodDays',
  );
  @override
  late final GeneratedColumn<int> gracePeriodDays = GeneratedColumn<int>(
    'grace_period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emiPaidMonthsMeta = const VerificationMeta(
    'emiPaidMonths',
  );
  @override
  late final GeneratedColumn<int> emiPaidMonths = GeneratedColumn<int>(
    'emi_paid_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PriorityLevel, int> priority =
      GeneratedColumn<int>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<PriorityLevel>($ObligationsTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<ObligationStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<ObligationStatus>($ObligationsTable.$converterstatus);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalBalanceMeta = const VerificationMeta(
    'totalBalance',
  );
  @override
  late final GeneratedColumn<double> totalBalance = GeneratedColumn<double>(
    'total_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    amount,
    startDate,
    endDate,
    emiDurationMonths,
    gracePeriodDays,
    emiPaidMonths,
    priority,
    status,
    category,
    notes,
    nextDueDate,
    totalBalance,
    interestRate,
    isActive,
    createdAt,
    updatedAt,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obligations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Obligation> instance, {
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('emi_duration_months')) {
      context.handle(
        _emiDurationMonthsMeta,
        emiDurationMonths.isAcceptableOrUnknown(
          data['emi_duration_months']!,
          _emiDurationMonthsMeta,
        ),
      );
    }
    if (data.containsKey('grace_period_days')) {
      context.handle(
        _gracePeriodDaysMeta,
        gracePeriodDays.isAcceptableOrUnknown(
          data['grace_period_days']!,
          _gracePeriodDaysMeta,
        ),
      );
    }
    if (data.containsKey('emi_paid_months')) {
      context.handle(
        _emiPaidMonthsMeta,
        emiPaidMonths.isAcceptableOrUnknown(
          data['emi_paid_months']!,
          _emiPaidMonthsMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('total_balance')) {
      context.handle(
        _totalBalanceMeta,
        totalBalance.isAcceptableOrUnknown(
          data['total_balance']!,
          _totalBalanceMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Obligation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Obligation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: $ObligationsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      emiDurationMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emi_duration_months'],
      ),
      gracePeriodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grace_period_days'],
      )!,
      emiPaidMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emi_paid_months'],
      )!,
      priority: $ObligationsTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}priority'],
        )!,
      ),
      status: $ObligationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      ),
      totalBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_balance'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $ObligationsTable createAlias(String alias) {
    return $ObligationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ObligationType, int, int> $convertertype =
      const EnumIndexConverter<ObligationType>(ObligationType.values);
  static JsonTypeConverter2<PriorityLevel, int, int> $converterpriority =
      const EnumIndexConverter<PriorityLevel>(PriorityLevel.values);
  static JsonTypeConverter2<ObligationStatus, int, int> $converterstatus =
      const EnumIndexConverter<ObligationStatus>(ObligationStatus.values);
}

class Obligation extends DataClass implements Insertable<Obligation> {
  final int id;
  final String title;
  final ObligationType type;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final int? emiDurationMonths;
  final int gracePeriodDays;
  final int emiPaidMonths;
  final PriorityLevel priority;
  final ObligationStatus status;
  final String category;
  final String? notes;
  final DateTime? nextDueDate;
  final double totalBalance;
  final double interestRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayOrder;
  const Obligation({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.startDate,
    this.endDate,
    this.emiDurationMonths,
    required this.gracePeriodDays,
    required this.emiPaidMonths,
    required this.priority,
    required this.status,
    required this.category,
    this.notes,
    this.nextDueDate,
    required this.totalBalance,
    required this.interestRate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['type'] = Variable<int>($ObligationsTable.$convertertype.toSql(type));
    }
    map['amount'] = Variable<double>(amount);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || emiDurationMonths != null) {
      map['emi_duration_months'] = Variable<int>(emiDurationMonths);
    }
    map['grace_period_days'] = Variable<int>(gracePeriodDays);
    map['emi_paid_months'] = Variable<int>(emiPaidMonths);
    {
      map['priority'] = Variable<int>(
        $ObligationsTable.$converterpriority.toSql(priority),
      );
    }
    {
      map['status'] = Variable<int>(
        $ObligationsTable.$converterstatus.toSql(status),
      );
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    map['total_balance'] = Variable<double>(totalBalance);
    map['interest_rate'] = Variable<double>(interestRate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  ObligationsCompanion toCompanion(bool nullToAbsent) {
    return ObligationsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      amount: Value(amount),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      emiDurationMonths: emiDurationMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(emiDurationMonths),
      gracePeriodDays: Value(gracePeriodDays),
      emiPaidMonths: Value(emiPaidMonths),
      priority: Value(priority),
      status: Value(status),
      category: Value(category),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      totalBalance: Value(totalBalance),
      interestRate: Value(interestRate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      displayOrder: Value(displayOrder),
    );
  }

  factory Obligation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Obligation(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: $ObligationsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      amount: serializer.fromJson<double>(json['amount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      emiDurationMonths: serializer.fromJson<int?>(json['emiDurationMonths']),
      gracePeriodDays: serializer.fromJson<int>(json['gracePeriodDays']),
      emiPaidMonths: serializer.fromJson<int>(json['emiPaidMonths']),
      priority: $ObligationsTable.$converterpriority.fromJson(
        serializer.fromJson<int>(json['priority']),
      ),
      status: $ObligationsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      category: serializer.fromJson<String>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      totalBalance: serializer.fromJson<double>(json['totalBalance']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<int>(
        $ObligationsTable.$convertertype.toJson(type),
      ),
      'amount': serializer.toJson<double>(amount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'emiDurationMonths': serializer.toJson<int?>(emiDurationMonths),
      'gracePeriodDays': serializer.toJson<int>(gracePeriodDays),
      'emiPaidMonths': serializer.toJson<int>(emiPaidMonths),
      'priority': serializer.toJson<int>(
        $ObligationsTable.$converterpriority.toJson(priority),
      ),
      'status': serializer.toJson<int>(
        $ObligationsTable.$converterstatus.toJson(status),
      ),
      'category': serializer.toJson<String>(category),
      'notes': serializer.toJson<String?>(notes),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'totalBalance': serializer.toJson<double>(totalBalance),
      'interestRate': serializer.toJson<double>(interestRate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  Obligation copyWith({
    int? id,
    String? title,
    ObligationType? type,
    double? amount,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> emiDurationMonths = const Value.absent(),
    int? gracePeriodDays,
    int? emiPaidMonths,
    PriorityLevel? priority,
    ObligationStatus? status,
    String? category,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> nextDueDate = const Value.absent(),
    double? totalBalance,
    double? interestRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayOrder,
  }) => Obligation(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    emiDurationMonths: emiDurationMonths.present
        ? emiDurationMonths.value
        : this.emiDurationMonths,
    gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
    emiPaidMonths: emiPaidMonths ?? this.emiPaidMonths,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    category: category ?? this.category,
    notes: notes.present ? notes.value : this.notes,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    totalBalance: totalBalance ?? this.totalBalance,
    interestRate: interestRate ?? this.interestRate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  Obligation copyWithCompanion(ObligationsCompanion data) {
    return Obligation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      emiDurationMonths: data.emiDurationMonths.present
          ? data.emiDurationMonths.value
          : this.emiDurationMonths,
      gracePeriodDays: data.gracePeriodDays.present
          ? data.gracePeriodDays.value
          : this.gracePeriodDays,
      emiPaidMonths: data.emiPaidMonths.present
          ? data.emiPaidMonths.value
          : this.emiPaidMonths,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      totalBalance: data.totalBalance.present
          ? data.totalBalance.value
          : this.totalBalance,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Obligation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('emiDurationMonths: $emiDurationMonths, ')
          ..write('gracePeriodDays: $gracePeriodDays, ')
          ..write('emiPaidMonths: $emiPaidMonths, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('totalBalance: $totalBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    amount,
    startDate,
    endDate,
    emiDurationMonths,
    gracePeriodDays,
    emiPaidMonths,
    priority,
    status,
    category,
    notes,
    nextDueDate,
    totalBalance,
    interestRate,
    isActive,
    createdAt,
    updatedAt,
    displayOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Obligation &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.emiDurationMonths == this.emiDurationMonths &&
          other.gracePeriodDays == this.gracePeriodDays &&
          other.emiPaidMonths == this.emiPaidMonths &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.nextDueDate == this.nextDueDate &&
          other.totalBalance == this.totalBalance &&
          other.interestRate == this.interestRate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.displayOrder == this.displayOrder);
}

class ObligationsCompanion extends UpdateCompanion<Obligation> {
  final Value<int> id;
  final Value<String> title;
  final Value<ObligationType> type;
  final Value<double> amount;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> emiDurationMonths;
  final Value<int> gracePeriodDays;
  final Value<int> emiPaidMonths;
  final Value<PriorityLevel> priority;
  final Value<ObligationStatus> status;
  final Value<String> category;
  final Value<String?> notes;
  final Value<DateTime?> nextDueDate;
  final Value<double> totalBalance;
  final Value<double> interestRate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> displayOrder;
  const ObligationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.emiDurationMonths = const Value.absent(),
    this.gracePeriodDays = const Value.absent(),
    this.emiPaidMonths = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.totalBalance = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  ObligationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required ObligationType type,
    required double amount,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.emiDurationMonths = const Value.absent(),
    this.gracePeriodDays = const Value.absent(),
    this.emiPaidMonths = const Value.absent(),
    required PriorityLevel priority,
    this.status = const Value.absent(),
    required String category,
    this.notes = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.totalBalance = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.displayOrder = const Value.absent(),
  }) : title = Value(title),
       type = Value(type),
       amount = Value(amount),
       startDate = Value(startDate),
       priority = Value(priority),
       category = Value(category);
  static Insertable<Obligation> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? type,
    Expression<double>? amount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? emiDurationMonths,
    Expression<int>? gracePeriodDays,
    Expression<int>? emiPaidMonths,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<DateTime>? nextDueDate,
    Expression<double>? totalBalance,
    Expression<double>? interestRate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (emiDurationMonths != null) 'emi_duration_months': emiDurationMonths,
      if (gracePeriodDays != null) 'grace_period_days': gracePeriodDays,
      if (emiPaidMonths != null) 'emi_paid_months': emiPaidMonths,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (totalBalance != null) 'total_balance': totalBalance,
      if (interestRate != null) 'interest_rate': interestRate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  ObligationsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<ObligationType>? type,
    Value<double>? amount,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? emiDurationMonths,
    Value<int>? gracePeriodDays,
    Value<int>? emiPaidMonths,
    Value<PriorityLevel>? priority,
    Value<ObligationStatus>? status,
    Value<String>? category,
    Value<String?>? notes,
    Value<DateTime?>? nextDueDate,
    Value<double>? totalBalance,
    Value<double>? interestRate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? displayOrder,
  }) {
    return ObligationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      emiDurationMonths: emiDurationMonths ?? this.emiDurationMonths,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      emiPaidMonths: emiPaidMonths ?? this.emiPaidMonths,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      totalBalance: totalBalance ?? this.totalBalance,
      interestRate: interestRate ?? this.interestRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayOrder: displayOrder ?? this.displayOrder,
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
    if (type.present) {
      map['type'] = Variable<int>(
        $ObligationsTable.$convertertype.toSql(type.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (emiDurationMonths.present) {
      map['emi_duration_months'] = Variable<int>(emiDurationMonths.value);
    }
    if (gracePeriodDays.present) {
      map['grace_period_days'] = Variable<int>(gracePeriodDays.value);
    }
    if (emiPaidMonths.present) {
      map['emi_paid_months'] = Variable<int>(emiPaidMonths.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
        $ObligationsTable.$converterpriority.toSql(priority.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $ObligationsTable.$converterstatus.toSql(status.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (totalBalance.present) {
      map['total_balance'] = Variable<double>(totalBalance.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObligationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('emiDurationMonths: $emiDurationMonths, ')
          ..write('gracePeriodDays: $gracePeriodDays, ')
          ..write('emiPaidMonths: $emiPaidMonths, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('totalBalance: $totalBalance, ')
          ..write('interestRate: $interestRate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _obligationIdMeta = const VerificationMeta(
    'obligationId',
  );
  @override
  late final GeneratedColumn<int> obligationId = GeneratedColumn<int>(
    'obligation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES obligations (id)',
    ),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    obligationId,
    amountPaid,
    paidDate,
    paymentType,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('obligation_id')) {
      context.handle(
        _obligationIdMeta,
        obligationId.isAcceptableOrUnknown(
          data['obligation_id']!,
          _obligationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_obligationIdMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      obligationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}obligation_id'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int obligationId;
  final double amountPaid;
  final DateTime paidDate;
  final String paymentType;
  final String? note;
  const Payment({
    required this.id,
    required this.obligationId,
    required this.amountPaid,
    required this.paidDate,
    required this.paymentType,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['obligation_id'] = Variable<int>(obligationId);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['paid_date'] = Variable<DateTime>(paidDate);
    map['payment_type'] = Variable<String>(paymentType);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      obligationId: Value(obligationId),
      amountPaid: Value(amountPaid),
      paidDate: Value(paidDate),
      paymentType: Value(paymentType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      obligationId: serializer.fromJson<int>(json['obligationId']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      paidDate: serializer.fromJson<DateTime>(json['paidDate']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'obligationId': serializer.toJson<int>(obligationId),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'paidDate': serializer.toJson<DateTime>(paidDate),
      'paymentType': serializer.toJson<String>(paymentType),
      'note': serializer.toJson<String?>(note),
    };
  }

  Payment copyWith({
    int? id,
    int? obligationId,
    double? amountPaid,
    DateTime? paidDate,
    String? paymentType,
    Value<String?> note = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    obligationId: obligationId ?? this.obligationId,
    amountPaid: amountPaid ?? this.amountPaid,
    paidDate: paidDate ?? this.paidDate,
    paymentType: paymentType ?? this.paymentType,
    note: note.present ? note.value : this.note,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      obligationId: data.obligationId.present
          ? data.obligationId.value
          : this.obligationId,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('obligationId: $obligationId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('paymentType: $paymentType, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, obligationId, amountPaid, paidDate, paymentType, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.obligationId == this.obligationId &&
          other.amountPaid == this.amountPaid &&
          other.paidDate == this.paidDate &&
          other.paymentType == this.paymentType &&
          other.note == this.note);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> obligationId;
  final Value<double> amountPaid;
  final Value<DateTime> paidDate;
  final Value<String> paymentType;
  final Value<String?> note;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.obligationId = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.note = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int obligationId,
    required double amountPaid,
    this.paidDate = const Value.absent(),
    required String paymentType,
    this.note = const Value.absent(),
  }) : obligationId = Value(obligationId),
       amountPaid = Value(amountPaid),
       paymentType = Value(paymentType);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? obligationId,
    Expression<double>? amountPaid,
    Expression<DateTime>? paidDate,
    Expression<String>? paymentType,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (obligationId != null) 'obligation_id': obligationId,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (paidDate != null) 'paid_date': paidDate,
      if (paymentType != null) 'payment_type': paymentType,
      if (note != null) 'note': note,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? obligationId,
    Value<double>? amountPaid,
    Value<DateTime>? paidDate,
    Value<String>? paymentType,
    Value<String?>? note,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      obligationId: obligationId ?? this.obligationId,
      amountPaid: amountPaid ?? this.amountPaid,
      paidDate: paidDate ?? this.paidDate,
      paymentType: paymentType ?? this.paymentType,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (obligationId.present) {
      map['obligation_id'] = Variable<int>(obligationId.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('obligationId: $obligationId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('paymentType: $paymentType, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _monthlyIncomeMeta = const VerificationMeta(
    'monthlyIncome',
  );
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
    'monthly_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('₹'),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderDaysBeforeMeta =
      const VerificationMeta('reminderDaysBefore');
  @override
  late final GeneratedColumn<int> reminderDaysBefore = GeneratedColumn<int>(
    'reminder_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _paydayOfMonthMeta = const VerificationMeta(
    'paydayOfMonth',
  );
  @override
  late final GeneratedColumn<int> paydayOfMonth = GeneratedColumn<int>(
    'payday_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _projectionMonthsMeta = const VerificationMeta(
    'projectionMonths',
  );
  @override
  late final GeneratedColumn<int> projectionMonths = GeneratedColumn<int>(
    'projection_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paymentStreakMeta = const VerificationMeta(
    'paymentStreak',
  );
  @override
  late final GeneratedColumn<int> paymentStreak = GeneratedColumn<int>(
    'payment_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPaymentDateMeta = const VerificationMeta(
    'lastPaymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPaymentDate =
      GeneratedColumn<DateTime>(
        'last_payment_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthlyIncome,
    currency,
    notificationsEnabled,
    reminderDaysBefore,
    paydayOfMonth,
    projectionMonths,
    themeMode,
    isPremium,
    paymentStreak,
    lastPaymentDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
        _monthlyIncomeMeta,
        monthlyIncome.isAcceptableOrUnknown(
          data['monthly_income']!,
          _monthlyIncomeMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_days_before')) {
      context.handle(
        _reminderDaysBeforeMeta,
        reminderDaysBefore.isAcceptableOrUnknown(
          data['reminder_days_before']!,
          _reminderDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('payday_of_month')) {
      context.handle(
        _paydayOfMonthMeta,
        paydayOfMonth.isAcceptableOrUnknown(
          data['payday_of_month']!,
          _paydayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('projection_months')) {
      context.handle(
        _projectionMonthsMeta,
        projectionMonths.isAcceptableOrUnknown(
          data['projection_months']!,
          _projectionMonthsMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    if (data.containsKey('payment_streak')) {
      context.handle(
        _paymentStreakMeta,
        paymentStreak.isAcceptableOrUnknown(
          data['payment_streak']!,
          _paymentStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_payment_date')) {
      context.handle(
        _lastPaymentDateMeta,
        lastPaymentDate.isAcceptableOrUnknown(
          data['last_payment_date']!,
          _lastPaymentDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_income'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      reminderDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_days_before'],
      )!,
      paydayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payday_of_month'],
      )!,
      projectionMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}projection_months'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
      paymentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_streak'],
      )!,
      lastPaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_payment_date'],
      ),
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int id;
  final double monthlyIncome;
  final String currency;
  final bool notificationsEnabled;
  final int reminderDaysBefore;
  final int paydayOfMonth;
  final int projectionMonths;
  final String themeMode;
  final bool isPremium;
  final int paymentStreak;
  final DateTime? lastPaymentDate;
  const UserSetting({
    required this.id,
    required this.monthlyIncome,
    required this.currency,
    required this.notificationsEnabled,
    required this.reminderDaysBefore,
    required this.paydayOfMonth,
    required this.projectionMonths,
    required this.themeMode,
    required this.isPremium,
    required this.paymentStreak,
    this.lastPaymentDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    map['currency'] = Variable<String>(currency);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['reminder_days_before'] = Variable<int>(reminderDaysBefore);
    map['payday_of_month'] = Variable<int>(paydayOfMonth);
    map['projection_months'] = Variable<int>(projectionMonths);
    map['theme_mode'] = Variable<String>(themeMode);
    map['is_premium'] = Variable<bool>(isPremium);
    map['payment_streak'] = Variable<int>(paymentStreak);
    if (!nullToAbsent || lastPaymentDate != null) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      monthlyIncome: Value(monthlyIncome),
      currency: Value(currency),
      notificationsEnabled: Value(notificationsEnabled),
      reminderDaysBefore: Value(reminderDaysBefore),
      paydayOfMonth: Value(paydayOfMonth),
      projectionMonths: Value(projectionMonths),
      themeMode: Value(themeMode),
      isPremium: Value(isPremium),
      paymentStreak: Value(paymentStreak),
      lastPaymentDate: lastPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaymentDate),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
      currency: serializer.fromJson<String>(json['currency']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      reminderDaysBefore: serializer.fromJson<int>(json['reminderDaysBefore']),
      paydayOfMonth: serializer.fromJson<int>(json['paydayOfMonth']),
      projectionMonths: serializer.fromJson<int>(json['projectionMonths']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      paymentStreak: serializer.fromJson<int>(json['paymentStreak']),
      lastPaymentDate: serializer.fromJson<DateTime?>(json['lastPaymentDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
      'currency': serializer.toJson<String>(currency),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'reminderDaysBefore': serializer.toJson<int>(reminderDaysBefore),
      'paydayOfMonth': serializer.toJson<int>(paydayOfMonth),
      'projectionMonths': serializer.toJson<int>(projectionMonths),
      'themeMode': serializer.toJson<String>(themeMode),
      'isPremium': serializer.toJson<bool>(isPremium),
      'paymentStreak': serializer.toJson<int>(paymentStreak),
      'lastPaymentDate': serializer.toJson<DateTime?>(lastPaymentDate),
    };
  }

  UserSetting copyWith({
    int? id,
    double? monthlyIncome,
    String? currency,
    bool? notificationsEnabled,
    int? reminderDaysBefore,
    int? paydayOfMonth,
    int? projectionMonths,
    String? themeMode,
    bool? isPremium,
    int? paymentStreak,
    Value<DateTime?> lastPaymentDate = const Value.absent(),
  }) => UserSetting(
    id: id ?? this.id,
    monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    currency: currency ?? this.currency,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    paydayOfMonth: paydayOfMonth ?? this.paydayOfMonth,
    projectionMonths: projectionMonths ?? this.projectionMonths,
    themeMode: themeMode ?? this.themeMode,
    isPremium: isPremium ?? this.isPremium,
    paymentStreak: paymentStreak ?? this.paymentStreak,
    lastPaymentDate: lastPaymentDate.present
        ? lastPaymentDate.value
        : this.lastPaymentDate,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
      currency: data.currency.present ? data.currency.value : this.currency,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      reminderDaysBefore: data.reminderDaysBefore.present
          ? data.reminderDaysBefore.value
          : this.reminderDaysBefore,
      paydayOfMonth: data.paydayOfMonth.present
          ? data.paydayOfMonth.value
          : this.paydayOfMonth,
      projectionMonths: data.projectionMonths.present
          ? data.projectionMonths.value
          : this.projectionMonths,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      paymentStreak: data.paymentStreak.present
          ? data.paymentStreak.value
          : this.paymentStreak,
      lastPaymentDate: data.lastPaymentDate.present
          ? data.lastPaymentDate.value
          : this.lastPaymentDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('currency: $currency, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('paydayOfMonth: $paydayOfMonth, ')
          ..write('projectionMonths: $projectionMonths, ')
          ..write('themeMode: $themeMode, ')
          ..write('isPremium: $isPremium, ')
          ..write('paymentStreak: $paymentStreak, ')
          ..write('lastPaymentDate: $lastPaymentDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthlyIncome,
    currency,
    notificationsEnabled,
    reminderDaysBefore,
    paydayOfMonth,
    projectionMonths,
    themeMode,
    isPremium,
    paymentStreak,
    lastPaymentDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.monthlyIncome == this.monthlyIncome &&
          other.currency == this.currency &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.reminderDaysBefore == this.reminderDaysBefore &&
          other.paydayOfMonth == this.paydayOfMonth &&
          other.projectionMonths == this.projectionMonths &&
          other.themeMode == this.themeMode &&
          other.isPremium == this.isPremium &&
          other.paymentStreak == this.paymentStreak &&
          other.lastPaymentDate == this.lastPaymentDate);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<double> monthlyIncome;
  final Value<String> currency;
  final Value<bool> notificationsEnabled;
  final Value<int> reminderDaysBefore;
  final Value<int> paydayOfMonth;
  final Value<int> projectionMonths;
  final Value<String> themeMode;
  final Value<bool> isPremium;
  final Value<int> paymentStreak;
  final Value<DateTime?> lastPaymentDate;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.currency = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.paydayOfMonth = const Value.absent(),
    this.projectionMonths = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.paymentStreak = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.currency = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.paydayOfMonth = const Value.absent(),
    this.projectionMonths = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.paymentStreak = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
  });
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<double>? monthlyIncome,
    Expression<String>? currency,
    Expression<bool>? notificationsEnabled,
    Expression<int>? reminderDaysBefore,
    Expression<int>? paydayOfMonth,
    Expression<int>? projectionMonths,
    Expression<String>? themeMode,
    Expression<bool>? isPremium,
    Expression<int>? paymentStreak,
    Expression<DateTime>? lastPaymentDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (currency != null) 'currency': currency,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (reminderDaysBefore != null)
        'reminder_days_before': reminderDaysBefore,
      if (paydayOfMonth != null) 'payday_of_month': paydayOfMonth,
      if (projectionMonths != null) 'projection_months': projectionMonths,
      if (themeMode != null) 'theme_mode': themeMode,
      if (isPremium != null) 'is_premium': isPremium,
      if (paymentStreak != null) 'payment_streak': paymentStreak,
      if (lastPaymentDate != null) 'last_payment_date': lastPaymentDate,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<double>? monthlyIncome,
    Value<String>? currency,
    Value<bool>? notificationsEnabled,
    Value<int>? reminderDaysBefore,
    Value<int>? paydayOfMonth,
    Value<int>? projectionMonths,
    Value<String>? themeMode,
    Value<bool>? isPremium,
    Value<int>? paymentStreak,
    Value<DateTime?>? lastPaymentDate,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      paydayOfMonth: paydayOfMonth ?? this.paydayOfMonth,
      projectionMonths: projectionMonths ?? this.projectionMonths,
      themeMode: themeMode ?? this.themeMode,
      isPremium: isPremium ?? this.isPremium,
      paymentStreak: paymentStreak ?? this.paymentStreak,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (reminderDaysBefore.present) {
      map['reminder_days_before'] = Variable<int>(reminderDaysBefore.value);
    }
    if (paydayOfMonth.present) {
      map['payday_of_month'] = Variable<int>(paydayOfMonth.value);
    }
    if (projectionMonths.present) {
      map['projection_months'] = Variable<int>(projectionMonths.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (paymentStreak.present) {
      map['payment_streak'] = Variable<int>(paymentStreak.value);
    }
    if (lastPaymentDate.present) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('currency: $currency, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('paydayOfMonth: $paydayOfMonth, ')
          ..write('projectionMonths: $projectionMonths, ')
          ..write('themeMode: $themeMode, ')
          ..write('isPremium: $isPremium, ')
          ..write('paymentStreak: $paymentStreak, ')
          ..write('lastPaymentDate: $lastPaymentDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ObligationsTable obligations = $ObligationsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    obligations,
    payments,
    userSettings,
  ];
}

typedef $$ObligationsTableCreateCompanionBuilder =
    ObligationsCompanion Function({
      Value<int> id,
      required String title,
      required ObligationType type,
      required double amount,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<int?> emiDurationMonths,
      Value<int> gracePeriodDays,
      Value<int> emiPaidMonths,
      required PriorityLevel priority,
      Value<ObligationStatus> status,
      required String category,
      Value<String?> notes,
      Value<DateTime?> nextDueDate,
      Value<double> totalBalance,
      Value<double> interestRate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> displayOrder,
    });
typedef $$ObligationsTableUpdateCompanionBuilder =
    ObligationsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<ObligationType> type,
      Value<double> amount,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<int?> emiDurationMonths,
      Value<int> gracePeriodDays,
      Value<int> emiPaidMonths,
      Value<PriorityLevel> priority,
      Value<ObligationStatus> status,
      Value<String> category,
      Value<String?> notes,
      Value<DateTime?> nextDueDate,
      Value<double> totalBalance,
      Value<double> interestRate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> displayOrder,
    });

final class $$ObligationsTableReferences
    extends BaseReferences<_$AppDatabase, $ObligationsTable, Obligation> {
  $$ObligationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(
      db.obligations.id,
      db.payments.obligationId,
    ),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.obligationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObligationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ObligationType, ObligationType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emiDurationMonths => $composableBuilder(
    column: $table.emiDurationMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gracePeriodDays => $composableBuilder(
    column: $table.gracePeriodDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emiPaidMonths => $composableBuilder(
    column: $table.emiPaidMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PriorityLevel, PriorityLevel, int>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ObligationStatus, ObligationStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalBalance => $composableBuilder(
    column: $table.totalBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.obligationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObligationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emiDurationMonths => $composableBuilder(
    column: $table.emiDurationMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gracePeriodDays => $composableBuilder(
    column: $table.gracePeriodDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emiPaidMonths => $composableBuilder(
    column: $table.emiPaidMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalBalance => $composableBuilder(
    column: $table.totalBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObligationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<ObligationType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get emiDurationMonths => $composableBuilder(
    column: $table.emiDurationMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gracePeriodDays => $composableBuilder(
    column: $table.gracePeriodDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get emiPaidMonths => $composableBuilder(
    column: $table.emiPaidMonths,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PriorityLevel, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ObligationStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalBalance => $composableBuilder(
    column: $table.totalBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.obligationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObligationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObligationsTable,
          Obligation,
          $$ObligationsTableFilterComposer,
          $$ObligationsTableOrderingComposer,
          $$ObligationsTableAnnotationComposer,
          $$ObligationsTableCreateCompanionBuilder,
          $$ObligationsTableUpdateCompanionBuilder,
          (Obligation, $$ObligationsTableReferences),
          Obligation,
          PrefetchHooks Function({bool paymentsRefs})
        > {
  $$ObligationsTableTableManager(_$AppDatabase db, $ObligationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObligationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObligationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObligationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<ObligationType> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> emiDurationMonths = const Value.absent(),
                Value<int> gracePeriodDays = const Value.absent(),
                Value<int> emiPaidMonths = const Value.absent(),
                Value<PriorityLevel> priority = const Value.absent(),
                Value<ObligationStatus> status = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<double> totalBalance = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => ObligationsCompanion(
                id: id,
                title: title,
                type: type,
                amount: amount,
                startDate: startDate,
                endDate: endDate,
                emiDurationMonths: emiDurationMonths,
                gracePeriodDays: gracePeriodDays,
                emiPaidMonths: emiPaidMonths,
                priority: priority,
                status: status,
                category: category,
                notes: notes,
                nextDueDate: nextDueDate,
                totalBalance: totalBalance,
                interestRate: interestRate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                displayOrder: displayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required ObligationType type,
                required double amount,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> emiDurationMonths = const Value.absent(),
                Value<int> gracePeriodDays = const Value.absent(),
                Value<int> emiPaidMonths = const Value.absent(),
                required PriorityLevel priority,
                Value<ObligationStatus> status = const Value.absent(),
                required String category,
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<double> totalBalance = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => ObligationsCompanion.insert(
                id: id,
                title: title,
                type: type,
                amount: amount,
                startDate: startDate,
                endDate: endDate,
                emiDurationMonths: emiDurationMonths,
                gracePeriodDays: gracePeriodDays,
                emiPaidMonths: emiPaidMonths,
                priority: priority,
                status: status,
                category: category,
                notes: notes,
                nextDueDate: nextDueDate,
                totalBalance: totalBalance,
                interestRate: interestRate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                displayOrder: displayOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObligationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<
                      Obligation,
                      $ObligationsTable,
                      Payment
                    >(
                      currentTable: table,
                      referencedTable: $$ObligationsTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ObligationsTableReferences(
                            db,
                            table,
                            p0,
                          ).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.obligationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ObligationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObligationsTable,
      Obligation,
      $$ObligationsTableFilterComposer,
      $$ObligationsTableOrderingComposer,
      $$ObligationsTableAnnotationComposer,
      $$ObligationsTableCreateCompanionBuilder,
      $$ObligationsTableUpdateCompanionBuilder,
      (Obligation, $$ObligationsTableReferences),
      Obligation,
      PrefetchHooks Function({bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int obligationId,
      required double amountPaid,
      Value<DateTime> paidDate,
      required String paymentType,
      Value<String?> note,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> obligationId,
      Value<double> amountPaid,
      Value<DateTime> paidDate,
      Value<String> paymentType,
      Value<String?> note,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObligationsTable _obligationIdTable(_$AppDatabase db) =>
      db.obligations.createAlias(
        $_aliasNameGenerator(db.payments.obligationId, db.obligations.id),
      );

  $$ObligationsTableProcessedTableManager get obligationId {
    final $_column = $_itemColumn<int>('obligation_id')!;

    final manager = $$ObligationsTableTableManager(
      $_db,
      $_db.obligations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_obligationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ObligationsTableFilterComposer get obligationId {
    final $$ObligationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableFilterComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObligationsTableOrderingComposer get obligationId {
    final $$ObligationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableOrderingComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ObligationsTableAnnotationComposer get obligationId {
    final $$ObligationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableAnnotationComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool obligationId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> obligationId = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime> paidDate = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                obligationId: obligationId,
                amountPaid: amountPaid,
                paidDate: paidDate,
                paymentType: paymentType,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int obligationId,
                required double amountPaid,
                Value<DateTime> paidDate = const Value.absent(),
                required String paymentType,
                Value<String?> note = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                obligationId: obligationId,
                amountPaid: amountPaid,
                paidDate: paidDate,
                paymentType: paymentType,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({obligationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (obligationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.obligationId,
                                referencedTable: $$PaymentsTableReferences
                                    ._obligationIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._obligationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool obligationId})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyIncome,
      Value<String> currency,
      Value<bool> notificationsEnabled,
      Value<int> reminderDaysBefore,
      Value<int> paydayOfMonth,
      Value<int> projectionMonths,
      Value<String> themeMode,
      Value<bool> isPremium,
      Value<int> paymentStreak,
      Value<DateTime?> lastPaymentDate,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyIncome,
      Value<String> currency,
      Value<bool> notificationsEnabled,
      Value<int> reminderDaysBefore,
      Value<int> paydayOfMonth,
      Value<int> projectionMonths,
      Value<String> themeMode,
      Value<bool> isPremium,
      Value<int> paymentStreak,
      Value<DateTime?> lastPaymentDate,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paydayOfMonth => $composableBuilder(
    column: $table.paydayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectionMonths => $composableBuilder(
    column: $table.projectionMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentStreak => $composableBuilder(
    column: $table.paymentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paydayOfMonth => $composableBuilder(
    column: $table.paydayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectionMonths => $composableBuilder(
    column: $table.projectionMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentStreak => $composableBuilder(
    column: $table.paymentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paydayOfMonth => $composableBuilder(
    column: $table.paydayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectionMonths => $composableBuilder(
    column: $table.projectionMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<int> get paymentStreak => $composableBuilder(
    column: $table.paymentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> reminderDaysBefore = const Value.absent(),
                Value<int> paydayOfMonth = const Value.absent(),
                Value<int> projectionMonths = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> paymentStreak = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                monthlyIncome: monthlyIncome,
                currency: currency,
                notificationsEnabled: notificationsEnabled,
                reminderDaysBefore: reminderDaysBefore,
                paydayOfMonth: paydayOfMonth,
                projectionMonths: projectionMonths,
                themeMode: themeMode,
                isPremium: isPremium,
                paymentStreak: paymentStreak,
                lastPaymentDate: lastPaymentDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> reminderDaysBefore = const Value.absent(),
                Value<int> paydayOfMonth = const Value.absent(),
                Value<int> projectionMonths = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> paymentStreak = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                monthlyIncome: monthlyIncome,
                currency: currency,
                notificationsEnabled: notificationsEnabled,
                reminderDaysBefore: reminderDaysBefore,
                paydayOfMonth: paydayOfMonth,
                projectionMonths: projectionMonths,
                themeMode: themeMode,
                isPremium: isPremium,
                paymentStreak: paymentStreak,
                lastPaymentDate: lastPaymentDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ObligationsTableTableManager get obligations =>
      $$ObligationsTableTableManager(_db, _db.obligations);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
