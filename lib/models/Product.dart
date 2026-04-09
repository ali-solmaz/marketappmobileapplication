import 'ModelBase.dart';

class Product extends ModelBase {
  String name;
  String? description;
  double price;
  int stock;
  DateTime creationTime;
  bool isActive;

  Product({
    required super.id,
    required super.createdDate,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.creationTime,
    required this.isActive,
  });
}
