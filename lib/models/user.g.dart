// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  ownedFruit: (json['ownedFruit'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
  currentFruit: json['currentFruit'] as String? ?? 'peach',
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'ownedFruit': instance.ownedFruit,
  'currentFruit': instance.currentFruit,
  'settings': instance.settings,
};
