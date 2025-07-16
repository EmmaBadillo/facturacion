import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final void Function(CartItem) onRemove;
  final Future<String?> Function(CartItem) onIncrease;
  final Future<String?> Function(CartItem) onDecrease;
  final VoidCallback onClearCart;
  final Future<void> Function() onReloadCart;
  final bool isLoading;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
    required this.onClearCart,
    required this.onReloadCart,
    this.isLoading = false,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isBuying = false;

  Future<void> _handleBuy() async {
    setState(() => _isBuying = true);
    try {
      final cartID = widget.cartItems.isNotEmpty ? widget.cartItems.first.cartId : null;
      if (cartID == null) throw 'No se encontró el ID del carrito.';

      final url = Uri.parse('https://api-sable-eta.vercel.app/api/carts/convert');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"cartID": cartID}),
      );

      final data = jsonDecode(response.body);
      if ( response.statusCode == 400 || data['error']) {
        final msg = data['error'] ?? 'Ocurrio un error, contacte con soporte';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (response.statusCode == 200 || data['resultado']) {
        final msg = data['resultado'] ?? 'Compra realizada correctamente.';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClearCart();
      } else {
        final errorMsg = data['error'] ?? 'Error desconocido al comprar.';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al comprar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de compras'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentGreen),
            tooltip: 'Recargar carrito',
            onPressed: widget.onReloadCart,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Vaciar carrito',
            onPressed: widget.onClearCart,
          ),
        ],
      ),
      backgroundColor: cardGray,
      body: widget.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: accentGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando carrito...',
                    style: TextStyle(color: primaryBlue, fontSize: 15),
                  ),
                ],
              ),
            )
          : widget.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 60, color: borderGray),
                      const SizedBox(height: 12),
                      Text(
                        'Tu carrito está vacío',
                        style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: widget.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return Card(
                      elevation: 3,
                      color: Colors.white,
                      shadowColor: borderGray.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: cardGray, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            // Imagen producto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: cardGray,
                                child: Image.network(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Icon(Icons.image, color: borderGray, size: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Info producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: accentGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Cantidad y acciones
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: primaryBlue, size: 20),
                                  onPressed: () async => await widget.onDecrease(item),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: accentGreen, size: 20),
                                  onPressed: () async => await widget.onIncrease(item),
                                ),
                              ],
                            ),
                            // Eliminar
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => widget.onRemove(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: widget.cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFB0BEC5), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total: \$${widget.cartItems.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isBuying ? null : _handleBuy,
                    icon: _isBuying
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.payment, size: 18),
                    label: Text(
                      _isBuying ? 'Procesando...' : 'Comprar',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
