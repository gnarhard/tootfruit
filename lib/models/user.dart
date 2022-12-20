import 'package:json_annotation/json_annotation.dart';
import 'package:toot_fruit/models/settings.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  List<String> ownedFruit;
  String currentFruit;
  Settings settings;

  User({
    List<String>? ownedFruit,
    required this.settings,
    this.currentFruit = 'peach', // Main Menu
  }) : ownedFruit = ownedFruit ?? ['peach'];

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
