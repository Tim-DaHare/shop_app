import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart' as provider;

class OrderItem extends StatefulWidget {
  final provider.OrderItem order;

  const OrderItem({
    Key key,
    @required this.order,
  }) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text("\$${widget.order.totalAmount}"),
            subtitle:
                Text(DateFormat("dd/MM/yyyy").format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            Container(
              // Maxheight logic
              height: min(
                widget.order.products.length * 20.0 + 10,
                100,
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: ListView.builder(
                itemCount: widget.order.productCount,
                itemBuilder: (ctx, i) {
                  final prod = widget.order.products[i];
                  return Container(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prod.product.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${prod.quantity}x \$${prod.totalPrice}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
