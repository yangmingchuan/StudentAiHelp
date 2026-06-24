// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalChildrenTable extends LocalChildren
    with TableInfo<$LocalChildrenTable, LocalChildrenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('小勇士'),
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _ageStageMeta = const VerificationMeta(
    'ageStage',
  );
  @override
  late final GeneratedColumn<String> ageStage = GeneratedColumn<String>(
    'age_stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('5-6'),
  );
  static const VerificationMeta _avatarIconMeta = const VerificationMeta(
    'avatarIcon',
  );
  @override
  late final GeneratedColumn<String> avatarIcon = GeneratedColumn<String>(
    'avatar_icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('face_rounded'),
  );
  static const VerificationMeta _avatarColorMeta = const VerificationMeta(
    'avatarColor',
  );
  @override
  late final GeneratedColumn<String> avatarColor = GeneratedColumn<String>(
    'avatar_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('green'),
  );
  static const VerificationMeta _needsProfileSetupMeta = const VerificationMeta(
    'needsProfileSetup',
  );
  @override
  late final GeneratedColumn<bool> needsProfileSetup = GeneratedColumn<bool>(
    'needs_profile_setup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_profile_setup" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    gender,
    ageStage,
    avatarIcon,
    avatarColor,
    needsProfileSetup,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_children';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChildrenData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('age_stage')) {
      context.handle(
        _ageStageMeta,
        ageStage.isAcceptableOrUnknown(data['age_stage']!, _ageStageMeta),
      );
    }
    if (data.containsKey('avatar_icon')) {
      context.handle(
        _avatarIconMeta,
        avatarIcon.isAcceptableOrUnknown(data['avatar_icon']!, _avatarIconMeta),
      );
    }
    if (data.containsKey('avatar_color')) {
      context.handle(
        _avatarColorMeta,
        avatarColor.isAcceptableOrUnknown(
          data['avatar_color']!,
          _avatarColorMeta,
        ),
      );
    }
    if (data.containsKey('needs_profile_setup')) {
      context.handle(
        _needsProfileSetupMeta,
        needsProfileSetup.isAcceptableOrUnknown(
          data['needs_profile_setup']!,
          _needsProfileSetupMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChildrenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChildrenData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      ageStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_stage'],
      )!,
      avatarIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_icon'],
      )!,
      avatarColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_color'],
      )!,
      needsProfileSetup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_profile_setup'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalChildrenTable createAlias(String alias) {
    return $LocalChildrenTable(attachedDatabase, alias);
  }
}

class LocalChildrenData extends DataClass
    implements Insertable<LocalChildrenData> {
  final int id;
  final String nickname;
  final String gender;
  final String ageStage;
  final String avatarIcon;
  final String avatarColor;
  final bool needsProfileSetup;
  final DateTime updatedAt;
  const LocalChildrenData({
    required this.id,
    required this.nickname,
    required this.gender,
    required this.ageStage,
    required this.avatarIcon,
    required this.avatarColor,
    required this.needsProfileSetup,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['gender'] = Variable<String>(gender);
    map['age_stage'] = Variable<String>(ageStage);
    map['avatar_icon'] = Variable<String>(avatarIcon);
    map['avatar_color'] = Variable<String>(avatarColor);
    map['needs_profile_setup'] = Variable<bool>(needsProfileSetup);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalChildrenCompanion toCompanion(bool nullToAbsent) {
    return LocalChildrenCompanion(
      id: Value(id),
      nickname: Value(nickname),
      gender: Value(gender),
      ageStage: Value(ageStage),
      avatarIcon: Value(avatarIcon),
      avatarColor: Value(avatarColor),
      needsProfileSetup: Value(needsProfileSetup),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalChildrenData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChildrenData(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      gender: serializer.fromJson<String>(json['gender']),
      ageStage: serializer.fromJson<String>(json['ageStage']),
      avatarIcon: serializer.fromJson<String>(json['avatarIcon']),
      avatarColor: serializer.fromJson<String>(json['avatarColor']),
      needsProfileSetup: serializer.fromJson<bool>(json['needsProfileSetup']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'gender': serializer.toJson<String>(gender),
      'ageStage': serializer.toJson<String>(ageStage),
      'avatarIcon': serializer.toJson<String>(avatarIcon),
      'avatarColor': serializer.toJson<String>(avatarColor),
      'needsProfileSetup': serializer.toJson<bool>(needsProfileSetup),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalChildrenData copyWith({
    int? id,
    String? nickname,
    String? gender,
    String? ageStage,
    String? avatarIcon,
    String? avatarColor,
    bool? needsProfileSetup,
    DateTime? updatedAt,
  }) => LocalChildrenData(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    gender: gender ?? this.gender,
    ageStage: ageStage ?? this.ageStage,
    avatarIcon: avatarIcon ?? this.avatarIcon,
    avatarColor: avatarColor ?? this.avatarColor,
    needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalChildrenData copyWithCompanion(LocalChildrenCompanion data) {
    return LocalChildrenData(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      gender: data.gender.present ? data.gender.value : this.gender,
      ageStage: data.ageStage.present ? data.ageStage.value : this.ageStage,
      avatarIcon: data.avatarIcon.present
          ? data.avatarIcon.value
          : this.avatarIcon,
      avatarColor: data.avatarColor.present
          ? data.avatarColor.value
          : this.avatarColor,
      needsProfileSetup: data.needsProfileSetup.present
          ? data.needsProfileSetup.value
          : this.needsProfileSetup,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildrenData(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('ageStage: $ageStage, ')
          ..write('avatarIcon: $avatarIcon, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('needsProfileSetup: $needsProfileSetup, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    gender,
    ageStage,
    avatarIcon,
    avatarColor,
    needsProfileSetup,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChildrenData &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.gender == this.gender &&
          other.ageStage == this.ageStage &&
          other.avatarIcon == this.avatarIcon &&
          other.avatarColor == this.avatarColor &&
          other.needsProfileSetup == this.needsProfileSetup &&
          other.updatedAt == this.updatedAt);
}

class LocalChildrenCompanion extends UpdateCompanion<LocalChildrenData> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> gender;
  final Value<String> ageStage;
  final Value<String> avatarIcon;
  final Value<String> avatarColor;
  final Value<bool> needsProfileSetup;
  final Value<DateTime> updatedAt;
  const LocalChildrenCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.ageStage = const Value.absent(),
    this.avatarIcon = const Value.absent(),
    this.avatarColor = const Value.absent(),
    this.needsProfileSetup = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalChildrenCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.ageStage = const Value.absent(),
    this.avatarIcon = const Value.absent(),
    this.avatarColor = const Value.absent(),
    this.needsProfileSetup = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<LocalChildrenData> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? gender,
    Expression<String>? ageStage,
    Expression<String>? avatarIcon,
    Expression<String>? avatarColor,
    Expression<bool>? needsProfileSetup,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (gender != null) 'gender': gender,
      if (ageStage != null) 'age_stage': ageStage,
      if (avatarIcon != null) 'avatar_icon': avatarIcon,
      if (avatarColor != null) 'avatar_color': avatarColor,
      if (needsProfileSetup != null) 'needs_profile_setup': needsProfileSetup,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalChildrenCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<String>? gender,
    Value<String>? ageStage,
    Value<String>? avatarIcon,
    Value<String>? avatarColor,
    Value<bool>? needsProfileSetup,
    Value<DateTime>? updatedAt,
  }) {
    return LocalChildrenCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      ageStage: ageStage ?? this.ageStage,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      avatarColor: avatarColor ?? this.avatarColor,
      needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (ageStage.present) {
      map['age_stage'] = Variable<String>(ageStage.value);
    }
    if (avatarIcon.present) {
      map['avatar_icon'] = Variable<String>(avatarIcon.value);
    }
    if (avatarColor.present) {
      map['avatar_color'] = Variable<String>(avatarColor.value);
    }
    if (needsProfileSetup.present) {
      map['needs_profile_setup'] = Variable<bool>(needsProfileSetup.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildrenCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('ageStage: $ageStage, ')
          ..write('avatarIcon: $avatarIcon, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('needsProfileSetup: $needsProfileSetup, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalHabitsTable extends LocalHabits
    with TableInfo<$LocalHabitsTable, LocalHabit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('task_alt'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    name,
    iconName,
    sortOrder,
    isActive,
    isDirty,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHabit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHabit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHabit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalHabitsTable createAlias(String alias) {
    return $LocalHabitsTable(attachedDatabase, alias);
  }
}

class LocalHabit extends DataClass implements Insertable<LocalHabit> {
  final int id;
  final int childId;
  final String name;
  final String iconName;
  final int sortOrder;
  final bool isActive;
  final bool isDirty;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LocalHabit({
    required this.id,
    required this.childId,
    required this.name,
    required this.iconName,
    required this.sortOrder,
    required this.isActive,
    required this.isDirty,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalHabitsCompanion toCompanion(bool nullToAbsent) {
    return LocalHabitsCompanion(
      id: Value(id),
      childId: Value(childId),
      name: Value(name),
      iconName: Value(iconName),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      isDirty: Value(isDirty),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalHabit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHabit(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'isDirty': serializer.toJson<bool>(isDirty),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalHabit copyWith({
    int? id,
    int? childId,
    String? name,
    String? iconName,
    int? sortOrder,
    bool? isActive,
    bool? isDirty,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalHabit(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    isDirty: isDirty ?? this.isDirty,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalHabit copyWithCompanion(LocalHabitsCompanion data) {
    return LocalHabit(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabit(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('isDirty: $isDirty, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    name,
    iconName,
    sortOrder,
    isActive,
    isDirty,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHabit &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.isDirty == this.isDirty &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalHabitsCompanion extends UpdateCompanion<LocalHabit> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<bool> isDirty;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const LocalHabitsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  LocalHabitsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String name,
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : childId = Value(childId),
       name = Value(name);
  static Insertable<LocalHabit> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<bool>? isDirty,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (isDirty != null) 'is_dirty': isDirty,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  LocalHabitsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? name,
    Value<String>? iconName,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<bool>? isDirty,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return LocalHabitsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isDirty: isDirty ?? this.isDirty,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabitsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('isDirty: $isDirty, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalHabitRecordsTable extends LocalHabitRecords
    with TableInfo<$LocalHabitRecordsTable, LocalHabitRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHabitRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<String> recordDate = GeneratedColumn<String>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    habitId,
    recordDate,
    status,
    operationId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_habit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHabitRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHabitRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHabitRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalHabitRecordsTable createAlias(String alias) {
    return $LocalHabitRecordsTable(attachedDatabase, alias);
  }
}

class LocalHabitRecord extends DataClass
    implements Insertable<LocalHabitRecord> {
  final int id;
  final int childId;
  final int habitId;
  final String recordDate;
  final String status;
  final String operationId;
  final DateTime updatedAt;
  const LocalHabitRecord({
    required this.id,
    required this.childId,
    required this.habitId,
    required this.recordDate,
    required this.status,
    required this.operationId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['habit_id'] = Variable<int>(habitId);
    map['record_date'] = Variable<String>(recordDate);
    map['status'] = Variable<String>(status);
    map['operation_id'] = Variable<String>(operationId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalHabitRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalHabitRecordsCompanion(
      id: Value(id),
      childId: Value(childId),
      habitId: Value(habitId),
      recordDate: Value(recordDate),
      status: Value(status),
      operationId: Value(operationId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalHabitRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHabitRecord(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      habitId: serializer.fromJson<int>(json['habitId']),
      recordDate: serializer.fromJson<String>(json['recordDate']),
      status: serializer.fromJson<String>(json['status']),
      operationId: serializer.fromJson<String>(json['operationId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'habitId': serializer.toJson<int>(habitId),
      'recordDate': serializer.toJson<String>(recordDate),
      'status': serializer.toJson<String>(status),
      'operationId': serializer.toJson<String>(operationId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalHabitRecord copyWith({
    int? id,
    int? childId,
    int? habitId,
    String? recordDate,
    String? status,
    String? operationId,
    DateTime? updatedAt,
  }) => LocalHabitRecord(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    habitId: habitId ?? this.habitId,
    recordDate: recordDate ?? this.recordDate,
    status: status ?? this.status,
    operationId: operationId ?? this.operationId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalHabitRecord copyWithCompanion(LocalHabitRecordsCompanion data) {
    return LocalHabitRecord(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      status: data.status.present ? data.status.value : this.status,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabitRecord(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('habitId: $habitId, ')
          ..write('recordDate: $recordDate, ')
          ..write('status: $status, ')
          ..write('operationId: $operationId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    habitId,
    recordDate,
    status,
    operationId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHabitRecord &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.habitId == this.habitId &&
          other.recordDate == this.recordDate &&
          other.status == this.status &&
          other.operationId == this.operationId &&
          other.updatedAt == this.updatedAt);
}

class LocalHabitRecordsCompanion extends UpdateCompanion<LocalHabitRecord> {
  final Value<int> id;
  final Value<int> childId;
  final Value<int> habitId;
  final Value<String> recordDate;
  final Value<String> status;
  final Value<String> operationId;
  final Value<DateTime> updatedAt;
  const LocalHabitRecordsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.habitId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.status = const Value.absent(),
    this.operationId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalHabitRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required int habitId,
    required String recordDate,
    this.status = const Value.absent(),
    this.operationId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : childId = Value(childId),
       habitId = Value(habitId),
       recordDate = Value(recordDate);
  static Insertable<LocalHabitRecord> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<int>? habitId,
    Expression<String>? recordDate,
    Expression<String>? status,
    Expression<String>? operationId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (habitId != null) 'habit_id': habitId,
      if (recordDate != null) 'record_date': recordDate,
      if (status != null) 'status': status,
      if (operationId != null) 'operation_id': operationId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalHabitRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<int>? habitId,
    Value<String>? recordDate,
    Value<String>? status,
    Value<String>? operationId,
    Value<DateTime>? updatedAt,
  }) {
    return LocalHabitRecordsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      habitId: habitId ?? this.habitId,
      recordDate: recordDate ?? this.recordDate,
      status: status ?? this.status,
      operationId: operationId ?? this.operationId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<String>(recordDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabitRecordsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('habitId: $habitId, ')
          ..write('recordDate: $recordDate, ')
          ..write('status: $status, ')
          ..write('operationId: $operationId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetSnapshotsTable extends LocalAssetSnapshots
    with TableInfo<$LocalAssetSnapshotsTable, LocalAssetSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _availableStarsMeta = const VerificationMeta(
    'availableStars',
  );
  @override
  late final GeneratedColumn<int> availableStars = GeneratedColumn<int>(
    'available_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lifetimeStarsMeta = const VerificationMeta(
    'lifetimeStars',
  );
  @override
  late final GeneratedColumn<int> lifetimeStars = GeneratedColumn<int>(
    'lifetime_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _badgeCountMeta = const VerificationMeta(
    'badgeCount',
  );
  @override
  late final GeneratedColumn<int> badgeCount = GeneratedColumn<int>(
    'badge_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heartsRemainingMeta = const VerificationMeta(
    'heartsRemaining',
  );
  @override
  late final GeneratedColumn<int> heartsRemaining = GeneratedColumn<int>(
    'hearts_remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _heartsLimitMeta = const VerificationMeta(
    'heartsLimit',
  );
  @override
  late final GeneratedColumn<int> heartsLimit = GeneratedColumn<int>(
    'hearts_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _snapshotDateMeta = const VerificationMeta(
    'snapshotDate',
  );
  @override
  late final GeneratedColumn<String> snapshotDate = GeneratedColumn<String>(
    'snapshot_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    availableStars,
    lifetimeStars,
    badgeCount,
    heartsRemaining,
    heartsLimit,
    snapshotDate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_asset_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssetSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    }
    if (data.containsKey('available_stars')) {
      context.handle(
        _availableStarsMeta,
        availableStars.isAcceptableOrUnknown(
          data['available_stars']!,
          _availableStarsMeta,
        ),
      );
    }
    if (data.containsKey('lifetime_stars')) {
      context.handle(
        _lifetimeStarsMeta,
        lifetimeStars.isAcceptableOrUnknown(
          data['lifetime_stars']!,
          _lifetimeStarsMeta,
        ),
      );
    }
    if (data.containsKey('badge_count')) {
      context.handle(
        _badgeCountMeta,
        badgeCount.isAcceptableOrUnknown(data['badge_count']!, _badgeCountMeta),
      );
    }
    if (data.containsKey('hearts_remaining')) {
      context.handle(
        _heartsRemainingMeta,
        heartsRemaining.isAcceptableOrUnknown(
          data['hearts_remaining']!,
          _heartsRemainingMeta,
        ),
      );
    }
    if (data.containsKey('hearts_limit')) {
      context.handle(
        _heartsLimitMeta,
        heartsLimit.isAcceptableOrUnknown(
          data['hearts_limit']!,
          _heartsLimitMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_date')) {
      context.handle(
        _snapshotDateMeta,
        snapshotDate.isAcceptableOrUnknown(
          data['snapshot_date']!,
          _snapshotDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId};
  @override
  LocalAssetSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssetSnapshot(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      availableStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_stars'],
      )!,
      lifetimeStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifetime_stars'],
      )!,
      badgeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}badge_count'],
      )!,
      heartsRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hearts_remaining'],
      )!,
      heartsLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hearts_limit'],
      )!,
      snapshotDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_date'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAssetSnapshotsTable createAlias(String alias) {
    return $LocalAssetSnapshotsTable(attachedDatabase, alias);
  }
}

class LocalAssetSnapshot extends DataClass
    implements Insertable<LocalAssetSnapshot> {
  final int childId;
  final int availableStars;
  final int lifetimeStars;
  final int badgeCount;
  final int heartsRemaining;
  final int heartsLimit;
  final String snapshotDate;
  final DateTime updatedAt;
  const LocalAssetSnapshot({
    required this.childId,
    required this.availableStars,
    required this.lifetimeStars,
    required this.badgeCount,
    required this.heartsRemaining,
    required this.heartsLimit,
    required this.snapshotDate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['available_stars'] = Variable<int>(availableStars);
    map['lifetime_stars'] = Variable<int>(lifetimeStars);
    map['badge_count'] = Variable<int>(badgeCount);
    map['hearts_remaining'] = Variable<int>(heartsRemaining);
    map['hearts_limit'] = Variable<int>(heartsLimit);
    map['snapshot_date'] = Variable<String>(snapshotDate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAssetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetSnapshotsCompanion(
      childId: Value(childId),
      availableStars: Value(availableStars),
      lifetimeStars: Value(lifetimeStars),
      badgeCount: Value(badgeCount),
      heartsRemaining: Value(heartsRemaining),
      heartsLimit: Value(heartsLimit),
      snapshotDate: Value(snapshotDate),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAssetSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssetSnapshot(
      childId: serializer.fromJson<int>(json['childId']),
      availableStars: serializer.fromJson<int>(json['availableStars']),
      lifetimeStars: serializer.fromJson<int>(json['lifetimeStars']),
      badgeCount: serializer.fromJson<int>(json['badgeCount']),
      heartsRemaining: serializer.fromJson<int>(json['heartsRemaining']),
      heartsLimit: serializer.fromJson<int>(json['heartsLimit']),
      snapshotDate: serializer.fromJson<String>(json['snapshotDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'availableStars': serializer.toJson<int>(availableStars),
      'lifetimeStars': serializer.toJson<int>(lifetimeStars),
      'badgeCount': serializer.toJson<int>(badgeCount),
      'heartsRemaining': serializer.toJson<int>(heartsRemaining),
      'heartsLimit': serializer.toJson<int>(heartsLimit),
      'snapshotDate': serializer.toJson<String>(snapshotDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAssetSnapshot copyWith({
    int? childId,
    int? availableStars,
    int? lifetimeStars,
    int? badgeCount,
    int? heartsRemaining,
    int? heartsLimit,
    String? snapshotDate,
    DateTime? updatedAt,
  }) => LocalAssetSnapshot(
    childId: childId ?? this.childId,
    availableStars: availableStars ?? this.availableStars,
    lifetimeStars: lifetimeStars ?? this.lifetimeStars,
    badgeCount: badgeCount ?? this.badgeCount,
    heartsRemaining: heartsRemaining ?? this.heartsRemaining,
    heartsLimit: heartsLimit ?? this.heartsLimit,
    snapshotDate: snapshotDate ?? this.snapshotDate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAssetSnapshot copyWithCompanion(LocalAssetSnapshotsCompanion data) {
    return LocalAssetSnapshot(
      childId: data.childId.present ? data.childId.value : this.childId,
      availableStars: data.availableStars.present
          ? data.availableStars.value
          : this.availableStars,
      lifetimeStars: data.lifetimeStars.present
          ? data.lifetimeStars.value
          : this.lifetimeStars,
      badgeCount: data.badgeCount.present
          ? data.badgeCount.value
          : this.badgeCount,
      heartsRemaining: data.heartsRemaining.present
          ? data.heartsRemaining.value
          : this.heartsRemaining,
      heartsLimit: data.heartsLimit.present
          ? data.heartsLimit.value
          : this.heartsLimit,
      snapshotDate: data.snapshotDate.present
          ? data.snapshotDate.value
          : this.snapshotDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetSnapshot(')
          ..write('childId: $childId, ')
          ..write('availableStars: $availableStars, ')
          ..write('lifetimeStars: $lifetimeStars, ')
          ..write('badgeCount: $badgeCount, ')
          ..write('heartsRemaining: $heartsRemaining, ')
          ..write('heartsLimit: $heartsLimit, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    childId,
    availableStars,
    lifetimeStars,
    badgeCount,
    heartsRemaining,
    heartsLimit,
    snapshotDate,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssetSnapshot &&
          other.childId == this.childId &&
          other.availableStars == this.availableStars &&
          other.lifetimeStars == this.lifetimeStars &&
          other.badgeCount == this.badgeCount &&
          other.heartsRemaining == this.heartsRemaining &&
          other.heartsLimit == this.heartsLimit &&
          other.snapshotDate == this.snapshotDate &&
          other.updatedAt == this.updatedAt);
}

class LocalAssetSnapshotsCompanion extends UpdateCompanion<LocalAssetSnapshot> {
  final Value<int> childId;
  final Value<int> availableStars;
  final Value<int> lifetimeStars;
  final Value<int> badgeCount;
  final Value<int> heartsRemaining;
  final Value<int> heartsLimit;
  final Value<String> snapshotDate;
  final Value<DateTime> updatedAt;
  const LocalAssetSnapshotsCompanion({
    this.childId = const Value.absent(),
    this.availableStars = const Value.absent(),
    this.lifetimeStars = const Value.absent(),
    this.badgeCount = const Value.absent(),
    this.heartsRemaining = const Value.absent(),
    this.heartsLimit = const Value.absent(),
    this.snapshotDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalAssetSnapshotsCompanion.insert({
    this.childId = const Value.absent(),
    this.availableStars = const Value.absent(),
    this.lifetimeStars = const Value.absent(),
    this.badgeCount = const Value.absent(),
    this.heartsRemaining = const Value.absent(),
    this.heartsLimit = const Value.absent(),
    required String snapshotDate,
    this.updatedAt = const Value.absent(),
  }) : snapshotDate = Value(snapshotDate);
  static Insertable<LocalAssetSnapshot> custom({
    Expression<int>? childId,
    Expression<int>? availableStars,
    Expression<int>? lifetimeStars,
    Expression<int>? badgeCount,
    Expression<int>? heartsRemaining,
    Expression<int>? heartsLimit,
    Expression<String>? snapshotDate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (availableStars != null) 'available_stars': availableStars,
      if (lifetimeStars != null) 'lifetime_stars': lifetimeStars,
      if (badgeCount != null) 'badge_count': badgeCount,
      if (heartsRemaining != null) 'hearts_remaining': heartsRemaining,
      if (heartsLimit != null) 'hearts_limit': heartsLimit,
      if (snapshotDate != null) 'snapshot_date': snapshotDate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalAssetSnapshotsCompanion copyWith({
    Value<int>? childId,
    Value<int>? availableStars,
    Value<int>? lifetimeStars,
    Value<int>? badgeCount,
    Value<int>? heartsRemaining,
    Value<int>? heartsLimit,
    Value<String>? snapshotDate,
    Value<DateTime>? updatedAt,
  }) {
    return LocalAssetSnapshotsCompanion(
      childId: childId ?? this.childId,
      availableStars: availableStars ?? this.availableStars,
      lifetimeStars: lifetimeStars ?? this.lifetimeStars,
      badgeCount: badgeCount ?? this.badgeCount,
      heartsRemaining: heartsRemaining ?? this.heartsRemaining,
      heartsLimit: heartsLimit ?? this.heartsLimit,
      snapshotDate: snapshotDate ?? this.snapshotDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (availableStars.present) {
      map['available_stars'] = Variable<int>(availableStars.value);
    }
    if (lifetimeStars.present) {
      map['lifetime_stars'] = Variable<int>(lifetimeStars.value);
    }
    if (badgeCount.present) {
      map['badge_count'] = Variable<int>(badgeCount.value);
    }
    if (heartsRemaining.present) {
      map['hearts_remaining'] = Variable<int>(heartsRemaining.value);
    }
    if (heartsLimit.present) {
      map['hearts_limit'] = Variable<int>(heartsLimit.value);
    }
    if (snapshotDate.present) {
      map['snapshot_date'] = Variable<String>(snapshotDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetSnapshotsCompanion(')
          ..write('childId: $childId, ')
          ..write('availableStars: $availableStars, ')
          ..write('lifetimeStars: $lifetimeStars, ')
          ..write('badgeCount: $badgeCount, ')
          ..write('heartsRemaining: $heartsRemaining, ')
          ..write('heartsLimit: $heartsLimit, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalChildBadgesTable extends LocalChildBadges
    with TableInfo<$LocalChildBadgesTable, LocalChildBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChildBadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('workspace_premium_rounded'),
  );
  static const VerificationMeta _earnedDateMeta = const VerificationMeta(
    'earnedDate',
  );
  @override
  late final GeneratedColumn<String> earnedDate = GeneratedColumn<String>(
    'earned_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    childId,
    name,
    iconName,
    earnedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_child_badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChildBadge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('earned_date')) {
      context.handle(
        _earnedDateMeta,
        earnedDate.isAcceptableOrUnknown(data['earned_date']!, _earnedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, code};
  @override
  LocalChildBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChildBadge(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      earnedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}earned_date'],
      )!,
    );
  }

  @override
  $LocalChildBadgesTable createAlias(String alias) {
    return $LocalChildBadgesTable(attachedDatabase, alias);
  }
}

class LocalChildBadge extends DataClass implements Insertable<LocalChildBadge> {
  final String code;
  final int childId;
  final String name;
  final String iconName;
  final String earnedDate;
  const LocalChildBadge({
    required this.code,
    required this.childId,
    required this.name,
    required this.iconName,
    required this.earnedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['child_id'] = Variable<int>(childId);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['earned_date'] = Variable<String>(earnedDate);
    return map;
  }

  LocalChildBadgesCompanion toCompanion(bool nullToAbsent) {
    return LocalChildBadgesCompanion(
      code: Value(code),
      childId: Value(childId),
      name: Value(name),
      iconName: Value(iconName),
      earnedDate: Value(earnedDate),
    );
  }

  factory LocalChildBadge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChildBadge(
      code: serializer.fromJson<String>(json['code']),
      childId: serializer.fromJson<int>(json['childId']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      earnedDate: serializer.fromJson<String>(json['earnedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'childId': serializer.toJson<int>(childId),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'earnedDate': serializer.toJson<String>(earnedDate),
    };
  }

  LocalChildBadge copyWith({
    String? code,
    int? childId,
    String? name,
    String? iconName,
    String? earnedDate,
  }) => LocalChildBadge(
    code: code ?? this.code,
    childId: childId ?? this.childId,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    earnedDate: earnedDate ?? this.earnedDate,
  );
  LocalChildBadge copyWithCompanion(LocalChildBadgesCompanion data) {
    return LocalChildBadge(
      code: data.code.present ? data.code.value : this.code,
      childId: data.childId.present ? data.childId.value : this.childId,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      earnedDate: data.earnedDate.present
          ? data.earnedDate.value
          : this.earnedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildBadge(')
          ..write('code: $code, ')
          ..write('childId: $childId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('earnedDate: $earnedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, childId, name, iconName, earnedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChildBadge &&
          other.code == this.code &&
          other.childId == this.childId &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.earnedDate == this.earnedDate);
}

class LocalChildBadgesCompanion extends UpdateCompanion<LocalChildBadge> {
  final Value<String> code;
  final Value<int> childId;
  final Value<String> name;
  final Value<String> iconName;
  final Value<String> earnedDate;
  final Value<int> rowid;
  const LocalChildBadgesCompanion({
    this.code = const Value.absent(),
    this.childId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.earnedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChildBadgesCompanion.insert({
    required String code,
    required int childId,
    required String name,
    this.iconName = const Value.absent(),
    required String earnedDate,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       childId = Value(childId),
       name = Value(name),
       earnedDate = Value(earnedDate);
  static Insertable<LocalChildBadge> custom({
    Expression<String>? code,
    Expression<int>? childId,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<String>? earnedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (childId != null) 'child_id': childId,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (earnedDate != null) 'earned_date': earnedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChildBadgesCompanion copyWith({
    Value<String>? code,
    Value<int>? childId,
    Value<String>? name,
    Value<String>? iconName,
    Value<String>? earnedDate,
    Value<int>? rowid,
  }) {
    return LocalChildBadgesCompanion(
      code: code ?? this.code,
      childId: childId ?? this.childId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      earnedDate: earnedDate ?? this.earnedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (earnedDate.present) {
      map['earned_date'] = Variable<String>(earnedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildBadgesCompanion(')
          ..write('code: $code, ')
          ..write('childId: $childId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('earnedDate: $earnedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDailyAwardsTable extends LocalDailyAwards
    with TableInfo<$LocalDailyAwardsTable, LocalDailyAward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDailyAwardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awardDateMeta = const VerificationMeta(
    'awardDate',
  );
  @override
  late final GeneratedColumn<String> awardDate = GeneratedColumn<String>(
    'award_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awardTypeMeta = const VerificationMeta(
    'awardType',
  );
  @override
  late final GeneratedColumn<String> awardType = GeneratedColumn<String>(
    'award_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    childId,
    awardDate,
    awardType,
    stars,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_daily_awards';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDailyAward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('award_date')) {
      context.handle(
        _awardDateMeta,
        awardDate.isAcceptableOrUnknown(data['award_date']!, _awardDateMeta),
      );
    } else if (isInserting) {
      context.missing(_awardDateMeta);
    }
    if (data.containsKey('award_type')) {
      context.handle(
        _awardTypeMeta,
        awardType.isAcceptableOrUnknown(data['award_type']!, _awardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_awardTypeMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
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
  LocalDailyAward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDailyAward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      awardDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}award_date'],
      )!,
      awardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}award_type'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalDailyAwardsTable createAlias(String alias) {
    return $LocalDailyAwardsTable(attachedDatabase, alias);
  }
}

class LocalDailyAward extends DataClass implements Insertable<LocalDailyAward> {
  final int id;
  final int childId;
  final String awardDate;
  final String awardType;
  final int stars;
  final DateTime createdAt;
  const LocalDailyAward({
    required this.id,
    required this.childId,
    required this.awardDate,
    required this.awardType,
    required this.stars,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['award_date'] = Variable<String>(awardDate);
    map['award_type'] = Variable<String>(awardType);
    map['stars'] = Variable<int>(stars);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalDailyAwardsCompanion toCompanion(bool nullToAbsent) {
    return LocalDailyAwardsCompanion(
      id: Value(id),
      childId: Value(childId),
      awardDate: Value(awardDate),
      awardType: Value(awardType),
      stars: Value(stars),
      createdAt: Value(createdAt),
    );
  }

  factory LocalDailyAward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDailyAward(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      awardDate: serializer.fromJson<String>(json['awardDate']),
      awardType: serializer.fromJson<String>(json['awardType']),
      stars: serializer.fromJson<int>(json['stars']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'awardDate': serializer.toJson<String>(awardDate),
      'awardType': serializer.toJson<String>(awardType),
      'stars': serializer.toJson<int>(stars),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalDailyAward copyWith({
    int? id,
    int? childId,
    String? awardDate,
    String? awardType,
    int? stars,
    DateTime? createdAt,
  }) => LocalDailyAward(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    awardDate: awardDate ?? this.awardDate,
    awardType: awardType ?? this.awardType,
    stars: stars ?? this.stars,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalDailyAward copyWithCompanion(LocalDailyAwardsCompanion data) {
    return LocalDailyAward(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      awardDate: data.awardDate.present ? data.awardDate.value : this.awardDate,
      awardType: data.awardType.present ? data.awardType.value : this.awardType,
      stars: data.stars.present ? data.stars.value : this.stars,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyAward(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('awardDate: $awardDate, ')
          ..write('awardType: $awardType, ')
          ..write('stars: $stars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, awardDate, awardType, stars, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDailyAward &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.awardDate == this.awardDate &&
          other.awardType == this.awardType &&
          other.stars == this.stars &&
          other.createdAt == this.createdAt);
}

class LocalDailyAwardsCompanion extends UpdateCompanion<LocalDailyAward> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> awardDate;
  final Value<String> awardType;
  final Value<int> stars;
  final Value<DateTime> createdAt;
  const LocalDailyAwardsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.awardDate = const Value.absent(),
    this.awardType = const Value.absent(),
    this.stars = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalDailyAwardsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String awardDate,
    required String awardType,
    required int stars,
    this.createdAt = const Value.absent(),
  }) : childId = Value(childId),
       awardDate = Value(awardDate),
       awardType = Value(awardType),
       stars = Value(stars);
  static Insertable<LocalDailyAward> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? awardDate,
    Expression<String>? awardType,
    Expression<int>? stars,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (awardDate != null) 'award_date': awardDate,
      if (awardType != null) 'award_type': awardType,
      if (stars != null) 'stars': stars,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalDailyAwardsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? awardDate,
    Value<String>? awardType,
    Value<int>? stars,
    Value<DateTime>? createdAt,
  }) {
    return LocalDailyAwardsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      awardDate: awardDate ?? this.awardDate,
      awardType: awardType ?? this.awardType,
      stars: stars ?? this.stars,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (awardDate.present) {
      map['award_date'] = Variable<String>(awardDate.value);
    }
    if (awardType.present) {
      map['award_type'] = Variable<String>(awardType.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyAwardsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('awardDate: $awardDate, ')
          ..write('awardType: $awardType, ')
          ..write('stars: $stars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    operationType,
    entityId,
    payloadJson,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperation(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperation extends DataClass implements Insertable<SyncOperation> {
  final String operationId;
  final String operationType;
  final String entityId;
  final String payloadJson;
  final String status;
  final int attemptCount;
  final String lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncOperation({
    required this.operationId,
    required this.operationType,
    required this.entityId,
    required this.payloadJson,
    required this.status,
    required this.attemptCount,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['operation_type'] = Variable<String>(operationType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['last_error'] = Variable<String>(lastError);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      operationId: Value(operationId),
      operationType: Value(operationType),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastError: Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperation(
      operationId: serializer.fromJson<String>(json['operationId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'operationType': serializer.toJson<String>(operationType),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncOperation copyWith({
    String? operationId,
    String? operationType,
    String? entityId,
    String? payloadJson,
    String? status,
    int? attemptCount,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncOperation(
    operationId: operationId ?? this.operationId,
    operationType: operationType ?? this.operationType,
    entityId: entityId ?? this.entityId,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError ?? this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncOperation copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperation(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperation(')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    operationType,
    entityId,
    payloadJson,
    status,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperation &&
          other.operationId == this.operationId &&
          other.operationType == this.operationType &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperation> {
  final Value<String> operationId;
  final Value<String> operationType;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.operationId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String operationId,
    required String operationType,
    required String entityId,
    required String payloadJson,
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       operationType = Value(operationType),
       entityId = Value(entityId),
       payloadJson = Value(payloadJson);
  static Insertable<SyncOperation> custom({
    Expression<String>? operationId,
    Expression<String>? operationType,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (operationType != null) 'operation_type': operationType,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? operationType,
    Value<String>? entityId,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<String>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalChildrenTable localChildren = $LocalChildrenTable(this);
  late final $LocalHabitsTable localHabits = $LocalHabitsTable(this);
  late final $LocalHabitRecordsTable localHabitRecords =
      $LocalHabitRecordsTable(this);
  late final $LocalAssetSnapshotsTable localAssetSnapshots =
      $LocalAssetSnapshotsTable(this);
  late final $LocalChildBadgesTable localChildBadges = $LocalChildBadgesTable(
    this,
  );
  late final $LocalDailyAwardsTable localDailyAwards = $LocalDailyAwardsTable(
    this,
  );
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localChildren,
    localHabits,
    localHabitRecords,
    localAssetSnapshots,
    localChildBadges,
    localDailyAwards,
    syncOperations,
  ];
}

typedef $$LocalChildrenTableCreateCompanionBuilder =
    LocalChildrenCompanion Function({
      Value<int> id,
      Value<String> nickname,
      Value<String> gender,
      Value<String> ageStage,
      Value<String> avatarIcon,
      Value<String> avatarColor,
      Value<bool> needsProfileSetup,
      Value<DateTime> updatedAt,
    });
typedef $$LocalChildrenTableUpdateCompanionBuilder =
    LocalChildrenCompanion Function({
      Value<int> id,
      Value<String> nickname,
      Value<String> gender,
      Value<String> ageStage,
      Value<String> avatarIcon,
      Value<String> avatarColor,
      Value<bool> needsProfileSetup,
      Value<DateTime> updatedAt,
    });

class $$LocalChildrenTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableFilterComposer({
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

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageStage => $composableBuilder(
    column: $table.ageStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarIcon => $composableBuilder(
    column: $table.avatarIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsProfileSetup => $composableBuilder(
    column: $table.needsProfileSetup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChildrenTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableOrderingComposer({
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

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageStage => $composableBuilder(
    column: $table.ageStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarIcon => $composableBuilder(
    column: $table.avatarIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsProfileSetup => $composableBuilder(
    column: $table.needsProfileSetup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChildrenTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get ageStage =>
      $composableBuilder(column: $table.ageStage, builder: (column) => column);

  GeneratedColumn<String> get avatarIcon => $composableBuilder(
    column: $table.avatarIcon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsProfileSetup => $composableBuilder(
    column: $table.needsProfileSetup,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalChildrenTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalChildrenTable,
          LocalChildrenData,
          $$LocalChildrenTableFilterComposer,
          $$LocalChildrenTableOrderingComposer,
          $$LocalChildrenTableAnnotationComposer,
          $$LocalChildrenTableCreateCompanionBuilder,
          $$LocalChildrenTableUpdateCompanionBuilder,
          (
            LocalChildrenData,
            BaseReferences<
              _$LocalDatabase,
              $LocalChildrenTable,
              LocalChildrenData
            >,
          ),
          LocalChildrenData,
          PrefetchHooks Function()
        > {
  $$LocalChildrenTableTableManager(
    _$LocalDatabase db,
    $LocalChildrenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> ageStage = const Value.absent(),
                Value<String> avatarIcon = const Value.absent(),
                Value<String> avatarColor = const Value.absent(),
                Value<bool> needsProfileSetup = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalChildrenCompanion(
                id: id,
                nickname: nickname,
                gender: gender,
                ageStage: ageStage,
                avatarIcon: avatarIcon,
                avatarColor: avatarColor,
                needsProfileSetup: needsProfileSetup,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> ageStage = const Value.absent(),
                Value<String> avatarIcon = const Value.absent(),
                Value<String> avatarColor = const Value.absent(),
                Value<bool> needsProfileSetup = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalChildrenCompanion.insert(
                id: id,
                nickname: nickname,
                gender: gender,
                ageStage: ageStage,
                avatarIcon: avatarIcon,
                avatarColor: avatarColor,
                needsProfileSetup: needsProfileSetup,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalChildrenTable,
      LocalChildrenData,
      $$LocalChildrenTableFilterComposer,
      $$LocalChildrenTableOrderingComposer,
      $$LocalChildrenTableAnnotationComposer,
      $$LocalChildrenTableCreateCompanionBuilder,
      $$LocalChildrenTableUpdateCompanionBuilder,
      (
        LocalChildrenData,
        BaseReferences<_$LocalDatabase, $LocalChildrenTable, LocalChildrenData>,
      ),
      LocalChildrenData,
      PrefetchHooks Function()
    >;
typedef $$LocalHabitsTableCreateCompanionBuilder =
    LocalHabitsCompanion Function({
      Value<int> id,
      required int childId,
      required String name,
      Value<String> iconName,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<bool> isDirty,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$LocalHabitsTableUpdateCompanionBuilder =
    LocalHabitsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> name,
      Value<String> iconName,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<bool> isDirty,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$LocalHabitsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalHabitsTable> {
  $$LocalHabitsTableFilterComposer({
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

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHabitsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalHabitsTable> {
  $$LocalHabitsTableOrderingComposer({
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

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHabitsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalHabitsTable> {
  $$LocalHabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalHabitsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalHabitsTable,
          LocalHabit,
          $$LocalHabitsTableFilterComposer,
          $$LocalHabitsTableOrderingComposer,
          $$LocalHabitsTableAnnotationComposer,
          $$LocalHabitsTableCreateCompanionBuilder,
          $$LocalHabitsTableUpdateCompanionBuilder,
          (
            LocalHabit,
            BaseReferences<_$LocalDatabase, $LocalHabitsTable, LocalHabit>,
          ),
          LocalHabit,
          PrefetchHooks Function()
        > {
  $$LocalHabitsTableTableManager(_$LocalDatabase db, $LocalHabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => LocalHabitsCompanion(
                id: id,
                childId: childId,
                name: name,
                iconName: iconName,
                sortOrder: sortOrder,
                isActive: isActive,
                isDirty: isDirty,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String name,
                Value<String> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => LocalHabitsCompanion.insert(
                id: id,
                childId: childId,
                name: name,
                iconName: iconName,
                sortOrder: sortOrder,
                isActive: isActive,
                isDirty: isDirty,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalHabitsTable,
      LocalHabit,
      $$LocalHabitsTableFilterComposer,
      $$LocalHabitsTableOrderingComposer,
      $$LocalHabitsTableAnnotationComposer,
      $$LocalHabitsTableCreateCompanionBuilder,
      $$LocalHabitsTableUpdateCompanionBuilder,
      (
        LocalHabit,
        BaseReferences<_$LocalDatabase, $LocalHabitsTable, LocalHabit>,
      ),
      LocalHabit,
      PrefetchHooks Function()
    >;
typedef $$LocalHabitRecordsTableCreateCompanionBuilder =
    LocalHabitRecordsCompanion Function({
      Value<int> id,
      required int childId,
      required int habitId,
      required String recordDate,
      Value<String> status,
      Value<String> operationId,
      Value<DateTime> updatedAt,
    });
typedef $$LocalHabitRecordsTableUpdateCompanionBuilder =
    LocalHabitRecordsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<int> habitId,
      Value<String> recordDate,
      Value<String> status,
      Value<String> operationId,
      Value<DateTime> updatedAt,
    });

class $$LocalHabitRecordsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalHabitRecordsTable> {
  $$LocalHabitRecordsTableFilterComposer({
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

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHabitRecordsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalHabitRecordsTable> {
  $$LocalHabitRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHabitRecordsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalHabitRecordsTable> {
  $$LocalHabitRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalHabitRecordsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalHabitRecordsTable,
          LocalHabitRecord,
          $$LocalHabitRecordsTableFilterComposer,
          $$LocalHabitRecordsTableOrderingComposer,
          $$LocalHabitRecordsTableAnnotationComposer,
          $$LocalHabitRecordsTableCreateCompanionBuilder,
          $$LocalHabitRecordsTableUpdateCompanionBuilder,
          (
            LocalHabitRecord,
            BaseReferences<
              _$LocalDatabase,
              $LocalHabitRecordsTable,
              LocalHabitRecord
            >,
          ),
          LocalHabitRecord,
          PrefetchHooks Function()
        > {
  $$LocalHabitRecordsTableTableManager(
    _$LocalDatabase db,
    $LocalHabitRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHabitRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHabitRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHabitRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<String> recordDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalHabitRecordsCompanion(
                id: id,
                childId: childId,
                habitId: habitId,
                recordDate: recordDate,
                status: status,
                operationId: operationId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required int habitId,
                required String recordDate,
                Value<String> status = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalHabitRecordsCompanion.insert(
                id: id,
                childId: childId,
                habitId: habitId,
                recordDate: recordDate,
                status: status,
                operationId: operationId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHabitRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalHabitRecordsTable,
      LocalHabitRecord,
      $$LocalHabitRecordsTableFilterComposer,
      $$LocalHabitRecordsTableOrderingComposer,
      $$LocalHabitRecordsTableAnnotationComposer,
      $$LocalHabitRecordsTableCreateCompanionBuilder,
      $$LocalHabitRecordsTableUpdateCompanionBuilder,
      (
        LocalHabitRecord,
        BaseReferences<
          _$LocalDatabase,
          $LocalHabitRecordsTable,
          LocalHabitRecord
        >,
      ),
      LocalHabitRecord,
      PrefetchHooks Function()
    >;
typedef $$LocalAssetSnapshotsTableCreateCompanionBuilder =
    LocalAssetSnapshotsCompanion Function({
      Value<int> childId,
      Value<int> availableStars,
      Value<int> lifetimeStars,
      Value<int> badgeCount,
      Value<int> heartsRemaining,
      Value<int> heartsLimit,
      required String snapshotDate,
      Value<DateTime> updatedAt,
    });
typedef $$LocalAssetSnapshotsTableUpdateCompanionBuilder =
    LocalAssetSnapshotsCompanion Function({
      Value<int> childId,
      Value<int> availableStars,
      Value<int> lifetimeStars,
      Value<int> badgeCount,
      Value<int> heartsRemaining,
      Value<int> heartsLimit,
      Value<String> snapshotDate,
      Value<DateTime> updatedAt,
    });

class $$LocalAssetSnapshotsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalAssetSnapshotsTable> {
  $$LocalAssetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableStars => $composableBuilder(
    column: $table.availableStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifetimeStars => $composableBuilder(
    column: $table.lifetimeStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartsRemaining => $composableBuilder(
    column: $table.heartsRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartsLimit => $composableBuilder(
    column: $table.heartsLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssetSnapshotsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalAssetSnapshotsTable> {
  $$LocalAssetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableStars => $composableBuilder(
    column: $table.availableStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifetimeStars => $composableBuilder(
    column: $table.lifetimeStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartsRemaining => $composableBuilder(
    column: $table.heartsRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartsLimit => $composableBuilder(
    column: $table.heartsLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssetSnapshotsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalAssetSnapshotsTable> {
  $$LocalAssetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<int> get availableStars => $composableBuilder(
    column: $table.availableStars,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifetimeStars => $composableBuilder(
    column: $table.lifetimeStars,
    builder: (column) => column,
  );

  GeneratedColumn<int> get badgeCount => $composableBuilder(
    column: $table.badgeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartsRemaining => $composableBuilder(
    column: $table.heartsRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartsLimit => $composableBuilder(
    column: $table.heartsLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAssetSnapshotsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalAssetSnapshotsTable,
          LocalAssetSnapshot,
          $$LocalAssetSnapshotsTableFilterComposer,
          $$LocalAssetSnapshotsTableOrderingComposer,
          $$LocalAssetSnapshotsTableAnnotationComposer,
          $$LocalAssetSnapshotsTableCreateCompanionBuilder,
          $$LocalAssetSnapshotsTableUpdateCompanionBuilder,
          (
            LocalAssetSnapshot,
            BaseReferences<
              _$LocalDatabase,
              $LocalAssetSnapshotsTable,
              LocalAssetSnapshot
            >,
          ),
          LocalAssetSnapshot,
          PrefetchHooks Function()
        > {
  $$LocalAssetSnapshotsTableTableManager(
    _$LocalDatabase db,
    $LocalAssetSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAssetSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> availableStars = const Value.absent(),
                Value<int> lifetimeStars = const Value.absent(),
                Value<int> badgeCount = const Value.absent(),
                Value<int> heartsRemaining = const Value.absent(),
                Value<int> heartsLimit = const Value.absent(),
                Value<String> snapshotDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalAssetSnapshotsCompanion(
                childId: childId,
                availableStars: availableStars,
                lifetimeStars: lifetimeStars,
                badgeCount: badgeCount,
                heartsRemaining: heartsRemaining,
                heartsLimit: heartsLimit,
                snapshotDate: snapshotDate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> availableStars = const Value.absent(),
                Value<int> lifetimeStars = const Value.absent(),
                Value<int> badgeCount = const Value.absent(),
                Value<int> heartsRemaining = const Value.absent(),
                Value<int> heartsLimit = const Value.absent(),
                required String snapshotDate,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalAssetSnapshotsCompanion.insert(
                childId: childId,
                availableStars: availableStars,
                lifetimeStars: lifetimeStars,
                badgeCount: badgeCount,
                heartsRemaining: heartsRemaining,
                heartsLimit: heartsLimit,
                snapshotDate: snapshotDate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssetSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalAssetSnapshotsTable,
      LocalAssetSnapshot,
      $$LocalAssetSnapshotsTableFilterComposer,
      $$LocalAssetSnapshotsTableOrderingComposer,
      $$LocalAssetSnapshotsTableAnnotationComposer,
      $$LocalAssetSnapshotsTableCreateCompanionBuilder,
      $$LocalAssetSnapshotsTableUpdateCompanionBuilder,
      (
        LocalAssetSnapshot,
        BaseReferences<
          _$LocalDatabase,
          $LocalAssetSnapshotsTable,
          LocalAssetSnapshot
        >,
      ),
      LocalAssetSnapshot,
      PrefetchHooks Function()
    >;
typedef $$LocalChildBadgesTableCreateCompanionBuilder =
    LocalChildBadgesCompanion Function({
      required String code,
      required int childId,
      required String name,
      Value<String> iconName,
      required String earnedDate,
      Value<int> rowid,
    });
typedef $$LocalChildBadgesTableUpdateCompanionBuilder =
    LocalChildBadgesCompanion Function({
      Value<String> code,
      Value<int> childId,
      Value<String> name,
      Value<String> iconName,
      Value<String> earnedDate,
      Value<int> rowid,
    });

class $$LocalChildBadgesTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalChildBadgesTable> {
  $$LocalChildBadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earnedDate => $composableBuilder(
    column: $table.earnedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChildBadgesTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalChildBadgesTable> {
  $$LocalChildBadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earnedDate => $composableBuilder(
    column: $table.earnedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChildBadgesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalChildBadgesTable> {
  $$LocalChildBadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get earnedDate => $composableBuilder(
    column: $table.earnedDate,
    builder: (column) => column,
  );
}

class $$LocalChildBadgesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalChildBadgesTable,
          LocalChildBadge,
          $$LocalChildBadgesTableFilterComposer,
          $$LocalChildBadgesTableOrderingComposer,
          $$LocalChildBadgesTableAnnotationComposer,
          $$LocalChildBadgesTableCreateCompanionBuilder,
          $$LocalChildBadgesTableUpdateCompanionBuilder,
          (
            LocalChildBadge,
            BaseReferences<
              _$LocalDatabase,
              $LocalChildBadgesTable,
              LocalChildBadge
            >,
          ),
          LocalChildBadge,
          PrefetchHooks Function()
        > {
  $$LocalChildBadgesTableTableManager(
    _$LocalDatabase db,
    $LocalChildBadgesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChildBadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChildBadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChildBadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> earnedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChildBadgesCompanion(
                code: code,
                childId: childId,
                name: name,
                iconName: iconName,
                earnedDate: earnedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required int childId,
                required String name,
                Value<String> iconName = const Value.absent(),
                required String earnedDate,
                Value<int> rowid = const Value.absent(),
              }) => LocalChildBadgesCompanion.insert(
                code: code,
                childId: childId,
                name: name,
                iconName: iconName,
                earnedDate: earnedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChildBadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalChildBadgesTable,
      LocalChildBadge,
      $$LocalChildBadgesTableFilterComposer,
      $$LocalChildBadgesTableOrderingComposer,
      $$LocalChildBadgesTableAnnotationComposer,
      $$LocalChildBadgesTableCreateCompanionBuilder,
      $$LocalChildBadgesTableUpdateCompanionBuilder,
      (
        LocalChildBadge,
        BaseReferences<
          _$LocalDatabase,
          $LocalChildBadgesTable,
          LocalChildBadge
        >,
      ),
      LocalChildBadge,
      PrefetchHooks Function()
    >;
typedef $$LocalDailyAwardsTableCreateCompanionBuilder =
    LocalDailyAwardsCompanion Function({
      Value<int> id,
      required int childId,
      required String awardDate,
      required String awardType,
      required int stars,
      Value<DateTime> createdAt,
    });
typedef $$LocalDailyAwardsTableUpdateCompanionBuilder =
    LocalDailyAwardsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> awardDate,
      Value<String> awardType,
      Value<int> stars,
      Value<DateTime> createdAt,
    });

class $$LocalDailyAwardsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalDailyAwardsTable> {
  $$LocalDailyAwardsTableFilterComposer({
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

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awardDate => $composableBuilder(
    column: $table.awardDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awardType => $composableBuilder(
    column: $table.awardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDailyAwardsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalDailyAwardsTable> {
  $$LocalDailyAwardsTableOrderingComposer({
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

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awardDate => $composableBuilder(
    column: $table.awardDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awardType => $composableBuilder(
    column: $table.awardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDailyAwardsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalDailyAwardsTable> {
  $$LocalDailyAwardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get awardDate =>
      $composableBuilder(column: $table.awardDate, builder: (column) => column);

  GeneratedColumn<String> get awardType =>
      $composableBuilder(column: $table.awardType, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalDailyAwardsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $LocalDailyAwardsTable,
          LocalDailyAward,
          $$LocalDailyAwardsTableFilterComposer,
          $$LocalDailyAwardsTableOrderingComposer,
          $$LocalDailyAwardsTableAnnotationComposer,
          $$LocalDailyAwardsTableCreateCompanionBuilder,
          $$LocalDailyAwardsTableUpdateCompanionBuilder,
          (
            LocalDailyAward,
            BaseReferences<
              _$LocalDatabase,
              $LocalDailyAwardsTable,
              LocalDailyAward
            >,
          ),
          LocalDailyAward,
          PrefetchHooks Function()
        > {
  $$LocalDailyAwardsTableTableManager(
    _$LocalDatabase db,
    $LocalDailyAwardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDailyAwardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDailyAwardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDailyAwardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> awardDate = const Value.absent(),
                Value<String> awardType = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalDailyAwardsCompanion(
                id: id,
                childId: childId,
                awardDate: awardDate,
                awardType: awardType,
                stars: stars,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String awardDate,
                required String awardType,
                required int stars,
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalDailyAwardsCompanion.insert(
                id: id,
                childId: childId,
                awardDate: awardDate,
                awardType: awardType,
                stars: stars,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDailyAwardsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $LocalDailyAwardsTable,
      LocalDailyAward,
      $$LocalDailyAwardsTableFilterComposer,
      $$LocalDailyAwardsTableOrderingComposer,
      $$LocalDailyAwardsTableAnnotationComposer,
      $$LocalDailyAwardsTableCreateCompanionBuilder,
      $$LocalDailyAwardsTableUpdateCompanionBuilder,
      (
        LocalDailyAward,
        BaseReferences<
          _$LocalDatabase,
          $LocalDailyAwardsTable,
          LocalDailyAward
        >,
      ),
      LocalDailyAward,
      PrefetchHooks Function()
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String operationId,
      required String operationType,
      required String entityId,
      required String payloadJson,
      Value<String> status,
      Value<int> attemptCount,
      Value<String> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> operationId,
      Value<String> operationType,
      Value<String> entityId,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> attemptCount,
      Value<String> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$LocalDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$LocalDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SyncOperationsTable,
          SyncOperation,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperation,
            BaseReferences<
              _$LocalDatabase,
              $SyncOperationsTable,
              SyncOperation
            >,
          ),
          SyncOperation,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$LocalDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                operationId: operationId,
                operationType: operationType,
                entityId: entityId,
                payloadJson: payloadJson,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String operationType,
                required String entityId,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                operationId: operationId,
                operationType: operationType,
                entityId: entityId,
                payloadJson: payloadJson,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SyncOperationsTable,
      SyncOperation,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperation,
        BaseReferences<_$LocalDatabase, $SyncOperationsTable, SyncOperation>,
      ),
      SyncOperation,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalChildrenTableTableManager get localChildren =>
      $$LocalChildrenTableTableManager(_db, _db.localChildren);
  $$LocalHabitsTableTableManager get localHabits =>
      $$LocalHabitsTableTableManager(_db, _db.localHabits);
  $$LocalHabitRecordsTableTableManager get localHabitRecords =>
      $$LocalHabitRecordsTableTableManager(_db, _db.localHabitRecords);
  $$LocalAssetSnapshotsTableTableManager get localAssetSnapshots =>
      $$LocalAssetSnapshotsTableTableManager(_db, _db.localAssetSnapshots);
  $$LocalChildBadgesTableTableManager get localChildBadges =>
      $$LocalChildBadgesTableTableManager(_db, _db.localChildBadges);
  $$LocalDailyAwardsTableTableManager get localDailyAwards =>
      $$LocalDailyAwardsTableTableManager(_db, _db.localDailyAwards);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
}
