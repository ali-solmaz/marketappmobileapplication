import 'ModelBase.dart';
import 'Order.dart';
import 'Product.dart';

class OrderDetail extends ModelBase {
  int productId;
  Product? product;
  int? orderId;
  Order? order;
  int piece;
  double unitPrice;

  OrderDetail({
    required super.id,
    required super.createdDate,
    required this.productId,
    this.product,
    this.orderId,
    this.order,
    required this.piece,
    required this.unitPrice,
  });

  double get totalPrice => piece * unitPrice;
}
