import 'ModelBase.dart';

class User extends ModelBase {
  String? username;
  String? password;

  User({
    required super.id,
    required super.createdDate,
    this.username,
    this.password,
  });
}
