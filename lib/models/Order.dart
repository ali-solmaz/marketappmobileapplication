import 'ModelBase.dart';
import 'OrderDetails.dart';
import 'User.dart';

class Order extends ModelBase {
  int userId;
  User? user;
  String customerName;
  String customerLastName;
  String telephone;
  String address;
  double totalPrice;
  String state;
  DateTime orderTime;
  List<OrderDetail>? details;

  Order({
    required super.id,
    required super.createdDate,
    required this.userId,
    this.user,
    required this.customerName,
    required this.customerLastName,
    required this.telephone,
    required this.address,
    required this.totalPrice,
    required this.state,
    required this.orderTime,
    this.details,
  }) {
    details ??= <OrderDetail>[];
  }
}
