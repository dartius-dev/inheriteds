import 'package:flutter/material.dart';
import 'package:dependents/dependents.dart';
import 'package:inheriteds/inheriteds.dart';

import 'shop_models.dart';

///
/// Main screen for the shop. Displays goods and cart side by side.
///
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});


  /// ProviderDependency links ShopOrder to ShopPrice.
  /// This means that when ShopPrice changes (for example, when item prices are updated),
  /// ShopOrder will automatically update to recalculate the cost of items in the cart.
  static final _shopOrderDependency = ProviderDependency<ShopOrder, ShopPrice>(
    dependency: (context) {
      return InheritedObject.of<ShopPrice>(context);
    },
    update: (object, price) {
      return object!.updatedBy(price!);
    },
  );

  @override
  Widget build(BuildContext context) {
    return InheritedProviders([
        InheritedProvider<ShopPrice>(
          initialObject: const ShopPrice({'Apple': 100, 'Banana': 50, 'Orange': 70})
        ),
        InheritedProvider<ShopOrder>(
          initialObject: const ShopOrder([]), 
          dependencies: [_shopOrderDependency]
        ),
      ],
      child: SizedBox.expand(
        child: Row(
          spacing: 10,
          children: [
            Expanded(child: const ShowCase()),
            Expanded(child: const ShopCart()),
          ],
        ),
      ),
    );
  }
}


///
/// Displays the list of goods available in the shop.
///
class ShowCase extends StatelessWidget {
  const ShowCase({super.key});

  @override
  Widget build(BuildContext context) {
    return DependentBuilder(
      // This dependency will rebuild the widget whenever the list of goods changes.
      // We are watching the item count and sort ordering by name.
      dependency: (context) => InheritedObject.of<ShopPrice>(context).goods.keys.toList(),
      builder: (context, _) {
        // no dependencies here, just a list of goods
        final shop = InheritedObject.get<ShopPrice>(context);
        return ListView(
          children: shop.goods.keys.map((name) => GoodCard(name: name)).toList(),
        );
      }
    );
  }
}

///
/// Displays the shopping cart with all items added by the user.
///
class ShopCart extends StatelessWidget {
  const ShopCart({super.key});

  @override
  Widget build(BuildContext context) {
    return DependentBuilder(
      // This dependency will rebuild the widget whenever the list of items changes.
      // We are watching the item count and sort ordering by name.
      dependency: (context) => InheritedObject.of<ShopOrder>(context).items.map((e) => e.name).toList(),
      builder: (context, _) {
        final order = InheritedObject.get<ShopOrder>(context);
        return ListView(
          children: [
            ...order.items.map((item) => OrderItemCard(name: item.name)),
            if (order.items.isNotEmpty) ShopOrderTotalCard()
          ],
        );
      }
    );
  }
}

///
/// Card widget for a single good in the shop.
///
class GoodCard extends StatelessWidget {
  final String name;
  const GoodCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Icon(Icons.add),
              onTap: () => InheritedProvider.update<ShopPrice>(context, (price) {
                return price.updatedWith(name, price.goods[name]! + 1);
              }),
            ),
            InkWell(
              child: Icon(Icons.remove),
              onTap: () => InheritedProvider.update<ShopPrice>(context, (price) {
                return price.updatedWith(name, (price.goods[name]! - 1).clamp(0, price.goods[name]!));
              }),
            ),
          ],
        ),
        trailing: Builder(
          builder: (context) {
            final inCart = InheritedObject.valueOf<bool, ShopOrder>(context, value: (o) => o.itemByName(name)!=null);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!inCart) InkWell(
                  child: Icon(Icons.add_shopping_cart_rounded),
                  onTap: () => InheritedProvider.update<ShopOrder>(context, (object) {
                    final price = InheritedObject.valueOf<int, ShopPrice>(context, value: (s) => s.goods[name] ?? 0);
                    return object.updatedWith(ShopOrderItem(name, 1, price));
                  }),
                ),
                if (inCart) InkWell(
                  child: Icon(Icons.delete_forever_outlined),
                  onTap: () => InheritedProvider.update<ShopOrder>(context, (object) {
                    return object.updatedWith(object.itemByName(name)!.copyWith(quantity: 0));
                  }),
                ),
              ],
            );
          }
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Builder(builder: (context) {
          final price = InheritedObject.valueOf<int,ShopPrice>(context, value: (s)=>s.goods[name] ?? 0);
          return Text("\$$price", style: Theme.of(context).textTheme.labelMedium);
        }
        ),
      ),
    );
  }
}

///
/// Card widget for a single item in the shopping cart.
///
class OrderItemCard extends StatelessWidget {
  final String name;
  const OrderItemCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: DependentBuilder(
        dependency: (context) {
          return InheritedObject.valueOf<ShopOrderItem?,ShopOrder>(context, 
            value: (o) => o.itemByName(name)
          );
        },
        builder: (context, _) {
          final item = DependentBuilder.dependencyOf<ShopOrderItem?>(context)!;
          final price = item.price;
          final quantity = item.quantity;
          final cost = item.cost;
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: const Icon(Icons.add),
                  onTap: () => InheritedProvider.update<ShopOrder>(context, (object) {
                    return object.updatedWith(item.copyWith(quantity: quantity + 1));
                  }),
                ),
                InkWell(
                  child: const Icon(Icons.remove),
                  onTap: () => InheritedProvider.update<ShopOrder>(context, (object) {
                    return object.updatedWith(item.copyWith(quantity: (quantity - 1).clamp(0, quantity)));
                  }),
                ),
              ],
            ),
            trailing: InkWell(
              child: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.primary),
              onTap: () => InheritedProvider.update<ShopOrder>(context, (object) {
                return object.updatedWith(item.copyWith(quantity: 0));
              }),
            ),
            title: Text('$name $quantity x $price', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('Cost: \$$cost', style: Theme.of(context).textTheme.labelMedium),
          );
        }
      ),
    );
  }
}

///
/// Card widget displaying the total cost and item count in the cart.
///
class ShopOrderTotalCard extends StatelessWidget {
  const ShopOrderTotalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Builder(
        builder: (context) {
          final (itemCount, totalCost) = InheritedObject.valueOf<(int,int),ShopOrder>(context, 
            value: (o) => (o.items.length, o.items.fold<int>(0, (sum, item) => sum + item.cost))
          );
          return ListTile(
            title: Text('$itemCount items', style: Theme.of(context).textTheme.titleMedium),
            trailing: Text('\$$totalCost', style: Theme.of(context).textTheme.titleLarge),
          );
        }
      ),
    );
  }
}