import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen_new.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  final Map<String, int> _productCounts = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await CartService.getOrderHistory();
      
      if (!mounted) return;
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      
      _loadProductCounts();
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductCounts() async {
    if (!mounted) return;
    
    
    // Procesar órdenes de forma más eficiente
    final futures = <Future<void>>[];
    
    for (var order in _orders) {
      if (!mounted) return;
      
      final orderId = _getOrderId(order);
      if (orderId.isNotEmpty && orderId != 'N/A') {
        futures.add(_loadSingleProductCount(orderId));
      }
    }
    
    // Esperar a que todas las cargas terminen o hasta que el widget se desmonte
    try {
      await Future.wait(futures);
      if (mounted) {
      }
    } catch (e) {
    }
  }
  
  Future<void> _loadSingleProductCount(String orderId) async {
    if (!mounted) return;
    
    try {
      
      final details = await CartService.getOrderDetails(int.parse(orderId));
      if (!mounted) return;
      
      final products = details['Items'] ??          // del getOrderDetails
                      details['items'] ?? 
                      details['products'] ?? 
                      details['Products'] ?? 
                      details['orderItems'] ??      // posible nombre
                      details['order_items'] ??     // snake_case
                      details['ORDER_ITEMS'] ??     // uppercase
                      [];
      
      int count = 0;
      if (products is List) {
        count = products.length;
      } else if (details['ProductCount'] != null) {
        // Si hay un campo específico para el conteo
        count = (details['ProductCount'] as num).toInt();
      }
      
      
      if (mounted) {
        setState(() {
          _productCounts[orderId] = count;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productCounts[orderId] = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Historial de Órdenes',
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.backgroundLight),
            onPressed: _loadOrderHistory,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : _error != null
              ? _buildErrorState()
              : _orders.isEmpty
              ? _buildEmptyState()
              : _buildOrdersList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Error al cargar el historial',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!.replaceAll('Exception: ', ''),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrderHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes órdenes aún',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus compras aparecerán aquí cuando realices tu primera orden',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Ir de Compras'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        if (order is Map<String, dynamic>) {
          order.forEach((key, value) {
            if (value is Map || value is List) {
            }
          });
        } else {
        }
        return _buildOrderCard(order, index);
      },
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    final orderId = _getOrderId(order);
    final date = _getOrderDate(order);
    final total = _getOrderTotal(order);
    final status = _getOrderStatus(order);
    final productCountText = _getProductCountText(orderId);

    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: borderGray.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToOrderDetail(order),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Ícono de orden
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long, color: accentGreen, size: 26),
                ),
                const SizedBox(width: 12),
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden #$orderId',
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 15, color: borderGray),
                          const SizedBox(width: 4),
                          Text(
                            productCountText,
                            style: TextStyle(
                              color: borderGray,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            status.toLowerCase().contains('complet')
                                ? Icons.check_circle
                                : Icons.timelapse,
                            size: 15,
                            color: accentGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: accentGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Total y botón detalles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 28,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToOrderDetail(order),
                        icon: Icon(Icons.visibility, color: primaryBlue, size: 16),
                        label: Text(
                          'Ver',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryBlue.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOrderDetail(dynamic order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
    );
  }

  // Helper methods para extraer datos de la orden
  String _getOrderId(dynamic order) {
    if (order is Map<String, dynamic>) {
      // Intentar diferentes campos que podrían contener el ID
      final id = order['OrderId'] ??          // del getOrderDetails
                 order['orderId'] ?? 
                 order['id'] ?? 
                 order['orderNumber'] ?? 
                 order['numero'] ?? 
                 order['Id'] ??
                 order['order_id'] ??         // snake_case
                 order['ORDER_ID'];           // uppercase
      final result = id?.toString() ?? 'N/A';
      return result;
    }
    return 'N/A';
  }

  // Método helper para obtener el total de la orden
  double _getOrderTotal(dynamic order) {
    if (order is Map<String, dynamic>) {
      final total = order['Total'] ??           // del getOrderDetails
                   order['total'] ?? 
                   order['totalAmount'] ?? 
                   order['amount'] ?? 
                   order['price'] ??
                   order['total_amount'] ??     // snake_case
                   order['TOTAL'] ??            // uppercase
                   0.0;
      
      double result = 0.0;
      if (total is String) {
        result = double.tryParse(total) ?? 0.0;
      } else {
        result = (total as num).toDouble();
      }
      return result;
    }
    return 0.0;
  }

  // Método helper para obtener la fecha de la orden
  String _getOrderDate(dynamic order) {
    if (order is Map<String, dynamic>) {
      final dateStr = order['OrderDate'] ??      // del getOrderDetails
                     order['createdAt'] ?? 
                     order['orderDate'] ?? 
                     order['date'] ?? 
                     order['Date'] ?? 
                     order['CreatedAt'] ?? 
                     order['fecha'] ??
                     order['created_at'] ??      // snake_case
                     order['order_date'] ??      // snake_case
                     order['CREATED_AT'] ??      // uppercase
                     order['ORDER_DATE'];        // uppercase
      
      
      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr.toString());
          final result = DateFormat('dd/MM/yyyy HH:mm').format(date);
          return result;
        } catch (e) {
          // Intentar otros formatos de fecha
          try {
            // Formato solo fecha sin hora
            final date = DateTime.parse(dateStr.toString() + 'T00:00:00');
            final result = DateFormat('dd/MM/yyyy').format(date);
            return result;
          } catch (e2) {
          }
        }
      }
    }
    return 'Fecha no disponible';
  }

  // Método helper para obtener el estado de la orden
  String _getOrderStatus(dynamic order) {
    if (order is Map<String, dynamic>) {
      final status = order['Status'] ??          // del getOrderDetails
                    order['status'] ?? 
                    order['estado'] ?? 
                    order['State'] ?? 
                    order['state'] ??
                    order['order_status'] ??     // snake_case
                    order['ORDER_STATUS'] ??     // uppercase
                    'Completada';                // default para órdenes existentes
      final result = status.toString();
      return result;
    }
    return 'Completada'; // Default para órdenes existentes
  }

  // Método helper para obtener el conteo de productos con fallback
  String _getProductCountText(String orderId) {
    if (_productCounts.containsKey(orderId)) {
      final count = _productCounts[orderId]!;
      return '$count producto${count != 1 ? 's' : ''}';
    } else {
      return 'Cargando...';
    }
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}
