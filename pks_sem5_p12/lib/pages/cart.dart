import 'package:flutter/material.dart';
import '/main.dart';
import '/models/cart_item.dart';
import '/pages/item_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  const Cart({super.key});
  @override
  createState() => CartState();
}

class CartState extends State<Cart> {
  @override
  void initState() {
    super.initState();
    appData.cartState = this;
    
  }

  List<CartItem> cartItems = appData.cartItems;
  void forceUpdateState() {
    if (mounted) {
      setState(() {});
    }
  }
  int calcTotalAmount()
  {
    int total = 0;
    for (final cart_item in cartItems)
    {
      total += cart_item.item.PriceRubles * cart_item.Count;
    }
    return total;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Запись"),
        ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60, top: 15),
            child: cartItems.isEmpty
                ? Center(child: Text("Вы пока ничего не добавили в Корзину."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    itemCount: cartItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        key: Key(index.toString()),
                        endActionPane: ActionPane(
                            motion: StretchMotion(),
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Удалить запись'),
                                        content: Text(
                                            'Вы действительно хотите удалить "${cartItems[index].item.Name}"?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Отмена'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); 
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Удалить'),
                                            onPressed: () async {
                                              int id = appData.cartItems[index].ID;
                                              http.delete(Uri(scheme: "http", host: appData.serverHost, port: appData.serverPort, path: "/cart", queryParameters: {"service_id": cartItems[index].item.ID.toString()}));
                                              setState(() {
                                                cartItems.removeAt(
                                                    index); 
                                              });
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                backgroundColor: Theme.of(context).canvasColor,
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Удалить',
                              )
                            ]),
                        child: GestureDetector(
                          child: cart_item_preview(cartItem: cartItems[index]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ItemView(shopItem: cartItems[index].item)));
                          },
                        ),
                      );
                    },
                  ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(right: 40, left: 20, bottom: 5),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: (){}, child: Text("Оплатить", style: TextStyle(fontSize: 18, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),),
                  Row(
                    children: [
                      const Text("Итог: ", style: TextStyle(fontSize: 18)),
                      Text("${calcTotalAmount()} руб.", style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.lightBlueAccent),),
                    ],
                  ),
                ],
              ),
            ),
          )
        )
        ],
      ),
    );
  }
}

class cart_item_preview extends StatefulWidget {
  cart_item_preview({super.key, required this.cartItem});
  CartItem cartItem;
  @override
  State<cart_item_preview> createState() => cart_item_previewState();
}

class cart_item_previewState extends State<cart_item_preview> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(widget.cartItem.item.ImageHref,
                      width: MediaQuery.of(context).size.width * 0.45,
                      fit: BoxFit.cover)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${(widget.cartItem.item.PriceRubles * 1.5 / 100).round() * 100}",
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 18,
                                  decorationThickness: 2),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${widget.cartItem.item.PriceRubles.toString()} руб.",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightBlueAccent),
                            ),
                          ],
                        ),
                        Text(widget.cartItem.item.Name,
                            style: TextStyle(fontSize: 16)),
                        Text(
                            widget.cartItem.item.Category,
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (widget.cartItem.Count > 1) {
                              setState(() {
                                widget.cartItem.Count -= 1;
                              });
                              http.put(Uri(scheme: "http", host: appData.serverHost, port: appData.serverPort, path: "/cart", queryParameters: {"service_id": widget.cartItem.item.ID.toString(), "count": widget.cartItem.Count.toString()}));
                              appData.cartState!.forceUpdateState();
                            }
                          },
                          icon: Icon(Icons.remove),
                          iconSize: 30,
                        ),
                        Text(
                          "${widget.cartItem.Count}",
                          style: TextStyle(fontSize: 24),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              widget.cartItem.Count += 1;
                            });
                            http.put(Uri(scheme: "http", host: appData.serverHost, port: appData.serverPort, path: "/cart", queryParameters: {"service_id": widget.cartItem.item.ID.toString(), "count": widget.cartItem.Count.toString()}));
                            appData.cartState!.forceUpdateState();
                          },
                          icon: Icon(Icons.add),
                          iconSize: 30,
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
