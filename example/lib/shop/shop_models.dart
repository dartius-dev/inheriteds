import 'package:equalone/equalone.dart';

///
/// Represents shop goods and their prices.
///
class ShopPrice with EqualoneMixin {
  final Map<String, int> goods;

  const ShopPrice(this.goods);

  ShopPrice updatedWith(String name, int price) {
    return ShopPrice({ ...goods, name: price});
  }
  
  @override
  List<Object?> get equalones => [Equalone(goods)];
}

///
/// Represents the current order in the shop, containing a list of items.
///
class ShopOrder with EqualoneMixin {
  final List<ShopOrderItem> items;

  const ShopOrder(this.items);

  ShopOrderItem? itemByName(String name) => items.skipWhile((item) => item.name != name).firstOrNull;

  ShopOrder updatedBy(ShopPrice price) {
    return ShopOrder(
      items.map((item) => switch(price.goods[item.name]) {
          int newPrice => item.copyWith(price: newPrice),
          _ => item
        }).toList(),
    );
  }

  ShopOrder updatedWith(ShopOrderItem item) {
    if (items.indexWhere( (i) => i.name == item.name) case int i when i >=0 ) {
      return ShopOrder(
        item.quantity==0 
        ? ([...items]..removeAt(i))
        : ([...items]..replaceRange(i, i+1, [item]))
      );
    }
    return ShopOrder([...items, item]);
  }
  
  @override
  List<Object?> get equalones => [Equalone(items)];
}

///
/// Represents a single item in the shop order.
///
class ShopOrderItem with EqualoneMixin {
  final String name;
  final int quantity;
  final int price;
  int get cost => quantity * price;

  const ShopOrderItem(this.name, this.quantity, this.price);

  ShopOrderItem copyWith({String? name, int? quantity, int? price}) => ShopOrderItem(
      name ?? this.name,
      quantity ?? this.quantity,
      price ?? this.price,
    );

  @override
  List<Object?> get equalones => [name, quantity, price];

  @override
  String toString() {
    return '$name: $quantity x $price';
  }
}
