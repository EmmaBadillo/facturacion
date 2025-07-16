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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Detalle de Orden #${_getOrderId()}',
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor:  Color(0xFF1A237E),
        foregroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Paleta contable
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color lightGray = Color(0xFFF5F5F5);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    final orderId = _getOrderId();
    final orderDate = _formatFullDate(_getOrderDate());
    final orderStatus = _getOrderStatus();
    final orderTotal = _formatPrice(_getOrderTotal());
    final productCount = _getProductCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue.withOpacity(0.98),
                  accentGreen.withOpacity(0.93),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGray.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: lightGray,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden #$orderId',
                        style: TextStyle(
                          color: lightGray,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orderDate,
                        style: TextStyle(
                          color: lightGray.withOpacity(0.92),
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: lightGray.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          orderStatus,
                          style: TextStyle(
                            color: lightGray,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info en dos columnas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderGray.withOpacity(0.45)),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.04),
                  blurRadius: 4,
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
                      Text('Fecha', style: TextStyle(color: borderGray, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(orderDate, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 12),
                      Text('Estado', style: TextStyle(color: borderGray, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(orderStatus, style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
                Container(width: 1, height: 54, color: cardGray),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(color: borderGray, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('\$$orderTotal', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Productos', style: TextStyle(color: borderGray, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('$productCount', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista de productos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderGray.withOpacity(0.45)),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.04),
                  blurRadius: 4,
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
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._getOrderItems().map((product) => _buildProductItem(product)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Resumen de totales
          _buildOrderSummaryCard(),

          // Botón de recibo
          const SizedBox(height: 24),
          Center(
            child: ReceiptPrintButton(
              orderData: _orderDetails ?? widget.order,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(dynamic product) {
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);

    final name = product['Name'] ?? product['name'] ?? product['productName'] ?? 'Producto';
    final quantity = product['Quantity'] ?? product['quantity'] ?? 1;
    final price = product['Price'] ?? product['price'] ?? product['unitPrice'] ?? 0;
    final total = product['Total'] ?? product['total'] ?? (quantity * price);
    final imageUrl = product['ImageUrl'] ?? product['imageUrl'] ?? product['image'] ?? product['Image'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Imagen del producto
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryBlue.withOpacity(0.13),
              ),
            ),
            child: imageUrl != null && imageUrl.toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl.toString(),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inventory_2,
                          color: primaryBlue,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: primaryBlue,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantidad: $quantity',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12.5,
                  ),
                ),
                if (price > 0) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Unitario: \$${_formatPrice(price)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.11),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen.withOpacity(0.22)),
            ),
            child: Text(
              '\$${_formatPrice(total)}',
              style: TextStyle(
                color: accentGreen,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final subtotal = _getOrderSubtotal();
    final tax = _getOrderTax();
    final total = _getOrderTotal();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal:', '\$${_formatPrice(subtotal)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Impuestos:', '\$${_formatPrice(tax)}'),
          const Divider(height: 20),
          _buildSummaryRow(
            'Total:',
            '\$${_formatPrice(total)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.accentColor : AppColors.textPrimary,
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
