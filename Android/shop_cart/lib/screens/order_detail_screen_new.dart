import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/cart_service.dart';
import '../widgets/receipt_print_button.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      
      final orderId = _getOrderId();
      
      if (orderId.isNotEmpty && orderId != 'N/A') {
        final details = await CartService.getOrderDetails(int.parse(orderId));
        details.forEach((key, value) {
        });
        
        if (!mounted) return;
        
        setState(() {
          _orderDetails = details;
          _isLoading = false;
        });
      } else {
        // Si no hay orderId válido, usar los datos básicos de la orden
        
        if (!mounted) return;
        
        setState(() {
          _orderDetails = Map<String, dynamic>.from(widget.order);
          _isLoading = false;
        });
      }
    } catch (e) {
      
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        // En caso de error, usar los datos básicos que tenemos
        _orderDetails = Map<String, dynamic>.from(widget.order);
        _isLoading = false;
      });
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
      backgroundColor: bgMuted,
      appBar: AppBar(
        title: Text(
          'Detalle de Orden #${_getOrderId()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: accent),
            )
          : _buildContent(primary, accent, bgCard, border, textPrimary, textSecondary, textMuted),
    );
  }

  Widget _buildContent(Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textSecondary, Color textMuted) {
    final orderId = _getOrderId();
    final orderDate = _formatFullDate(_getOrderDate());
    final orderStatus = _getOrderStatus();
    final orderTotal = _formatPrice(_getOrderTotal());
    final productCount = _getProductCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.98), accent.withOpacity(0.93)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden #$orderId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orderDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          orderStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Info en dos columnas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border.withOpacity(0.55)),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha', style: TextStyle(color: textMuted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(orderDate, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 14),
                      Text('Estado', style: TextStyle(color: textMuted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(orderStatus, style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: border.withOpacity(0.5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(color: textMuted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('\$$orderTotal', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 14),
                      Text('Productos', style: TextStyle(color: textMuted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('$productCount', style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Lista de productos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border.withOpacity(0.55)),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos Ordenados',
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ..._getOrderItems().map((product) => _buildProductItemModern(product, primary, accent, border, textPrimary, textMuted)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Resumen de totales
          _buildOrderSummaryCardModern(primary, accent, bgCard, border, textPrimary, textMuted),

          // Botón de recibo
          const SizedBox(height: 28),
          Center(
            child: ReceiptPrintButton(
              orderData: _orderDetails ?? widget.order,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemModern(dynamic product, Color primary, Color accent, Color border, Color textPrimary, Color textMuted) {
    final name = product['Name'] ?? product['name'] ?? product['productName'] ?? 'Producto';
    final quantity = product['Quantity'] ?? product['quantity'] ?? 1;
    final price = product['Price'] ?? product['price'] ?? product['unitPrice'] ?? 0;
    final total = product['Total'] ?? product['total'] ?? (quantity * price);
    final imageUrl = product['ImageUrl'] ?? product['imageUrl'] ?? product['image'] ?? product['Image'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primary.withOpacity(0.13),
              ),
            ),
            child: imageUrl != null && imageUrl.toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl.toString(),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inventory_2,
                          color: primary,
                          size: 26,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: primary,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantidad: $quantity',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
                if (price > 0) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Unitario: \$${_formatPrice(price)}',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Text(
              '\$${_formatPrice(total)}',
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCardModern(Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textMuted) {
    final subtotal = _getOrderSubtotal();
    final tax = _getOrderTax();
    final total = _getOrderTotal();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRowModern('Subtotal:', '\$${_formatPrice(subtotal)}', textPrimary, textMuted),
          const SizedBox(height: 8),
          _buildSummaryRowModern('Impuestos:', '\$${_formatPrice(tax)}', textPrimary, textMuted),
          const Divider(height: 20),
          _buildSummaryRowModern(
            'Total:',
            '\$${_formatPrice(total)}',
            accent,
            textMuted,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowModern(String label, String value, Color textColor, Color textMuted, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? textColor : textMuted,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? textColor : textMuted,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }

  // Helper methods para extraer datos de la orden
  String _getOrderId() {
    // Primero intentar con _orderDetails, luego con widget.order
    final sources = [_orderDetails, widget.order];
    
    final idFields = [
      'OrderId', 'orderId', 'id', 'orderNumber', 'numero', 
      'Id', 'order_id', 'ORDER_ID', 'orderIdField'
    ];
    
    
    for (int i = 0; i < sources.length; i++) {
      final data = sources[i];
      if (data == null) continue;
      
      
      for (String field in idFields) {
        final value = data[field];
        if (value != null && value.toString().trim().isNotEmpty) {
          final result = value.toString().trim();
          return result;
        }
      }
    }
    
    return 'N/A';
  }

  String _getOrderDate() {
    // Primero intentar con _orderDetails, luego con widget.order
    final sources = [_orderDetails, widget.order];
    
    // Buscar en múltiples campos posibles con logging
    final dateFields = [
      'OrderDate', 'orderDate', 'createdAt', 'CreatedAt', 
      'date', 'Date', 'created_at', 'order_date',
      'CREATED_AT', 'ORDER_DATE', 'timestamp', 'Timestamp'
    ];
    
    
    for (int i = 0; i < sources.length; i++) {
      final data = sources[i];
      if (data == null) continue;
      
      for (String field in dateFields) {
        final value = data[field];
        if (value != null && value.toString().trim().isNotEmpty) {
          final result = value.toString().trim();
          return result;
        }
      }
    }
    
    
    // Si no encontramos fecha en ningún lado, devolver string vacío para que _formatDate maneje el caso
    return '';
  }

  String _getOrderStatus() {
    final data = _orderDetails ?? widget.order;
    return data['Status'] ?? data['status'] ?? 'Completada';
  }

  dynamic _getOrderTotal() {
    final data = _orderDetails ?? widget.order;
    
    // Buscar total con logging
    final totalFields = [
      'Total', 'total', 'totalAmount', 'amount', 
      'total_amount', 'TOTAL', 'grandTotal'
    ];
    
    for (String field in totalFields) {
      final value = data[field];
      if (value != null) {
        return value;
      }
    }
    
    return 0;
  }

  dynamic _getOrderSubtotal() {
    final data = _orderDetails ?? widget.order;
    
    // Buscar subtotal específico, si no existe calcular desde items
    final subtotalFields = [
      'Subtotal', 'subtotal', 'subTotal', 'sub_total', 'SUBTOTAL'
    ];
    
    for (String field in subtotalFields) {
      final value = data[field];
      if (value != null) {
        return value;
      }
    }
    
    // Si no hay subtotal específico, calcular desde los items
    final items = _getOrderItems();
    if (items.isNotEmpty) {
      double calculatedSubtotal = 0.0;
      for (var item in items) {
        final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
        final price = item['Price'] ?? item['price'] ?? item['unitPrice'] ?? 0;
        calculatedSubtotal += (quantity * price);
      }
      return calculatedSubtotal;
    }
    
    // Último recurso: usar el total como subtotal
    final total = _getOrderTotal();
    return total;
  }

  dynamic _getOrderTax() {
    final data = _orderDetails ?? widget.order;
    return data['Tax'] ?? data['tax'] ?? 0;
  }

  List<dynamic> _getOrderItems() {
    final data = _orderDetails ?? widget.order;
    
    // Buscar items en múltiples campos posibles
    final itemFields = [
      'Items', 'items', 'products', 'Products', 
      'orderItems', 'OrderItems', 'lineItems'
    ];
    
    for (String field in itemFields) {
      final value = data[field];
      if (value is List && value.isNotEmpty) {
        return value;
      }
    }
    
    return [];
  }

  int _getProductCount() {
    final items = _getOrderItems();
    return items.fold<int>(0, (sum, item) {
      final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
      return sum + (quantity as int);
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr.trim().isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      final date = DateTime.parse(dateStr);
      final formatted = DateFormat('dd/MM/yyyy').format(date);
      return formatted;
    } catch (e) {
      // Intentar otros formatos comunes
      try {
        // Formato ISO sin milisegundos
        final date = DateTime.parse(dateStr + (dateStr.contains('T') ? '' : 'T00:00:00'));
        final formatted = DateFormat('dd/MM/yyyy').format(date);
        return formatted;
      } catch (e2) {
        return 'Fecha no disponible';
      }
    }
  }

  String _formatFullDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr.trim().isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      final date = DateTime.parse(dateStr);
      final formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
      return formatted;
    } catch (e) {
      // Intentar otros formatos comunes
      try {
        // Formato ISO sin milisegundos
        final date = DateTime.parse(dateStr + (dateStr.contains('T') ? '' : 'T00:00:00'));
        final formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
        return formatted;
      } catch (e2) {
        return 'Fecha no disponible';
      }
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    try {
      final numPrice = price is num ? price : double.parse(price.toString());
      return numPrice.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }
}
