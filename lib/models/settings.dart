import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  Settings();

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
}
