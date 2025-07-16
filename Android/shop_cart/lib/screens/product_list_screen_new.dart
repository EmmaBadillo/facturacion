import 'package:flutter/material.dart';
import 'dart:async';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';
import '../widgets/search_filters.dart';
import '../widgets/pagination_widget.dart';
import './cart_screen.dart';
import 'order_history_screen_new.dart';
import 'profile_screen.dart';

class ProductListScreenNew extends StatefulWidget {
  final Future<void> Function(Product) onAddToCart;
  final VoidCallback onLogout;
  final List<CartItem> cartItems;
  final void Function(Product) onRemoveFromCart;
  final Future<String?> Function(Product) onIncreaseQuantity;
  final Future<String?> Function(Product) onDecreaseQuantity;
  final VoidCallback onClearCart;
  final Future<void> Function() onReloadCart;

  const ProductListScreenNew({
    super.key,
    required this.onAddToCart,
    required this.onLogout,
    required this.cartItems,
    required this.onRemoveFromCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onClearCart,
    required this.onReloadCart,
  });

  @override
  State<ProductListScreenNew> createState() => _ProductListScreenNewState();
}

class _ProductListScreenNewState extends State<ProductListScreenNew> {
  // Estado para loading por producto
  final Set<int> _loadingProductIds = {};
  // Estado
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = true;
  bool _productsLoading = false;
  String _searchTerm = "";
  String _selectedCategory = "";
  int _currentPage = 1;
  int _totalProducts = 0;

  final int _pageSize = 50;
  int get _totalPages => (_totalProducts / _pageSize).ceil();

  // Controllers para los filtros
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Método principal para cargar datos iniciales (similar a loadInitialData en React)
  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
    });

    await Future.wait([
      _fetchCategories(),
      _fetchProducts(1, _searchTerm, _selectedCategory),
    ]);

    setState(() {
      _loading = false;
    });
  }

  // Método para obtener productos (similar a fetchProducts en React)
  Future<void> _fetchProducts(int page, String filtro, String categoryId) async {
    setState(() {
      _productsLoading = true;
    });

    try {
      final result = await ProductService.fetchProducts(
        page: page,
        pageSize: _pageSize,
        filtro: filtro.isNotEmpty ? filtro : null,
        categoryId: categoryId.isNotEmpty ? categoryId : null,
      );

      setState(() {
        _products = result.products;
        _totalProducts = result.total;
        _currentPage = page;
        _productsLoading = false;
      });
    } catch (error) {
      setState(() {
        _products = [];
        _totalProducts = 0;
        _productsLoading = false;
      });
    }
  }

  // Método para obtener categorías (similar a fetchCategories en React)
  Future<void> _fetchCategories() async {
    try {
      final categories = await CategoryService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (error) {
    }
  }

  // Manejo de cambios en la búsqueda con debounce
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final newSearchTerm = _searchController.text.trim();
      if (newSearchTerm != _searchTerm) {
        setState(() {
          _searchTerm = newSearchTerm;
        });
        _fetchProducts(1, _searchTerm, _selectedCategory);
      }
    });
  }

  // Manejo de cambio de página (similar a handlePageChange en React)
  void _handlePageChange(int page) {
    _fetchProducts(page, _searchTerm, _selectedCategory);
  }

  // Manejo de cambio de categoría (similar a handleCategoryChange en React)
  void _handleCategoryChange(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId ?? '';
    });
    _fetchProducts(1, _searchTerm, _selectedCategory);
  }

  // Limpiar filtros
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchTerm = "";
      _selectedCategory = "";
    });
    _fetchProducts(1, "", "");
  }

  @override
  Widget build(BuildContext context) {
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color primaryHover = Color(0xFF1d4ed8);
    const Color secondary = Color(0xFF64748b);
    const Color accent = Color(0xFF059669);
    const Color accentHover = Color(0xFF047857);
    const Color bgMain = Color(0xFFf8fafc);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgInput = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textSecondary = Color(0xFF475569);
    const Color textMuted = Color(0xFF64748b);
    const Color textWhite = Color(0xFFFFFFFF);
    const Color border = Color(0xFFe2e8f0);
    const Color borderFocus = Color(0xFF3b82f6);
    const Color success = Color(0xFF10b981);
    const Color error = Color(0xFFef4444);
    const Color warning = Color(0xFFf59e0b);

    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Productos', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          backgroundColor: bgCard,
          foregroundColor: primary,
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: bgMain,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: 16),
              Text(
                'Cargando productos...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                  if (widget.cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: accent.withOpacity(0.18), blurRadius: 6, offset: Offset(0,2))],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${widget.cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Ver carrito (${widget.cartItems.length} items)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      cartItems: widget.cartItems,
                      onRemove: (cartItem) => widget.onRemoveFromCart(cartItem.product),
                      onIncrease: (cartItem) => widget.onIncreaseQuantity(cartItem.product),
                      onDecrease: (cartItem) => widget.onDecreaseQuantity(cartItem.product),
                      onClearCart: widget.onClearCart,
                      onReloadCart: widget.onReloadCart,
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white, size: 24),
            tooltip: 'Historial de compras',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 24),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(onLogout: widget.onLogout),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await UserService.logout();
              widget.onLogout();
            },
          ),
        ],
      ),
      backgroundColor: bgMain,
      body: Column(
        children: [
          // Filtros de búsqueda
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              border: Border(bottom: BorderSide(color: border, width: 1)),
              boxShadow: [BoxShadow(color: border.withOpacity(0.08), blurRadius: 8, offset: Offset(0,2))],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            child: SearchFilters(
              categories: _categories,
              onSearch: (term) {
                _searchController.text = term;
              },
              onCategoryChange: _handleCategoryChange,
              searchTerm: _searchTerm,
              selectedCategory: _selectedCategory,
              searchController: _searchController,
              onClearFilters: _clearFilters,
            ),
          ),
          // Información de productos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _productsLoading
                        ? "Buscando..."
                        : "$_totalProducts producto${_totalProducts != 1 ? "s" : ""} encontrado${_totalProducts != 1 ? "s" : ""}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Página $_currentPage de $_totalPages",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: _productsLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: accent,
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: border,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron productos',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_searchTerm.isNotEmpty || _selectedCategory.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Limpiar filtros'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: textWhite,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(14.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.90,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildProductGridCard(product, theme);
                        },
                      ),
          ),
          // Paginación
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 2),
              child: PaginationWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChange: _handlePageChange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, ThemeData theme) {
    const Color primaryBlue = Color(0xFF1A237E);
    const Color accentGreen = Color(0xFF43A047);
    const Color cardGray = Color(0xFFE3E6EA);
    const Color borderGray = Color(0xFFB0BEC5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 4,
        color: cardGray,
        shadowColor: borderGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderGray, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                  child: Image.network(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Icon(
                      Icons.image,
                      color: borderGray,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de agregar al carrito
              IconButton(
                icon: const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await widget.onAddToCart(product);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} agregado al carrito'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: accentGreen,
                      ),
                    );
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridCard(Product product, ThemeData theme) {
    // Paleta moderna
    const Color primary = Color(0xFF1e40af);
    const Color primaryHover = Color(0xFF1d4ed8);
    const Color accent = Color(0xFF059669);
    const Color accentHover = Color(0xFF047857);
    const Color bgCard = Color(0xFFFFFFFF);
    const Color bgMuted = Color(0xFFf1f5f9);
    const Color textPrimary = Color(0xFF0f172a);
    const Color textSecondary = Color(0xFF475569);
    const Color textMuted = Color(0xFF64748b);
    const Color border = Color(0xFFe2e8f0);

    final isLoading = _loadingProductIds.contains(product.productId);
    return Container(
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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 90,
                    color: bgMuted,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Icon(
                        Icons.image,
                        color: border,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 15.5,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accent,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _loadingProductIds.add(product.productId);
                                      });
                                      await widget.onAddToCart(product);
                                      if (mounted) {
                                        setState(() {
                                          _loadingProductIds.remove(product.productId);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${product.name} agregado al carrito'),
                                            duration: const Duration(seconds: 2),
                                            backgroundColor: accent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgMuted,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: primary, width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_shopping_cart, size: 16, color: primary),
                                        SizedBox(width: 5),
                                        const Text(
                                          'Agregar',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
