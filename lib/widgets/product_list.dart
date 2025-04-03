// TODO Implement this library.
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductList extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Leche', quantity: 2, expirationDate: DateTime(2025, 3, 20)),
    Product(name: 'Queso', quantity: 1, expirationDate: DateTime(2025, 2, 15)),
    Product(name: 'Huevos', quantity: 12, expirationDate: DateTime(2025, 3, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('Caduca: ${product.expirationDate.toLocal()}'),
            trailing: Text('Cantidad: ${product.quantity}'),
          ),
        );
      },
    );
  }
}
