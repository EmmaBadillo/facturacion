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
        title: const Text(
          'Historial de Órdenes',
          style: TextStyle(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrderHistory,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: accent),
            )
          : _error != null
              ? _buildErrorState(primary, accent, bgCard, border, error, textPrimary, textSecondary)
              : _orders.isEmpty
                  ? _buildEmptyState(primary, accent, bgCard, textPrimary, textSecondary)
                  : _buildOrdersList(primary, accent, bgCard, border, textPrimary, textSecondary, textMuted),
    );
  }

  Widget _buildErrorState(Color primary, Color accent, Color bgCard, Color border, Color error, Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: error),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: error.withOpacity(0.18)),
              ),
              child: Column(
                children: [
                  Text(
                    'Error al cargar el historial',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!.replaceAll('Exception: ', ''),
                    style: TextStyle(
                      color: textSecondary,
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
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primary, Color accent, Color bgCard, Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes órdenes aún',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus compras aparecerán aquí cuando realices tu primera orden',
              style: TextStyle(color: textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text('Ir de Compras', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textSecondary, Color textMuted) {
    return ListView.builder(
      padding: const EdgeInsets.all(18.0),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order, index, primary, accent, bgCard, border, textPrimary, textSecondary, textMuted);
      },
    );
  }

  Widget _buildOrderCard(dynamic order, int index, Color primary, Color accent, Color bgCard, Color border, Color textPrimary, Color textSecondary, Color textMuted) {
    final orderId = _getOrderId(order);
    final date = _getOrderDate(order);
    final total = _getOrderTotal(order);
    final status = _getOrderStatus(order);
    final productCountText = _getProductCountText(orderId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToOrderDetail(order),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono de orden
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long, color: accent, size: 28),
                ),
                const SizedBox(width: 16),
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden #$orderId',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 16, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            productCountText,
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            status.toLowerCase().contains('complet')
                                ? Icons.check_circle
                                : Icons.timelapse,
                            size: 16,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToOrderDetail(order),
                        icon: Icon(Icons.visibility, color: primary, size: 17),
                        label: Text(
                          'Ver',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary.withOpacity(0.18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          elevation: 0,
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
