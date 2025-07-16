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
  // Controladores para inputs de cantidad
  final Map<int, TextEditingController> _qtyControllers = {};

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmRemove(CartItem item) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Deseas eliminar "${item.product.name}" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) widget.onRemove(item);
  }

  Future<void> _confirmRemoveOnZero(CartItem item) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('La cantidad llegó a 0. ¿Deseas eliminar "${item.product.name}" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      widget.onRemove(item);
    } else {
      // Restaurar cantidad a 1 si cancela
      _qtyControllers[item.product.productId]?.text = '1';
      await widget.onIncrease(item);
      setState(() {});
    }
  }
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
      if (response.statusCode == 400 || (data['error'] != null || data['Error'] != null || data['ERROR'] != null)) {
        final errorMsg = data['error'] ?? data['Error'] ?? data['ERROR'] ?? 'Error desconocido al comprar.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (data['message'] != null) {
        final msg = data['message'] ?? 'Compra realizada correctamente.';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClearCart();
        return;
      }  else {
        // Handle cases where 'resultado' is not true and there's no 'error'
        const errorMsg = 'Error desconocido al comprar.';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
        return;
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
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color accent = Color(0xFF059669);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textSecondary = Color(0xFF475569);
    const Color textMuted = Color(0xFF64748b);
    const Color border = Color(0xFFe2e8f0);
    const Color borderFocus = Color(0xFF3b82f6);
    const Color error = Color(0xFFef4444);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de compras', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Recargar carrito',
            onPressed: widget.onReloadCart,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Vaciar carrito',
            onPressed: widget.onClearCart,
          ),
        ],
      ),
      backgroundColor: bgMuted,
      body: widget.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: accent),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando carrito...',
                    style: const TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : widget.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 60, color: border),
                      const SizedBox(height: 12),
                      Text(
                        'Tu carrito está vacío',
                        style: const TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: widget.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    // Controlador de cantidad
                    final qtyController = _qtyControllers.putIfAbsent(
                      item.product.productId,
                      () => TextEditingController(text: item.quantity.toString()),
                    );
                    return Container(
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: border.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Imagen producto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 54,
                                height: 54,
                                color: bgMuted,
                                child: Image.network(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Icon(Icons.image, color: border, size: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      fontSize: 14.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Cantidad y acciones
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: primary, size: 22),
                                  onPressed: () async {
                                    if (item.quantity == 1) {
                                      await _confirmRemoveOnZero(item);
                                    } else {
                                      await widget.onDecrease(item);
                                      qtyController.text = (item.quantity - 1).toString();
                                      setState(() {});
                                    }
                                  },
                                  splashRadius: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: accent, size: 22),
                                  onPressed: () async {
                                    final stock = item.product.stock ?? 999999;
                                    if (item.quantity < stock) {
                                      await widget.onIncrease(item);
                                      qtyController.text = (item.quantity + 1).toString();
                                      setState(() {});
                                    }
                                  },
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                            // Eliminar
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: error, size: 22),
                              onPressed: () => _confirmRemove(item),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: widget.cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: bgCard,
                border: Border(top: BorderSide(color: border, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: border.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total: \$${widget.cartItems.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isBuying ? null : _handleBuy,
                    icon: _isBuying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.payment, size: 18, color: Colors.white),
                    label: Text(
                      _isBuying ? 'Procesando...' : 'Comprar',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
